import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

class ClosedCaptionView extends StatelessWidget {
  final Responsive responsive;
  final double distanceFromBottom;

  ///[customCaptionView] when a custom view for the captions is needed
  final Widget Function(BuildContext context, MeeduPlayerController controller,
      Responsive responsive, String text)? customCaptionView;
  const ClosedCaptionView({
    Key? key,
    required this.responsive,
    this.distanceFromBottom = 30,
    this.customCaptionView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = MeeduPlayerController.of(context);
    return RxBuilder(
        //observables: [_.closedCaptionEnabled],
        (__) {
      if (!_.closedCaptionEnabled.value) return Container();

      return StreamBuilder<Duration>(
        initialData: Duration.zero,
        stream: _.onPositionChanged,
        builder: (__, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          final strSubtitle = _.videoPlayerController!.value.caption.text;

          return Positioned(
            left: 60,
            right: 60,
            bottom: responsive.subtitlePadding,
            child: customCaptionView != null
                ? customCaptionView!(context, _, responsive, strSubtitle)
                : ClosedCaption(
                    text: strSubtitle,
                    blackBackground: responsive.subtitleBg,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.subtitleSize,
                    ),
                  ),
          );
        },
      );
    });
  }
}

class ClosedCaption extends StatelessWidget {
  /// Creates a a new closed caption, designed to be used with
  /// [VideoPlayerValue.caption].
  ///
  /// If [text] is null or empty, nothing will be displayed.
  const ClosedCaption({
    Key? key,
    this.text,
    this.textStyle,
    this.blackBackground = true,
  }) : super(key: key);

  /// The text that will be shown in the closed caption, or null if no caption
  /// should be shown.
  /// If the text is empty the caption will not be shown.
  final String? text;

  /// Specifies how the text in the closed caption should look.
  ///
  /// If null, defaults to [DefaultTextStyle.of(context).style] with size 36
  /// font colored white.
  final TextStyle? textStyle;

  final bool blackBackground;

  @override
  Widget build(BuildContext context) {
    final String? text = this.text;
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    final TextStyle effectiveTextStyle = textStyle ??
        DefaultTextStyle.of(context).style.copyWith(
              fontSize: 36.0,
              color: Colors.white,
            );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            color: blackBackground ? const Color(0xB8000000) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(text, style: effectiveTextStyle),
          ),
        ),
      ),
    );
  }
}
