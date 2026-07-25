// Non-web platforms (Android, iOS, desktop): the install card only makes
// sense on the web build, so this always returns false there.
bool shouldOfferIosInstall() => false;
void dismissIosInstallForSession() {}
