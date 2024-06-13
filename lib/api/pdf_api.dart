import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:intl/intl.dart';
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

    // Load the logo from assets
    final PdfBitmap logo = await loadLogo(AssetsManager.userIcon);

    // draw table
    drawGrid(
      assessmentModel,
      page,
      logo,
    );

    // add a signature image to the page
    addSignatureImage(
      assessmentModel,
      page,
      signatureImage,
    );

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

    final creatorName = assessmentModel.createdBy;
    String dateTime = DateFormat.yMMMEd().format(assessmentModel.createdAt);

    final signatureText = '''Creator: $creatorName
Date: $dateTime''';

    page.graphics.drawString(
      signatureText,
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(
        pageSize.width - 250,
        pageSize.height - 50,
        0,
        0,
      ),
    );
    page.graphics.drawImage(
      image,
      Rect.fromLTWH(
        pageSize.width - 100,
        pageSize.height - 60,
        100,
        40,
      ),
    );
  }

  static Future<void> drawGrid(
    AssessmentModel assessmentModel,
    PdfPage page,
    PdfBitmap logo,
  ) async {
    // Draw the header
    drawHeader(
      page,
      "Risk Assessment",
      assessmentModel.id,
      logo,
    );

    // Create a list of grids to add together for a custom grid
    final List<PdfGrid> grids = [];

    // First grid with one column
    final grid1 = PdfGrid();
    // Second grid with two columns
    final grid2 = PdfGrid();
    // Third grid with one columns
    final grid3 = PdfGrid();
    // Fourth grid with three columns
    final grid4 = PdfGrid();
    // Fifth grid with one colum
    final grid5 = PdfGrid();

    // Add a column to grid1
    grid1.columns.add(count: 1);
    // Add two columns to grid2
    grid2.columns.add(count: 2);
    // Add a column to grid3
    grid3.columns.add(count: 1);
    // Add three columns to grid4
    grid4.columns.add(count: 3);
    // Add a column to grid1
    grid5.columns.add(count: 1);

    // Make this a header and put the title of the assessment here
    final headerRow1 = grid1.headers.add(1)[0];
    // Make one header row for grid2 with "Task:" and "Date and Time:"
    final headerRow2 = grid2.headers.add(1)[0];
    // make a heard for grid3 for "Equipment and tools"
    final headerRow3 = grid3.headers.add(1)[0];
    // make a header for grid4 for "Hazards", "Risk", and "Control"
    final headerRow4 = grid4.headers.add(1)[0];
    // Make this a header and put the summary
    final headerRow5 = grid5.headers.add(1)[0];

    // create a list of header rows
    final headerRowList = [
      headerRow1,
      headerRow2,
      headerRow3,
      headerRow4,
      headerRow5,
    ];

    // Get the header style for the grid
    for (var headerRow in headerRowList) {
      getHeaderStyle(headerRow);
      getBackGroundColor(headerRow);
      cellPadding(headerRow, 0, true);
    }

    // Add the data in the first grid (grid1)
    headerRow1.cells[0].value = assessmentModel.title.toUpperCase();
    headerRow1.cells[0].style.stringFormat = await centerHeaderTitle();
    grids.add(grid1);

    // Add the data in the second grid (grid2)
    headerRow2.cells[0].value = 'TASK:';
    headerRow2.cells[1].value = 'DATE & TIME:';
    // cell padding Date and Time
    cellPadding(headerRow2, 1, true);

    // Create a new row for the task and date/time data
    final dataRow1 = grid2.rows.add();
    dataRow1.cells[0].value = assessmentModel.taskToAchieve;
    dataRow1.cells[1].value =
        DateFormat.yMMMEd().format(assessmentModel.createdAt);
    applyCellPaddingToRow(dataRow1, false);
    grids.add(grid2);

    // Add the data in the third grid (grid3)
    headerRow3.cells[0].value = "EQUIPMENT AND TOOLS TO BE USED";
    headerRow3.cells[0].style.stringFormat = await centerHeaderTitle();

    // add the equipments list from the assessment model to grid3
    int index = 1;
    for (final equipment in assessmentModel.equipments) {
      final dataRow = grid3.rows.add();
      dataRow.cells[0].value = '${index++}. $equipment';
      applyCellPaddingToRow(dataRow, false);
    }
    grids.add(grid3);

    headerRow4.cells[0].value = "HAZARDS";
    headerRow4.cells[1].value = "RISKS";
    headerRow4.cells[2].value = "CONTROL MEASURES";
    // center the text in the header
    for (int i = 0; i < headerRow4.cells.count; i++) {
      headerRow4.cells[i].style.stringFormat = await centerHeaderTitle();
      cellPadding(headerRow4, i, true);
    }

    // Add the data in the fourth grid (grid4)
    final maxLength = [
      assessmentModel.hazards.length,
      assessmentModel.risks.length,
      assessmentModel.control.length,
    ].reduce((a, b) => a > b ? a : b);

    // Add the data in the fourth grid (grid4)
    for (int i = 0; i < maxLength; i++) {
      final dataRow = grid4.rows.add();
      dataRow.cells[0].value = i < assessmentModel.hazards.length
          ? '${i + 1}. ${assessmentModel.hazards[i]}'
          : '';
      dataRow.cells[1].value = i < assessmentModel.risks.length
          ? '${i + 1}. ${assessmentModel.risks[i]}'
          : '';
      dataRow.cells[2].value = i < assessmentModel.control.length
          ? '${i + 1}. ${assessmentModel.control[i]}'
          : '';
      applyCellPaddingToRow(dataRow, false);
    }
    grids.add(grid4);

    headerRow5.cells[0].value = "SUMMARY";
    // Create a new row for the task and date/time data
    final dataRow5 = grid5.rows.add();
    dataRow5.cells[0].value = assessmentModel.summary;
    applyCellPaddingToRow(dataRow5, false);
    grids.add(grid5);

    // Initial vertical offset
    double currentOffsetY = 80;

    // Draw all the grids one after the other
    for (final grid in grids) {
      final result = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
          20,
          currentOffsetY,
          page.getClientSize().width - 40,
          0, // Height set to 0 for auto-height adjustment
        ),
      );

      // Update the current vertical offset for the next grid
      if (result != null) {
        currentOffsetY += result.bounds.height + 10; // space between grids
      }
    }
  }

  static void drawHeader(
      PdfPage page, String title, String documentId, PdfImage logo) {
    final trimmedDocId = documentId.substring(0, 13);
    log('ID: $documentId');
    final graphics = page.graphics;

    // Define the bounds for the header elements
    const double margin = 20;
    const double headerHeight = 50;
    // get page size
    final pageSize = page.getClientSize();

    // Set the font and brush for the title
    final titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final documentIdFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final brush = PdfSolidBrush(PdfColor(0, 0, 0));

    // Draw the title on the top left
    graphics.drawString(title, titleFont,
        brush: brush,
        bounds: const Rect.fromLTWH(margin, margin, 200, headerHeight));

    // Draw the document ID below the title
    graphics.drawString('ID: $trimmedDocId', documentIdFont,
        brush: brush,
        bounds: const Rect.fromLTWH(margin, margin + 20, 200, headerHeight));

    // Draw the image/logo on the top right
    graphics.drawImage(
        logo,
        Rect.fromLTWH(pageSize.width - (margin * 5), margin - 10, headerHeight,
            headerHeight));
  }

  static Future<PdfBitmap> loadLogo(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    return PdfBitmap(bytes);
  }

