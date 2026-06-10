import 'package:flutter/material.dart';

abstract final class AppMessenger {
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();
}
