import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Offline indicator widget
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // connectivity_plus không hỗ trợ web, skip trên web
    if (kIsWeb) {
      return const SizedBox();
    }
    
    final connectivityAsync = ref.watch(connectivityProvider);
    
    return connectivityAsync.when(
      data: (connectivityResults) {
        final isOffline = connectivityResults.contains(ConnectivityResult.none) ||
            (connectivityResults.isEmpty);
        
        if (!isOffline) return const SizedBox();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange,
          child: const Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You are offline. Some features may be limited.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
    );
  }
}

/// Connectivity provider - chỉ hoạt động trên mobile platforms
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  // Skip trên web
  if (kIsWeb) {
    return Stream.value([ConnectivityResult.wifi]);
  }
  return Connectivity().onConnectivityChanged;
});

