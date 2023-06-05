import 'package:hex/hex.dart';
import 'package:logging/logging.dart';
import 'package:collection/collection.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

import '../config/config.dart';
import '../models/rocket_chat/rocket_chat_channel.dart';
import '../services/rocket_chat_service.dart';
import '../utils/utils.dart';

class RocketChatPlatformHandler {
  late final Zenon _zenon;
  final _log = Logger('RocketChatPlatformHandler');

  RocketChatPlatformHandler(this._zenon);

  run() async {
    await RocketChatService()
        .authenticate(Config.rocketChatUsername, Config.rocketChatPassword);
    final chatUsers = await _getChatUsers();
    final allowedUsers = await _getAllowedUsers(chatUsers);
    final channel = await _getChannelInfo();
    if (channel != null) {
      await _kickUnallowedUsersFromChannel(allowedUsers, channel);
      await _addAllowedUsersToChannel(allowedUsers, channel);
    }
  }

  Future<List<dynamic>> _getChatUsers() async {
    final users = (await RocketChatService().getUserList())
        .where((e) =>
            (e['roles'].contains('user') || e['roles'].contains('admin')))
        .toList();
    _log.info('Rocket Chat users: ${users.length}');
    return users;
  }

  Future<List<String>> _getAllowedUsers(chatUsers) async {
    final List<String> ids = [];
    for (final Map<String, dynamic> user in chatUsers) {
      if (!user.containsKey('username')) {
        continue;
      }
      if (user['roles'].contains('admin')) {
        ids.add(user['_id']);
        continue;
      }
      final fields =
          (await RocketChatService().getUserCustomFields(user['_id']));
      if (fields.length == 0) continue;
      if (!(await _isPillarPublicKey(fields['Pillar public key']!))) continue;
      final isValid = await Utils.verifySignature(fields['Message to sign']!,
          fields['Pillar public key']!, fields['Pillar signature']!);
      if (isValid) {
        ids.add(user['_id']);
      }
    }
    _log.info('Allowed users: ${ids.length}');
    return ids;
  }

  Future<bool> _isPillarPublicKey(String publicKey) async {
    try {
      final pillar = await _zenon.embedded.pillar
          .getByOwner(Address.fromPublicKey(HEX.decode(publicKey)));
      return pillar.isNotEmpty;
    } catch (e) {
      _log.info('Public key does not belong to a Pillar: ${publicKey}');
      return false;
    }
  }

  Future<RocketChatChannel?> _getChannelInfo() async {
    final id = await RocketChatService()
        .getGroupId(Config.rocketChatPrivateChannelName);
    if (id.isNotEmpty) {
      final users = await RocketChatService().getGroupUsers(id);
      if (users.isNotEmpty) {
        return RocketChatChannel(id, users);
      }
    }
    return null;
  }

  Future<void> _kickUnallowedUsersFromChannel(
      List<String> allowedUsers, RocketChatChannel channel) async {
    for (final user in channel.users) {
      if (!allowedUsers.contains(user['_id'])) {
        await RocketChatService().kickUserFromGroup(user['_id'], channel.id);
      }
    }
  }

  Future<void> _addAllowedUsersToChannel(
      List<String> allowedUsers, RocketChatChannel channel) async {
    for (final userId in allowedUsers) {
      if (channel.users.firstWhereOrNull((item) => item['_id'] == userId) ==
          null) {
        await RocketChatService().addUserToGroup(userId, channel.id);
      }
    }
  }
}
