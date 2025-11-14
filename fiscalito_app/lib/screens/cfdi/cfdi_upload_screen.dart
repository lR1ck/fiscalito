import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla para subir/escanear facturas (CFDI)
///
/// Permite al usuario:
/// - Subir archivos XML de CFDI
/// - Escanear facturas físicas con OCR
/// - Ver preview de la información extraída
///
/// Por ahora es solo UI mock. En producción se integraría
/// con file_picker, camera, y Tesseract/Google ML Kit para OCR.
class CfdiUploadScreen extends StatefulWidget {
  const CfdiUploadScreen({super.key});

  @override
  State<CfdiUploadScreen> createState() => _CfdiUploadScreenState();
}

class _CfdiUploadScreenState extends State<CfdiUploadScreen> {
  /// Datos extraídos del CFDI (mock)
  Map<String, String>? _extractedData;

  /// Estado de carga
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Factura'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _extractedData == null
          ? _buildUploadOptions()
          : _buildPreview(),
    );
  }

  /// Construye las opciones de subida
  Widget _buildUploadOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Icon(
            Icons.cloud_upload_outlined,
            size: 80,
            color: AppTheme.primaryMagenta,
          ),
          const SizedBox(height: 16),
          Text(
            'Sube tu factura',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Elige cómo quieres agregar tu CFDI',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Opción 1: Subir XML
          _buildUploadOption(
            icon: Icons.insert_drive_file_outlined,
            title: 'Subir archivo XML',
            description: 'Selecciona el archivo XML de tu factura',
            color: AppTheme.infoBlue,
            onTap: _handleUploadXml,
          ),

          const SizedBox(height: 16),

          // Opción 2: Escanear con cámara
          _buildUploadOption(
            icon: Icons.camera_alt_outlined,
            title: 'Escanear con cámara',
            description: 'Toma una foto de tu factura física',
            color: AppTheme.successGreen,
            onTap: _handleScanCamera,
          ),

          const SizedBox(height: 16),

          // Opción 3: Seleccionar de galería
          _buildUploadOption(
            icon: Icons.photo_library_outlined,
            title: 'Desde galería',
            description: 'Elige una foto de tu factura',
            color: AppTheme.warningOrange,
            onTap: _handlePickFromGallery,
          ),

          const SizedBox(height: 32),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
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
                      '¿Qué es un CFDI?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.infoBlue,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'El CFDI (Comprobante Fiscal Digital por Internet) es una factura electrónica '
                  'en formato XML que contiene toda la información de una transacción.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una opción de subida
  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
      child: InkWell(
        onTap: _isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el preview de la factura
  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono de éxito
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 60,
              color: AppTheme.successGreen,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Factura procesada',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Revisa la información extraída',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Card con datos extraídos
          Container(
            decoration: AppTheme.cardDecoration(),
            padding: const EdgeInsets.all(AppTheme.kPaddingCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos del CFDI',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Campos extraídos
                ..._extractedData!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          ElevatedButton(
            onPressed: _handleSaveCfdi,
            child: const Text('Guardar factura'),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () {
              setState(() {
                _extractedData = null;
              });
            },
            child: const Text('Subir otra factura'),
          ),
        ],
      ),
    );
  }

  /// Maneja la subida de archivo XML
  void _handleUploadXml() async {
    setState(() => _isProcessing = true);

    // TODO: Implementar file_picker
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['xml'],
    // );

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _extractedData = {
        'Folio Fiscal (UUID)': '12345678-ABCD-1234-ABCD-123456789012',
        'Emisor': 'Tienda Ejemplo SA de CV',
        'RFC Emisor': 'TEM123456789',
        'Receptor': 'Juan Pérez García',
        'RFC Receptor': 'XAXX010101000',
        'Fecha': '15 de diciembre, 2025',
        'Total': '\$1,250.00 MXN',
        'Tipo': 'Ingreso',
      };
    });
  }

  /// Maneja el escaneo con cámara
  void _handleScanCamera() async {
    setState(() => _isProcessing = true);

    // TODO: Implementar camera + OCR
    // final image = await ImagePicker().pickImage(source: ImageSource.camera);
    // final text = await TesseractOcr.extractText(image.path);

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _extractedData = {
        'Folio Fiscal (UUID)': '98765432-DCBA-4321-DCBA-987654321098',
        'Emisor': 'Restaurante El Sabor',
        'RFC Emisor': 'RES987654321',
        'Receptor': 'Juan Pérez García',
        'RFC Receptor': 'XAXX010101000',
        'Fecha': '14 de diciembre, 2025',
        'Total': '\$450.00 MXN',
        'Tipo': 'Egreso',
      };
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Factura escaneada con OCR (simulado)'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  /// Maneja la selección desde galería
  void _handlePickFromGallery() async {
    setState(() => _isProcessing = true);

    // TODO: Implementar image_picker + OCR
    // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // final text = await TesseractOcr.extractText(image.path);

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _extractedData = {
        'Folio Fiscal (UUID)': 'ABCD1234-5678-9012-3456-7890ABCDEF12',
        'Emisor': 'Gasolinera La Estrella',
        'RFC Emisor': 'GES456789012',
        'Receptor': 'Juan Pérez García',
        'RFC Receptor': 'XAXX010101000',
        'Fecha': '13 de diciembre, 2025',
        'Total': '\$850.00 MXN',
        'Tipo': 'Egreso',
      };
    });
  }

  /// Guarda el CFDI
  void _handleSaveCfdi() {
    // TODO: Guardar en Firestore
    // await FirestoreService.saveCfdi(_extractedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Factura guardada correctamente'),
        backgroundColor: AppTheme.successGreen,
      ),
    );

    // Volver a la lista de facturas
    Navigator.pop(context);
  }
}
