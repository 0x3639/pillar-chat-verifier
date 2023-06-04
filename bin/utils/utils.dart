import 'dart:convert';

import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class Utils {
  static String toJson(dynamic values) {
    return JsonEncoder.withIndent(' ').convert(values);
  }

  static Future<bool> verifySignature(
      String message, String pubKey, String signature) async {
    final decodedMsg = HEX.decode(HEX.encode(Utf8Encoder().convert(message)));
    final decodedPubKey = HEX.decode(pubKey);
    final decodedSignature = HEX.decode(signature);
    return (await Crypto.verify(decodedSignature, decodedMsg, decodedPubKey));
  }

  static int get unixTimeNow =>
      (DateTime.now().millisecondsSinceEpoch / 1000).round();
}
