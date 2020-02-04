import 'package:dio/dio.dart';

import '../models/exceptions/no_internet_exception.dart';
import '../models/exceptions/something_went_wrong_exception.dart';

enum TypeHttpRequest { post, get, patch }

class HttpRequestWrapper {
  Dio httpManager;

  HttpRequestWrapper({this.httpManager});

  Future<Response> makeRequest(
    TypeHttpRequest typeHttpRequest,
    String url,
    Options options,
    dynamic postBody,
  ) async {
    Response response;

    switch (typeHttpRequest) {
      case TypeHttpRequest.post:
        response =
            await httpManager.post(url, data: postBody, options: options);
        break;
      case TypeHttpRequest.get:
        response = await httpManager.get(url, options: options);
        break;
      case TypeHttpRequest.patch:
        response =
            await httpManager.patch(url, data: postBody, options: options);
        break;
    }

    return response;
  }

  String getWhatConnectionError(DioError error) {
    if (error.type == DioErrorType.DEFAULT &&
        error.error.osError?.message == "Network is unreachable") {
      return "Activate the internet connection to connect to RyFy.";
    } else {
      return "Couldn't connect with the RyFy server. Try again later.";
    }
  }

  Future<T> request<T>({
    String url,
    Future<T> Function(dynamic x) onCorrectStatusCode,
    Future<T> Function(dynamic x) onIncorrectStatusCode,
    TypeHttpRequest typeHttpRequest = TypeHttpRequest.get,
    int correctStatusCode = 200,
    dynamic Function(DioError) onUnknownDioError,
    postBody,
    Options dioOptions,
  }) async {
    Future<T> parsedResponse;

    if (onUnknownDioError == null) {
      onUnknownDioError = (_) {
        throw SomethingWentWrongException();
      };
    }

    if (typeHttpRequest == TypeHttpRequest.get && postBody != null) {
      throw Exception("Cannot use bodyPost without post request!");
    }

    try {
      final response = await makeRequest(
        typeHttpRequest = typeHttpRequest,
        url = url,
        dioOptions = dioOptions,
        postBody = postBody,
      );

      if (response.statusCode == correctStatusCode) {
        parsedResponse = onCorrectStatusCode(response);
      }
      //Otherwise we received something not expected. We throw an error.
      else {
        onIncorrectStatusCode(response);
      }
    } on DioError catch (error) {
      if (error.type != DioErrorType.RESPONSE) {
        throw NoInternetException(getWhatConnectionError(error));
      }

      onUnknownDioError(error);
    }

    return parsedResponse;
  }
}
