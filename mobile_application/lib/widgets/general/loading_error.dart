import 'package:flutter/material.dart';

import '../../models/exceptions/no_internet_exception.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import 'button_styled.dart';
import 'custom_alert_dialog.dart';

class LoadingError extends StatefulWidget {
  final Exception exception;
  final Function retry;
  final BuildContext buildContext;

  LoadingError({
    @required this.exception,
    @required this.retry,
    @required this.buildContext,
  });

  @override
  _LoadingErrorState createState() => _LoadingErrorState();
}

class _LoadingErrorState extends State<LoadingError> {
  @override
  Widget build(BuildContext context) {
    if (widget.exception is NoInternetException) {
      return NoInternetConnectionWidget(
        retryToConnect: widget.retry,
        exception: (widget.exception as NoInternetException),
      );
    }

    return GeneralErrorWidget(
      exception: widget.exception,
      retry: widget.retry,
    );
  }
}

class NoInternetConnectionWidget extends StatefulWidget {
  final Function retryToConnect;
  final NoInternetException exception;

  const NoInternetConnectionWidget({
    @required this.retryToConnect,
    @required this.exception,
  });

  @override
  _NoInternetConnectionWidgetState createState() =>
      _NoInternetConnectionWidgetState();
}

class _NoInternetConnectionWidgetState
    extends State<NoInternetConnectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showErrorDialog(
        context,
        widget.exception.getMessage(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Text(widget.exception.getMessage()),
          ),
          const SizedBox(height: 16),
          Center(
            child: ButtonStyled(
              fractionalWidthDimension: 0.4,
              text: "Retry now",
              onPressFunction: widget.retryToConnect,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneralErrorWidget extends StatefulWidget {
  final Exception exception;
  final Function retry;

  GeneralErrorWidget({
    @required this.exception,
    @required this.retry,
  });

  @override
  _GeneralErrorWidgetState createState() => _GeneralErrorWidgetState();
}

class _GeneralErrorWidgetState extends State<GeneralErrorWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showErrorDialog(
        context,
        widget.exception is SomethingWentWrongException
            ? (widget.exception as SomethingWentWrongException).getMessage()
            : "Oopsie! Something went wrong!",
      );
      goBackToPreviousPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Text("Oops! Something went wrong!"),
          ),
          const SizedBox(height: 16),
          Center(
            child: ButtonStyled(
              fractionalWidthDimension: 0.4,
              text: Navigator.of(context).canPop() ? "Go back" : "Retry",
              onPressFunction: goBackOrRetry,
            ),
          ),
        ],
      ),
    );
  }

  void goBackToPreviousPage() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void goBackOrRetry() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      widget.retry();
    }
  }
}
