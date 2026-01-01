import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import '../../../shared/widgets/responsive_builder.dart';

class BulkUploadScreen extends StatefulWidget {
  const BulkUploadScreen({super.key});

  @override
  State<BulkUploadScreen> createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  int _currentStep = 1;
  PlatformFile? _selectedFile;
  List<List<dynamic>> _csvData = [];
  bool _isUploading = false;
  Map<String, dynamic>? _uploadReport;

  // Mock Upload Function
  Future<void> _handleUpload() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    // Mock Report
    final total = _csvData.length - 1; // Exclude header
    final success = (total * 0.8).round();
    
    setState(() {
      _isUploading = false;
      _uploadReport = {
        'total_processed': total,
        'success_count': success,
        'failure_count': total - success,
        'errors': ['Row 3: Invalid Email', 'Row 7: Missing Name'],
      };
      _currentStep = 3;
    });
  }

  Future<void> _pickFile() async {
    try {
      // Request Storage Permission (Android 12 and below mostly, but good practice per user request)
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isPermanentlyDenied) {
        openAppSettings();
        return;
      }
      
      // On Android 13+, storage permission is split. 
      // File Picker usually handles this without permission for "picking", 
      // but "reading" the path might trigger issues if not permitted.
      // We proceed if granted or limited (Android 13 often returns denied for generic storage but allows picking).
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: false, // Don't load into memory on mobile, use path
      );

      if (result != null) {
        final file = result.files.first;
        setState(() => _selectedFile = file);
        
        String? csvString;
        
        if (file.bytes != null) {
          csvString = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          final input = File(file.path!);
          csvString = await input.readAsString();
        }

        if (csvString != null) {
           final fields = const CsvToListConverter().convert(csvString);
           setState(() {
             _csvData = fields;
             _currentStep = 2;
           });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading file: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Layout Wrapper
    return Scaffold(
      // backgroundColor: const Color(0xFFF3F4F6), // Removed
      appBar: AppBar(
        title: Text('Bulk Employee Upload', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000), // Max width for large screens
          padding: EdgeInsets.all(ResponsiveBuilder.isMobile(context) ? 16 : 32),
          child: Column(
            children: [
              _buildStepper(context),
              const SizedBox(height: 32),
              Expanded(
                child: _buildCurrentStep(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(context, 1, 'Upload', _currentStep >= 1),
        _buildStepConnector(context, _currentStep >= 2),
        _buildStepIndicator(context, 2, 'Preview', _currentStep >= 2),
        _buildStepConnector(context, _currentStep >= 3),
        _buildStepIndicator(context, 3, 'Done', _currentStep >= 3),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final color = isActive ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB);
    final textColor = isActive ? const Color(0xFF4F46E5) : const Color(0xFF6B7280);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (!isMobile) ...[
           const SizedBox(width: 8),
           Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        ]
      ],
    );
  }

  Widget _buildStepConnector(BuildContext context, bool isActive) {
    return Container(
      width: ResponsiveBuilder.isMobile(context) ? 40 : 80,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 1:
        return _buildUploadStep(context);
      case 2:
        return _buildPreviewStep(context);
      case 3:
        return _buildSuccessStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUploadStep(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(height: 24),
                  Text('Click to upload CSV file', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: 8),
                  Text('Max 5MB', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Select File', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ],
              ),
            ),
          ),
           const SizedBox(height: 32),
           TextButton.icon(
             onPressed: () {}, // Download sample logic
             icon: Icon(Icons.download, size: 16, color: Theme.of(context).primaryColor),
             label: Text('Download Sample CSV Template', style: TextStyle(color: Theme.of(context).primaryColor)),
           ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.description_outlined, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedFile?.name ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text('${((_selectedFile?.size ?? 0) / 1024).toStringAsFixed(2)} KB', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => setState(() { _currentStep = 1; _selectedFile = null; _csvData = []; }),
                  icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          // Table
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
                  columns: [
                    DataColumn(label: Text('NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color))),
                    DataColumn(label: Text('EMAIL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color))),
                    DataColumn(label: Text('ROLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color))),
                  ],
                  rows: _csvData.skip(1).take(50).map((row) {
                    final isValid = row.length >= 2 && row[0].toString().isNotEmpty && row[1].toString().isNotEmpty; // Simple Validation
                    return DataRow(cells: [
                      DataCell(Text(row.length > 0 ? row[0].toString() : '', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
                      DataCell(Text(row.length > 1 ? row[1].toString() : '', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
                      DataCell(Text(row.length > 2 ? row[2].toString() : '-', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isValid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isValid ? Icons.check_circle : Icons.error, size: 14, color: isValid ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                            const SizedBox(width: 4),
                            Text(isValid ? 'Valid' : 'Error', style: TextStyle(fontSize: 12, color: isValid ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                          ],
                        ),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
               border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _handleUpload,
                  icon: _isUploading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const SizedBox.shrink(),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Employees', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, size: 48, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 24),
          Text('Upload Processed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 16),
          Text(
            'Processed: ${_uploadReport?['total_processed']}\nSuccess: ${_uploadReport?['success_count']}\nFailed: ${_uploadReport?['failure_count']}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                  side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                ),
                child: const Text('View Employee List'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => setState(() { _currentStep = 1; _selectedFile = null; _csvData = []; _uploadReport = null; }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Upload More', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
