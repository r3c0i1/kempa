// lib/core/debug/debug_overlay.dart

import 'package:flutter/material.dart';
import 'debug_log.dart';

class DebugOverlay extends StatelessWidget {
  final Widget child;

  const DebugOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 100,
          left: 8,
          right: 8,
          child: IgnorePointer(
            child: ListenableBuilder(
              listenable: DebugLog.instance,
              builder: (context, _) {
                final logs = DebugLog.instance.logs;

                if (logs.isEmpty) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: logs.length,
                    itemBuilder: (_, i) {
                      final index = logs.length - 1 - i;
                      return Text(
                        logs[index],
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}