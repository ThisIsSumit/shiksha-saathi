// ═══════════════════════════════════════════════════
// FILE 6/6: lib/features/parent/presentation/screens/parent_profile_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

const parentPurple = Color(0xFF3C3489);

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    final name = user?.name ?? 'Parent User';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final phone = user?.phone ?? '+91 98765 43210';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: parentPurple,
        title: const Text(
          'प्रोफ़ाइल / Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Hero Profile
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: parentPurple,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: parentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: parentPurple.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'अभिभावक · Parent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: parentPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Quick Stats Row
            Row(
              children: const [
                StatChip(
                  value: '1',
                  label: 'बच्चे',
                  labelEn: 'Children',
                  icon: Icons.child_care_outlined,
                  color: parentPurple,
                ),
                SizedBox(width: 10),
                StatChip(
                  value: '3',
                  label: 'सूचनाएं',
                  labelEn: 'Notifications',
                  icon: Icons.notifications_outlined,
                  color: AppColors.saffron,
                ),
                SizedBox(width: 10),
                StatChip(
                  value: '87%',
                  label: 'उपस्थिति',
                  labelEn: 'Child Att.',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Linked Children section BEFORE Information
            const SectionHeader(
              title: 'मेरे बच्चे',
              subtitle: 'My Children',
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 10),

            AppCard(
              onTap: () => context.push('/parent/child'),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: parentPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('👦', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rahul Kumar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Class 4-A · Roll 03',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: parentPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'प्रगति →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: parentPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Information Section
            const SectionHeader(
              title: 'व्यक्तिगत जानकारी',
              subtitle: 'Personal Information',
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 10),

            AppCard(
              child: Column(
                children: [
                  _ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    labelHi: 'फ़ोन नंबर',
                    labelEn: 'Phone Number',
                    value: phone,
                  ),
                  const Divider(height: 16),
                  const _ProfileInfoTile(
                    icon: Icons.language_outlined,
                    labelHi: 'पसंदीदा भाषा',
                    labelEn: 'Preferred Language',
                    value: 'हिंदी (Hindi)',
                  ),
                  const Divider(height: 16),
                  const _ProfileInfoTile(
                    icon: Icons.calendar_today_outlined,
                    labelHi: 'सदस्यता तिथि',
                    labelEn: 'Member Since',
                    value: 'August 2025',
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 28),

            // Logout button with EXACT specified code
            ElevatedButton.icon(
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout / लॉग आउट'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => context.read<AuthBloc>().add(AuthLogout()),
            ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

            const SizedBox(height: 20),

            // App Version
            const Text(
              'Shiksha Saathi v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String labelHi;
  final String labelEn;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.labelHi,
    required this.labelEn,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: parentPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$labelHi / $labelEn',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
