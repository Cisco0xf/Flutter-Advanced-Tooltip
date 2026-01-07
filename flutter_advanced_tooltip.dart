import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portfolio/common/app_dimenssions.dart';
import 'package:portfolio/common/commons.dart';
import 'package:portfolio/common/gaps.dart';
import 'package:portfolio/constants/colors.dart';
import 'package:portfolio/constants/enums.dart';
import 'package:portfolio/constants/paths.dart';
import 'package:portfolio/data/models/skill_model.dart';
import 'package:portfolio/presentaition/web/main_web.dart';

const List<SkillModel> testSkills = [
  SkillModel(
    imageUrl: Assets.dart,
    title: 'Dart',
    rate: 0.88,
    about:
        'Core language I use for development. Love its strong typing and clean syntax',
  ),

  // Framework
  SkillModel(
    imageUrl: Assets.flutter,
    title: 'Flutter',
    rate: 0.83,
    color: Color(0xFF44D1FD),
    about:
        "Expert in building beautiful, highly performant applications for mobile and web",
  ),

  SkillModel(
    imageUrl: Assets.riverpod,
    title: 'Riverpod',
    rate: 0.8,
    about: 'Currently my go-to for state management. Clean and type-safe',
  ),

  // State Management
  SkillModel(
    imageUrl: Assets.provider,
    rate: 0.85,
    title: 'Provider',
    color: Color(0xFF0f4c5c),
    about:
        'My first state management solution. Still use it for simpler projects',
  ),

  // Backend & Database
  SkillModel(
    imageUrl: Assets.firebase,
    title: 'Firebase',
    color: Color(0xFFF5820D),
    rate: 0.73,
    about:
        "I use Firebase for backend services in my mobile apps • Firestore & Realtime DB • Cloud Functions",
  ),

  SkillModel(
    imageUrl: Assets.supabase,
    title: 'Supabase',
    rate: 0.7,
    color: Color(0xFF34B27B),
    about:
        'My Firebase alternative when I need PostgreSQL. Love the open-source approach',
  ),

  SkillModel(
    imageUrl: Assets.hive,
    title: 'Hive NoSQL',
    color: Color(0xFF00F7FF),
    rate: 0.9,
    about:
        "My favorite local storage solution for offline-first apps • Type-safe and blazing fast",
  ),
];

class AdvancevToolTip extends StatefulWidget {
  const AdvancevToolTip({super.key});

  @override
  State<AdvancevToolTip> createState() => _AdvancevToolTipState();
}

class _AdvancevToolTipState extends State<AdvancevToolTip> {
  double dx = 0.0;
  double dy = 0.0;