// Save the file to the device
  static Future<File> saveFile(PdfDocument document) async {
    // Get the path to the document directory
    final path = await getApplicationDocumentsDirectory();
    // Get the file name
    final fileName =
        '${path.path}/RiskAssessment${DateTime.now().toIso8601String()}.pdf';
    // Save the document to the device
    final file = File(fileName);
    // Write the document to the file
    file.writeAsBytes(await document.save());
    // Dispose the document
    document.dispose();
    // Return the file
    return file;
  }

  // Get the header style for the grid
  static Future<PdfStandardFont> getHeaderStyle(PdfGridRow headerRow) async {
    final headerRowStyle = headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    return headerRowStyle;
  }

  // Get the header style for the grid
  static Future<PdfSolidBrush> getBackGroundColor(PdfGridRow headerRow) async {
    final headerRowStyle = headerRow.style.backgroundBrush =
        PdfSolidBrush(PdfColor(200, 200, 200));
    return headerRowStyle;
  }

  // Center-align the title in the cell
  static Future<PdfStringFormat> centerHeaderTitle() async {
    // Center-align the title in the cell
    final centerFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    return centerFormat;
  }

  static Future<PdfPaddings> cellPadding(
    PdfGridRow headerRow,
    int index,
    bool isHeading,
  ) async {
    final headerPadding =
        headerRow.cells[index].style.cellPadding = PdfPaddings(
      bottom: isHeading ? 5 : 2,
      left: isHeading ? 5 : 2,
      right: isHeading ? 5 : 2,
      top: isHeading ? 5 : 2,
    );
    return headerPadding;
  }

  // Apply cell padding to a row
  static void applyCellPaddingToRow(PdfGridRow row, bool isHeading) {
    for (int i = 0; i < row.cells.count; i++) {
      cellPadding(row, i, isHeading);
    }
  }
}
