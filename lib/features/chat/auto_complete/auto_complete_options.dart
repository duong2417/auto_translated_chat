// ignore_for_file: no-empty-block

import 'package:flutter/material.dart';
import 'package:public_chat/utils/constants.dart';

/// A helper widget used to show the options of a [AutocompleteWidget].
class AutocompleteOptions<T extends Object> extends StatelessWidget {
  /// Creates a [AutocompleteOptions] widget.
  const AutocompleteOptions({
    super.key,
    this.color,
    this.elevation = 2,
    this.margin = const EdgeInsets.all(8),
    this.clipBehavior = Clip.hardEdge,
    required this.options,
    this.maxHeight,
    required this.optionBuilder,
    this.headerBuilder,
    this.shape = kDefaultAutocompleteOptionsShape,
  });

  /// The background color of the options card.
  final Color? color;

  /// The elevation of the options card.
  ///
  /// The default value is 2.
  final double elevation;

  /// The margin of the options card.
  ///
  /// The default value is [EdgeInsets.all(8)].
  final EdgeInsetsGeometry margin;

  /// The clip behavior of the options card.
  ///
  /// The default value is [Clip.hardEdge].
  final Clip clipBehavior;

  /// The shape of the options card.
  final ShapeBorder shape;

  /// The options to display.
  final Iterable<T> options;

  /// The maximum height of the options card.
  ///
  /// Defaults to half the height of the screen.
  final double? maxHeight;

  /// The builder for the options.
  final Widget Function(BuildContext context, T option) optionBuilder;

  /// The builder for the header of the options.
  final WidgetBuilder? headerBuilder;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Card(
      margin: margin,
      elevation: elevation,
      color: color,
      shape: shape,
      clipBehavior: clipBehavior,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (headerBuilder != null) ...[
            headerBuilder!(context),
            const Divider(height: 0),
          ],
          LimitedBox(
            maxHeight: maxHeight ?? height * 0.5,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return optionBuilder(context, option);
              },
            ),
          ),
        ],
      ),
    );
  }
}
