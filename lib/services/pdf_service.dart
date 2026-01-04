import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:food_recipe/models/recipe_model.dart';

class PDFService {
  static final PDFService _instance = PDFService._internal();

  factory PDFService() {
    return _instance;
  }

  PDFService._internal();

  /// generate pdf for a recipe and save to downloads
  Future<File?> generateRecipePDF(Recipe recipe) async {
    try {
      final pdf = pw.Document();

      // Add content to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Title
            pw.Text(
              recipe.title,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),

            // Recipe Info Row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Cuisine: ${recipe.cuisine}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Difficulty: ${recipe.difficulty}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Cooking Time: ${recipe.cookingTime} mins',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Servings: ${recipe.servings}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Description
            pw.Text(
              'Description',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              recipe.description,
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 20),

            // Ingredients
            pw.Text(
              'Ingredients',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: recipe.ingredients
                  .map(
                    (ingredient) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        children: [
                          pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                          pw.Expanded(
                            child: pw.Text(
                              ingredient,
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),

            // Steps
            pw.Text(
              'Instructions',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(
                recipe.steps.length,
                (index) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Step ${index + 1}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        recipe.steps[index],
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Author info
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text(
              'Recipe by: ${recipe.authorName}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Generated from Food Recipe App',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      );

      // Save PDF to Downloads folder
      final output = await getExternalStorageDirectory();
      if (output == null) {
        return null;
      }

      // Create Downloads directory path
      final downloadsPath = output.path.replaceAll('Android/data/com.example.food_recipe/files', 'Download');
      final downloadDir = Directory(downloadsPath);
      
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final fileName = '${recipe.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${downloadDir.path}/$fileName');
      
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      return null;
    }
  }

  /// print recipe pdf
  Future<void> printRecipePDF(Recipe recipe) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            pw.Text(
              recipe.title,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Cuisine: ${recipe.cuisine}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Difficulty: ${recipe.difficulty}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Cooking Time: ${recipe.cookingTime} mins',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Servings: ${recipe.servings}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Description',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              recipe.description,
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Ingredients',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: recipe.ingredients
                  .map(
                    (ingredient) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        children: [
                          pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                          pw.Expanded(
                            child: pw.Text(
                              ingredient,
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Instructions',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(
                recipe.steps.length,
                (index) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Step ${index + 1}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        recipe.steps[index],
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text(
              'Recipe by: ${recipe.authorName}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Generated from Food Recipe App',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      // error printing pdf
    }
  }
}
