import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart' hide Color;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/theming/theme_provider.dart';
import '../../providers/user/edit_profile_controller_provider.dart';
import 'add_photo_widget.dart';
import 'image_wrapper.dart';

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

class QuestionController {
  String question;
  TextEditingController answerController;
  bool isExpanded;

  QuestionController({
    String question,
    String answer,
    isExpanded,
  }) {
    this.question = question;
    answerController = TextEditingController(text: answer);
    this.isExpanded = isExpanded ?? false;
  }

  void dispose() {
    answerController.dispose();
  }

  String get answer => answerController.text;
}

class MentorQuestionController {
  TextEditingController questionController;
  TextEditingController timeController;
  bool isExpanded;

  MentorQuestionController({
    String question,
    int time,
    this.isExpanded = false,
  }) {
    questionController = TextEditingController(text: question ?? "");
    timeController = TextEditingController(text: time.toString() ?? "");
  }

  void dispose() {
    questionController.dispose();
    timeController.dispose();
  }

  String get question => questionController.text;

  int get time => int.parse(timeController.text) * 60;
}

///
/// WIDGETS
///
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
      Image thumbnail = copyRotate(copyResizeCropSquare(im, 250), 270);
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
              assetPath: AssetImages.work,
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
    Image thumbnail = copyRotate(copyResizeCropSquare(im, 250), 270);
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
              assetPath: AssetImages.education,
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
      leading: Icon(Icons.info),
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

class QuestionExpansionList extends StatefulWidget {
  @override
  _QuestionExpansionListState createState() => _QuestionExpansionListState();
}

class _QuestionExpansionListState extends State<QuestionExpansionList> {
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
      key: PageStorageKey<String>('QuestionList'),
      title: AutoSizeText("Questions", style: _textTheme.title),
      leading: Icon(Icons.info),
      children: <Widget>[
        Consumer<EditProfileControllerProvider>(
          builder: (_, dataProvider, __) {
            var availableQuestions = dataProvider.currentAvailableQuestions;

            return Column(
              children: [
                if (availableQuestions.isNotEmpty)
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      items: availableQuestions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: AutoSizeText(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        dataProvider.addQuestion(value);
                      },
                      hint: Center(
                        child: RaisedButton.icon(
                          icon: Icon(Icons.add),
                          label: AutoSizeText("Add"),
                          onPressed: () {},
                        ),
                      ),
                      icon: Container(),
                      isExpanded: true,
                    ),
                  ),
                ...dataProvider.questionsController.entries
                    .map<Widget>(
                      (entry) => Dismissible(
                        key: ValueKey("QuestionDismissable${entry.key}"),
                        onDismissed: (_) {
                          dataProvider.removeQuestion(entry.key);
                        },
                        background: Container(color: Colors.red),
                        child: ExpansionTile(
                          initiallyExpanded: entry.value.isExpanded,
                          key: PageStorageKey(
                            "QuestionSubList${entry.key}",
                          ),
                          title: AutoSizeText(
                            "Question:"
                            " ${entry.value.question}",
                          ),
                          children: [
                            Divider(),
                            EditText(
                              storageKey: PageStorageKey<String>(
                                'QuestionAnswer${entry.key}',
                              ),
                              controller: entry.value.answerController,
                              oneLiner: true,
                              textFieldName: "Answer",
                              errorText: "Enter a valid answer!",
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class MentorQuestionsExpandableList extends StatefulWidget {
  final void Function() addElement;

  MentorQuestionsExpandableList({this.addElement});

  @override
  _MentorQuestionsExpandableListState createState() =>
      _MentorQuestionsExpandableListState();
}

class _MentorQuestionsExpandableListState
    extends State<MentorQuestionsExpandableList> {
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
      key: PageStorageKey<String>('MentorQuestionsList'),
      title: AutoSizeText("Questions for contact", style: _textTheme.title),
      leading: Icon(Icons.info),
      children: <Widget>[
        RaisedButton.icon(
          icon: Icon(Icons.add),
          label: const AutoSizeText("Add"),
          onPressed: widget.addElement,
        ),
        Selector<EditProfileControllerProvider, Map>(
          selector: (_, dataProvider) => dataProvider.mentorQuestionsController,
          shouldRebuild: (_, __) => true,
          builder: (_, questions, __) {
            return Column(
              children: questions.entries
                  .map<Widget>(
                    (entry) => Dismissible(
                      key: ValueKey("MentorQuestionsDismissable${entry.key}"),
                      onDismissed: (_) {
                        questions.remove(entry.key)..dispose();
                      },
                      background: Container(color: Colors.red),
                      child: ExpansionTile(
                        initiallyExpanded: entry.value.isExpanded,
                        key: PageStorageKey(
                          "MentorQuestionsSubList${entry.key}",
                        ),
                        title: AutoSizeText(
                          "Question:"
                          " ${entry.value.question != "" ? entry.value.question : "No name set."}",
                        ),
                        children: <Widget>[
                          EditText(
                            storageKey: PageStorageKey<String>(
                              'MentorQuestionsQuestion${entry.key}',
                            ),
                            controller: entry.value.questionController,
                            oneLiner: false,
                            textFieldName: "Question",
                            errorText: "Enter a question!",
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: PageStorageKey<String>(
                              'MentorQuestionsTime${entry.key}',
                            ),
                            maxLines: 1,
                            controller: entry.value.timeController,
                            decoration: InputDecoration(
                              labelText: "Minutes available for answer",
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Enter a valid time duration";
                              }

                              final n = num.tryParse(value);
                              if (n == null) {
                                return '"$value" is not a valid number';
                              }
                              if (n <= 0) {
                                return '"$value" is not a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
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

class WorkSpecializationExpansionList extends StatefulWidget {
  @override
  _WorkSpecializationExpansionListState createState() =>
      _WorkSpecializationExpansionListState();
}

class _WorkSpecializationExpansionListState
    extends State<WorkSpecializationExpansionList> {
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
      key: PageStorageKey<String>('WorkSpecializationList'),
      title: AutoSizeText("Specializations", style: _textTheme.title),
      leading: Icon(Icons.info),
      children: <Widget>[
        Consumer<EditProfileControllerProvider>(
          builder: (_, dataProvider, __) {
            var availableSpecializations =
                dataProvider.currentAvailableSpecializations;

            return Column(
              children: [
                if (availableSpecializations.isNotEmpty)
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      items: availableSpecializations.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: AutoSizeText(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        dataProvider.addSpecialization(value);
                      },
                      hint: Center(
                        child: RaisedButton.icon(
                          icon: Icon(Icons.add),
                          label: AutoSizeText("Add"),
                          onPressed: () {},
                        ),
                      ),
                      icon: Container(),
                      isExpanded: true,
                    ),
                  ),
                ...dataProvider.selectedSpecializations
                    .map<Widget>(
                      (specialization) => Dismissible(
                        key: ValueKey("QuestionDismissable$specialization"),
                        onDismissed: (_) {
                          dataProvider.removeQuestion(specialization);
                        },
                        background: Container(color: Colors.red),
                        child: AutoSizeText(
                          specialization,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    )
                    .toList(),
              ],
            );
          },
        ),
      ],
    );
  }
}
