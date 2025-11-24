import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';

/// Pantalla de escaneo de códigos QR de facturas CFDI
///
/// Utiliza la cámara del dispositivo para escanear códigos QR
/// de facturas electrónicas del SAT (CFDI) y extrae:
/// - UUID (Folio fiscal)
/// - RFC del emisor
/// - RFC del receptor
/// - Monto total
///
/// Los datos escaneados se guardan en Firestore para el usuario actual.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  /// Controlador del escáner de códigos (API 7.x)
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  /// Indica si se está procesando un código escaneado
  bool _isProcessing = false;

  /// Indica si la linterna está encendida
  bool _isTorchOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Obtiene el RFC del usuario actual desde Firestore
  Future<String?> _getUserRfc() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      final data = userDoc.data();
      return data?['rfc']?.toString().toUpperCase();
    } catch (e) {
      return null;
    }
  }

  /// Determina el tipo de factura basándose en el RFC del usuario
  ///
  /// - Si rfcReceptor == RFC usuario → EGRESO (recibe factura, paga)
  /// - Si rfcEmisor == RFC usuario → INGRESO (emite factura, cobra)
  /// - Si ninguno coincide → null (preguntar al usuario)
  String? _determinarTipoFactura(
    Map<String, dynamic> cfdiData,
    String? userRfc,
  ) {
    if (userRfc == null || userRfc.isEmpty) return null;

    final rfcEmisor = cfdiData['rfcEmisor']?.toString().toUpperCase() ?? '';
    final rfcReceptor = cfdiData['rfcReceptor']?.toString().toUpperCase() ?? '';

    if (rfcReceptor == userRfc) {
      // El usuario es el receptor → recibe la factura → EGRESO (gasta)
      return 'Egreso';
    } else if (rfcEmisor == userRfc) {
      // El usuario es el emisor → emite la factura → INGRESO (cobra)
      return 'Ingreso';
    }

    // No se puede determinar automáticamente
    return null;
  }

  /// Procesa el código QR detectado
  ///
  /// Valida que sea un QR del SAT, extrae los datos,
  /// determina el tipo de factura y muestra un diálogo de confirmación.
  Future<void> _onDetect(BarcodeCapture capture) async {
    // Evitar procesar múltiples códigos simultáneamente
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Pausar el escáner mientras procesamos
      await _scannerController.stop();

      // Validar y parsear el QR
      final cfdiData = _parseCfdiQr(rawValue);

      if (cfdiData != null) {
        // Obtener RFC del usuario para determinar tipo
        final userRfc = await _getUserRfc();
        final tipoAutodetectado = _determinarTipoFactura(cfdiData, userRfc);

        // Mostrar diálogo de confirmación con el tipo
        final result = await _showConfirmationDialog(
          cfdiData,
          tipoAutodetectado: tipoAutodetectado,
          userRfc: userRfc,
        );

        if (result != null && result['shouldSave'] == true && mounted) {
          await _saveToFirestore(cfdiData, tipo: result['tipo']);
        }
      } else {
        // QR no válido del SAT
        if (mounted) {
          _showErrorSnackbar(
            'Este código QR no es de una factura CFDI del SAT',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error al procesar el código QR: $e');
      }
    } finally {
      // Reiniciar el escáner si seguimos en la pantalla
      if (mounted) {
        setState(() => _isProcessing = false);
        await _scannerController.start();
      }
    }
  }

  /// Parsea un código QR de factura CFDI del SAT
  ///
  /// El formato esperado es:
  /// https://verificacfdi.facturaelectronica.sat.gob.mx/default.aspx?id=UUID&re=RFC_EMISOR&rr=RFC_RECEPTOR&tt=TOTAL&fe=SELLO
  ///
  /// Retorna un Map con los datos extraídos o null si el QR no es válido.
  Map<String, dynamic>? _parseCfdiQr(String qrValue) {
    try {
      // Verificar que sea una URL del SAT
      if (!qrValue.toLowerCase().contains('verificacfdi') &&
          !qrValue.toLowerCase().contains('sat.gob.mx')) {
        return null;
      }

      // Parsear la URL
      final Uri? uri = Uri.tryParse(qrValue);
      if (uri == null) return null;

      // Extraer parámetros
      final String? uuid = uri.queryParameters['id'] ?? uri.queryParameters['Id'];
      final String? rfcEmisor = uri.queryParameters['re'] ?? uri.queryParameters['Re'];
      final String? rfcReceptor = uri.queryParameters['rr'] ?? uri.queryParameters['Rr'];
      final String? totalStr = uri.queryParameters['tt'] ?? uri.queryParameters['Tt'];

      // Validar que tengamos los datos mínimos
      if (uuid == null || uuid.isEmpty) return null;

      // Parsear el total (puede tener formato 0000001234.56 o 1234.56)
      double? total;
      if (totalStr != null && totalStr.isNotEmpty) {
        // Remover ceros iniciales si existen
        final cleanTotal = totalStr.replaceFirst(RegExp(r'^0+'), '');
        total = double.tryParse(cleanTotal.isEmpty ? '0' : cleanTotal);
      }

      return {
        'uuid': uuid.toUpperCase(),
        'rfcEmisor': rfcEmisor?.toUpperCase() ?? 'No disponible',
        'rfcReceptor': rfcReceptor?.toUpperCase() ?? 'No disponible',
        'total': total ?? 0.0,
        'rawUrl': qrValue,
      };
    } catch (e) {
      return null;
    }
  }

  /// Muestra un diálogo de confirmación con los datos extraídos
  ///
  /// Retorna un Map con 'shouldSave' (bool) y 'tipo' (String).
  /// Si el tipo no se puede autodetectar, muestra un selector.
  Future<Map<String, dynamic>?> _showConfirmationDialog(
    Map<String, dynamic> cfdiData, {
    String? tipoAutodetectado,
    String? userRfc,
  }) {
    // Si el tipo se autodetectó, usarlo; si no, default a 'Ingreso'
    String tipoSeleccionado = tipoAutodetectado ?? 'Ingreso';
    final bool necesitaSeleccionManual = tipoAutodetectado == null;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.successGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Factura Detectada',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDataRow(
                      'UUID',
                      cfdiData['uuid'],
                      Icons.fingerprint,
                    ),
                    const SizedBox(height: 12),
                    _buildDataRow(
                      'RFC Emisor',
                      cfdiData['rfcEmisor'],
                      Icons.business,
                    ),
                    const SizedBox(height: 12),
                    _buildDataRow(
                      'RFC Receptor',
                      cfdiData['rfcReceptor'],
                      Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildDataRow(
                      'Total',
                      '\$${cfdiData['total'].toStringAsFixed(2)}',
                      Icons.attach_money,
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 16),
                    // Selector de tipo de factura
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
                        border: necesitaSeleccionManual
                            ? Border.all(color: AppTheme.warningOrange.withOpacity(0.5))
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                necesitaSeleccionManual
                                    ? Icons.help_outline
                                    : Icons.auto_awesome,
                                color: necesitaSeleccionManual
                                    ? AppTheme.warningOrange
                                    : AppTheme.successGreen,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  necesitaSeleccionManual
                                      ? 'Selecciona el tipo de factura:'
                                      : 'Tipo detectado automáticamente:',
                                  style: TextStyle(
                                    color: necesitaSeleccionManual
                                        ? AppTheme.warningOrange
                                        : AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTipoButton(
                                  'Ingreso',
                                  Icons.arrow_downward,
                                  AppTheme.successGreen,
                                  tipoSeleccionado == 'Ingreso',
                                  () {
                                    setDialogState(() {
                                      tipoSeleccionado = 'Ingreso';
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTipoButton(
                                  'Egreso',
                                  Icons.arrow_upward,
                                  AppTheme.errorRed,
                                  tipoSeleccionado == 'Egreso',
                                  () {
                                    setDialogState(() {
                                      tipoSeleccionado = 'Egreso';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(dialogContext).pop({
                    'shouldSave': true,
                    'tipo': tipoSeleccionado,
                  }),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Construye un botón de selección de tipo (Ingreso/Egreso)
  Widget _buildTipoButton(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppTheme.textDisabled,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una fila de datos para el diálogo
  Widget _buildDataRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.successGreen.withOpacity(0.1)
            : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
        border: isHighlighted
            ? Border.all(color: AppTheme.successGreen.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isHighlighted ? AppTheme.successGreen : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isHighlighted
                        ? AppTheme.successGreen
                        : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Guarda la factura escaneada en Firestore
  ///
  /// Crea un documento en la colección 'facturas' con los datos
  /// extraídos del QR y el userId del usuario actual.
  ///
  /// [tipo] - Tipo de factura: 'Ingreso' o 'Egreso'
  Future<void> _saveToFirestore(
    Map<String, dynamic> cfdiData, {
    required String tipo,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackbar('Debes iniciar sesión para guardar facturas');
        return;
      }

      // Verificar si ya existe una factura con este UUID
      final existingQuery = await FirebaseFirestore.instance
          .collection('facturas')
          .where('userId', isEqualTo: user.uid)
          .where('uuid', isEqualTo: cfdiData['uuid'])
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        if (mounted) {
          _showWarningSnackbar('Esta factura ya fue escaneada anteriormente');
        }
        return;
      }

      // Guardar la nueva factura con el tipo correcto
      await FirebaseFirestore.instance.collection('facturas').add({
        'uuid': cfdiData['uuid'],
        'rfcEmisor': cfdiData['rfcEmisor'],
        'rfcReceptor': cfdiData['rfcReceptor'],
        'total': cfdiData['total'],
        'fechaEscaneo': FieldValue.serverTimestamp(),
        'userId': user.uid,
        // Campos adicionales para compatibilidad con CfdiModel
        'folio': cfdiData['uuid'].substring(0, 8),
        'emisor': cfdiData['rfcEmisor'],
        'monto': cfdiData['total'],
        'fecha': FieldValue.serverTimestamp(),
        'tipo': tipo, // Tipo determinado automáticamente o seleccionado
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        final tipoTexto = tipo == 'Ingreso' ? 'ingreso' : 'egreso';
        _showSuccessSnackbar('Factura de $tipoTexto guardada correctamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error al guardar: $e');
      }
    }
  }

  /// Muestra un snackbar de error
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Muestra un snackbar de advertencia
  void _showWarningSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: AppTheme.warningOrange),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra un snackbar de éxito
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.successGreen),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Alterna el estado de la linterna (API 7.x)
  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
      if (mounted) {
        setState(() => _isTorchOn = !_isTorchOn);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('No se pudo controlar la linterna');
      }
    }
  }

  /// Cambia entre cámara frontal y trasera (API 7.x)
  Future<void> _switchCamera() async {
    try {
      await _scannerController.switchCamera();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('No se pudo cambiar la cámara');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Factura'),
        actions: [
          // Botón de linterna
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? AppTheme.warningOrange : AppTheme.textPrimary,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Linterna',
          ),
          // Botón para cambiar cámara
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
            tooltip: 'Cambiar cámara',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Escáner de cámara
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return _buildErrorWidget(error);
            },
          ),

          // Overlay con marco de escaneo
          _buildScanOverlay(),

          // Indicador de procesamiento
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryMagenta,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Procesando...',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Instrucciones en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInstructions(),
          ),
        ],
      ),
    );
  }

  /// Construye el overlay con el marco de escaneo
  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.75;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 40;

        return Stack(
          children: [
            // Fondo oscuro con hueco transparente
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Marco de escaneo con esquinas
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryMagenta,
                    width: 3,
                  ),
                ),
              ),
            ),

            // Esquinas decorativas
            ..._buildCorners(left, top, scanAreaSize),
          ],
        );
      },
    );
  }

  /// Construye las esquinas decorativas del marco
  List<Widget> _buildCorners(double left, double top, double size) {
    const cornerSize = 30.0;
    const cornerWidth = 4.0;

    return [
      // Esquina superior izquierda
      Positioned(
        left: left - 2,
        top: top - 2,
        child: _buildCorner(cornerSize, cornerWidth, true, true),
      ),
      // Esquina superior derecha
      Positioned(
        right: left - 2,
        top: top - 2,
        child: _buildCorner(cornerSize, cornerWidth, true, false),
      ),
      // Esquina inferior izquierda
      Positioned(
        left: left - 2,
        bottom: MediaQuery.of(context).size.height - top - size - 2,
        child: _buildCorner(cornerSize, cornerWidth, false, true),
      ),
      // Esquina inferior derecha
      Positioned(
        right: left - 2,
        bottom: MediaQuery.of(context).size.height - top - size - 2,
        child: _buildCorner(cornerSize, cornerWidth, false, false),
      ),
    ];
  }

  /// Construye una esquina decorativa
  Widget _buildCorner(
    double size,
    double width,
    bool isTop,
    bool isLeft,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: AppTheme.primaryMagenta,
          strokeWidth: width,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }

  /// Construye el widget de instrucciones
  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.backgroundPrimary.withOpacity(0.9),
            AppTheme.backgroundPrimary,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            color: AppTheme.primaryMagenta,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Apunta la cámara al código QR',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'El código QR se encuentra en tu factura CFDI\nen la esquina inferior derecha',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Chip informativo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.infoBlue.withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.infoBlue,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Solo facturas oficiales del SAT',
                  style: TextStyle(
                    color: AppTheme.infoBlue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el widget de error de cámara
  Widget _buildErrorWidget(MobileScannerException error) {
    String errorMessage;
    IconData errorIcon;

    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permiso de cámara denegado.\n'
            'Ve a Configuración > Fiscalito > Cámara\n'
            'y activa el permiso.';
        errorIcon = Icons.no_photography;
        break;
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Este dispositivo no soporta\nescaneo de códigos QR.';
        errorIcon = Icons.phonelink_erase;
        break;
      default:
        errorMessage = 'Error al iniciar la cámara.\n'
            'Intenta reiniciar la aplicación.';
        errorIcon = Icons.error_outline;
    }

    return Container(
      color: AppTheme.backgroundPrimary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                errorIcon,
                size: 80,
                color: AppTheme.errorRed.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter personalizado para dibujar esquinas decorativas
class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isTop;
  final bool isLeft;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
