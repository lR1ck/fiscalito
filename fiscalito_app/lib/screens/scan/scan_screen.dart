import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de escaneo OCR
///
/// Permite al usuario escanear tickets y facturas físicas
/// usando la cámara del dispositivo. Por ahora es UI mock.
///
/// En producción se integraría con:
/// - camera package para capturar imágenes
/// - google_mlkit_text_recognition o tesseract_ocr para OCR
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  /// Estado de la cámara (simulado)
  bool _isCameraActive = false;

  /// Estado de procesamiento
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isCameraActive ? _buildCameraView() : _buildInstructions(),
    );
  }

  /// Construye las instrucciones iniciales
  Widget _buildInstructions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono principal
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: AppTheme.successGreen,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Escanea tu ticket o factura',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'Usa la cámara de tu dispositivo para escanear tickets físicos y extraer la información automáticamente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Card con instrucciones
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warningOrange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Consejos para un buen escaneo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTip(
                  '1. Usa buena iluminación',
                  'Asegúrate de tener suficiente luz para que el texto sea legible',
                ),
                const SizedBox(height: 12),
                _buildTip(
                  '2. Mantén el ticket plano',
                  'Alisa el ticket para evitar sombras y distorsiones',
                ),
                const SizedBox(height: 12),
                _buildTip(
                  '3. Enfoca el texto claramente',
                  'El texto debe estar nítido y completo en el encuadre',
                ),
                const SizedBox(height: 12),
                _buildTip(
                  '4. Evita reflejos',
                  'Si el ticket es brillante, ajusta el ángulo para evitar reflejos',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Card con información deducible
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
              border: Border.all(
                color: AppTheme.infoBlue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.infoBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '¿Qué puedo escanear?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.infoBlue,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Tickets de compra\n'
                  '• Facturas físicas\n'
                  '• Notas de venta\n'
                  '• Comprobantes de pago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botón principal
          ElevatedButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Abrir cámara'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 12),

          // Botón secundario
          OutlinedButton.icon(
            onPressed: () {
              // Navegar a subir desde galería (ya existe esta pantalla)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usa la opción "Desde galería" en Subir CFDI'),
                ),
              );
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Elegir de galería'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la vista de la cámara (placeholder)
  Widget _buildCameraView() {
    return Stack(
      children: [
        // Placeholder de cámara
        Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 100,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Vista de cámara',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '(Placeholder)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Overlay con guías
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.successGreen,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Esquinas
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.successGreen, width: 6),
                        left:
                            BorderSide(color: AppTheme.successGreen, width: 6),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.successGreen, width: 6),
                        right:
                            BorderSide(color: AppTheme.successGreen, width: 6),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: AppTheme.successGreen, width: 6),
                        left:
                            BorderSide(color: AppTheme.successGreen, width: 6),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: AppTheme.successGreen, width: 6),
                        right:
                            BorderSide(color: AppTheme.successGreen, width: 6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instrucciones overlay
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Centra el ticket dentro del marco\ny asegúrate de que el texto sea legible',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Controles
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (_isProcessing)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Procesando imagen...'),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón cancelar
                  FloatingActionButton(
                    heroTag: 'cancel',
                    onPressed: () {
                      setState(() {
                        _isCameraActive = false;
                        _isProcessing = false;
                      });
                    },
                    backgroundColor: AppTheme.errorRed,
                    child: const Icon(Icons.close),
                  ),

                  // Botón capturar
                  FloatingActionButton.large(
                    heroTag: 'capture',
                    onPressed: _isProcessing ? null : _captureImage,
                    backgroundColor: AppTheme.successGreen,
                    child: const Icon(Icons.camera, size: 36),
                  ),

                  // Botón flash (placeholder)
                  FloatingActionButton(
                    heroTag: 'flash',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Control de flash próximamente'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    backgroundColor: AppTheme.surfaceElevated,
                    child: const Icon(Icons.flash_off),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye un tip
  Widget _buildTip(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          color: AppTheme.successGreen,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Abre la cámara
  void _openCamera() {
    setState(() {
      _isCameraActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cámara activada (modo demo)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Captura una imagen
  void _captureImage() async {
    setState(() {
      _isProcessing = true;
    });

    // Simular procesamiento OCR
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _isCameraActive = false;
    });

    // Mostrar resultado
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función OCR disponible próximamente'),
        backgroundColor: AppTheme.infoBlue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Muestra el diálogo de ayuda
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda de escaneo'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Cómo funciona el OCR?'),
              SizedBox(height: 8),
              Text(
                'OCR (Optical Character Recognition) es tecnología que extrae texto de imágenes.\n\n'
                'Fiscalito puede leer:\n'
                '• RFC del emisor\n'
                '• Monto total\n'
                '• Fecha de la transacción\n'
                '• Concepto de compra',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              SizedBox(height: 16),
              Text('Nota:'),
              SizedBox(height: 4),
              Text(
                'Para mayor precisión, te recomendamos solicitar el CFDI (factura electrónica en XML) directamente al emisor.',
                style: TextStyle(
                  color: AppTheme.warningOrange,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
