import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:mobile_application/models/users/user.dart';
import 'package:mobile_application/models/utility/available_sizes.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
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
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return ScopedModel<AvailableSizes>(
              //-100 used for [CardContainer] to define the available size
              // to occupy.
              model: AvailableSizes(height: constraints.maxHeight - 100),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: UserProfileBuilder(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserProfileBuilder extends StatefulWidget {
  final double maxWidth, maxHeight;

  UserProfileBuilder({
    @required this.maxWidth,
    @required this.maxHeight,
  });

  @override
  UserProfileBuilderState createState() => UserProfileBuilderState();
}

class UserProfileBuilderState extends State<UserProfileBuilder> {
  Map<String, dynamic> data = {};
  Map<int, Map<String, dynamic>> experienceList = {};
  Map<int, Map<String, dynamic>> educationList = {};

  void sendUpdatedValues() async {
    try {
      data["experienceList"] =
          experienceList.entries.map((entry) => entry.value).toList();

      await Provider.of<UserDataProvider>(context, listen: false)
          .patchUserData(data);
      data.clear();
      final snackBar = SnackBar(
        content: const Text('Correctly updated!'),
        backgroundColor: Provider.of<ThemeProvider>(context, listen: false)
            .getTheme()
            .primaryColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = const SnackBar(
        content: Text('Oops! Something went wrong!'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserDataProvider>(context).user;
    return Provider.value(
      value: this,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 100,
                alignment: Alignment.center,
                child: TopButtons(
                  width: widget.maxWidth * 0.85,
                  isAnotherUser: false,
                ),
              ),
              CardContent(
                user: Provider.of<UserDataProvider>(context).user,
                width: widget.maxWidth * 0.9,
              ),
            ],
          ),
          UserImage(userPictureUrl: user.pictureUrl),
          Positioned(
            top: 120,
            right: (widget.maxWidth * 0.075) - 8 + 20,
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
          )
        ],
      ),
    );
  }
}

class CardContent extends StatefulWidget {
  final double width;
  final User user;

  CardContent({this.width, @required this.user});

  @override
  _CardContentState createState() => _CardContentState();
}

class _CardContentState extends State<CardContent> {
  TextEditingController _nameController;
  TextEditingController _surnameController;
  TextEditingController _bioController;
  TextEditingController _locationController;

  var dataProvider;

  int indexJobExperiences = 0;
  Map<int, JobController> jobExperiences = {};

  void addJobExperience() {
    setState(() {
      jobExperiences[indexJobExperiences] = JobController(
        dataProvider: dataProvider,
      );
      indexJobExperiences++;
    });
  }

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<UserProfileBuilderState>(context, listen: false);

    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _bioController = TextEditingController(text: widget.user.bio);
    _locationController = TextEditingController(text: widget.user.location);

    _nameController.addListener(() {
      dataProvider.data["name"] = _nameController.text;
    });
    _surnameController.addListener(() {
      dataProvider.data["surname"] = _surnameController.text;
    });
    _bioController.addListener(() {
      dataProvider.data["bio"] = _bioController.text;
    });
    _locationController.addListener(() {
      dataProvider.data["location"] = _locationController.text;
    });

    widget.user.jobExperiences.forEach(
      (j) {
        jobExperiences[indexJobExperiences] = JobController(
          index: indexJobExperiences,
          imageUrl: j?.pictureUrl,
          nameInstitution: j?.at,
          workingRole: j.workingRole,
          fromDate: j?.fromDate,
          toDate: j?.toDate,
          dataProvider: dataProvider,
        );

        indexJobExperiences++;
      },
    );
  }

  @override
  void dispose() async {
    _nameController.dispose();
    _surnameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme =
        Provider.of<ThemeProvider>(context).getTheme().textTheme;
    return Container(
      width: widget.width,
      padding: EdgeInsets.only(bottom: 12.0),
      child: CardContainer(
        onLongPress: () {},
        canExpand: true,
        startingColor: widget.user.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 60),
            ExpansionTile(
              title: AutoSizeText("Name and Surname", style: textTheme.title),
              children: <Widget>[
                Selector<UserDataProvider, String>(
                  selector: (_, userDataProvider) => userDataProvider.user.name,
                  builder: (_, name, __) => EditText(
                    controller: _nameController,
                    oneLiner: false,
                    textFieldName: "Name",
                  ),
                ),
                Selector<UserDataProvider, String>(
                  selector: (_, userDataProvider) =>
                      userDataProvider.user.surname,
                  builder: (_, surname, __) => EditText(
                    controller: _surnameController,
                    oneLiner: false,
                    textFieldName: "Surname",
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: AutoSizeText("Bio", style: textTheme.title),
              children: <Widget>[
                Selector<UserDataProvider, String>(
                  selector: (_, userDataProvider) => userDataProvider.user.bio,
                  builder: (_, bio, __) => EditText(
                    controller: _bioController,
                    oneLiner: false,
                    textFieldName: "Biography",
                  ),
                ),
              ],
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
              title: AutoSizeText("Work experience", style: textTheme.title),
              children: <Widget>[
                RaisedButton.icon(
                  icon: Icon(Icons.add),
                  label: const Text("Add"),
                  onPressed: addJobExperience,
                ),
                ...jobExperiences.entries
                    .map((entry) => EditJob(
                          controller: entry.value,
                          signalParentForRemove: () {
                            jobExperiences.remove(entry.key)..dispose();
                          },
                        ))
                    .toList()
              ],
            ),
            ExpansionTile(
              title: AutoSizeText("Location", style: textTheme.title),
              children: <Widget>[
                EditText(
                  controller: _locationController,
                  oneLiner: false,
                  textFieldName: "Location",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
