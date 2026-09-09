import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  /// Generates and previews/prints a worksheet PDF
  static Future<void> exportWorksheetPdf({
    required String title,
    required String grade,
    required String subject,
    required String topic,
    required List<dynamic> questions,
    String schoolName = 'Government Primary School / प्राथमिक विद्यालय',
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.notoSansDevanagariRegular();
    final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (context) => _buildWorksheetHeader(
          schoolName: schoolName,
          title: title,
          grade: grade,
          subject: subject,
          topic: topic,
          context: context,
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}  •  शिक्षा साथी (Shiksha Saathi)',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 12),
          // Student details fill area
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'विद्यार्थी का नाम (Name): _______________________',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'अनुक्रमांक (Roll No): ________',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'दिनांक (Date): ____________',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Questions section
          ...questions.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final q = entry.value is Map ? Map<String, dynamic>.from(entry.value) : <String, dynamic>{};
            final qText = q['question']?.toString() ?? q['text']?.toString() ?? 'Question $idx';
            final options = q['options'] is List ? (q['options'] as List) : [];
            final type = q['type']?.toString() ?? (options.isNotEmpty ? 'mcq' : 'short');

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 22,
                        height: 22,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('1A5C38'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '$idx',
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          qText,
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (type == 'mcq' && options.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 30),
                      child: pw.Wrap(
                        spacing: 24,
                        runSpacing: 6,
                        children: options.asMap().entries.map((optEntry) {
                          final optLetter = String.fromCharCode(65 + optEntry.key);
                          return pw.SizedBox(
                            width: 200,
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 14,
                                  height: 14,
                                  decoration: pw.BoxDecoration(
                                    shape: pw.BoxShape.circle,
                                    border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(
                                      optLetter,
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ),
                                pw.SizedBox(width: 6),
                                pw.Expanded(
                                  child: pw.Text(
                                    optEntry.value.toString(),
                                    style: const pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else ...[
                    pw.SizedBox(height: 8),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 30),
                      child: pw.Container(
                        height: 35,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.8, style: pw.BorderStyle.dashed),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}_Worksheet.pdf',
    );
  }

  static pw.Widget _buildWorksheetHeader({
    required String schoolName,
    required String title,
    required String grade,
    required String subject,
    required String topic,
    required pw.Context context,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromHex('1A5C38'), width: 2),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            schoolName,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('1A5C38'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('कक्षा (Class): $grade', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(width: 16),
              pw.Text('विषय (Subject): $subject', style: const pw.TextStyle(fontSize: 10)),
              if (topic.isNotEmpty) ...[
                pw.SizedBox(width: 16),
                pw.Text('पाठ (Topic): $topic', style: const pw.TextStyle(fontSize: 10)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Generates and previews/prints a Lesson Plan PDF
  static Future<void> exportLessonPlanPdf({
    required String title,
    required String grade,
    required String subject,
    required String topic,
    required Map<String, dynamic> content,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansDevanagariRegular();
    final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration:  pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('1A5C38'), width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('शिक्षा साथी • पाठ योजना (Lesson Plan)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1A5C38'))),
                  pw.Text('$subject • $grade • $topic', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                ],
              ),
              pw.Text('45 Minutes', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('F4A828'))),
            ],
          ),
        ),
        build: (context) {
          final objectives = content['objectives'] is List ? (content['objectives'] as List) : [];
          final materials = content['materials'] is List ? (content['materials'] as List) : [];
          final timeline = content['timeline'] is List ? (content['timeline'] as List) : [];
          final boardNotes = content['board_notes']?.toString() ?? content['boardNotes']?.toString() ?? '';
          final homework = content['homework']?.toString() ?? '';

          return [
            pw.SizedBox(height: 12),
            if (objectives.isNotEmpty) ...[
              _buildSectionTitle('🎯 शिक्षण उद्देश्य (Learning Objectives)'),
              pw.SizedBox(height: 6),
              ...objectives.map((obj) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1A5C38'))),
                    pw.Expanded(child: pw.Text(obj.toString(), style: const pw.TextStyle(fontSize: 10))),
                  ],
                ),
              )),
              pw.SizedBox(height: 12),
            ],

            if (materials.isNotEmpty) ...[
              _buildSectionTitle('📦 आवश्यक सामग्री (Required Materials)'),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 8,
                runSpacing: 4,
                children: materials.map((m) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('EAF7EF'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(m.toString(), style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('1A5C38'))),
                )).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            if (timeline.isNotEmpty) ...[
              _buildSectionTitle('⏱️ समय सारिणी व गतिविधियाँ (Timeline & Activities)'),
              pw.SizedBox(height: 6),
              ...timeline.map((step) {
                final map = step is Map ? Map<String, dynamic>.from(step) : <String, dynamic>{};
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('FDF3DC'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          map['duration']?.toString() ?? '5m',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('7B4F2E')),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(map['activity']?.toString() ?? map['title']?.toString() ?? 'Activity', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            if (map['description'] != null)
                              pw.Text(map['description'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 12),
            ],

            if (boardNotes.isNotEmpty) ...[
              _buildSectionTitle('📋 श्यामपट्ट कार्य (Blackboard Notes)'),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('F8FAF9'),
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Text(boardNotes, style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.3)),
              ),
              pw.SizedBox(height: 12),
            ],

            if (homework.isNotEmpty) ...[
              _buildSectionTitle('✍️ गृहकार्य (Homework)'),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('1A5C38')),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Text(homework, style:  pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}_LessonPlan.pdf',
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1A5C38')),
    );
  }
}
