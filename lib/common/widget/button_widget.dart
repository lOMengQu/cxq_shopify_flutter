import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TranButton extends StatelessWidget {
  final Widget child;
  final double radius;
  final VoidCallback onTap;
  const TranButton({super.key, required this.child,  this.radius=16, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: primary),
          borderRadius: BorderRadius.circular(radius.r)
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
class ThemeButton extends StatelessWidget {
  final Widget child;
  final double radius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool enabled;

  const ThemeButton({
    super.key,
    required this.child,
    this.radius = 16,
    this.onTap,
    this.backgroundColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = enabled
        ? (backgroundColor ?? primary)
        : const Color(0xFFEEF1F5);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius.r),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
