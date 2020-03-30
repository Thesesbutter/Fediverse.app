
import 'dart:io';

import 'package:fedi/Pleroma/Foundation/Client.dart';
import 'package:flutter/widgets.dart';

class RestRequest {
  final HTTPMethod type;

  final String relativeUrlPath;

  List<RestRequestQueryArg> queryArgs;
  Map<String, dynamic> bodyJson;
  Map<String, String> headers;

  RestRequest._private(
      {@required this.type,
        @required this.relativeUrlPath,
        @required this.queryArgs,
        @required this.bodyJson,
        @required this.headers}) {
    queryArgs = queryArgs ?? [];
    bodyJson = bodyJson ?? {};
    headers = headers ?? {};
  }

  RestRequest.get({
    @required String relativePath,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,

  }) : this._private(
    type: HTTPMethod.GET,
    relativeUrlPath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: null,
  );

  RestRequest.head({
    @required String relativePath,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,

  }) : this._private(
    type: HTTPMethod.HEAD,
    relativeUrlPath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: null,
  );

  RestRequest.delete({
    @required String relativePath,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,

  }) : this._private(
    type: HTTPMethod.DELETE,
    relativeUrlPath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: null,
  );

  RestRequest.post({
    @required String relativePath,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,
    Map<String, dynamic> bodyJson,

  }) : this._private(
    type: HTTPMethod.POST,
    relativeUrlPath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: bodyJson,
  );

  RestRequest.put({
    @required String relativePath,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,
    Map<String, dynamic> bodyJson,

  }) : this._private(
    type: HTTPMethod.PUT,
    relativeUrlPath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: bodyJson,
  );

  RestRequest.patch({
    @required String relativePath,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,
    Map<String, dynamic> bodyJson,

  }) : this._private(
    type: HTTPMethod.PATCH,
    relativeUrlPath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: bodyJson,
  );

  @override
  String toString() {
    return 'RestRequest{type: $type, '
        ' relativePath: $relativeUrlPath, queryArgs: $queryArgs,'
        ' bodyJson: $bodyJson, headers: $headers';
  }
}

class UploadMultipartRestRequest extends RestRequest {
  final Map<String, File> files;

  UploadMultipartRestRequest.get({
    @required String relativePath,
    @required this.files,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,

  }) : super.get(
    relativePath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
  );

  UploadMultipartRestRequest.delete({
    @required String relativePath,
    @required this.files,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,

  }) : super.delete(
    relativePath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
  );

  UploadMultipartRestRequest.head({
    @required String relativePath,
    @required this.files,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,

  }) : super.head(
    relativePath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
  );

  UploadMultipartRestRequest.post({
    @required String relativePath,
    @required this.files,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,
    Map<String, dynamic> bodyJson,

  }) : super.post(
    relativePath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: bodyJson,
  );

  UploadMultipartRestRequest.put({
    @required String relativePath,
    @required this.files,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,
    Map<String, dynamic> bodyJson,

  }) : super.put(
    relativePath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: bodyJson,
  );

  UploadMultipartRestRequest.patch({
    @required String relativePath,
    @required this.files,
    List<RestRequestQueryArg> queryArgs,
    Map<String, String> headers,
    Map<String, dynamic> bodyJson,

  }) : super.patch(
    relativePath: relativePath,
    queryArgs: queryArgs,
    headers: headers,
    bodyJson: bodyJson,
  );
}

class RestRequestQueryArg {
  final String key;
  final String value;


  RestRequestQueryArg(this.key, this.value);

  @override
  String toString() {
    return 'RestRequestQueryArg{key: $key, value: $value}';
  }
}