  static const int _dotsCount = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              testSkills.length,
              (index) {
                return SkillItem(skill: testSkills[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SkillItem extends StatefulWidget {
  const SkillItem({
    super.key,
    required this.skill,
  });

  final SkillModel skill;

  @override
  State<SkillItem> createState() => _SkillItemState();
}

class _SkillItemState extends State<SkillItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 20.0).animate(_controller);
    super.initState();
  }

  bool isFocus = false;

  Future<void> _onEnter() async {
    setState(() => isFocus = true);
    await _controller.forward();
  }

  Future<void> _onExit() async {
    setState(() => isFocus = false);
    await _controller.reverse();
  }

  SkillModel get _skill => widget.skill;

  Widget _buildImage() {
    final bool isSvg = _skill.imageUrl.endsWith(".svg");

    if (isSvg) {
      return SvgPicture.network(_skill.imageUrl);
    }

    return Image.network(_skill.imageUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Padding(
          padding: padding(p: 30.0, from: From.horizontal),
          child: CustomToolTip(
            skill: _skill,
            onEnter: () => _onEnter(),
            onExit: () => _onExit(),
            child: Transform.translate(
              offset: Offset(0.0, -_animation.value),
              child: Column(
                children: <Widget>[
                  SizedBox.square(
                    dimension: context.screenHeight * .1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isFocus
                            ? <BoxShadow>[
                                BoxShadow(
                                  blurRadius: _animation.value + 5,
                                  spreadRadius: (_animation.value + 5) / 4,
                                  color:
                                      widget.skill.skillColor.withOpacity(0.6),
                                )
                              ]
                            : null,
                      ),
                      child: _buildImage(),
                    ),
                  ),
                  const Gap(height: 10.0),
                  Text(
                    _skill.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomToolTip extends StatefulWidget {
  const CustomToolTip({
    super.key,
    required this.child,
    required this.onEnter,
    required this.onExit,
    required this.skill,
  });

  final SkillModel skill;
  final Future<void> Function() onEnter;
  final Future<void> Function() onExit;

  final Widget child;

  @override
  State<CustomToolTip> createState() => _CustomToolTipState();
}

class _CustomToolTipState extends State<CustomToolTip> {
  final LayerLink layerLink = LayerLink();
  OverlayEntry? _targetOverlay;

  void _showCustomToolTip() {
    _targetOverlay = _buildOverlay();
    Overlay.of(context).insert(_targetOverlay!);
  }

  void _hideCustomToolTip() {
    _targetOverlay?.remove();
    _targetOverlay = null;
  }

  @override
  void dispose() {
    _hideCustomToolTip();
    super.dispose();
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: context.screenWidth * .26,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: const Offset(30, -200),
            child: MouseRegion(
              onEnter: (_) async {
                await widget.onEnter();

                setState(() => innerFocus = true);
              },
              onExit: (_) {
                setState(() => innerFocus = false);
                _hideCustomToolTip();
              },
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, animation, _) {
                  return Transform.scale(
                    scale: animation,
                    child: Transform.rotate(
                      angle: -(animation * 2 * pi),
                      child: Material(
                        color: Colors.transparent,
                        child: TestBody(skill: widget.skill),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  bool innerFocus = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) async {
        await widget.onEnter();
        if (!innerFocus) {
          _showCustomToolTip();
        }
      },
      onExit: (_) async {
        await widget.onExit();
        _hideCustomToolTip();
      },
      child: GestureDetector(
        onTap: () {
          _showCustomToolTip();
          _hideCustomToolTip();
        },
        onDoubleTap: () {
          _showCustomToolTip();
          _hideCustomToolTip();
        },
        child: CompositedTransformTarget(
          link: layerLink,
          child: widget.child,
        ),
      ),
    );
  }
}

class TestBody extends StatelessWidget {
  const TestBody({super.key, required this.skill});

  final SkillModel skill;

  SkillModel get _skill => skill;

  Widget _buildImage() {
    final bool isSvg = _skill.imageUrl.endsWith(".svg");

    if (isSvg) {
      return SvgPicture.network(_skill.imageUrl);
    }

    return Image.network(_skill.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: _skill.rate),
      curve: Curves.linear,
      builder: (context, animation, _) {
        return ClipRRect(
          borderRadius: borderRadius(10.0),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                padding: padding(),
                decoration: BoxDecoration(
                  borderRadius: borderRadius(10.0),
                  color: _skill.skillColor.withOpacity(0.3),
                  border: Border.all(color: DarkColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 8.0,
                          backgroundColor: _skill.skillColor,
                        ),
                        const Gap(width: 5.0),
                        Text(
                          _skill.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _skill.about!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox.square(
                          dimension: context.screenHeight * .08,
                          child: _buildImage(),
                        ),
                        SizedBox.square(
                          dimension: context.screenHeight * 0.08,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${(animation * 100).toStringAsFixed(0)} %",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: CircularProgressIndicator(
                                  value: animation,
                                  strokeCap: StrokeCap.round,
                                  color: DarkColors.borderColor,
                                  valueColor: AlwaysStoppedAnimation(
                                    _skill.skillColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
