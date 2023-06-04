import 'dart:io';

import 'package:settings_yaml/settings_yaml.dart';

class Config {
  static String _nodeUrlWs = '';
  static String _rocketChatUrl = '';
  static String _rocketChatUsername = '';
  static String _rocketChatPassword = '';
  static String _rocketChatPrivateChannelName = '';

  static String get nodeUrlWs {
    return _nodeUrlWs;
  }

  static String get rocketChatUrl {
    return _rocketChatUrl;
  }

  static String get rocketChatUsername {
    return _rocketChatUsername;
  }

  static String get rocketChatPassword {
    return _rocketChatPassword;
  }

  static String get rocketChatPrivateChannelName {
    return _rocketChatPrivateChannelName;
  }

  static void load() {
    final settings = SettingsYaml.load(
        pathToSettings: '${Directory.current.path}/config.yaml');

    _nodeUrlWs = settings['node_url_ws'] as String;
    _rocketChatUrl = settings['rocket_chat_url'] as String;
    _rocketChatUsername = settings['rocket_chat_username'] as String;
    _rocketChatPassword = settings['rocket_chat_password'] as String;
    _rocketChatPrivateChannelName =
        settings['rocket_chat_private_channel_name'] as String;
  }
}
