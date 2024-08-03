import 'dart:io';
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
    headerRow.cells[2].value = 'GROUP';
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

    // First grid with one column for the title
    final grid1 = PdfGrid();
    // Second grid with two columns for task and date/time
    final grid2 = PdfGrid();
    // Third grid with three columns for equipment, hazards, and risks
    final grid3 = PdfGrid();
    // Fourth grid with one column for control measures
    final grid4 = PdfGrid();
    // Fifth grid with one column for summary
    final grid5 = PdfGrid();
    // Grid for PPE images with dynamic columns
    final ppeGrid = PdfGrid();

    // Add columns to grids
    grid1.columns.add(count: 1);
    grid2.columns.add(count: 2);
    grid3.columns.add(count: 3);
    grid4.columns.add(count: 1);
    grid5.columns.add(count: 1);
    ppeGrid.columns.add(count: ppeImages.length);

    // Create header rows
    final headerRow1 = grid1.headers.add(1)[0];
    final headerRow2 = grid2.headers.add(1)[0];
    final headerRow3 = grid3.headers.add(1)[0];
    final headerRow4 = grid4.headers.add(1)[0];
    final headerRow5 = grid5.headers.add(1)[0];

    // Apply styles to header rows
    final headerRowList = [
      headerRow1,
      headerRow2,
      headerRow3,
      headerRow4,
      headerRow5
    ];
    for (var headerRow in headerRowList) {
      getHeaderStyle(headerRow);
      getBackGroundColor(headerRow);
      cellPadding(headerRow, 0, true);
    }

    // Grid 1: Title
    headerRow1.cells[0].value = assessmentModel.title.toUpperCase();
    headerRow1.cells[0].style.stringFormat = await centerHeaderTitle();
    grids.add(grid1);

    // Grid 2: Task and Date/Time
    headerRow2.cells[0].value = 'TASK:';
    headerRow2.cells[1].value = 'DATE & TIME:';
    cellPadding(headerRow2, 1, true);
    final dataRow1 = grid2.rows.add();
    dataRow1.cells[0].value = assessmentModel.taskToAchieve;
    dataRow1.cells[1].value =
        DateFormat.yMMMEd().format(assessmentModel.createdAt);
    applyCellPaddingToRow(dataRow1, false);
    grids.add(grid2);

    // Grid 3: Equipment, Hazards, and Risks
    headerRow3.cells[0].value = "EQUIPMENT AND TOOLS";
    headerRow3.cells[1].value = "HAZARDS";
    headerRow3.cells[2].value = "RISKS";
    for (int i = 0; i < headerRow3.cells.count; i++) {
      headerRow3.cells[i].style.stringFormat = await centerHeaderTitle();
      cellPadding(headerRow3, i, true);
    }

    final maxLength = [
      assessmentModel.equipments.length,
      assessmentModel.hazards.length,
      assessmentModel.risks.length,
    ].reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      final dataRow = grid3.rows.add();
      dataRow.cells[0].value = i < assessmentModel.equipments.length
          ? '${i + 1}. ${assessmentModel.equipments[i]}'
          : '';
      dataRow.cells[1].value = i < assessmentModel.hazards.length
          ? '${i + 1}. ${assessmentModel.hazards[i]}'
          : '';
      dataRow.cells[2].value = i < assessmentModel.risks.length
          ? '${i + 1}. ${assessmentModel.risks[i]}'
          : '';
      applyCellPaddingToRow(dataRow, false);
    }
    grids.add(grid3);

    // Grid 4: Control Measures
    headerRow4.cells[0].value = "CONTROL MEASURES";
    headerRow4.cells[0].style.stringFormat = await centerHeaderTitle();
    for (int i = 0; i < assessmentModel.control.length; i++) {
      final dataRow = grid4.rows.add();
      dataRow.cells[0].value = '${i + 1}. ${assessmentModel.control[i]}';
      applyCellPaddingToRow(dataRow, false);
    }
    grids.add(grid4);

    // PPE Grid
    final ppeRow = ppeGrid.rows.add();
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
    grids.add(ppeGrid);

    // Grid 5: Summary
    headerRow5.cells[0].value = "SUMMARY";
    final dataRow5 = grid5.rows.add();
    dataRow5.cells[0].value = assessmentModel.summary;
    applyCellPaddingToRow(dataRow5, false);
    grids.add(grid5);

    // Draw all the grids one after the other
    double currentOffsetY = 80;
    for (final grid in grids) {
      final result = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, currentOffsetY, 0, 0),
      );
      if (result != null) {
        currentOffsetY += result.bounds.height + 10;
      }
    }
  }

  static void drawHeader(PdfPage page, String title, String documentId,
      PdfImage logo, String creatorName) {
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

    // draw the creator name below the document ID
    graphics.drawString(
      'Created by: $creatorName',
      documentIdFont,
      brush: brush,
      bounds: const Rect.fromLTWH(
        0,
        margin + 30,
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

  static Future<List<PdfBitmap>> loadImagesList(List<String> images) async {
    final logoList = <PdfBitmap>[];
    for (final image in images) {
      final logo = await loadImage(image);
      logoList.add(logo);
    }
    return logoList;
  }

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
    final folderName = 'RiskAssessments';
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
