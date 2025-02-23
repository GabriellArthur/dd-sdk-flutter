// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2023-Present Datadog, Inc.

import 'package:args/command_runner.dart';
import 'package:ci_helpers/simulator_command.dart';

void main(List<String> arguments) {
  final runner = CommandRunner(
      'ci', 'Helper command line utils for CI of the Datadog Flutter SDK')
    ..addCommand(SimulatorCommand())
    ..run(arguments);
}
