import 'package:flutter/material.dart';
import 'package:mobile_application/models/exceptions/no_internet_exception.dart';

import 'custom_alert_dialog.dart';
import 'no_internet_connection.dart';

class LoadingError extends StatelessWidget {
  final Exception exception;
  final Function retry;

  LoadingError({
    @required this.exception,
    @required this.retry,
  });

  @override
  Widget build(BuildContext context) {
    if (exception is NoInternetException) {
      Future.delayed(
        Duration.zero,
        () => showErrorDialog(
          context,
          (exception as NoInternetException).getMessage(),
        ),
      );
      return NoInternetConnectionWidget(
        retryToConnect: () => retry(),
        errorText: (exception as NoInternetException).getMessage(),
      );
    }

    Future.delayed(
      Duration.zero,
      () => showErrorDialog(context, "Something went wrong..."),
    );
    return const Center();
  }
}
