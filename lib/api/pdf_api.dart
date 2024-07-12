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
    PdfPage currentPage = document.pages.add();
    addHeaderAndSignature(currentPage);

    // Draw table on the first page
    List<PdfGrid> remainingGrids = await drawGrid(
      heading,
      assessmentModel,
      currentPage,
      logo,
      ppeImages,
      selectedPPEImages,
    );

// If there are remaining grids, create new pages
    while (remainingGrids.isNotEmpty) {
      currentPage = document.pages.add();
      addHeaderAndSignature(currentPage);
      remainingGrids = await drawGrid(
        heading,
        assessmentModel,
        currentPage,
        logo,
        ppeImages,
        selectedPPEImages,
        initialGrids: remainingGrids,
      );
    }

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

    // Add page numbers
    addPageNumbers(document);

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

//   static void addSignatureImage(
//     AssessmentModel assessmentModel,
//     PdfPage page,
//     Uint8List signatureImage,
//     String creatorName,
//   ) {
//     // get page size
//     final pageSize = page.getClientSize();
//     // add a signature image to the page
//     final image = PdfBitmap(signatureImage);
//     // draw the image on the page and locate it at the bottom right corner

//     //final creatorName = assessmentModel.createdBy;
//     String dateTime = DateFormat.yMMMEd().format(assessmentModel.createdAt);

//     final signatureText = '''Creator: $creatorName
// Date: $dateTime''';

