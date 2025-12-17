// Web-specific PDF download implementation
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadPDF(Uint8List pdfBytes, String fileName) async {
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Create download link and trigger click
  final anchor = html.AnchorElement()
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  
  html.document.body!.children.add(anchor);
  anchor.click();
  
  // Cleanup
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
