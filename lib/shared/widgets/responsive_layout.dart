
import 'package:flutter/material.dart';

/// Screen sizes for responsive design
enum ScreenSize {
  /// Small screens (phones)
  small,
  
  /// Medium screens (large phones, small tablets)
  medium,
  
  /// Large screens (tablets)
  large,
  
  /// Extra large screens (desktops)
  extraLarge,
}

/// Widget for implementing responsive layouts
class ResponsiveLayout extends StatelessWidget {
  /// Builder for small screens
  final Widget Function(BuildContext) small;
  
  /// Builder for medium screens
  final Widget Function(BuildContext)? medium;
  
  /// Builder for large screens
  final Widget Function(BuildContext)? large;
  
  /// Builder for extra large screens
  final Widget Function(BuildContext)? extraLarge;
  
  /// Breakpoint for small screens (phones)
  static const double smallBreakpoint = 600;
  
  /// Breakpoint for medium screens (large phones, small tablets)
  static const double mediumBreakpoint = 900;
  
  /// Breakpoint for large screens (tablets)
  static const double largeBreakpoint = 1200;
  
  /// Creates a ResponsiveLayout widget
  const ResponsiveLayout({
    Key? key,
    required this.small,
    this.medium,
    this.large,
    this.extraLarge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        // Determine screen size based on width
        if (screenWidth >= largeBreakpoint && extraLarge != null) {
          return extraLarge!(context);
        } else if (screenWidth >= mediumBreakpoint && large != null) {
          return large!(context);
        } else if (screenWidth >= smallBreakpoint && medium != null) {
          return medium!(context);
        } else {
          return small(context);
        }
      },
    );
  }
  
  /// Returns the current screen size based on the context
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= largeBreakpoint) {
      return ScreenSize.extraLarge;
    } else if (width >= mediumBreakpoint) {
      return ScreenSize.large;
    } else if (width >= smallBreakpoint) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.small;
    }
  }
  
  /// Returns true if the current screen size is small
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }
  
  /// Returns true if the current screen size is medium
  static bool isMediumScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.medium;
  }
  
  /// Returns true if the current screen size is large
  static bool isLargeScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.large;
  }
  
  /// Returns true if the current screen size is extra large
  static bool isExtraLargeScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.extraLarge;
  }
  
  /// Returns true if the current screen is a mobile device
  static bool isMobile(BuildContext context) {
    return isSmallScreen(context) || isMediumScreen(context);
  }
  
  /// Returns true if the current screen is a tablet or desktop
  static bool isDesktop(BuildContext context) {
    return isLargeScreen(context) || isExtraLargeScreen(context);
  }
}
