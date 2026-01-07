# Advanced Tooltip with `CompositedTransform` (Web)

**A performant, fully customizable tooltip system for Flutter using the compositing layer. Perfect for portfolios, dashboards, and complex UIs requiring sophisticated hover interactions.**


## Why This Exists
I was working on a Flutter web project and needed a tooltip that follows its target widget precisely. I had three options:

### - `showMenu()`

- Position detected by parent `BuildContext` with the `Offset` of the `RenderObject`
- No `show()` / `hide()` control
- Limited flexibility

### - `Tooltip`

- Great for simple use cases
- But only supports text or InlineSpan
- Can't build rich, complex content

### - `OverlayPortal`

- Has `show()` / `hide()` methods ✓
- But still needs `BuildContext` for positioning
- Manual position calculations required as the `showMenu()`

### - **My Solution**
After research, I discovered the perfect combo:

- `CompositedTransformTarget`
- `LayerLink`
- `CompositedTransformFollower`

These give you precise positioning relative to any widget without BuildContext constraints. This is the result.


## GIF Image
![Eample1_GIF](https://github.com/Cisco0xf/Flutter-Advanced-Tooltip/blob/main/assets/0106.gif)


## Features
- **Smooth Animations** - Buttery 60fps hover effects with custom curves
- **Glassmorphic Design** - Backdrop blur with customizable colors
- **Precise Positioning** - Follows any widget without constraints
- **Rich Content** - Support for complex layouts, images, and progress indicators
- **Performance** - Uses compositing layers for optimal rendering
- **Fully Customizable** - Every aspect can be styled to match your design

## Widget Code:

```dart

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
```

-----------------------

## About the `CompositedTransformTarget` | `CompositedTransformFollower` | `LayerLink`

- Both the **`CompositedTransformTarget`** | **`CompositedTransformFollower`** are coming from the [widgets library](https://api.flutter.dev/flutter/widgets/) the **`LinkLayer`** class is coming from [rendering liberry](https://api.flutter.dev/flutter/rendering/)

- These components are commonly used together to create effects where one widget (the follower) positions itself relative to another (the target) in the widget tree, **even if they are not direct parent-child relationships**. This is achieved through *compositing layers* during the *rendering process*.

- The **`LayerLink`** acts as the connector between a target and one or more followers. The target must appear earlier in the paint order than the followers for the positioning to work correctly.

____________

### 1. [`LayerLink`](https://api.flutter.dev/flutter/rendering/LayerLink-class.html) (from *rendering* library)

- An object that a [LeaderLayer](https://api.flutter.dev/flutter/rendering/LeaderLayer-class.html) can register with.
- An instance of this class should be provided as the `LeaderLayer.link` and the `FollowerLayer.link` properties to cause the `FollowerLayer` to follow the `LeaderLayer` and this is how **widget is not direct parent-child relationships positions itself relative to another**.

### 2. [`CompositedTransformTarget`](https://api.flutter.dev/flutter/widgets/CompositedTransformTarget-class.html) (from *widgets* library)

- A widget that can be targeted by a `CompositedTransformFollower`.
- When this widget is composited during the compositing phase (**which comes after the paint phase**, as described in [`WidgetsBinding.drawFrame(Please Read this)`](https://api.flutter.dev/flutter/widgets/WidgetsBinding/drawFrame.html) ), it updates the link object so that any `CompositedTransformFollower` widgets that are subsequently composited in the same frame and were given the same LayerLink can position themselves at the same screen location.


> [!NOTE]
> **A single [`CompositedTransformTarget`](https://api.flutter.dev/flutter/widgets/CompositedTransformFollower-class.html) can be followed by multiple `CompositedTransformFollower` widgets.**
> The `CompositedTransformTarget` must come earlier in the paint order than any linked `CompositedTransformFollower`s.

### 3. `CompositedTransformFollower` (from *widgets* library)

- A widget that follows a `CompositedTransformTarget`.
- When this widget is composited during the compositing phase (which comes after the paint phase, as described in `WidgetsBinding.drawFrame`), it applies a transformation that brings targetAnchor of the linked `CompositedTransformTarget` and followerAnchor of this widget together.
- The two anchor points will have the same global coordinates, unless offset is not `Offset.zero`, in which case followerAnchor will be offset by offset in the linked `CompositedTransformTarget`'s coordinate space.

  
> [!NOTE]
> The LayerLink object used as the link must be the same object as that provided to the matching CompositedTransformTarget.
> The CompositedTransformTarget must come earlier in the paint order than this CompositedTransformFollower.

- Hit testing on descendants of this widget **will only work if the target position is within the box** that this widget's parent considers to be hittable. If the parent covers the screen, this is trivially achievable, so this widget is usually used as the root of an **`OverlayEntry`** in an app-wide **`Overlay`** (e.g. as created by the MaterialApp widget's Navigator).


> [!IMPORTANT]
> The Controller of the **show** and **hide** is th `OverlayEntry` Widget and the **link** bwtween these two widgets is `LayerLink`.

**You can see this in this method in the code above:**

 ```dart
 
  void _showCustomToolTip() {
    _targetOverlay = _buildOverlay();
    Overlay.of(context).insert(_targetOverlay!);
  }

  void _hideCustomToolTip() {
    _targetOverlay?.remove();
    _targetOverlay = null;
  }

```

## License
**MIT © Mahmoud Nagy**
