// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2016-Present Datadog, Inc.

import 'dart:async';

import 'package:datadog_sdk/src/rum/ddrum.dart';
import 'package:datadog_sdk/src/rum/ddrum_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockType {
  final int value;

  MockType(this.value);

  @override
  String toString() {
    return 'MockType($value)';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DdRumMethodChannel ddRumPlatform;
  final List<MethodCall> log = [];

  setUp(() {
    ddRumPlatform = DdRumMethodChannel();
    ddRumPlatform.methodChannel.setMockMethodCallHandler((call) async {
      log.add(call);
      return null;
    });
  });

  tearDown(() {
    log.clear();
  });

  test('startView calls to platform', () async {
    await ddRumPlatform.startView('my_key', 'my_name', {'attribute': 'value'});

    expect(log, [
      isMethodCall('startView', arguments: {
        'key': 'my_key',
        'name': 'my_name',
        'attributes': {'attribute': 'value'}
      })
    ]);
  });

  test('stopView calls to platform', () async {
    await ddRumPlatform.stopView('my_key', {'stop_attribute': 'my_value'});

    expect(log, [
      isMethodCall('stopView', arguments: {
        'key': 'my_key',
        'attributes': {'stop_attribute': 'my_value'}
      })
    ]);
  });

  test('addTiming calls to platform', () async {
    await ddRumPlatform.addTiming('my timing name');

    expect(log, [
      isMethodCall('addTiming', arguments: {'name': 'my timing name'})
    ]);
  });

  test('startResourceLoading calls to platform', () async {
    await ddRumPlatform.startResourceLoading('resource_key', RumHttpMethod.get,
        'https://fakeresource.com/url', {'attribute_key': 'attribute_value'});

    expect(log, [
      isMethodCall('startResourceLoading', arguments: {
        'key': 'resource_key',
        'httpMethod': 'RumHttpMethod.get',
        'url': 'https://fakeresource.com/url',
        'attributes': {'attribute_key': 'attribute_value'}
      })
    ]);
  });

  test('stopResourceLoading calls to platform', () async {
    await ddRumPlatform.stopResourceLoading('resource_key', 202,
        RumResourceType.image, 41123, {'attribute_key': 'attribute_value'});

    expect(log, [
      isMethodCall('stopResourceLoading', arguments: {
        'key': 'resource_key',
        'statusCode': 202,
        'kind': 'RumResourceType.image',
        'size': 41123,
        'attributes': {'attribute_key': 'attribute_value'}
      })
    ]);
  });

  test('stopResourceLoadingWithError calls to platform with info', () async {
    final exception = TimeoutException(
        'Timeout retrieving resource', const Duration(seconds: 5));
    await ddRumPlatform.stopResourceLoadingWithError(
        'resource_key', exception, {'attribute_key': 'attribute_value'});

    expect(log, [
      isMethodCall('stopResourceLoadingWithError', arguments: {
        'key': 'resource_key',
        'message': exception.toString(),
        'attributes': {'attribute_key': 'attribute_value'}
      })
    ]);
  });

  test('stopResourceLoadingWithErrorInfo calls to platform', () async {
    await ddRumPlatform.stopResourceLoadingWithErrorInfo('resource_key',
        'Exception message', {'attribute_key': 'attribute_value'});

    expect(log, [
      isMethodCall('stopResourceLoadingWithError', arguments: {
        'key': 'resource_key',
        'message': 'Exception message',
        'attributes': {'attribute_key': 'attribute_value'}
      })
    ]);
  });

  test('addError calls to platform with info', () async {
    final exception = TimeoutException(
        'Timeout retrieving resource', const Duration(seconds: 5));
    await ddRumPlatform.addError(exception, RumErrorSource.source, null,
        {'attribute_key': 'attribute_value'});

    expect(log.length, 1);
    final call = log.first;
    expect(call.method, 'addError');
    expect(call.arguments['message'], exception.toString());
    expect(call.arguments['source'], 'RumErrorSource.source');
    expect(call.arguments['stackTrace'], isNotNull);
    expect(call.arguments['attributes'], {
      // '_dd.error.source_type': 'flutter'
      'attribute_key': 'attribute_value'
    });
  });

  test('addErrorInfo calls to platform with info', () async {
    await ddRumPlatform.addErrorInfo('Exception message', RumErrorSource.source,
        null, {'attribute_key': 'attribute_value'});

    expect(log.length, 1);
    final call = log.first;
    expect(call.method, 'addError');
    expect(call.arguments['message'], 'Exception message');
    expect(call.arguments['source'], 'RumErrorSource.source');
    expect(call.arguments['stackTrace'], isNotNull);
    expect(call.arguments['attributes'], {
      // '_dd.error.source_type': 'flutter'
      'attribute_key': 'attribute_value'
    });
  });

  test('addUserAction calls to platform', () async {
    await ddRumPlatform
        .addUserAction(RumUserActionType.tap, 'fake_user_action', {
      'attribute_name': 'attribute_value',
    });

    expect(log, [
      isMethodCall('addUserAction', arguments: {
        'type': 'RumUserActionType.tap',
        'name': 'fake_user_action',
        'attributes': {'attribute_name': 'attribute_value'}
      })
    ]);
  });

  test('startUserAction calls to platform', () async {
    await ddRumPlatform.startUserAction(RumUserActionType.scroll,
        'user_action_scroll', {'attribute_name': 'attribute_value'});

    expect(log, [
      isMethodCall('startUserAction', arguments: {
        'type': 'RumUserActionType.scroll',
        'name': 'user_action_scroll',
        'attributes': {'attribute_name': 'attribute_value'}
      })
    ]);
  });

  test('stopUserAction calls to platform', () async {
    await ddRumPlatform.stopUserAction(RumUserActionType.swipe,
        'user_action_swipe', {'attribute_name': 'attribute_value'});

    expect(log, [
      isMethodCall('stopUserAction', arguments: {
        'type': 'RumUserActionType.swipe',
        'name': 'user_action_swipe',
        'attributes': {'attribute_name': 'attribute_value'}
      })
    ]);
  });

  test('addAttribute calls to platform', () async {
    await ddRumPlatform.addAttribute('attribute_key', 'my attribute value');

    expect(log, [
      isMethodCall('addAttribute',
          arguments: {'key': 'attribute_key', 'value': 'my attribute value'})
    ]);
  });

  test('removeAttribute calls to platform', () async {
    await ddRumPlatform.removeAttribute('attribute_key');

    expect(log, [
      isMethodCall('removeAttribute', arguments: {'key': 'attribute_key'})
    ]);
  });
}
