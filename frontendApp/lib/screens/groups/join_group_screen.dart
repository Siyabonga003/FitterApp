import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/services/groups_services.dart';
import 'package:frontend_app/services/auth_service.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GroupsApiService _apiService = GroupsApiService();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Enter an invite code.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No active session token found.');

      await _apiService.joinViaInviteCode(token, code);

      if (mounted) {
        Navigator.of(context).pop(true); // signal GroupsScreen to refresh
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e'.replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('JOIN WITH CODE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the invite code someone shared with you',
              style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: 'ABCD1234',
                hintStyle: const TextStyle(color: AppTheme.textLight, letterSpacing: 4),
                filled: true,
                fillColor: AppTheme.darkCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13)),
              ),

            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
                    : const Text('Join Group', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}