//     page.graphics.drawString(
//       signatureText,
//       PdfStandardFont(PdfFontFamily.helvetica, 12),
//       format: PdfStringFormat(alignment: PdfTextAlignment.left),
//       brush: PdfSolidBrush(PdfColor(0, 0, 0)),
//       bounds: Rect.fromLTWH(
//         pageSize.width - 250,
//         pageSize.height - 40,
//         0,
//         0,
//       ),
//     );
//     page.graphics.drawImage(
//       image,
//       Rect.fromLTWH(
//         pageSize.width - 100,
//         pageSize.height - 50,
//         100,
//         40,
//       ),
//     );
//   }

  static void addSignatureImage(
    AssessmentModel assessmentModel,
    PdfPage page,
    Uint8List signatureImage,
    String creatorName,
  ) {
    // Get page size
    final pageSize = page.getClientSize();

    // Create the signature image
    final image = PdfBitmap(signatureImage);

    // Define signature and text dimensions
    const double signatureWidth = 100;
    const double signatureHeight = 40;
    const double textHeight = 30;
    const double padding = 10;

    // Calculate positions
    final double signatureX = pageSize.width - signatureWidth - padding;
    final double signatureY = pageSize.height - signatureHeight - padding;
    final double textY = signatureY - textHeight;

    // Format the date
    String dateTime = DateFormat.yMMMEd().format(assessmentModel.createdAt);

    // Create the signature text
    final signatureText = '''Creator: $creatorName
Date: $dateTime''';

    // Draw the text
    page.graphics.drawString(
      signatureText,
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(
        signatureX,
        textY,
        signatureWidth,
        textHeight,
      ),
    );

    // Draw the signature image
    page.graphics.drawImage(
      image,
      Rect.fromLTWH(
        signatureX,
        signatureY,
        signatureWidth,
        signatureHeight,
      ),
    );
  }

  static Future<List<PdfGrid>> drawGrid(
      String heading,
      AssessmentModel assessmentModel,
      PdfPage page,
      PdfBitmap logo,
      List<(PdfBitmap, String)> ppeImages,
      List<(PdfBitmap, String)> selectedPPEImages,
      {List<PdfGrid>? initialGrids}) async {
    // Create a list of grids to add together for a custom grid
    List<PdfGrid> grids = initialGrids ?? [];

    if (grids.isEmpty) {
      // Create new grids only if initialGrids is null or empty
      grids.addAll([
        createGrid1(assessmentModel),
        createGrid2(assessmentModel),
        createGrid3(assessmentModel),
        createGrid4(assessmentModel),
        createPPEGrid(ppeImages, selectedPPEImages),
        createGrid5(assessmentModel),
      ]);
    }

    // Initial vertical offset
    double currentOffsetY = 80;
    List<PdfGrid> remainingGrids = [];

    // Draw all the grids one after the other
    for (final grid in grids) {
      final result = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
          0,
          currentOffsetY,
          page.getClientSize().width,
          0, // Height set to 0 for auto-height adjustment
        ),
        format: PdfLayoutFormat(
          layoutType: PdfLayoutType.paginate,
          breakType: PdfLayoutBreakType.fitPage,
        ),
      );

      if (result != null) {
        if (result.bounds.bottom > page.getClientSize().height - 50) {
          // If the grid doesn't fit on the current page, add it to remainingGrids
          remainingGrids.add(grid);
          break;
        } else {
          // Update the current vertical offset for the next grid
          currentOffsetY = result.bounds.bottom + 10; // Space between grids
        }
      }
    }

    return remainingGrids;
  }

  // Helper methods to create individual grids
  static PdfGrid createGrid1(AssessmentModel assessmentModel) {
    final grid = PdfGrid();
    grid.columns.add(count: 1);
    final headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = assessmentModel.title.toUpperCase();
    getHeaderStyle(headerRow);
    getBackGroundColor(headerRow);
    cellPadding(headerRow, 0, true);
    return grid;
  }

  static PdfGrid createGrid2(AssessmentModel assessmentModel) {
    final grid = PdfGrid();
    grid.columns.add(count: 2);
    final headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'TASK:';
    headerRow.cells[1].value = 'DATE & TIME:';
    cellPadding(headerRow, 1, true);
    final dataRow = grid.rows.add();
    dataRow.cells[0].value = assessmentModel.taskToAchieve;
    dataRow.cells[1].value =
        DateFormat.yMMMEd().format(assessmentModel.createdAt);
    applyCellPaddingToRow(dataRow, false);
    return grid;
  }

  static PdfGrid createGrid3(AssessmentModel assessmentModel) {
    final grid = PdfGrid();
    grid.columns.add(count: 1);
    final headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = "EQUIPMENT AND TOOLS TO BE USED";
    centerHeaderTitle()
        .then((format) => headerRow.cells[0].style.stringFormat = format);
    int index = 1;
    for (final equipment in assessmentModel.equipments) {
      final dataRow = grid.rows.add();
      dataRow.cells[0].value = '${index++}. $equipment';
      applyCellPaddingToRow(dataRow, false);
    }
    return grid;
  }

  static PdfGrid createGrid4(AssessmentModel assessmentModel) {
    final grid = PdfGrid();
    grid.columns.add(count: 3);
    final headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = "HAZARDS";
    headerRow.cells[1].value = "RISKS";
    headerRow.cells[2].value = "CONTROL MEASURES";
    for (int i = 0; i < headerRow.cells.count; i++) {
      centerHeaderTitle()
          .then((format) => headerRow.cells[i].style.stringFormat = format);
      cellPadding(headerRow, i, true);
    }
    final maxLength = [
      assessmentModel.hazards.length,
      assessmentModel.risks.length,
      assessmentModel.control.length,
    ].reduce((a, b) => a > b ? a : b);
    for (int i = 0; i < maxLength; i++) {
      final dataRow = grid.rows.add();
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
    return grid;
  }

  static PdfGrid createPPEGrid(List<(PdfBitmap, String)> ppeImages,
      List<(PdfBitmap, String)> selectedPPEImages) {
    final grid = PdfGrid();
    grid.columns.add(count: ppeImages.length);
    final ppeRow = grid.rows.add();
    ppeRow.height = 50;
    for (int i = 0; i < ppeImages.length; i++) {
      final (image, identifier) = ppeImages[i];
      ppeRow.cells[i].value = '';
      ppeRow.cells[i].style.backgroundImage = image;
      ppeRow.cells[i].style.stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      ppeRow.cells[i].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
      if (selectedPPEImages.any((selected) => selected.$2 == identifier)) {
        ppeRow.cells[i].style.backgroundBrush =
            PdfSolidBrush(PdfColor(255, 255, 0));
      }
      applyCellPaddingToRow(ppeRow, false);
    }
    return grid;
  }

  static PdfGrid createGrid5(AssessmentModel assessmentModel) {
    final grid = PdfGrid();
    grid.columns.add(count: 1);
    final headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = "SUMMARY";
    final dataRow = grid.rows.add();
    dataRow.cells[0].value = assessmentModel.summary;
    applyCellPaddingToRow(dataRow, false);
    return grid;
  }

  static void addPageNumbers(PdfDocument document) {
    for (int i = 0; i < document.pages.count; i++) {
      final page = document.pages[i];
      final pageSize = page.getClientSize();
      final font = PdfStandardFont(PdfFontFamily.helvetica, 10);
      final format = PdfStringFormat(alignment: PdfTextAlignment.center);

      page.graphics.drawString(
        'Page ${i + 1} of ${document.pages.count}',
        font,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, pageSize.height - 25, pageSize.width, 20),
        format: format,
      );
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
