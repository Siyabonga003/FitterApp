import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_app/theme/app_theme.dart';


Future<File?> showProfilePhotoPicker(BuildContext context) async {
  final picker = ImagePicker();

  return showModalBottomSheet<File?>(
    context: context,
    backgroundColor: AppTheme.darkCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('CHANGE PROFILE PHOTO',
                  style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryOrange),
                title: const Text('Take Photo', style: TextStyle(color: AppTheme.textWhite)),
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop(picked != null ? File(picked.path) : null);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryOrange),
                title: const Text('Choose from Gallery', style: TextStyle(color: AppTheme.textWhite)),
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop(picked != null ? File(picked.path) : null);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}