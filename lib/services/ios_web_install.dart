// Platform-agnostic entry point. Resolves to the web implementation only
// when compiling for web (dart:html is only available there); every other
// target gets the no-op stub.
export 'ios_web_install_stub.dart'
    if (dart.library.html) 'ios_web_install_web.dart';
