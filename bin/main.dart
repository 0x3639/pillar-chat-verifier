import 'dart:async';

import 'package:logging/logging.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

import 'config/config.dart';
import 'platform_handlers/rocket_chat_platform_handler.dart';
import 'utils/utils.dart';

final _log = Logger('main');

Future main() async {
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  Config.load();

  final zenon = Zenon();
  await zenon.wsClient.initialize(Config.nodeUrlWs);

  _run(RocketChatPlatformHandler(zenon));
}

Future<void> _run(RocketChatPlatformHandler rocketChatHandler) async {
  _log.info('Running Pillar Chat Verifier');
  final startTime = Utils.unixTimeNow;
  await rocketChatHandler.run();
  final elapsed = Duration(seconds: Utils.unixTimeNow - startTime);
  final delay = elapsed < Duration(seconds: 10)
      ? Duration(seconds: 10) - elapsed
      : Duration.zero;
  Future.delayed(delay, () => _run(rocketChatHandler));
}
