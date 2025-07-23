// lib/widgets/report_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class ReportDialog extends StatefulWidget {
  final String title;
  final Function(String reason) onReport;

  const ReportDialog({
    super.key,
    required this.title,
    required this.onReport,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final _customReasonController = TextEditingController();

  final List<String> _reportReasons = [
    'Spam or unwanted content',
    'Harassment or bullying',
    'Inappropriate or offensive content',
    'False information',
    'Violates community guidelines',
    'Other (please specify)',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Report ${widget.title}',
        style: GoogleFonts.pixelifySans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryBorder,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you reporting this ${widget.title.toLowerCase()}?',
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: _reportReasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(
                    reason,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 14,
                    ),
                  ),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            if (_selectedReason == 'Other (please specify)') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customReasonController,
                decoration: InputDecoration(
                  labelText: 'Please specify',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.pixelifySans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedReason != null ? _submitReport : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Report',
            style: GoogleFonts.pixelifySans(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _submitReport() {
    String reason = _selectedReason!;
    
    if (reason == 'Other (please specify)') {
      final customReason = _customReasonController.text.trim();
      if (customReason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please specify your reason'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      reason = customReason;
    }

    widget.onReport(reason);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.title} reported successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}