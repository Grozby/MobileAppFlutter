import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:image/image.dart';

import 'add_photo_widget.dart';

Image decode(File image) {
  return decodeImage(image.readAsBytesSync());
}

decodeCompute(File image) {
  return compute(decode, image);
}

String encodeBase64(Image image) {
  return base64Encode(encodePng(image));
}

encodeCompute(Image image) {
  return compute(encodeBase64, image);
}

class EditText extends StatelessWidget {
  final bool oneLiner;
  final TextEditingController controller;
  final String textFieldName;
  final String errorText;

  EditText({
    @required this.oneLiner,
    @required this.controller,
    @required this.textFieldName,
    @required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: oneLiner ? 1 : null,
      controller: controller,
      decoration: InputDecoration(
        labelText: textFieldName,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }
}

class ExperienceController {
  int index;
  String institutionImage;
  TextEditingController nameInstitutionController;
  DateTime fromDate;
  DateTime toDate;

  ExperienceController({
    this.index,
    String imageUrl,
    String nameInstitution,
    DateTime fromDate,
    DateTime toDate,
  }) {
    institutionImage ??= imageUrl;
    nameInstitutionController =
        TextEditingController(text: nameInstitution ?? "");
    this.fromDate ??= fromDate;
    this.toDate ??= toDate;
  }

  void dispose() {
    nameInstitutionController.dispose();
  }
}

class JobController extends ExperienceController {
  TextEditingController workingRoleController;

  JobController({
    int index,
    String imageUrl,
    String nameInstitution,
    DateTime fromDate,
    DateTime toDate,
    String workingRole,
    dataProvider,
  }) : super(
          index: index,
          imageUrl: imageUrl,
          nameInstitution: nameInstitution,
          fromDate: fromDate,
          toDate: toDate,
        ) {
    workingRoleController = TextEditingController(text: workingRole ?? "");
  }

  @override
  void dispose() {
    workingRoleController.dispose();
    super.dispose();
  }
}

class AcademicDegreeController extends ExperienceController {
  TextEditingController degreeLevelRoleController;
  TextEditingController fieldOfStudyRoleController;

  AcademicDegreeController(
      {int index,
      String imageUrl,
      String nameInstitution,
      DateTime fromDate,
      DateTime toDate,
      String degreeLevel,
      String fieldOfStudy,
      dataProvider})
      : super(
          index: index,
          imageUrl: imageUrl,
          nameInstitution: nameInstitution,
          fromDate: fromDate,
          toDate: toDate,
        ) {
    degreeLevelRoleController = TextEditingController(text: degreeLevel ?? "");
    fieldOfStudyRoleController =
        TextEditingController(text: fieldOfStudy ?? "");
  }

  @override
  void dispose() {
    degreeLevelRoleController.dispose();
    fieldOfStudyRoleController.dispose();
    super.dispose();
  }
}

class EditJob extends StatefulWidget {
  final JobController controller;
  final void Function() signalParentForRemove;

  EditJob({
    @required this.controller,
    @required this.signalParentForRemove,
  });

  @override
  _EditJobState createState() => _EditJobState();
}

class _EditJobState extends State<EditJob> {
  void setImage(File image) async {
    Image im = await decodeCompute(image);
    Image thumbnail = copyResize(im, height: 250, width: 250);
    widget.controller.institutionImage = await encodeCompute(thumbnail);
  }

  Future<Null> _selectDate(BuildContext context, bool starting) async {
    DateTime selectedDate = DateTime.now();

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked.isBefore(selectedDate)) {
      setState(() {
        if (starting) {
          widget.controller.fromDate = picked;
        } else {
          widget.controller.toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AddPhotoWidget(
              width: 60,
              height: 60,
              setImage: setImage,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: <Widget>[
                  EditText(
                    controller: widget.controller.nameInstitutionController,
                    oneLiner: false,
                    textFieldName: "Company",
                    errorText: "Enter a company name!",
                  ),
                  const SizedBox(height: 8),
                  EditText(
                      controller: widget.controller.workingRoleController,
                      oneLiner: false,
                      textFieldName: "Working Role",
                      errorText: "Enter a working role!"),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  StringValidator(
                    builder: (_) => AutoSizeText(
                      widget.controller.fromDate != null
                          ? "${widget.controller.fromDate}".split(' ')[0]
                          : "No date selected",
                      maxLines: 1,
                    ),
                    validator: (_) {
                      if (widget.controller.fromDate == null) {
                        return "Select a date!";
                      }
                      return null;
                    },
                  ),
                  RaisedButton(
                    onPressed: () => _selectDate(context, true),
                    child: AutoSizeText(
                      'Select starting date',
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  AutoSizeText(
                    widget.controller.toDate != null
                        ? "${widget.controller.toDate}".split(' ')[0]
                        : "Ongoing",
                    maxLines: 1,
                  ),
                  RaisedButton(
                    onPressed: () => _selectDate(context, false),
                    child: AutoSizeText(
                      'Select ending date',
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}

class StringValidator extends FormField<String> {
  StringValidator({builder, validator})
      : super(builder: builder, validator: validator);
}
