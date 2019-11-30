import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AvailableSizes extends Model {
  double height;

  AvailableSizes(this.height);

  static AvailableSizes of(BuildContext context) =>
      ScopedModel.of<AvailableSizes>(context);
}