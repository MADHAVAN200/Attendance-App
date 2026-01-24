import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/feedback_service.dart';

class FeedbackMobileView extends StatefulWidget {
  const FeedbackMobileView({super.key});

  @override
  State<FeedbackMobileView> createState() => _FeedbackMobileViewState();
}

class _FeedbackMobileViewState extends State<FeedbackMobileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FeedbackService _feedbackService;
  
  // State
  // Admin Lists
  List<dynamic> _allFeedback = [];
  bool _isLoadingAll = false;

  // Submit Form
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedType = 'BUG';
  List<File> _attachedFiles = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize Service
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final dio = Provider.of<AuthService>(context, listen: false).dio;
       _feedbackService = FeedbackService(dio);
       _tabController.addListener(() {
         if (_tabController.index == 1) _fetchAllFeedback();
       });
    });
  }

  Future<void> _fetchAllFeedback() async {
    setState(() => _isLoadingAll = true);
    try {
      final data = await _feedbackService.getAllFeedback();
      if (mounted) setState(() => _allFeedback = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching feedback: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingAll = false);
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    try {
      await _feedbackService.submitFeedback(
        title: _titleController.text,
        description: _descController.text,
        type: _selectedType,
        files: _attachedFiles,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feedback Submitted Successfully")));
        _titleController.clear();
        _descController.clear();
        setState(() => _attachedFiles = []);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submit Failed: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachedFiles.addAll(result.paths.where((p) => p != null).map((p) => File(p!)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     final isAdmin = Provider.of<AuthService>(context).user?.role == 'ADMIN'; 

     return Column(
       children: [
         // Tabs - Compact for Mobile
         if (isAdmin) _buildTabs(context),
         
         Expanded(
           child: isAdmin 
             ? TabBarView(
                 controller: _tabController,
                 children: [
                   _buildSubmitForm(context),
                   _buildAllFeedbackList(context),
                 ],
               )
             : _buildSubmitForm(context),
         ),
       ],
     );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      height: 45, // Slightly taller for better touch
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4), 
        tabs: const [
          Tab(text: 'Submit'),
          Tab(text: 'All Feedback'),
        ],
      ),
    );
  }

  Widget _buildSubmitForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Submit Feedback", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['BUG', 'FEATURE', 'IMPROVEMENT', 'OTHER'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 12),
              
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.attach_file, size: 18),
                label: const Text("Attach"),
              ),
              if (_attachedFiles.isNotEmpty)
                ..._attachedFiles.map((f) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(f.path.split(Platform.pathSeparator).last, style: GoogleFonts.poppins(fontSize: 12)),
                  trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _attachedFiles.remove(f))),
                  dense: true,
                )),

              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                  child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllFeedbackList(BuildContext context) {
    if (_isLoadingAll) return const Center(child: CircularProgressIndicator());
    if (_allFeedback.isEmpty) return const Center(child: Text("No feedback found"));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _allFeedback.length,
      itemBuilder: (ctx, i) {
        final fb = _allFeedback[i];
        final status = fb['status'] ?? 'OPEN';
        final color = _getStatusColor(status);

        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(
                       color: color.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(4),
                       border: Border.all(color: color.withOpacity(0.2)),
                     ),
                     child: Text(
                       status,
                       style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                     ),
                   ),
                   Text(
                     fb['created_at'] != null ? fb['created_at'].toString().split('T')[0] : '', 
                     style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                   ),
                 ],
               ),
               const SizedBox(height: 8),
               Text(
                 fb['title'] ?? 'No Title', 
                 style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
               ),
               const SizedBox(height: 4),
               Text(
                 fb['description'] ?? '', 
                 style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                 maxLines: 2, 
                 overflow: TextOverflow.ellipsis,
               ),
               const SizedBox(height: 12),
               SizedBox(
                 width: double.infinity,
                 child: OutlinedButton(
                   onPressed: () => _showStatusDialog(fb),
                   style: OutlinedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 8),
                     side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                   ),
                   child: Text("Update Status", style: GoogleFonts.poppins(fontSize: 12)),
                 ),
               ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN': return Colors.blue;
      case 'IN_PROGRESS': return Colors.orange;
      case 'RESOLVED': return Colors.green;
      case 'CLOSED': return Colors.grey;
      default: return Colors.blue;
    }
  }

  void _showStatusDialog(dynamic feedback) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Update Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'].map((s) => 
               ListTile(
                 title: Text(s),
                 onTap: () async {
                    Navigator.pop(ctx);
                    await _updateStatus(feedback['feedback_id'], s);
                 },
               )
            ).toList(),
          ),
        );
      }
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await _feedbackService.updateFeedbackStatus(id, status);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status Updated")));
         _fetchAllFeedback();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }
}
