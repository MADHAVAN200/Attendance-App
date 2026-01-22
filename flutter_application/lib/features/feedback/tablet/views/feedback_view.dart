import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/feedback_service.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> with SingleTickerProviderStateMixin {
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
       // Check if admin to fetch all? For now, fetch all if on second tab
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
     final isAdmin = Provider.of<AuthService>(context).user?.role == 'ADMIN' || true; // Force true for dev if needed, or check real role

     return Column(
       children: [
         // Tabs
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.white,
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
        tabs: const [
          Tab(text: 'Submit Feedback'),
          Tab(text: 'All Feedback (Admin)'),
        ],
      ),
    );
  }

  Widget _buildSubmitForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Submit Feedback / Report Bug", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['BUG', 'FEATURE', 'IMPROVEMENT', 'OTHER'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.attach_file),
                label: const Text("Attach Files"),
              ),
              if (_attachedFiles.isNotEmpty)
                ..._attachedFiles.map((f) => ListTile(
                  title: Text(f.path.split(Platform.pathSeparator).last),
                  trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _attachedFiles.remove(f))),
                  dense: true,
                )),

              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit"),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _allFeedback.length,
      itemBuilder: (ctx, i) {
        final fb = _allFeedback[i];
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: ListTile(
            title: Text("${fb['title']} (${fb['type']})", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text(fb['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Chip(label: Text(fb['status'] ?? 'OPEN')),
            onTap: () {
              // Expand details or change status dialog
            },
          ),
        );
      },
    );
  }
}
