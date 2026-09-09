// ═══════════════════════════════════════════════════
// FILE 4/6: lib/features/parent/presentation/screens/parent_notifications_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

const parentPurple = Color(0xFF3C3489);

class ParentNotificationsScreen extends StatefulWidget {
  const ParentNotificationsScreen({super.key});

  @override
  State<ParentNotificationsScreen> createState() => _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState extends State<ParentNotificationsScreen> {
  bool _loading = false;

  // TODO: replace with API
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      {
        'id': 'n1',
        'type': 'attendance',
        'emoji': '✅',
        'title': 'Rahul आज उपस्थित है',
        'body': 'आज सुबह 8:15 बजे Rahul स्कूल पहुंचे।',
        'time': '2 घंटे पहले',
        'read': true,
      },
      {
        'id': 'n2',
        'type': 'homework',
        'emoji': '📚',
        'title': 'गणित का गृहकार्य',
        'body': 'आज गणित में भिन्न पर गृहकार्य दिया गया — पृष्ठ 24, Q1-Q5।',
        'time': '3 घंटे पहले',
        'read': false,
      },
      {
        'id': 'n3',
        'type': 'exam',
        'emoji': '📝',
        'title': 'कल हिंदी Quiz है',
        'body': 'कल कक्षा में हिंदी का Quiz होगा। तैयारी करवाएं।',
        'time': 'कल',
        'read': false,
      },
      {
        'id': 'n4',
        'type': 'progress',
        'emoji': '📊',
        'title': 'हिंदी में सुधार',
        'body': 'Rahul की हिंदी में +8% का सुधार हुआ है इस हफ्ते।',
        'time': '2 दिन पहले',
        'read': true,
      },
      {
        'id': 'n5',
        'type': 'announcement',
        'emoji': '📢',
        'title': '15 अगस्त कार्यक्रम',
        'body': 'स्वतंत्रता दिवस पर स्कूल में विशेष कार्यक्रम होगा।',
        'time': '3 दिन पहले',
        'read': true,
      },
      {
        'id': 'n6',
        'type': 'attendance',
        'emoji': '⚠️',
        'title': 'कल अनुपस्थित था',
        'body': 'Rahul कल स्कूल में अनुपस्थित था।',
        'time': '4 दिन पहले',
        'read': true,
      },
      {
        'id': 'n7',
        'type': 'homework',
        'emoji': '📚',
        'title': 'Science worksheet',
        'body': 'Science का worksheet पूरा करना है इस हफ्ते।',
        'time': '5 दिन पहले',
        'read': true,
      },
    ];
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['read'] == false).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: parentPurple,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'सूचनाएं',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              'Notifications',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_rounded, color: Colors.white),
                  Positioned(
                    top: 10,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'सब पढ़ा',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: parentPurple))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🔔', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text(
                        'कोई सूचना नहीं',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No notifications',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = _notifications[i];
                    final isRead = item['read'] as bool;

                    return GestureDetector(
                      onTap: () => _markAsRead(i),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isRead ? AppColors.surfaceCard : parentPurple.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: isRead
                              ? Border.all(color: AppColors.border, width: 0.5)
                              : const Border(
                                  left: BorderSide(color: parentPurple, width: 3),
                                  top: BorderSide(color: AppColors.border, width: 0.5),
                                  right: BorderSide(color: AppColors.border, width: 0.5),
                                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isRead ? AppColors.surface : parentPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title'] as String,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(left: 6),
                                          decoration: const BoxDecoration(
                                            color: parentPurple,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['body'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['time'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(
                      delay: Duration(milliseconds: 100 + i * 60),
                    ).fadeIn().slideX(begin: 0.2);
                  },
                ),
    );
  }
}
