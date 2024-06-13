import 'package:flutter/material.dart';

class MediaKitSkipButton {
  final int duration;
  final int activateOn;
  final String label;
  final int skipTime;
  final bool enabled;

  MediaKitSkipButton(
      {required this.duration,
      required this.activateOn,
      required this.label,
      required this.skipTime,
      required this.enabled});
}

class MediaKitNextButton {
  final int duration;
  final int activateTimeLeft;
  final bool enabled;
  final String label;
  final VoidCallback? callback;

  MediaKitNextButton(
      {required this.duration,
      required this.activateTimeLeft,
      required this.label,
      this.callback,
      required this.enabled});
}
