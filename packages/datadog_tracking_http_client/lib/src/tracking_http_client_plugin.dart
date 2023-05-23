// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2019-Present Datadog, Inc.

import 'dart:io';

import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:datadog_flutter_plugin/datadog_internal.dart';

import '../datadog_tracking_http_client.dart';

/// An interface for providing attributes to Datadog RUM resources by listening to HttpClient
/// requests and responses
///
/// DatadogTrackingHttpClient allows you to recieve a callback when an HttpClientRequest starts
/// and when an HttpClientResponse finishes. They provide a mutable Map<String, Object?> of
/// attributes that you can modify to add attributes the the resulting Datadog RUM resource.
///
/// Note, the userAttributes parameter supplied in [requestStarted] and [responseFinished]
/// are the same map, and it is possible to inspect and modify attributes between the two calls.
/// Only the attributes remaining after [responseFinished] is called will be sent to Datadog.
abstract class DatadogTrackingHttpClientListener {
  /// Called when an HttpClientRequest is started.
  void requestStarted({
    HttpClientRequest request,
    Map<String, Object?> userAttributes,
  });

  /// Called when an HttpClientResponse is finished.
  void responseFinished({
    HttpClientResponse response,
    Map<String, Object?> userAttributes,
    Object? error,
  });
}

class DdHttpTrackingPluginConfiguration extends DatadogPluginConfiguration {
  DatadogTrackingHttpClientListener? clientListener;

  DdHttpTrackingPluginConfiguration({this.clientListener});

  @override
  DatadogPlugin create(DatadogSdk datadogInstance) {
    return _DdHttpTrackingPlugin(datadogInstance, this);
  }
}

class _DdHttpTrackingPlugin extends DatadogPlugin {
  final DdHttpTrackingPluginConfiguration configuration;

  _DdHttpTrackingPlugin(
    DatadogSdk datadogInstance,
    this.configuration,
  ) : super(datadogInstance);

  @override
  void initialize() {
    HttpOverrides.global =
        DatadogTrackingHttpOverrides(instance, configuration);
    instance.updateConfigurationInfo(
        LateConfigurationProperty.trackNetworkRequests, true);
  }
}
