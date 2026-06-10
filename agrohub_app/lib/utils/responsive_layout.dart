class ResponsiveLayout {
  static bool isCompact(double screenWidth) => screenWidth < 520;

  static double contentMaxWidth(
    double screenWidth, {
    double mobile = 400,
    double tablet = 620,
    double desktop = 820,
  }) {
    if (screenWidth >= 1200) {
      return desktop;
    }

    if (screenWidth >= 700) {
      return tablet;
    }

    return mobile;
  }

  static double pageHorizontalPadding(double screenWidth) {
    if (screenWidth >= 1200) {
      return 48;
    }

    if (screenWidth >= 700) {
      return 32;
    }

    return 24;
  }

  static double homeMaxWidth(double screenWidth) {
    if (screenWidth >= 1200) {
      return 1120;
    }

    if (screenWidth >= 800) {
      return 960;
    }

    return screenWidth;
  }

  static double summaryCardWidth(double screenWidth) {
    if (screenWidth >= 1200) {
      return 220;
    }

    if (screenWidth >= 800) {
      return 200;
    }

    return 150;
  }

  static double listImageWidth(double screenWidth) {
    if (screenWidth >= 1200) {
      return 96;
    }

    if (screenWidth >= 700) {
      return 88;
    }

    return 72;
  }

  static double listImageHeight(double screenWidth) {
    if (screenWidth >= 1200) {
      return 84;
    }

    if (screenWidth >= 700) {
      return 76;
    }

    return 68;
  }
}
