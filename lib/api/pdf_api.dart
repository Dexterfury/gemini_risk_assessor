import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;

class PdfApi {
  static Future<File> generatePdf({
    required AssessmentModel assessmentModel,
    required Uint8List signatureImage,
    required String heading,
    required String creatorName,
  }) async {
    final document = PdfDocument();

    // Load the logo from assets
    final PdfBitmap logo = await loadImage(AssetsManager.appLogo);

    // Load all ppe from assets
    final List<(PdfBitmap, String)> ppeImages = await loadPPELogoList();

    // load all selected ppe from assets
    final List<(PdfBitmap, String)> selectedPPEImages =
        await loadSelectedPPELogoList(assessmentModel.ppe);

    List<PdfBitmap> images = [];

    if (assessmentModel.images.isNotEmpty) {
      // Get images from assets or firestore
      images = await loadImagesList(assessmentModel.images);
    }

    // Function to add header and signature to a page
    void addHeaderAndSignature(PdfPage page) {
      drawHeader(
        page,
        heading,
        assessmentModel.id,
        logo,
      );
      addSignatureImage(
        assessmentModel,
        page,
        signatureImage,
        creatorName,
      );
    }

    // Add first page
    final firstPage = document.pages.add();
    addHeaderAndSignature(firstPage);

    // Draw table on the first page
    drawGrid(
      heading,
      assessmentModel,
      firstPage,
      logo,
      ppeImages,
      selectedPPEImages,
    );

    if (images.isNotEmpty) {
      // Add a new page for images
      final imagePage = document.pages.add();
      addHeaderAndSignature(imagePage);
      await addImagesOnNewPage(images, imagePage);
    }

    // Add a new page for names
    final namesPage = document.pages.add();
    addHeaderAndSignature(namesPage);
    addNamesPage(namesPage);

    return saveFile(
      document,
      heading,
      assessmentModel.id,
    );
  }

  static void addNamesPage(PdfPage page) {
    final grid = PdfGrid();
    grid.columns.add(count: 4);

    final headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'NAME';
    headerRow.cells[1].value = 'SURNAME';
    headerRow.cells[2].value = 'ORGANIZATION';
    headerRow.cells[3].value = 'SIGNATURE';

    // Apply styling to header row
    for (int i = 0; i < headerRow.cells.count; i++) {
      var cell = headerRow.cells[i];
      cell.style.backgroundBrush = PdfSolidBrush(PdfColor(100, 100, 100));
      cell.style.textBrush = PdfBrushes.white;
      cell.style.font = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
    }

    // Add empty rows for data entry
    for (int i = 0; i < 25; i++) {
      final row = grid.rows.add();
      for (int j = 0; j < row.cells.count; j++) {
        row.cells[j].style.borders.all = PdfPen(PdfColor(0, 0, 0), width: 0.5);
      }
      // apply padding to row
      row.height = 20;
    }

    // // Add a row for TIME at the bottom
    // final timeRow = grid.rows.add();
    // timeRow.cells[0].value = 'TIME:';
    // timeRow.cells[0].columnSpan = 4;
    // timeRow.height = 30;

    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);

