// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_builder/code_builder.dart';
import 'package:messages/messages.dart';
import 'package:messages/package_intl_object.dart';

import '../generation_options.dart';
import '../message_with_metadata.dart';
import 'generation.dart';

class MethodGeneration extends Generation<Method> {
  final GenerationOptions options;
  final String? context;
  final MessageListWithMetadata messageList;
  final Map<String, String> resourceToHash;

  MethodGeneration(
    this.options,
    this.context,
    this.messageList,
    this.resourceToHash,
  );

  Method generateMessageCall(int index, MessageWithMetadata message) {
    final arguments =
        message.placeholders.map((placeholder) => placeholder.name).join(', ');

    final index = '${enumName(messageList.context)}.${message.name}.index';
    final body = '_currentMessages.generateStringAtIndex($index, [$arguments])';
    return Method(
      (mb) => mb
        ..name = message.name
        ..lambda = true
        ..returns = const Reference('String')
        ..optionalParameters
            .addAll(message.placeholders.map((placeholder) => Parameter(
                  (pb) => pb
                    ..type = Reference(placeholder.type)
                    ..name = placeholder.name
                    ..named = true
                    ..required = true,
                )))
        ..body = Code(body),
    );
  }

  Method generateInlinedMessageCall(int index, MessageWithMetadata message) {
    final placeholders =
        message.placeholders.map((placeholder) => placeholder.name);
    final arguments = placeholders.join(', ');

    final msg = message.message;
    String body;
    if (msg is StringMessage) {
      body = msg.generateString(
        placeholders.map((e) => '\$$e').toList(),
        intl: OldIntlObject(),
      );
    } else if (msg is CombinedMessage) {
    } else if (msg is PluralMessage) {
    } else if (msg is SelectMessage) {
    } else if (msg is GenderMessage) {
    } else {
      throw ArgumentError();
    }
    body =
        '''_currentMessages.generateStringAtIndex(${indicesName(messageList.context)}.${message.name}, [$arguments])''';
    return Method(
      (mb) => mb
        ..name = message.name
        ..lambda = true
        ..returns = const Reference('String')
        ..requiredParameters
            .addAll(message.placeholders.map((placeholder) => Parameter(
                  (pb) => pb
                    ..type = Reference(placeholder.type)
                    ..name = placeholder.name,
                )))
        ..body = Code(body),
    );
  }

  @override
  List<Method> generate() {
    final messages = messageList.messages;
    List<Method> messageCalls;
    if (options.messageCalls) {
      messageCalls = List.generate(messages.length, (i) {
        return generateMessageCall(i, messages[i]);
      });
    } else {
      messageCalls = [];
    }
    final awaitModifier = options.makeAsync ? 'await' : '';
    final loadLocale = Method(
      (mb) {
        final loading = switch (options.deserialization) {
          DeserializationType.web => '''
          final data = $awaitModifier _fileLoader(carb);
          final messageList = MessageListJson.fromString(data, intlObject);''',
        };
        mb
          ..name = 'loadLocale'
          ..requiredParameters.add(Parameter(
            (p0) => p0
              ..name = 'locale'
              ..type = const Reference('String'),
          ))
          ..body = Code('''
          if (!_messages.containsKey(locale)) {
            final carb = _carbs[locale];
            if (carb == null) {
              throw ArgumentError('Locale \$locale is not in \$knownLocales');
            }
            $loading
            if (messageList.preamble.hash != _messageListHashes[carb]) {
              throw ArgumentError(\'\'\'
              Messages file has different hash "\${messageList.preamble.hash}" than generated code "\${_messageListHashes[carb]}".\'\'\');
            }
            _messages[locale] = messageList;
          }
          _currentLocale = locale;
      ''')
          ..returns = getAsyncReference('void', options);

        if (options.makeAsync) {
          mb.modifier = MethodModifier.async;
        }
      },
    );
    final loadAllLocales = Method(
      (mb) {
        mb
          ..name = 'loadAllLocales'
          ..returns = getAsyncReference('void', options)
          ..body = Code('''
          for (var locale in knownLocales) {
            $awaitModifier loadLocale(locale);
          }
      ''');
        if (options.makeAsync) {
          mb.modifier = MethodModifier.async;
        }
      },
    );
    final getKnownLocales = Method(
      (mb) => mb
        ..name = 'knownLocales'
        ..type = MethodType.getter
        ..lambda = true
        ..body = const Code('_carbs.keys')
        ..returns = const Reference('Iterable<String>'),
    );
    final getCurrentMessages = Method(
      (mb) => mb
        ..name = '_currentMessages'
        ..type = MethodType.getter
        ..lambda = true
        ..body = const Code('_messages[currentLocale]!')
        ..returns = const Reference('MessageList'),
    );
    final getCurrentLocale = Method(
      (mb) => mb
        ..name = 'currentLocale'
        ..type = MethodType.getter
        ..lambda = true
        ..body = const Code('_currentLocale')
        ..returns = const Reference('String'),
    );
    final setCurrentLocale = Method(
      (p0) => p0
        ..name = 'currentLocale'
        ..type = MethodType.setter
        ..requiredParameters.add(Parameter(
          (p0) => p0
            ..name = 'locale'
            ..type = const Reference('String'),
        ))
        ..body = const Code('''
    if (_currentLocale != locale) {
      loadLocale(locale);
    }'''),
    );
    final getMessagebyId = Method((mb) => mb
      ..name = 'getById'
      ..requiredParameters.addAll([
        Parameter(
          (pb) => pb
            ..name = 'id'
            ..type = const Reference('String'),
        )
      ])
      ..optionalParameters.add(Parameter(
        (pb) => pb
          ..name = 'args'
          ..type = const Reference('List<dynamic>')
          ..defaultTo = const Code('const []'),
      ))
      ..body = Code(
          '''return _currentMessages.generateStringAtId(id, ${options.useCleaner ? 'args, cleaner' : 'args'});''')
      ..returns = const Reference('String'));
    final findByIndex = Method((mb) => mb
      ..name = 'getByIndex'
      ..annotations
          .add(const CodeExpression(Code("pragma('dart2js:noInline')")))
      ..requiredParameters.add(Parameter(
        (pb) => pb
          ..name = 'index'
          ..type = const Reference('int'),
      ))
      ..optionalParameters.add(Parameter(
        (pb) => pb
          ..name = 'args'
          ..type = const Reference('List<dynamic>')
          ..defaultTo = const Code('const []'),
      ))
      ..body = const Code('_currentMessages.generateStringAtIndex(index, args)')
      ..lambda = true
      ..returns = const Reference('String'));
    final findByEnum = Method((mb) => mb
      ..name = 'getByEnum'
      ..annotations
          .add(const CodeExpression(Code("pragma('dart2js:noInline')")))
      ..requiredParameters.add(Parameter(
        (pb) => pb
          ..name = 'val'
          ..type = Reference(enumName(context)),
      ))
      ..optionalParameters.add(Parameter(
        (pb) => pb
          ..name = 'args'
          ..type = const Reference('List<dynamic>')
          ..defaultTo = const Code('const []'),
      ))
      ..body =
          const Code('_currentMessages.generateStringAtIndex(val.index, args)')
      ..lambda = true
      ..returns = const Reference('String'));

    return [
      getCurrentLocale,
      getCurrentMessages,
      if (!options.makeAsync) setCurrentLocale,
      if (options.findById) getMessagebyId,
      if (options.findByType == IndexType.enumerate) findByEnum,
      if (options.findByType == IndexType.integer) findByIndex,
      getKnownLocales,
      loadLocale,
      loadAllLocales,
      ...messageCalls,
    ];
  }
}
