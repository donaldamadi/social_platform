import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class CustomLauncher {
  Future<void> launchURL(BuildContext context, String url) async {
    final theme = Theme.of(context);
    try {
      await launch(
        url,
        customTabsOption: CustomTabsOption(
          toolbarColor: theme.primaryColor,
          // enableDefaultShare: true,
          // enableUrlBarHiding: true, s
          showPageTitle: true,
          animation: CustomTabsSystemAnimation.slideIn(),
          extraCustomTabs: const <String>[
            'org.mozilla.firefox',
            'com.microsoft.emmx',
          ],
        ),
        safariVCOption: SafariViewControllerOption(
            preferredBarTintColor: theme.primaryColor,
            preferredControlTintColor: Colors.white,
            barCollapsingEnabled: true,
            entersReaderIfAvailable: false,
            dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
            statusBarBrightness: theme.brightness),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      // debugPrint(e.toString());
    }
  }
}
