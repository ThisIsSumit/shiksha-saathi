// ═══════════════════════════════════════════════════
// FILE 6/6: lib/features/teacher/presentation/screens/teacher_profile_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/snack_helper.dart';
import '../../../../shared/widgets/stat_chip.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

const teacherGreen = Color(0xFF166534);
const teacherLight = Color(0xFF22C55E);

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    final name = user?.name ?? 'Teacher';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'T';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teacherGreen,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'प्रोफ़ाइल',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // Profile Header
            CircleAvatar(
              radius: 48,
              backgroundColor: teacherGreen,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).scale(duration: 400.ms),
            const SizedBox(height: 12),

            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: teacherGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'शिक्षक · Teacher',
                style: TextStyle(
                  color: teacherGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 4),

            // TODO API: replace fallback school name with API endpoint data
            const Text(
              'Govt. Primary School, Hamirpur',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 24),

            // Statistics Row
            const Row(
              children: [
                StatChip(
                  value: '28',
                  label: 'छात्र',
                  labelEn: 'Students',
                  icon: Icons.people_outline_rounded,
                  color: teacherGreen,
                ),
                SizedBox(width: 8),
                StatChip(
                  value: '4',
                  label: 'कक्षाएं',
                  labelEn: 'Classes',
                  icon: Icons.class_outlined,
                  color: AppColors.info,
                ),
                SizedBox(width: 8),
                StatChip(
                  value: '76%',
                  label: 'औसत स्कोर',
                  labelEn: 'Avg Score',
                  icon: Icons.stars_rounded,
                  color: AppColors.success,
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            const SizedBox(height: 24),

            // Teacher Information Section
            const SectionHeader(
              title: 'जानकारी',
              subtitle: 'Information',
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'फ़ोन नंबर',
                    labelEn: 'Phone Number',
                    value: user?.phone ?? '—',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // TODO API: replace fallback school with API field
                  const _InfoRow(
                    icon: Icons.school_outlined,
                    label: 'स्कूल',
                    labelEn: 'School',
                    value: 'Govt. Primary School, Hamirpur',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // TODO API: replace fallback subjects with API field
                  const _InfoRow(
                    icon: Icons.book_outlined,
                    label: 'विषय',
                    labelEn: 'Subjects',
                    value: 'गणित, विज्ञान / Math, Science',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  const _InfoRow(
                    icon: Icons.language_rounded,
                    label: 'भाषा',
                    labelEn: 'Language',
                    value: 'हिंदी, English',
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3),
            const SizedBox(height: 24),

            // Settings Section
            const SectionHeader(
              title: 'सेटिंग्स',
              subtitle: 'Settings',
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'सूचनाएं',
                    subtitle: 'Notifications',
                    onTap: () => SnackHelper.info(context, 'Coming soon / जल्द आएगा'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    title: 'भाषा',
                    subtitle: 'Language',
                    onTap: () => SnackHelper.info(context, 'Coming soon / जल्द आएगा'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'सहायता',
                    subtitle: 'Help',
                    onTap: () => SnackHelper.info(context, 'Coming soon / जल्द आएगा'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
            const SizedBox(height: 32),

            // Logout Button
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
            ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.3),
            const SizedBox(height: 24),

            // Version text
            const Center(
              child: Text(
                'Shiksha Saathi v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String labelEn;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.labelEn,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: teacherGreen),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                labelEn,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: teacherGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: teacherGreen),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textMuted,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
