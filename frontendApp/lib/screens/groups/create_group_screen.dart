import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/services/groups_services.dart';
import 'package:frontend_app/services/auth_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetDistanceController = TextEditingController();

  final GroupsApiService _apiService = GroupsApiService();

  final Map<String, _PrivacyMetadata> _privacyOptions = {
    'OPEN': _PrivacyMetadata(
      label: 'Open',
      description: 'Anyone can find and join this group instantly.',
      icon: Icons.public_rounded,
    ),
    'INVITE_ONLY': _PrivacyMetadata(
      label: 'Invite Only',
      description: 'Members must be invited or approved by an admin.',
      icon: Icons.vpn_key_rounded,
    ),
    'PRIVATE': _PrivacyMetadata(
      label: 'Private',
      description: 'Hidden from search. Visible by invite link only.',
      icon: Icons.lock_rounded,
    ),
  };

  String _privacy = 'OPEN';
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetDistanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No active session token found.');
      }

      final targetText = _targetDistanceController.text.trim();
      final targetDistanceKm = targetText.isEmpty ? null : double.tryParse(targetText);

      await _apiService.createGroup(
        token,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        privacy: _privacy,
        targetDistanceKm: targetDistanceKm,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create group: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CREATE GROUP',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildLabel('Group Name'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: _inputDecoration('e.g. Lusaka Morning Runners'),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Group name is required' : null,
              ),
              const SizedBox(height: 24),

              _buildLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppTheme.textWhite),
                maxLines: 3,
                decoration: _inputDecoration('What is this group about?'),
              ),
              const SizedBox(height: 24),

              _buildLabel('Privacy'),
              _buildPrivacySelectors(),
              const SizedBox(height: 24),

              _buildLabel('Target Distance Goal (km) — optional'),
              TextFormField(
                controller: _targetDistanceController,
                style: const TextStyle(color: AppTheme.textWhite),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('e.g. 100'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid distance';
                  return null;
                },
              ),
              const SizedBox(height: 36),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13),
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.black,
                    shadowColor: AppTheme.primaryOrange.withOpacity(0.3),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                  )
                      : const Text(
                    'Create Group',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySelectors() {
    return Column(
      children: _privacyOptions.entries.map((entry) {
        final option = entry.key;
        final data = entry.value;
        final isSelected = _privacy == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _privacy = option),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryOrange.withOpacity(0.08)
                      : AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryOrange
                        : Colors.white.withOpacity(0.05),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      data.icon,
                      color: isSelected ? AppTheme.primaryOrange : AppTheme.textLight,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryOrange : AppTheme.textWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.description,
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Check indicator
                    AnimatedScale(
                      scale: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primaryOrange,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textLight,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 14),
    filled: true,
    fillColor: AppTheme.darkCard,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  );
}

class _PrivacyMetadata {
  final String label;
  final String description;
  final IconData icon;

  _PrivacyMetadata({
    required this.label,
    required this.description,
    required this.icon,
  });
}