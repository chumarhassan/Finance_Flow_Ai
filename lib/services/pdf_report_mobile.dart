// Mobile-specific PDF download implementation
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadPDF(Uint8List pdfBytes, String fileName) async {
  // Get downloads directory
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  
  // Save file
  final file = File(filePath);
  await file.writeAsBytes(pdfBytes);
  
  // Open the file
  await OpenFile.open(filePath);
}
