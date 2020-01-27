import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AvailableSizes extends Model {
  double height;
  double width;

  AvailableSizes({this.height, this.width});

  static AvailableSizes of(BuildContext context) =>
      ScopedModel.of<AvailableSizes>(context);
}