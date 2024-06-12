import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfApi {
  static Future<File> generatePdf({
    required AssessmentModel assessmentModel,
    required Uint8List signatureImage,
  }) async {
    final document = PdfDocument();

    // add a page to the document
    final page = document.pages.add();

    // add a signature image to the page
    addSignatureImage(assessmentModel, page, signatureImage);

    return saveFile(document);
  }

  static void addSignatureImage(
    AssessmentModel assessmentModel,
    PdfPage page,
    Uint8List signatureImage,
  ) {
    // get page size
    final pageSize = page.getClientSize();
    // add a signature image to the page
    final image = PdfBitmap(signatureImage);
    // draw the image on the page and locate it at the bottom right corner
    page.graphics.drawImage(
      image,
      Rect.fromLTWH(
        pageSize.width - 120,
        pageSize.height - 200,
        100,
        40,
      ),
    );
  }

  // save the file to the device
  static Future<File> saveFile(PdfDocument document) async {
    // get the path to the document directory
    final path = await getApplicationDocumentsDirectory();
    // get the file name
    final fileName =
        '${path.path}/RiskAssessment${DateTime.now().toIso8601String()}.pdf';
    // save the document to the device
    final file = File(fileName);
    // write the document to the file
    file.writeAsBytes(await document.save());
    // dispose the document
    document.dispose();
    // return the file
    return file;
  }
}
