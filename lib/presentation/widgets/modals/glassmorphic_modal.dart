import 'dart:ui';
import 'package:flutter/material.dart';

Future<T?> showGlassmorphicModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return RepaintBoundary(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: Colors.white.withAlpha(51),
                  width: 1.5,
                ),
              ),
              child: builder(ctx),
            ),
          ),
        ),
      );
    },
  );
}
