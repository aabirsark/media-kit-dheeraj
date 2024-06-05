/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/Slidebar_controller.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';

import 'package:media_kit_video/media_kit_video_controls/src/controls/widgets/video_controls_theme_data_injector.dart';

/// Whether a [Video] present in the current [BuildContext] is in fullscreen or not.
bool isFullscreen(BuildContext context) =>
    FullscreenInheritedWidget.maybeOf(context) != null;

/// Makes the [Video] present in the current [BuildContext] enter fullscreen.
Future<void> enterFullscreen(BuildContext context) {
  return lock.synchronized(() async {
    if (!isFullscreen(context)) {
      if (context.mounted) {
        final stateValue = state(context);
        final contextNotifierValue = contextNotifier(context);
        final videoViewParametersNotifierValue =
            videoViewParametersNotifier(context);
        final controllerValue = controller(context);
        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ChangeNotifierProvider(
              create: (context) => MediaXSidebarController(),
              builder: (ctx, child) {
                final stateProv = ctx.watch<MediaXSidebarController>();
                return Material(
                  color: Colors.black,
                  child: VideoControlsThemeDataInjector(
                    // NOTE: Make various *VideoControlsThemeData from the parent context available in the fullscreen context.
                    context: context,
                    child: VideoStateInheritedWidget(
                      state: stateValue,
                      contextNotifier: contextNotifierValue,
                      videoViewParametersNotifier:
                          videoViewParametersNotifierValue,
                      child: FullscreenInheritedWidget(
                        parent: stateValue,
                        // Another [VideoStateInheritedWidget] inside [FullscreenInheritedWidget] is important to notify about the fullscreen [BuildContext].
                        child: VideoStateInheritedWidget(
                            state: stateValue,
                            contextNotifier: contextNotifierValue,
                            videoViewParametersNotifier:
                                videoViewParametersNotifierValue,
                            child: Row(children: [
                              Expanded(
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 100),
                                  scale: stateProv.isOpen ? 0.95 : 1.0,
                                  child: FullScreenVideo(
                                      controllerValue: controllerValue,
                                      videoViewParametersNotifierValue:
                                          videoViewParametersNotifierValue,
                                      stateValue: stateValue),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: stateProv.isOpen ? 200 : 0.0,
                                child: stateProv.child,
                              )
                            ])),
                      ),
                    ),
                  ),
                );
              },
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        await onEnterFullscreen(context)?.call();
      }
    }
  });
}

class FullScreenVideo extends StatefulWidget {
  const FullScreenVideo({
    super.key,
    required this.controllerValue,
    required this.videoViewParametersNotifierValue,
    required this.stateValue,
  });

  final VideoController controllerValue;
  final ValueNotifier<VideoViewParameters> videoViewParametersNotifierValue;
  final VideoState stateValue;

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  @override
  void dispose() {
    Provider.of<MediaXSidebarController>(context, listen: false).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: widget.controllerValue,
      // Do not restrict the video's width & height in fullscreen mode:
      width: null,
      height: null,
      fit: widget.videoViewParametersNotifierValue.value.fit,
      fill: widget.videoViewParametersNotifierValue.value.fill,
      alignment: widget.videoViewParametersNotifierValue.value.alignment,
      aspectRatio: widget.videoViewParametersNotifierValue.value.aspectRatio,
      filterQuality:
          widget.videoViewParametersNotifierValue.value.filterQuality,
      controls: widget.videoViewParametersNotifierValue.value.controls,
      // Do not acquire or modify existing wakelock in fullscreen mode:
      wakelock: false,
      pauseUponEnteringBackgroundMode:
          widget.stateValue.widget.pauseUponEnteringBackgroundMode,
      resumeUponEnteringForegroundMode:
          widget.stateValue.widget.resumeUponEnteringForegroundMode,
      subtitleViewConfiguration: widget
          .videoViewParametersNotifierValue.value.subtitleViewConfiguration,
      onEnterFullscreen: widget.stateValue.widget.onEnterFullscreen,
      onExitFullscreen: widget.stateValue.widget.onExitFullscreen,
    );
  }
}

/// Makes the [Video] present in the current [BuildContext] exit fullscreen.
Future<void> exitFullscreen(BuildContext context) {
  return lock.synchronized(() async {
    if (isFullscreen(context)) {
      if (context.mounted) {
        await Navigator.of(context).maybePop();
        // It is known that this [context] will have a [FullscreenInheritedWidget] above it.
        if (context.mounted) {
          FullscreenInheritedWidget.of(context).parent.refreshView();
        }
      }
      // [exitNativeFullscreen] is moved to [WillPopScope] in [FullscreenInheritedWidget].
      // This is because [exitNativeFullscreen] needs to be called when the user presses the back button.
    }
  });
}

/// Toggles fullscreen for the [Video] present in the current [BuildContext].
Future<void> toggleFullscreen(
  BuildContext context,
) {
  if (isFullscreen(context)) {
    return exitFullscreen(context);
  } else {
    return enterFullscreen(context);
  }
}

void toggleSidebar(BuildContext context, Widget? child) {
  MediaXSidebarController().toggleSidebar(child);
}

/// For synchronizing [enterFullscreen] & [exitFullscreen] operations.
final Lock lock = Lock();
