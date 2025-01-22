import 'package:universal_html/html.dart' as html; // Para descargar en web

class Pdfweb {

  void download(dynamic pdf, String fileName){
    final blob = html.Blob([pdf]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = fileName
        ..click();
      html.Url.revokeObjectUrl(url); // Limpieza de memoria
      print("Archivo descargado en la web.");
  }

}