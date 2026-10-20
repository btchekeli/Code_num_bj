import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static const String assetPdfPath =
      'assets/CODE DU NUMERIQUE VERSION ACTUALISEE.pdf';
  static const String pdfFileName =
      'Code_du_numerique_Benin_Version_Actualisee.pdf';

  /// Affiche une feuille modale présentant le document avant téléchargement
  static Future<void> showDownloadModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _buildDownloadBottomSheet(ctx),
    );
  }

  static Widget _buildDownloadBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Code du numérique',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Version actualisée • Document PDF officiel',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Téléchargez ou enregistrez la version intégrale et actualisée du Code du numérique en République du Bénin (3,4 Mo).',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: const Text(
                'Télécharger le PDF',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
                downloadAndSharePdf(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Prépare le PDF et déclenche le téléchargement / sauvegarde
  static Future<void> downloadAndSharePdf(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Préparation du document PDF...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final ByteData data = await rootBundle.load(assetPdfPath);
      final Uint8List bytes = data.buffer.asUint8List();

      Directory? targetDir;
      if (Platform.isAndroid) {
        targetDir = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      } else {
        targetDir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      final File targetFile = File('${targetDir.path}/$pdfFileName');
      await targetFile.writeAsBytes(bytes, flush: true);

      scaffoldMessenger.hideCurrentSnackBar();

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('PDF enregistré dans : ${targetFile.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Déclenche la boîte de dialogue native de partage / enregistrement
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              targetFile.path,
              mimeType: 'application/pdf',
              name: pdfFileName,
            ),
          ],
          text: 'Code du numérique en République du Bénin - Version actualisée',
          subject: 'Code du numérique Bénin (Version actualisée)',
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors du téléchargement du PDF: $e');
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la préparation du PDF : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
