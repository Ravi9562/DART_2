// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:io';

import 'package:example_json/testarbctx2.g.dart';
import 'package:messages/package_intl_object.dart';

Future<void> main(List<String> arguments) async {
  final messages = AboutPageMessages(
    (String id) => File('lib/$id').readAsString(),
    OldIntlObject(),
  );
  // final index = AboutPageMessagesEnum.aboutMessage;

  await messages.loadLocale('en');
  print('AboutMessage en:');
  print('\t${messages.aboutMessage(websitename: 'typesafe.en')}');
  // print('\t${messages.getById('aboutMessage', ['get-by-id.en'])}');
  // print('\t${messages.getByEnum(index, ['get-by-index.en'])}');

  await messages.loadLocale('fr');
  print('AboutMessage fr:');
  print('\t${messages.aboutMessage(websitename: 'typesafe.fr')}');
  // print('\t${messages.getById('aboutMessage', ['get-by-id.fr'])}');
  // print('\t${messages.getByEnum(index, ['get-by-index.fr'])}');
}
