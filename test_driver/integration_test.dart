import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (nome, bytes, [argumentos]) async {
      final arquivo = File('screenshots/$nome.png');
      await arquivo.parent.create(recursive: true);
      await arquivo.writeAsBytes(bytes);
      return true;
    },
    writeResponseOnFailure: true,
    responseDataCallback: (dados) async {
      final arquivo = File('.tools/conta_teste.json');
      await arquivo.parent.create(recursive: true);
      await arquivo.writeAsString(
        jsonEncode({'email': dados?['email'], 'uid': dados?['uid']}),
      );
    },
  );
}
