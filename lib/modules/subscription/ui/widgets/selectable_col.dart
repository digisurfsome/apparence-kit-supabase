import 'dart:ui';

import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/selectable_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';


class SelectableColGroup<T> extends StatefulWidget {

  final List<SelectableOption<T>> items;

  final OnSelectItem<T> onSelectItem;

  final int initialSelectedIndex;

  // A brightness to adapt the colors of the selectable cols
  // we usually not stick to the theme brightness because
  // paywalls try to sometimes contrast with the app theme so we need to set it manually
  final Brightness brightness;

  const SelectableColGroup({
    super.key,
    required this.items,
    required this.onSelectItem,
    this.initialSelectedIndex = 0,
    required this.brightness,
  });

  @override
  State<SelectableColGroup> createState() => _SelectableColGroupState<T>();
}

class _SelectableColGroupState<T> extends State<SelectableColGroup<T>> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  OnSelectItem<T> get onSelectItem => widget.onSelectItem;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          for (var i = 0; i < widget.items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedIndex == i) {
                      return;
                    }
                    HapticFeedback.heavyImpact();
                    SystemSound.play(SystemSoundType.click);
                    selectedIndex = i;
                    onSelectItem(widget.items[i].data);
                  });
                },
                child: Animate(
                  effects: [
                    FadeEffect(
                      delay: Duration(milliseconds: 100 + 100 * i),
                      duration: const Duration(milliseconds: 500),
                    ),
                  ],
                  child: SelectableCol.fromOption(
                    key: ValueKey('item_$i'),
                    widget.items[i],
                    selected: selectedIndex == i,
                    brightness: widget.brightness,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SelectableCol extends StatefulWidget {
  final bool selected;
  final String label;
  final String price;
  final String sublabel;
  final String? trial;
  final String? promotion;
  final bool disabled;
  final IconData? icon;
  final Brightness? brightness;

  const SelectableCol({
    super.key,
    this.icon,
    required this.selected,
    required this.label,
    required this.price,
    required this.sublabel,
    this.promotion,
    this.disabled = false,
    this.trial,
    this.brightness,
  });

  factory SelectableCol.fromOption(
    SelectableOption option, {
    Key? key,
    required bool selected,
    required Brightness brightness,
  }) {
    return SelectableCol(
      key: key,
      selected: selected,
      label: option.label,
      price: option.price,
      sublabel: option.sublabel,
      trial: option.trial,
      promotion: option.promotion,
      icon: option.icon,
      brightness: brightness,
    );
  }

  @override
  State<SelectableCol> createState() => _SelectableColState();
}

class _SelectableColState extends State<SelectableCol>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void didUpdateWidget(covariant SelectableCol oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected && widget.selected) {
      _controller.forward();
    } else if (oldWidget.selected != widget.selected && !widget.selected) {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => SizedBox(
        height: 150,
        child: Opacity(
          opacity: widget.disabled ? .6 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: widget.selected
                        ? context.colors.primary
                            .withValues(alpha: _opacityAnimation.value)
                        : context.colors.primary
                            .withValues(alpha: .3 * _opacityAnimation.value + .15),
                  ),
                ),
                // padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    if (widget.promotion != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            widget.promotion!.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: context.kitTheme.defaultTextTheme.primary.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: switch(widget.brightness) {
                                _ => Colors.white,
                              },
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    if(widget.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Icon(
                          widget.icon, 
                          size: 24, 
                          color: switch(widget.brightness) {
                            Brightness.light => context.colors.onBackground,
                            _ => context.colors.background,
                          },
                        ),
                      ),
                    Flexible(
                      flex: 0,
                      child: Text(
                        widget.label.toUpperCase(),
                        style: context
                            .kitTheme.defaultTextTheme.primary
                            .copyWith(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: switch(widget.brightness) {
                            Brightness.light => context.colors.onBackground,
                            _ => context.colors.background,
                          },
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.price,
                      style: context
                          .kitTheme.defaultTextTheme.primary
                          .copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: switch(widget.brightness) {
                          Brightness.light => context.colors.onBackground,
                          _ => context.colors.background,
                        },
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    if(widget.sublabel.isNotEmpty)
                      Text(
                        widget.sublabel,
                        style: context
                            .kitTheme.defaultTextTheme.primary
                            .copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: switch(widget.brightness) {
                            Brightness.light => context.colors.onBackground.withValues(alpha: .7),
                            _ => context.colors.background,
                          },
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    const Spacer(),
                    if (widget.trial != null)
                      Flexible(
                        flex: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            widget.trial!,
                            textAlign: TextAlign.center,
                            style: context.kitTheme.defaultTextTheme.primary
                                .copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: switch(widget.brightness) {
                                _ => context.colors.background,
                              },
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoundRadioBox extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData? icon;
  final double iconOpacity;
  final double iconSize;

  const RoundRadioBox({
    super.key,
    required this.bgColor,
    required this.borderColor,
    this.iconOpacity = 1,
    this.iconSize = 1,
    this.icon,
  });

  factory RoundRadioBox.selected(
    BuildContext context, {
    double iconOpacity = 1,
    double iconSize = 1,
  }) {
    return RoundRadioBox(
      bgColor: Theme.of(context).colorScheme.primary,
      borderColor: Colors.black.withValues(alpha: .3),
      icon: Icons.check,
      iconOpacity: iconOpacity,
      iconSize: iconSize,
    );
  }

  // ignore: avoid_unused_constructor_parameters
  factory RoundRadioBox.unselected(BuildContext context) {
    return RoundRadioBox(
      bgColor: const Color(0xFFD9D9D9).withValues(alpha: .6),
      borderColor: Colors.black.withValues(alpha: .3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: icon != null
            ? Opacity(
                opacity: iconOpacity,
                child: Transform.scale(
                  scale: iconSize,
                  child: Icon(icon, color: Colors.white, size: 21),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
