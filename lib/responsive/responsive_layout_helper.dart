import 'package:flutter/material.dart';

class ResponsiveLayoutHelper {
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1200.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _tabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletBreakpoint &&
      MediaQuery.of(context).size.width < _desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  static double widthPercent(BuildContext context, double percent) =>
      MediaQuery.of(context).size.width * percent;

  static double heightPercent(BuildContext context, double percent) =>
      MediaQuery.of(context).size.height * percent;

  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static EdgeInsets responsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static int getColumnCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 2;
    }
  }
}
