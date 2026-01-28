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

  Future<void> _pickAndUploadImage() async {
    if (!widget.canEdit) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image == null) return;

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

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?';
    final imageUrl = user?.profileImage;

    return Stack(
      children: [
        GestureDetector(
          onTap: _pickAndUploadImage,
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
                          imageUrl: imageUrl.startsWith('http') ? imageUrl : '${ApiConstants.baseUrl}/$imageUrl', // Handle relative/absolute URLs
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) => _buildInitials(initials),
                        ),
                      )
                    : _buildInitials(initials),
          ),
        ),
        if (widget.canEdit && !_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B60F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
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
