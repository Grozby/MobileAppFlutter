import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile_application/models/exceptions/something_went_wrong_exception.dart';

import '../models/exceptions/no_internet_exception.dart';

typedef T ParserResponseFunction<T>(dynamic x);

enum TypeHttpRequest { post, get }

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
    }

    return response;
  }

  String getWhatConnectionError(DioError error) {
    if (error.type == DioErrorType.DEFAULT &&
        error.error.osError.message == "Network is unreachable") {
      return "Activate the internet connection to connect to RyFy.";
    } else {
      return "Couldn't connect with the RyFy server. Try again later.";
    }
  }

  Future<T> request<T>({
    String url,
    ParserResponseFunction onCorrectStatusCode,
    ParserResponseFunction onIncorrectStatusCode,
    TypeHttpRequest typeHttpRequest = TypeHttpRequest.get,
    int correctStatusCode = 200,
    Function onUnknownDioError,
    postBody,
    dioOptions,
  }) async {
    Future<T> parsedResponse;

    if (onUnknownDioError == null) {
      onUnknownDioError = () {
        throw SomethingWentWrongException();
      };
    }

    if (typeHttpRequest != TypeHttpRequest.post && postBody != null) {
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
