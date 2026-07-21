import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class SignUpFormView extends StatefulWidget {
  final dynamic parentState;

  const SignUpFormView({super.key, required this.parentState});

  @override
  State<SignUpFormView> createState() => _SignUpFormViewState();
}

class _SignUpFormViewState extends State<SignUpFormView> {
  bool _obscureSignUpPassword = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  void _processNextStep() {
    final state = widget.parentState;
    if (state.signUpFormKey.currentState!.validate()) {
      if (state.signUpStep < 2) {
        setState(() {
          state.signUpStep++;
          _autovalidateMode = AutovalidateMode.disabled;
        });
      } else {
        state.submitAuthSession(false);
      }
    } else {
      setState(() => _autovalidateMode = AutovalidateMode.always);
    }
  }

  Future<void> _localPickBirthDate() async {
    final state = widget.parentState;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryOrange, surface: AppTheme.darkCard),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => state.selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.parentState;

    return Form(
      key: state.signUpFormKey,
      autovalidateMode: _autovalidateMode,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 8.0 : 0.0),
                  decoration: BoxDecoration(
                    color: index <= state.signUpStep ? AppTheme.primaryOrange : Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          if (state.signUpStep == 0) ...[
            _buildField(controller: state.signUpEmailController, hintText: 'Email Address', icon: Icons.email_outlined),
            const SizedBox(height: 16),
            _buildField(controller: state.signUpPasswordController, hintText: 'Password', icon: Icons.lock_outline_rounded, isObscure: _obscureSignUpPassword),
            CheckboxListTile(
              title: const Text('Show Password', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
              value: !_obscureSignUpPassword,
              onChanged: (val) => setState(() => _obscureSignUpPassword = !val!),
              activeColor: AppTheme.primaryOrange,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ] else if (state.signUpStep == 1) ...[
            _buildField(controller: state.signUpFirstNameController, hintText: 'First Name', icon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildField(controller: state.signUpLastNameController, hintText: 'Last Name', icon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildField(controller: state.signUpDisplayNameController, hintText: 'Display Name', icon: Icons.badge_outlined),
          ] else if (state.signUpStep == 2) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
              child: DropdownButtonFormField<String>(
                value: state.selectedGender,
                dropdownColor: AppTheme.darkCard,
                style: const TextStyle(color: AppTheme.textWhite),
                hint: const Text('Gender', style: TextStyle(color: AppTheme.textLight)),
                items: ['MALE', 'FEMALE', 'OTHER'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => state.selectedGender = val),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _localPickBirthDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: Text(
                  state.selectedBirthDate == null
                      ? 'Date of Birth'
                      : '${state.selectedBirthDate!.year}-${state.selectedBirthDate!.month}-${state.selectedBirthDate!.day}',
                  style: TextStyle(color: state.selectedBirthDate == null ? AppTheme.textLight : AppTheme.textWhite),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (state.signUpStep > 0)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), minimumSize: const Size(0, 52)),
                    onPressed: () => setState(() => state.signUpStep--),
                    child: const Text('BACK', style: TextStyle(color: AppTheme.textWhite)),
                  ),
                ),
              if (state.signUpStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                    onPressed: _processNextStep,
                    child: Text(state.signUpStep == 2 ? 'CREATE ACCOUNT' : 'NEXT', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String hintText, required IconData icon, bool isObscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: AppTheme.textWhite),
      validator: (val) => (val == null || val.isEmpty) ? 'Field required' : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textLight),
        prefixIcon: Icon(icon, color: AppTheme.textLight),
        filled: true,
        fillColor: AppTheme.darkCard,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
      ),
    );
  }
}