// Generated by package:messages_builder.

import 'package:intl4x/intl4x.dart';
import 'package:messages/messages_json.dart';

class AboutPageMessages {
  AboutPageMessages(this._fileLoader);

  final Future<String> Function(String id) _fileLoader;

  String _currentLocale = 'en';

  final Map<String, MessageList> _messages = {};

  static const _dataFiles = {
    'fr': ('lib/testarbctx2_fr.json', 'EyPjEJJU'),
    'en': ('lib/testarbctx2.json', 'QrwRSsOy')
  };

  String get currentLocale => _currentLocale;

  MessageList get _currentMessages => _messages[currentLocale]!;

  static Iterable<String> get knownLocales => _dataFiles.keys;

  Future<void> loadLocale(String locale) async {
    if (!_messages.containsKey(locale)) {
      final info = _dataFiles[locale];
      final carb = info?.$1;
      if (carb == null) {
        throw ArgumentError('Locale $locale is not in $knownLocales');
      }
      final data = await _fileLoader(carb);
      final messageList = MessageListJson.fromString(data, pluralSelector);
      if (messageList.preamble.hash != info?.$2) {
        throw ArgumentError('''
              Messages file for locale $locale has different hash "${messageList.preamble.hash}" than generated code "${info?.$2}".''');
      }
      _messages[locale] = messageList;
    }
    _currentLocale = locale;
  }

  void loadAllLocales() {
    for (final locale in knownLocales) {
      loadLocale(locale);
    }
  }

  Message pluralSelector(
    num howMany, {
    required Message other,
    Message? few,
    Message? many,
    Map<int, Message>? numberCases,
    Map<int, Message>? wordCases,
  }) {
    Message getCase(int i) => numberCases?[i] ?? wordCases?[i] ?? other;
    return switch (
        Intl(locale: Locale.parse(currentLocale)).plural().select(howMany)) {
      PluralCategory.zero => getCase(0),
      PluralCategory.one => getCase(1),
      PluralCategory.two => getCase(2),
      PluralCategory.few => few ?? other,
      PluralCategory.many => many ?? other,
      PluralCategory.other => other,
    };
  }

  String aboutMessage(String websitename) =>
      _currentMessages.generateStringAtIndex(0, [websitename]);

  String helloAndWelcome(
    String firstName,
    int lastName,
  ) =>
      _currentMessages.generateStringAtIndex(1, [firstName, lastName]);

  String newMessages(int newMessages) =>
      _currentMessages.generateStringAtIndex(2, [newMessages]);

  String newMessages2(
    String gender,
    int newVar,
  ) =>
      _currentMessages.generateStringAtIndex(3, [gender, newVar]);

  String get otherMsg => _currentMessages.generateStringAtIndex(4, []);
}
