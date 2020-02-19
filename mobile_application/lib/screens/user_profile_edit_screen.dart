import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:image/image.dart';
import 'package:provider/provider.dart';
import 'package:ryfy/models/exceptions/no_internet_exception.dart';
import 'package:ryfy/widgets/general/add_photo_widget.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/users/user.dart';
import '../models/utility/available_sizes.dart';
import '../providers/theming/theme_provider.dart';
import '../providers/user/edit_profile_controller_provider.dart';
import '../providers/user/user_data_provider.dart';
import '../screens/user_profile_screen.dart';
import '../widgets/general/image_wrapper.dart';
import '../widgets/general/settings_drawer.dart';
import '../widgets/general/user_profile_edit_widgets.dart';
import '../widgets/phone/explore/card_container.dart';
import '../widgets/phone/explore/circular_button.dart';

class UserProfileEditScreen extends StatefulWidget {
  static const routeName = '/editprofile';

  @override
  _UserProfileEditScreenState createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      endDrawer: SettingsDrawer(),
      body: SafeArea(
        child: UserProfileBuilder(),
      ),
    );
  }
}

class UserProfileBuilder extends StatefulWidget {
  UserProfileBuilder();

  @override
  UserProfileBuilderState createState() => UserProfileBuilderState();
}

class UserProfileBuilderState extends State<UserProfileBuilder> {
  GlobalKey<FormState> _formKey;

  User user;
  EditProfileControllerProvider _controllerProvider;
  AvailableSizes availableSizes;
  Widget saveButton;
  Widget topButtons;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    user = Provider.of<UserDataProvider>(context, listen: false).user;
    _controllerProvider = EditProfileControllerProvider(user);
  }

  @override
  void dispose() {
    _controllerProvider.dispose();
    super.dispose();
  }

  SnackBar getSnackBar(String text) {
    return SnackBar(
      content: AutoSizeText(text),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
    );
  }

  void sendUpdatedValues() async {
    try {

      if (!_formKey.currentState.validate()) {
        final snackBar =
            getSnackBar('Some of the inserted data are incorrect!');
        Scaffold.of(context).showSnackBar(snackBar);
        return;
      }

      await Future.delayed(Duration(milliseconds: 500));
      await Provider.of<UserDataProvider>(
        context,
        listen: false,
      ).patchUserData(_controllerProvider.retrievePatchBody());

      final snackBar = getSnackBar('Correctly updated!');
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {
      var snackBar;
      if(e is NoInternetException) {
        snackBar = getSnackBar(e.getMessage());
      } else {
        snackBar = getSnackBar('Oops! Something went wrong!');
      }

      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> setImage(File image, String type) async {
    if (image != null) {
      Image im = await decodeCompute(image);
      Image thumbnail = copyResizeCropSquare(im, 250);
      if(type == "camera"){
        thumbnail = copyRotate(thumbnail, 90);
      }

      _controllerProvider.profileImage = await encodeCompute(thumbnail);
    } else {
      _controllerProvider.profileImage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controllerProvider,
      child: LayoutBuilder(
        builder: (ctx, constraints) => ScopedModel<AvailableSizes>(
          model: (availableSizes ??=
              AvailableSizes(height: constraints.maxHeight - 100)),
          child: Container(
            height: availableSizes.height + 100,
            child: SingleChildScrollView(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: topButtons ??= TopButtons(
                      width: constraints.maxWidth * 0.85,
                      isAnotherUser: false,
                    ),
                  ),
                  CardContent(
                    user: Provider.of<UserDataProvider>(
                      context,
                      listen: false,
                    ).user,
                    width: constraints.maxWidth * 0.9,
                    formKey: _formKey,
                  ),
                  Positioned(
                    top: 40,
                    child: AddPhotoWidget(
                      width: 120,
                      height: 120,
                      setImage: setImage,
                      startingImage: _controllerProvider.profileImage,
                      assetPath: AssetImages.user,
                    ),
                  ),
                  saveButton ??= Positioned(
                    top: 120,
                    right: (constraints.maxWidth * 0.075) - 8 + 20,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      child: CircularButton(
                        height: 36,
                        width: 36,
                        alignment: Alignment.center,
                        assetPath: AssetImages.save,
                        onPressFunction: sendUpdatedValues,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardContent extends StatefulWidget {
  final double width;
  final User user;
  final Key formKey;

  CardContent({
    @required this.width,
    @required this.user,
    @required this.formKey,
  });

  @override
  _CardContentState createState() => _CardContentState();
}

class _CardContentState extends State<CardContent> {
  EditProfileControllerProvider dataProvider;

  Widget nameTextField;
  Widget surnameTextField;
  Widget bioTextField;
  Widget locationTextField;
  Widget expansionTileJobs;
  Widget expansionTileEducations;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<EditProfileControllerProvider>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: EdgeInsets.only(top: 100, bottom: 12.0),
      child: CardContainer(
        onLongPress: () {},
        canExpand: true,
        startingColor: widget.user.cardColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Form(
            key: widget.formKey,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              key: PageStorageKey('view'),
              children: <Widget>[
                nameTextField ??= EditText(
                  controller: dataProvider.nameController,
                  oneLiner: false,
                  textFieldName: "Name",
                  errorText: "Enter a name!",
                ),
                surnameTextField ??= EditText(
                  controller: dataProvider.surnameController,
                  oneLiner: false,
                  textFieldName: "Surname",
                  errorText: "Enter a surname!",
                ),
                bioTextField ??= EditText(
                  controller: dataProvider.bioController,
                  oneLiner: false,
                  textFieldName: "Biography",
                  errorText: "Enter a biography!",
                ),
                locationTextField ??= EditText(
                  controller: dataProvider.locationController,
                  oneLiner: false,
                  textFieldName: "Location",
                  errorText: "Enter a location!",
                ),
                Tooltip(
                  message:
                      "Insert information of your current job you have, if any.",
                  preferBelow: false,
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    key: PageStorageKey<String>('CurrentJob'),
                    leading: Icon(Icons.info),
                    title: AutoSizeText(
                      "Current job",
                      style: Theme.of(context).textTheme.title,
                    ),
                    children: <Widget>[
                      EditJob(
                        controller: dataProvider.currentJobController,
                      )
                    ],
                  ),
                ),
                expansionTileEducations ??= Tooltip(
                  message: "Insert you academic degrees, obtained and ongoing.",
                  child: ExperienceExpansionList(
                    key: dataProvider.educationListKey,
                    title: "Education",
                    subtitle: "School",
                    selector: (_, dataProvider) =>
                        dataProvider.academicExperiences,
                    builder: (c) => EditEducation(controller: c),
                    addElement: dataProvider.addAcademicExperience,
                  ),
                ),
                expansionTileJobs ??= Tooltip(
                  message: "Insert you work experiences, past and ongoing.",
                  child: ExperienceExpansionList(
                    key: dataProvider.workListKey,
                    title: "Work experience",
                    subtitle: "Company",
                    selector: (_, dataProvider) => dataProvider.jobExperiences,
                    builder: (c) => EditJob(controller: c),
                    addElement: dataProvider.addJobExperience,
                  ),
                ),
                Tooltip(
                  message:
                      "Answer to some of the proposed questions on the platform.",
                  child: QuestionExpansionList(),
                ),
                Tooltip(
                  message: "Add your working specializations.",
                  child: WorkSpecializationExpansionList(),
                ),
                if (dataProvider.isMentor)
                  Tooltip(
                    message:
                        "Insert the questions to propose to any mentee that wants to contact you.",
                    child: MentorQuestionsExpandableList(
                      addElement: dataProvider.addMentorQuestion,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
