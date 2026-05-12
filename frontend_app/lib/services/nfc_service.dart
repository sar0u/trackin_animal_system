import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<String?> scanTag() async {
    final available = await isAvailable();

    if (!available) {
      return null;
    }

    final completer = Completer<String?>();

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final id = _extractTagIdentifier(tag);

        await NfcManager.instance.stopSession();

        if (!completer.isCompleted) {
          completer.complete(id);
        }
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () async {
        await NfcManager.instance.stopSession();
        return null;
      },
    );
  }

  String? _extractTagIdentifier(NfcTag tag) {
    final data = tag.data;

    final techs = [
      'nfca',
      'mifareclassic',
      'mifareultralight',
      'ndef',
      'iso7816',
      'isodep',
    ];

    for (final tech in techs) {
      final techData = data[tech];

      if (techData != null && techData['identifier'] != null) {
        final identifier = techData['identifier'];

        if (identifier is List) {
          return identifier
              .map((e) => (e as int).toRadixString(16).padLeft(2, '0'))
              .join()
              .toUpperCase();
        }
      }
    }

    return null;
  }
}