    // Define header and footer space
    double headerHeight = 80.0;
    double footerHeight = 40.0;

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, headerHeight, page.getClientSize().width,
          page.getClientSize().height - headerHeight - footerHeight),
    );
  }

  static Future<void> addImagesOnNewPage(
      List<PdfBitmap> images, PdfPage page) async {
    const double padding = 20.0;
    double headerHeight = 80.0;
    double footerHeight = 20.0;
    double imageWidth = (page.getClientSize().width - 3 * padding) / 2;
    double currentX = padding;
    double currentY = padding + headerHeight;

    for (int i = 0; i < images.length; i++) {
      if (i > 0 && i % 2 == 0) {
        // Move to the next row
        currentX = padding;
        currentY +=
            images[i - 1].height * imageWidth / images[i - 1].width + padding;
      }

      page.graphics.drawImage(
        images[i],
        Rect.fromLTWH(currentX, currentY, imageWidth,
            images[i].height * imageWidth / images[i].width),
      );

      currentX += imageWidth + padding;
    }
  }

  static void addSignatureImage(
    AssessmentModel assessmentModel,
    PdfPage page,
    Uint8List signatureImage,
    String creatorName,
  ) {
    // get page size
    final pageSize = page.getClientSize();
    // add a signature image to the page
    final image = PdfBitmap(signatureImage);
    // draw the image on the page and locate it at the bottom right corner

    //final creatorName = assessmentModel.createdBy;
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
        pageSize.height - 40,
        0,
        0,
      ),
    );
    page.graphics.drawImage(
      image,
      Rect.fromLTWH(
        pageSize.width - 100,
        pageSize.height - 50,
        100,
        40,
      ),
    );
  }

  static Future<void> drawGrid(
    String heading,
    AssessmentModel assessmentModel,
    PdfPage page,
    PdfBitmap logo,
    List<(PdfBitmap, String)> ppeImages,
    List<(PdfBitmap, String)> selectedPPEImages,
  ) async {
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
    // Fifth grid with one column
    final grid5 = PdfGrid();
    // Grid for PPE images with dynamic columns
    final ppeGrid = PdfGrid();

    // Add a column to grid1
    grid1.columns.add(count: 1);
    // Add two columns to grid2
    grid2.columns.add(count: 2);
    // Add a column to grid3
    grid3.columns.add(count: 1);
    // Add three columns to grid4
    grid4.columns.add(count: 3);
    // Add a column to grid5
    grid5.columns.add(count: 1);
    // Add dynamic columns to ppeGrid based on number of images
    ppeGrid.columns.add(count: ppeImages.length);

    // Make this a header and put the title of the assessment here
    final headerRow1 = grid1.headers.add(1)[0];
    // Make one header row for grid2 with "Task:" and "Date and Time:"
    final headerRow2 = grid2.headers.add(1)[0];
    // Make a header for grid3 for "Equipment and tools"
    final headerRow3 = grid3.headers.add(1)[0];
    // Make a header for grid4 for "Hazards", "Risk", and "Control"
    final headerRow4 = grid4.headers.add(1)[0];
    // Make this a header and put the summary
    final headerRow5 = grid5.headers.add(1)[0];
    // Remove the header row for PPE images
    // final headerRowPPE = ppeGrid.headers.add(1)[0];

    // Create a list of header rows
    final headerRowList = [
      headerRow1,
      headerRow2,
      headerRow3,
      headerRow4,
      headerRow5,
      // headerRowPPE,
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
    // Cell padding Date and Time
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

    // Add the equipments list from the assessment model to grid3
    int index = 1;
    for (final equipment in assessmentModel.equipments) {
      final dataRow = grid3.rows.add();
      dataRow.cells[0].value = '${index++}. $equipment';
      applyCellPaddingToRow(dataRow, false);
    }
    grids.add(grid3);

    // Add the data in the fourth grid (grid4)
    headerRow4.cells[0].value = "HAZARDS";
    headerRow4.cells[1].value = "RISKS";
    headerRow4.cells[2].value = "CONTROL MEASURES";
    // Center the text in the header
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

    // Add PPE images to ppeGrid without a header
    // headerRowPPE.cells[0].value = "PERSONAL PROTECTIVE EQUIPMENT (PPE)";
    // headerRowPPE.cells[0].style.stringFormat = await centerHeaderTitle();

    // Add images to the ppeGrid
    final ppeRow = ppeGrid.rows.add();
    ppeRow.height = 50; // Set a fixed height for the row to accommodate images

    for (int i = 0; i < ppeImages.length; i++) {
      final (image, identifier) = ppeImages[i];
      ppeRow.cells[i].value = '';
      ppeRow.cells[i].style.backgroundImage = image;
      ppeRow.cells[i].style.stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      // Add padding to the cells
      ppeRow.cells[i].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);

      // Check if this PPE image is selected
      if (selectedPPEImages.any((selected) => selected.$2 == identifier)) {
        // Set a background color for selected PPE images
        ppeRow.cells[i].style.backgroundBrush =
            PdfSolidBrush(PdfColor(255, 255, 0)); // Yellow background
      }

      applyCellPaddingToRow(ppeRow, false);
    }
    grids.add(ppeGrid);

    // Add the summary to grid5
    headerRow5.cells[0].value = "SUMMARY";
    // Create a new row for the summary data
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
          0,
          currentOffsetY,
          0,
          0, // Height set to 0 for auto-height adjustment
        ),
      );

      // Update the current vertical offset for the next grid
      if (result != null) {
        currentOffsetY += result.bounds.height + 10; // Space between grids
      }
    }
  }

  static void drawHeader(
      PdfPage page, String title, String documentId, PdfImage logo) {
    final trimmedDocId = documentId.substring(0, 13);
    final graphics = page.graphics;

    // Define the bounds for the header elements
    const double margin = 20;
    const double headerHeight = 50;
    // Get page size
    final pageSize = page.getClientSize();

    // Set the font and brush for the title
    final titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final documentIdFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final brush = PdfSolidBrush(PdfColor(0, 0, 0));

    // Draw the title on the top left
    graphics.drawString(
      title,
      titleFont,
      brush: brush,
      bounds: const Rect.fromLTWH(
        0,
        margin,
        0,
        headerHeight,
      ),
    );

    // Draw the document ID below the title
    graphics.drawString(
      'ID: $trimmedDocId',
      documentIdFont,
      brush: brush,
      bounds: const Rect.fromLTWH(
        0,
        margin + 20,
        0,
        headerHeight,
      ),
    );

    // Draw the image/logo on the top right
    const logoWidth = headerHeight;
    final logoXPosition = pageSize.width - margin - logoWidth;
    graphics.drawImage(
      logo,
      Rect.fromLTWH(
        logoXPosition,
        margin,
        logoWidth,
        headerHeight,
      ),
    );
  }

  static Future<PdfBitmap> loadImage(String path) async {
    if (path.startsWith('http')) {
      // Load image from a remote URL
      final response = await http.get(Uri.parse(path));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        return PdfBitmap(bytes);
      } else {
        throw Exception('Failed to load image from URL');
      }
    } else {
      // Load image from local assets
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();
      return PdfBitmap(bytes);
    }
  }

  // static Future<List<PdfBitmap>> loadSelectedPPELogoList(
  //     List<String> ppe) async {
  //   final logoList = <PdfBitmap>[];
  //   final assetPaths = await getSelectedAssets(ppe);

  //   for (final assetPath in assetPaths) {
  //     final logo = await loadImage(assetPath);
  //     logoList.add(logo); // Error occurs here
  //   }
  //   return logoList;
  // }

  static Future<List<PdfBitmap>> loadImagesList(List<String> images) async {
    final logoList = <PdfBitmap>[];
    for (final image in images) {
      final logo = await loadImage(image);
      logoList.add(logo);
    }
    return logoList;
  }

  // static Future<List<PdfBitmap>> loadPPELogoList() async {
  //   final logoList = <PdfBitmap>[];
  //   final assetPaths = await getAssetsPath();

  //   for (final assetPath in assetPaths) {
  //     final logo = await loadImage(assetPath);
  //     logoList.add(logo); // Error occurs here
  //   }
  //   return logoList;
  // }

  static Future<List<(PdfBitmap, String)>> loadSelectedPPELogoList(
      List<String> ppe) async {
    final logoList = <(PdfBitmap, String)>[];
    final assetPaths = await getSelectedAssets(ppe);
    for (final assetPath in assetPaths) {
      final logo = await loadImage(assetPath);
      logoList.add((logo, assetPath));
    }
    return logoList;
  }

  static Future<List<(PdfBitmap, String)>> loadPPELogoList() async {
    final logoList = <(PdfBitmap, String)>[];
    final assetPaths = await getAssetsPath();
    for (final assetPath in assetPaths) {
      final logo = await loadImage(assetPath);
      logoList.add((logo, assetPath));
    }
    return logoList;
  }

  static Future<List<String>> getAssetsPath() async {
    List<String> assetPaths = [];
    for (var item in Constants.ppeAssetsList) {
      assetPaths.add(item);
    }
    return assetPaths;
  }

  static Future<List<String>> getSelectedAssets(List<String> ppe) async {
    List<String> assetPaths = [];
    for (var item in ppe) {
      switch (item) {
        case 'Dust Mask':
          assetPaths.add(AssetsManager.dustMask);
          break;
        case 'Ear Protection':
          assetPaths.add(AssetsManager.earProtection);
          break;
        case 'Face Shield':
          assetPaths.add(AssetsManager.faceShield);
          break;
        case 'Foot Protection':
          assetPaths.add(AssetsManager.footProtection);
          break;
        case 'Hand Protection':
          assetPaths.add(AssetsManager.handProtection);
          break;
        case 'Head Protection':
          assetPaths.add(AssetsManager.headProtection);
          break;
        case 'High Vis Clothing':
          assetPaths.add(AssetsManager.highVisClothing);
          break;
        case 'Life Jacket':
          assetPaths.add(AssetsManager.lifeJacket);
          break;
        case 'Protective Clothing':
          assetPaths.add(AssetsManager.protectiveClothing);
          break;
        case 'Safety Glasses':
          assetPaths.add(AssetsManager.safetyGlasses);
          break;
        case 'Other':
        default:
          assetPaths.add(AssetsManager.appLogo);
          break;
      }
    }
    return assetPaths;
  }

// Save the file to the device
  static Future<File> saveFile(
    PdfDocument document,
    String heading,
    String pdfName,
  ) async {
    final folderName = Constants.getFolderName(heading);
    // Get the path to the document directory
    final path = await getApplicationDocumentsDirectory();
    final dirPath = '${path.path}/$folderName';
    final fileName = '$dirPath/$pdfName.pdf';

    // Create the directory if it doesn't exist
    await Directory(dirPath).create(recursive: true);

    // Save the document to the device
    final file = File(fileName);

    // Write the document to the file
    await file.writeAsBytes(await document.save());

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
