import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:image/image.dart' hide Color;
import 'package:intl/intl.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/providers/user/edit_profile_controller_provider.dart';
import 'package:provider/provider.dart';

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

class EditText extends StatefulWidget {
  final PageStorageKey storageKey;
  final bool oneLiner, readOnly;
  final TextEditingController controller;
  final String textFieldName;
  final String errorText;
  final void Function() onTap;

  EditText({
    this.storageKey,
    @required this.oneLiner,
    @required this.controller,
    @required this.textFieldName,
    this.errorText,
    bool readOnly,
    onTap,
  })  : onTap = (onTap ?? () {}),
        readOnly = (readOnly ?? false);

  @override
  _EditTextState createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.storageKey,
      onTap: widget.onTap,
      maxLines: widget.oneLiner ? 1 : null,
      readOnly: widget.readOnly,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.textFieldName,
      ),
      validator: (value) {
        if (widget.errorText != null && value.isEmpty) {
          return widget.errorText;
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ExperienceController {
  int index;
  bool expanded;
  String institutionImage;
  TextEditingController nameInstitutionController;
  TextEditingController fromDateController;
  TextEditingController toDateController;

  ExperienceController({
    this.index,
    String imageUrl,
    String nameInstitution,
    DateTime fromDate,
    DateTime toDate,
    this.expanded = true,
  }) {
    institutionImage ??= imageUrl;
    nameInstitutionController = TextEditingController(
      text: nameInstitution ?? "",
    );
    this.fromDateController = TextEditingController(
      text: fromDate != null ? DateFormat.yMd().format(fromDate) : "",
    );
    this.toDateController = TextEditingController(
      text: toDate != null ? DateFormat.yMd().format(toDate) : "Ongoing",
    );
  }

  void dispose() {
    nameInstitutionController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
  }

  String get nameInstitution => nameInstitutionController.text;

  String _parseString(String text) => _getDateTime(text).toIso8601String();

  DateTime _getDateTime(String text) => DateFormat.yMd().parse(text);

  String get fromDate => _parseString(fromDateController.text);

  String get toDate => _parseString(toDateController.text);

  DateTime get fromDateDateTime => _getDateTime(fromDateController.text);

  DateTime get toDateDateTime => _getDateTime(toDateController.text);
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
    bool expanded = true,
  }) : super(
          index: index,
          imageUrl: imageUrl,
          nameInstitution: nameInstitution,
          fromDate: fromDate,
          toDate: toDate,
          expanded: expanded,
        ) {
    workingRoleController = TextEditingController(text: workingRole ?? "");
  }

  @override
  void dispose() {
    workingRoleController.dispose();
    super.dispose();
  }

  String get workingRole => workingRoleController.text;
}

class AcademicDegreeController extends ExperienceController {
  TextEditingController degreeLevelController;
  TextEditingController fieldOfStudyController;

  AcademicDegreeController({
    int index,
    String imageUrl,
    String nameInstitution,
    DateTime fromDate,
    DateTime toDate,
    String degreeLevel,
    String fieldOfStudy,
    bool expanded = true,
  }) : super(
          index: index,
          imageUrl: imageUrl,
          nameInstitution: nameInstitution,
          fromDate: fromDate,
          toDate: toDate,
          expanded: expanded,
        ) {
    degreeLevelController = TextEditingController(text: degreeLevel ?? "");
    fieldOfStudyController = TextEditingController(text: fieldOfStudy ?? "");
  }

  @override
  void dispose() {
    degreeLevelController.dispose();
    fieldOfStudyController.dispose();
    super.dispose();
  }

  String get degreeLevel => degreeLevelController.text;

  String get fieldOfStudy => fieldOfStudyController.text;
}

class EditJob extends StatefulWidget {
  final JobController controller;

  EditJob({
    @required this.controller,
  });

  @override
  _EditJobState createState() => _EditJobState();
}

class _EditJobState extends State<EditJob> {
  void setImage(File image) async {
    if (image != null) {
      Image im = await decodeCompute(image);
      Image thumbnail = copyResizeCropSquare(im, 250);
      widget.controller.institutionImage = await encodeCompute(thumbnail);
    } else {
      widget.controller.institutionImage = null;
    }
  }

