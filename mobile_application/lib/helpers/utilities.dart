import 'package:dio/dio.dart';

String getWhatConnectionError(DioError error){
  if (error.type == DioErrorType.DEFAULT) {
    return "Activate the internet connection to connect to RyFy.";
  } else {
    return "Couldn't connect with the RyFy server. Try again later.";
  }
}

