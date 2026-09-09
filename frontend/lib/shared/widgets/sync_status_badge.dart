import 'package:flutter/material.dart';
import '../../core/services/offline_sync_service.dart';
import '../../core/theme/app_theme.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: OfflineSyncService.instance.isOnlineNotifier,
      builder: (context, isOnline, _) {
        return ValueListenableBuilder<int>(
          valueListenable: OfflineSyncService.instance.pendingCountNotifier,
          builder: (context, pendingCount, _) {
            if (isOnline && pendingCount == 0) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                if (isOnline && pendingCount > 0) {
                  OfflineSyncService.instance.syncPending();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.saffron.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isOnline ? AppColors.saffron : AppColors.error,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.sync_rounded : Icons.cloud_off_rounded,
                      size: 14,
                      color: isOnline ? AppColors.saffron : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Sync ($pendingCount)' : 'Offline',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isOnline ? AppColors.saffron : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