  Future<Null> _selectDate(BuildContext context, bool starting) async {
    DateTime selectedDate = DateTime.now();

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: !starting && widget.controller.fromDate != ""
          ? widget.controller.fromDateDateTime
          : DateTime(1950, 1),
      lastDate: selectedDate,
    );
    if (picked != null) {
      setState(() {
        if (starting) {
          widget.controller.fromDateController.text =
              DateFormat.yMd().format(picked);
        } else {
          widget.controller.toDateController.text =
              DateFormat.yMd().format(picked);
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
              startingImage: widget.controller.institutionImage,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: <Widget>[
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'Company${widget.controller.index}',
                    ),
                    controller: widget.controller.nameInstitutionController,
                    oneLiner: false,
                    textFieldName: "Company",
                    errorText: "Enter a company name!",
                  ),
                  const SizedBox(height: 8),
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'WorkingRole${widget.controller.index}',
                    ),
                    controller: widget.controller.workingRoleController,
                    oneLiner: false,
                    textFieldName: "Working Role",
                    errorText: "Enter a working role!",
                  ),
                  const SizedBox(height: 8),
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'FromDate${widget.controller.index}',
                    ),
                    controller: widget.controller.fromDateController,
                    oneLiner: true,
                    readOnly: true,
                    textFieldName: "From date",
                    errorText: "Enter a valid date!",
                    onTap: () => _selectDate(context, true),
                  ),
                  const SizedBox(height: 8),
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'ToDate${widget.controller.index}',
                    ),
                    controller: widget.controller.toDateController,
                    oneLiner: true,
                    readOnly: true,
                    textFieldName: "To date",
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class StringValidator extends FormField<String> {
  StringValidator({key, builder, validator})
      : super(key: key, builder: builder, validator: validator);
}

class EditEducation extends StatefulWidget {
  final AcademicDegreeController controller;

  EditEducation({
    @required this.controller,
  });

  @override
  _EditEducationState createState() => _EditEducationState();
}

class _EditEducationState extends State<EditEducation> {
  void setImage(File image) async {
    Image im = await decodeCompute(image);
    Image thumbnail = copyResizeCropSquare(im, 250);
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
          widget.controller.fromDateController.text =
              DateFormat.yMd().format(picked);
          ;
        } else {
          widget.controller.toDateController.text =
              DateFormat.yMd().format(picked);
          ;
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
              startingImage: widget.controller.institutionImage,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: <Widget>[
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'Education${widget.controller.index}',
                    ),
                    controller: widget.controller.nameInstitutionController,
                    oneLiner: false,
                    textFieldName: "School",
                    errorText: "Enter a school name!",
                  ),
                  const SizedBox(height: 8),
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'DegreeLevel${widget.controller.index}',
                    ),
                    controller: widget.controller.degreeLevelController,
                    oneLiner: false,
                    textFieldName: "Degree Level",
                    errorText: "Enter a degree level!",
                  ),
                  const SizedBox(height: 8),
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'FieldOfStudy${widget.controller.index}',
                    ),
                    controller: widget.controller.fieldOfStudyController,
                    oneLiner: false,
                    textFieldName: "Field of study",
                    errorText: "Enter a field of study!",
                  ),
                  const SizedBox(height: 8),
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'FromDate${widget.controller.index}',
                    ),
                    controller: widget.controller.fromDateController,
                    oneLiner: true,
                    textFieldName: "From date",
                    errorText: "Enter a valid date!",
                    onTap: () => _selectDate(context, true),
                  ),
                  const SizedBox(height: 8),
                  EditText(
                    storageKey: PageStorageKey<String>(
                      'ToDate${widget.controller.index}',
                    ),
                    controller: widget.controller.toDateController,
                    oneLiner: true,
                    textFieldName: "To date",
                    onTap: () => _selectDate(context, false),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class ExperienceExpansionList extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget Function(ExperienceController) builder;
  final void Function() addElement;
  final Map Function(BuildContext, EditProfileControllerProvider) selector;

  ExperienceExpansionList({
    this.title,
    this.subtitle,
    this.builder,
    this.selector,
    this.addElement,
  });

  @override
  _ExperienceExpansionListState createState() =>
      _ExperienceExpansionListState();
}

class _ExperienceExpansionListState extends State<ExperienceExpansionList> {
  TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
    _textTheme = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).getTheme().textTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey<String>('${widget.title}List'),
      title: AutoSizeText("${widget.title}", style: _textTheme.title),
      children: <Widget>[
        RaisedButton.icon(
          icon: Icon(Icons.add),
          label: const AutoSizeText("Add"),
          onPressed: widget.addElement,
        ),
        Selector<EditProfileControllerProvider, Map>(
          selector: widget.selector,
          shouldRebuild: (_, __) => true,
          builder: (_, experiences, __) {
            return Column(
              children: experiences.entries
                  .map<Widget>(
                    (entry) => Dismissible(
                      key: ValueKey("${widget.title}Dismissable${entry.key}"),
                      onDismissed: (_) {
                        experiences.remove(entry.key)..dispose();
                      },
                      background: Container(color: Colors.red),
                      child: ExpansionTile(
                        initiallyExpanded: entry.value.expanded,
                        key: PageStorageKey(
                          "${widget.title}SubList${entry.key}",
                        ),
                        title: AutoSizeText(
                          "${widget.subtitle}:"
                          " ${entry.value.nameInstitution != "" ? entry.value.nameInstitution : "No name set."}",
                        ),
                        children: [widget.builder(entry.value)],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
