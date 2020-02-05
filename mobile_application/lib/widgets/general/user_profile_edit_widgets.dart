import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:image/image.dart';
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

class EditText extends StatelessWidget {
  final PageStorageKey storageKey;
  final bool oneLiner;
  final TextEditingController controller;
  final String textFieldName;
  final String errorText;

  EditText({
    this.storageKey,
    @required this.oneLiner,
    @required this.controller,
    @required this.textFieldName,
    @required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: storageKey,
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
  bool expanded;
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
    expanded = true,
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

  String get nameInstitution => nameInstitutionController.text;
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
    bool expanded,
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
    bool expanded,
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
                    key: PageStorageKey<String>(
                      'FromDate${widget.controller.index}',
                    ),
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
  StringValidator({key, builder, validator})
      : super(key: key, builder: builder, validator: validator);
}

class JobExpansionList extends StatefulWidget {
  @override
  _JobExpansionListState createState() => _JobExpansionListState();
}

class _JobExpansionListState extends State<JobExpansionList> {
  EditProfileControllerProvider _controllerProvider;
  TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
    _controllerProvider = Provider.of<EditProfileControllerProvider>(
      context,
      listen: false,
    );
    _textTheme = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).getTheme().textTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey<String>('JobList'),
      title: AutoSizeText("Work experience", style: _textTheme.title),
      children: <Widget>[
        RaisedButton.icon(
          icon: Icon(Icons.add),
          label: const AutoSizeText("Add"),
          onPressed: _controllerProvider.addJobExperience,
        ),
        Selector<EditProfileControllerProvider, Map>(
          selector: (_, dataProvider) => dataProvider.jobExperiences,
          shouldRebuild: (prev, now) => true,
          builder: (_, experiences, __) {
            return Column(
              children: experiences.entries
                  .map<Widget>(
                    (entry) => Dismissible(
                      key: UniqueKey(),
                      onDismissed: (_) => () {
                        experiences.remove(entry.key)..dispose();
                      },
                      background: Container(color: Colors.red),
                      child: ExpansionTile(
                        initiallyExpanded: entry.value.expanded,
                        key: PageStorageKey("JobSubList${entry.key}"),
                        title: AutoSizeText(
                          "Company:"
                          " ${entry.value.nameInstitution != "" ? entry.value.nameInstitution : "Not set."}",
                        ),
                        children: [EditJob(controller: entry.value)],
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
                    key: PageStorageKey<String>(
                      'FromDate${widget.controller.index}',
                    ),
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

class AcademicExpansionList extends StatefulWidget {
  @override
  _AcademicExpansionListState createState() => _AcademicExpansionListState();
}

class _AcademicExpansionListState extends State<AcademicExpansionList> {
  EditProfileControllerProvider _controllerProvider;
  TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
    _controllerProvider = Provider.of<EditProfileControllerProvider>(
      context,
      listen: false,
    );
    _textTheme = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).getTheme().textTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey<String>('EducationList'),
      title: AutoSizeText("Education", style: _textTheme.title),
      children: <Widget>[
        RaisedButton.icon(
          icon: Icon(Icons.add),
          label: const AutoSizeText("Add"),
          onPressed: _controllerProvider.addAcademicExperience,
        ),
        Selector<EditProfileControllerProvider, Map>(
          selector: (_, dataProvider) => dataProvider.academicExperiences,
          shouldRebuild: (prev, now) => true,
          builder: (_, experiences, __) {
            return Column(
              children: experiences.entries
                  .map<Widget>(
                    (entry) => Dismissible(
                      key: UniqueKey(),
                      onDismissed: (_) {
                        experiences.remove(entry.key)..dispose();
                      },
                      background: Container(color: Colors.red),
                      child: ExpansionTile(
                        initiallyExpanded: entry.value.expanded,
                        key: PageStorageKey("EducationSubList${entry.key}"),
                        title: AutoSizeText(
                          "School:"
                          " ${entry.value.nameInstitution ?? "Not set."}",
                        ),
                        children: [EditEducation(controller: entry.value)],
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
