import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class CustomTimerCountdown extends StatelessWidget {
  final String label;
  final DateTime endTime;
  final VoidCallback? onEnd;

  const CustomTimerCountdown({required this.label, required this.endTime, this.onEnd, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(height: 8),
              TimerCountdown(
                onEnd: onEnd,
                endTime: endTime,
                format: CountDownTimerFormat.hoursMinutesSeconds,
                timeTextStyle: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                enableDescriptions: true,
                descriptionTextStyle: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
        ));
  }
}
