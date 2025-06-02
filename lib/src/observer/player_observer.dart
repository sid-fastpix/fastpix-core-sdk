mixin PlayerObserver {

  bool isPlayerFullScreen();

  bool isPlayerPaused();

  bool isPlayerAutoPlayOn();

  double playerWidth();

  double playerHeight();

  String playerLanguageCode();

  bool playerPreLoadOn();

  String videoThumbnailUrl();

  String videoSourceUrl();

  String videoSourceMimeType();

  int videoSourceDuration();

  bool isVideoSourceLive();

  double videoSourceHeight();

  double videoSourceWidth();

  Future<int> playerPlayHeadTime();
}
