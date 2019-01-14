import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:next_day/constant/api.dart';

enum HttpMethod { GET, POST, PUT, DELETE, PATCH, HEAD }

class HttpService {
  final ValueChanged<dynamic> onSuccess;
  final ValueChanged<int> onError;
  final ValueChanged<bool> onComplete;
  final HttpMethod method;

  Uri _uri;

  HttpService(
      {String scheme = API_SCHEME,
      String host = API_HOST,
      @required String path,
      this.method = HttpMethod.GET,
      String query,
      Map<String, dynamic /*String|Iterable<String>*/ > queryParameters,
      this.onSuccess,
      this.onError,
      this.onComplete,
      bool autoStart = true})
      : assert(path != null) {
    _uri = new Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: queryParameters);
    if (autoStart) {
      start();
    }
  }

  start() async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request;
    switch (method) {
      case HttpMethod.GET:
        request = await httpClient.getUrl(_uri);
        break;
      case HttpMethod.POST:
        request = await httpClient.postUrl(_uri);
        break;
      case HttpMethod.PUT:
        request = await httpClient.putUrl(_uri);
        break;
      case HttpMethod.DELETE:
        request = await httpClient.deleteUrl(_uri);
        break;
      case HttpMethod.PATCH:
        request = await httpClient.patchUrl(_uri);
        break;
      case HttpMethod.HEAD:
        request = await httpClient.headUrl(_uri);
        break;
      default:
        request = await httpClient.getUrl(_uri);
    }
    HttpClientResponse response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      var responseJson = await response.transform(utf8.decoder).join();
      var data = json.decode(responseJson);
      if (onSuccess != null) {
        onSuccess(data);
      }
    } else {
      if (onError != null) {
        onError(response.statusCode);
      }
    }
    if (onComplete != null) {
      onComplete(response.statusCode == HttpStatus.ok);
    }
  }
}
