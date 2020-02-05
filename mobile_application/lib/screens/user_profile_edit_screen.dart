import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:mobile_application/models/users/user.dart';
import 'package:mobile_application/models/utility/available_sizes.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/providers/user/edit_profile_controller_provider.dart';
import 'package:mobile_application/providers/user/user_data_provider.dart';
import 'package:mobile_application/screens/user_profile_screen.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import 'package:mobile_application/widgets/general/settings_drawer.dart';
import 'package:mobile_application/widgets/general/user_profile_edit_widgets.dart';
import 'package:mobile_application/widgets/phone/explore/card_container.dart';
import 'package:mobile_application/widgets/phone/explore/circular_button.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

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
  final _formKey = GlobalKey<FormState>();

  User user;
  EditProfileControllerProvider _controllerProvider;
  AvailableSizes availableSizes;
  Widget saveButton;
  Widget topButtons;

  @override
  void initState() {
    super.initState();

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

      await Provider.of<UserDataProvider>(
        context,
        listen: false,
      ).patchUserData(_controllerProvider.retrievePatchBody());

      final snackBar = getSnackBar('Correctly updated!');
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = getSnackBar('Oops! Something went wrong!');
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controllerProvider,
      child: LayoutBuilder(
        builder: (ctx, constraints) => ScopedModel<AvailableSizes>(
          model: availableSizes ??=
              AvailableSizes(height: constraints.maxHeight - 100),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: topButtons ??= TopButtons(
                        width: constraints.maxWidth * 0.85,
                        isAnotherUser: false,
                      ),
                    ),
                    CardContent(
                      user:
                          Provider.of<UserDataProvider>(context, listen: false)
                              .user,
                      width: constraints.maxWidth * 0.9,
                      formKey: _formKey,
                    ),
                  ],
                ),
                UserImage(userPictureUrl: user.pictureUrl),
                saveButton ??= Positioned(
                  top: 120,
                  right: (constraints.maxWidth * 0.075) - 8 + 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: Provider.of<ThemeProvider>(context)
                            .getTheme()
                            .primaryColorLight,
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
  TextTheme textTheme;

  Widget nameTextField;
  Widget surnameTextField;
  Widget bioTextField;
  Widget locationTextField;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<EditProfileControllerProvider>(
      context,
      listen: false,
    );
    textTheme = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).getTheme().textTheme;
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: ScopedModel.of<AvailableSizes>(context).height,
      padding: EdgeInsets.only(bottom: 12.0),
      child: Builder(builder: (context) {
        return CardContainer(
          onLongPress: () {},
          canExpand: true,
          startingColor: widget.user.cardColor,
          child: Form(
            key: widget.formKey,
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 60),
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
                ExpansionTile(
                  title: AutoSizeText("Current job", style: textTheme.title),
                  children: <Widget>[],
                ),
                ExpansionTile(
                  title: AutoSizeText("Education", style: textTheme.title),
                  children: <Widget>[],
                ),
                ExpansionTile(
                  title:
                      AutoSizeText("Work experience", style: textTheme.title),
                  children: <Widget>[
                    RaisedButton.icon(
                      icon: Icon(Icons.add),
                      label: const AutoSizeText("Add"),
                      onPressed: dataProvider.addJobExperience,
                    ),
                    Selector<EditProfileControllerProvider, Map>(
                      selector: (_, dataProvider) =>
                          dataProvider.jobExperiences,
                      shouldRebuild: (prev, now) => true,
                      builder: (_, experiences, __) {
                        var entries = experiences.entries.toList();
                        return Container(
                          height: 250,
                          child: ListView.builder(
                            primary: false,
                            itemCount: entries.length,
                            itemBuilder: (ctx, index) => EditJob(
                              controller: entries[index].value,
                              signalParentForRemove: () {
                                experiences.remove(entries[index].key)
                                  ..dispose();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
