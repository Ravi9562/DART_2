// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'package:intl4x/intl4x.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('NumberFormat options', () {
    var intl = Intl(ecmaPolicy: const AlwaysEcma(), locale: 'en_US');
    testWithFormatting('significantDigits', () {
      var formatter = intl.numberFormat.custom(
        digits: Digits.withSignificantDigits(
          const SignificantDigits(minimum: 1, maximum: 3),
        ),
      );
      expect(formatter.format(3), '3');
      expect(formatter.format(3.1), '3.1');
      expect(formatter.format(3.12), '3.12');
      expect(formatter.format(3.123), '3.12');
    });

    testWithFormatting('fractionDigits', () {
      var formatter = intl.numberFormat.custom(
        minimumIntegerDigits: 3,
        digits: Digits.withFractionDigits(const FractionDigits(minimum: 4)),
      );
      expect(formatter.format(4.33), '004.3300');
    });

    testWithFormatting('percent', () {
      expect(intl.numberFormat.percent().format(4.33), '433%');
    });
  });
}
