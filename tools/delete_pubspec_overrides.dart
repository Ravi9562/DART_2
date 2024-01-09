// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

void main(List<String> arguments) => Directory.current
    .list(recursive: true)
    .where((f) => f.path.endsWith('pubspec_overrides.yaml'))
    .forEach((f) => f.deleteSync());
