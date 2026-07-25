// Web only (compiled in via a conditional export, see ios_web_install.dart):
// detects "running in Safari on iOS/iPadOS, not yet installed to the home
// screen" — the case where we can usefully guide the user to
// Share -> Add to Home Screen. dart:html is soft-deprecated in favor of
// package:web/js_interop, but remains fully functional and is simplest here.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

bool shouldOfferIosInstall() {
  final dynamic nav = html.window.navigator;
  final String ua = (nav.userAgent as String?) ?? '';
  final String platform = (nav.platform as String?) ?? '';
  final int maxTouchPoints = (nav.maxTouchPoints as num?)?.toInt() ?? 0;
  // iOS Safari exposes this non-standard property once the page is running
  // as an installed home-screen app.
  final bool standalone = (nav.standalone as bool?) ?? false;

  final isIOS = RegExp(r'iPhone|iPad|iPod').hasMatch(ua);
  // iPadOS 13+ reports as "Mac" in the user agent but has touch support.
  final isIPadOS = platform == 'MacIntel' && maxTouchPoints > 1;
  final isSafari = ua.contains('Safari') && !RegExp(r'CriOS|FxiOS|EdgiOS').hasMatch(ua);
  final dismissed = html.window.sessionStorage['ios_install_dismissed'] == '1';

  return (isIOS || isIPadOS) && isSafari && !standalone && !dismissed;
}

void dismissIosInstallForSession() {
  html.window.sessionStorage['ios_install_dismissed'] = '1';
}
