import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/constants/api_constants.dart';

class ProfileAvatar extends StatefulWidget {
  final double size;
  final User? user;
  final bool canEdit;

  const ProfileAvatar({
    super.key,
    required this.size,
    required this.user,
    this.canEdit = true,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (!widget.canEdit) return;

    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      // Validate Size (Max 5MB)
      final int sizeInBytes = await image.length();
      if (sizeInBytes > 5 * 1024 * 1024) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image is too large (Max 5MB)'), backgroundColor: Colors.red),
            );
         }
         return;
      }

      setState(() => _isUploading = true);

      if (!mounted) return;
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateProfilePicture(File(image.path));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showEditOptions() {
    if (!widget.canEdit) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Change Profile Photo",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionItem(
                  icon: Icons.camera_alt_outlined, 
                  label: "Camera", 
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }
                ),
                _buildOptionItem(
                  icon: Icons.photo_library_outlined, 
                  label: "Gallery", 
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({required IconData icon, required String label, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white24 : (Colors.grey[300] ?? Colors.grey)),
            ),
            child: Icon(
              icon, 
              size: 28, 
              color: isDark ? Colors.white : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }

  void _openViewer() {
    if (widget.user?.profileImage == null) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9), // Dark overlay
      builder: (context) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.user!.profileImage!.startsWith('http') 
                    ? widget.user!.profileImage! 
                    : '${ApiConstants.baseUrl}/${widget.user!.profileImage!}',
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, err) => const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?';
    final imageUrl = user?.profileImage;

    return Stack(
      children: [
        GestureDetector(
          onTap: imageUrl != null ? _openViewer : null,
          child: Hero( // Hero animation for smooth transition
            tag: 'profile-avatar-${user?.id ?? "me"}',
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: const Color(0xFF5B60F6).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5B60F6).withValues(alpha: 0.3), width: 2),
              ),
              child: _isUploading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : imageUrl != null && imageUrl.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl.startsWith('http') ? imageUrl : '${ApiConstants.baseUrl}/$imageUrl',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) => _buildInitials(initials),
                          ),
                        )
                      : _buildInitials(initials),
            ),
          ),
        ),
        if (widget.canEdit && !_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showEditOptions,
              child: Container(
                padding: const EdgeInsets.all(8), // Larger touch target
                decoration: BoxDecoration(
                  color: const Color(0xFF5B60F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2), // Match bg
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: widget.size * 0.4,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5B60F6),
        ),
      ),
    );
  }
}
