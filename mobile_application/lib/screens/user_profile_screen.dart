import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/widgets/general/loading_error.dart';
import 'package:mobile_application/widgets/transition/loading_animated.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/asset_images.dart';
import '../models/users/experiences/past_experience.dart';
import '../models/users/question.dart';
import '../models/users/socials/social_account.dart';
import '../models/users/user.dart';
import '../models/utility/available_sizes.dart';
import '../providers/user/user_data_provider.dart';
import '../screens/settings_screen.dart';
import '../widgets/general/expandable_widget.dart';
import '../widgets/general/image_wrapper.dart';
import '../widgets/phone/explore/card_container.dart';
import '../widgets/phone/explore/circular_button.dart';

class UserProfileArguments {
  final String id;

  UserProfileArguments(this.id);
}

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  UserProfileScreen();

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future _loadUserData;
  UserProfileArguments _arguments;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _arguments = ModalRoute.of(context).settings.arguments;

      _loadUserData = _arguments != null
          ? Provider.of<UserDataProvider>(context)
              .loadSpecifiedUserData(_arguments.id)
          : Provider.of<UserDataProvider>(context).loadUserData();
      //: Future.delayed(Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserDataProvider>(context).user;

    return Scaffold(body: SafeArea(
      child: LayoutBuilder(builder: (ctx, constraints) {
        return ScopedModel<AvailableSizes>(
          model: AvailableSizes(constraints.maxHeight - 100),
          child: FutureBuilder(
            future: _loadUserData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              bool isWaiting =
                  snapshot.connectionState == ConnectionState.waiting;

              if (snapshot.hasError && !isWaiting) {
                return LoadingError(
                  exception: snapshot.error,
                  buildContext: context,
                  retry: () => setState(() {
                    _loadUserData = _arguments != null
                        ? Provider.of<UserDataProvider>(context)
                            .loadSpecifiedUserData(_arguments.id)
                        : Provider.of<UserDataProvider>(context).loadUserData();
                  }),
                );
              }

              return AnimatedCrossFade(
                duration: Duration(milliseconds: 1500),
                crossFadeState: isWaiting
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: const Center(
                  child: const LoadingUserProfile(),
                ),
                secondChild: isWaiting
                    ? const Center()
                    : Builder(
                        builder: (BuildContext context) {
                          User user = this._arguments != null
                              ? snapshot.data
                              : Provider.of<UserDataProvider>(context).user;

                          return SingleChildScrollView(
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Column(
                                  children: <Widget>[
                                    Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: TopButtons(
                                        width: constraints.maxWidth * 0.85,
                                      ),
                                    ),
                                    CardContent(
                                      user: user,
                                      width: constraints.maxWidth * 0.9,
                                    ),
                                  ],
                                ),
                                UserImage(userPictureUrl: user.pictureUrl),
                              ],
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        );
      }),
    ));
  }
}

class TopButtons extends StatelessWidget {
  final double width;

  TopButtons({this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      child: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child: CircularButton(
                assetPath: AssetImages.BACK_ARROW,
                alignment: Alignment.centerLeft,
                width: 30,
                height: 30,
                applyElevation: false,
                onPressFunction: () => backButton(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: const Center(),
            ),
            Expanded(
              child: CircularButton(
                assetPath: AssetImages.SETTINGS,
                alignment: Alignment.centerRight,
                width: 30,
                height: 30,
                applyElevation: false,
                onPressFunction: () => goToSettingPage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void backButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goToSettingPage(BuildContext context) {
    Navigator.of(context).pushNamed(SettingsScreen.routeName);
  }
}

class UserImage extends StatelessWidget {
  final String userPictureUrl;

  UserImage({@required this.userPictureUrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      child: Container(
        alignment: Alignment.center,
        height: 120,
        width: 120,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              spreadRadius: 2.0,
              offset: Offset(2.0, 2.0),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(const Radius.circular(1000)),
          child: ImageWrapper(
            assetPath: AssetImages.USER,
            imageUrl: userPictureUrl,
          ),
        ),
      ),
    );
  }
}

class CardContent extends StatelessWidget {
  final double width;
  final User user;

  CardContent({this.width, @required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.only(bottom: 12.0),
      child: CardContainer(
        rotateCard: () {},
        canExpand: true,
        startingColor: user.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 60),
            Container(
              child: Text(
                user.completeName,
                style: Theme.of(context).textTheme.title,
              ),
            ),
            const SizedBox(height: 8),
            AutoSizeText(
              user.currentJob.workingRole + " @ ",
              style: Theme.of(context).textTheme.overline,
            ),
            AutoSizeText(
              user.currentJob.at,
              style: Theme.of(context).textTheme.overline.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ExpandableWidget(
              height: 120,
              durationInMilliseconds: 300,
              child: Container(
                alignment: Alignment.topCenter,
                child: Text(
                  user.bio,
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (user.jobExperiences.isNotEmpty)
              PastExperiencesSection(
                title: "Experience",
                experience: user.jobExperiences,
                width: width * 0.9,
              ),
            if (user.academicExperiences.isNotEmpty)
              PastExperiencesSection(
                title: "Education",
                experience: user.academicExperiences,
                width: width * 0.9,
              ),
            if (user.questions.isNotEmpty)
              QuestionSection(questions: user.questions),
            if (user.location != null) Location(location: user.location),
            const SizedBox(height: 16),
            if (user.socialAccounts.isNotEmpty)
              SocialIcons(socialAccounts: user.socialAccounts)
          ],
        ),
      ),
    );
  }
}

class PastExperiencesSection extends StatelessWidget {
  final List<PastExperience> experience;
  final double width;
  final String title;

  PastExperiencesSection({
    @required this.experience,
    @required this.width,
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(),
        AutoSizeText(
          title,
          style: Theme.of(context).textTheme.overline,
        ),
        const SizedBox(height: 8),
        Container(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: experience
                .map((e) => Container(
                      width: width * 0.9,
                      child: ExperienceElement(experience: e),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class ExperienceElement extends StatelessWidget {
  final PastExperience experience;

  ExperienceElement({@required this.experience});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 48,
          width: 48,
          child: ImageWrapper(
            imageUrl: experience.pictureUrl,
            assetPath: experience.assetPath,
            boxFit:
                experience.pictureUrl != null ? BoxFit.contain : BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(
                experience.haveDone,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
              AutoSizeText(
                experience.at,
                style: Theme.of(context).textTheme.body1,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuestionSection extends StatelessWidget {
  final List<Question> questions;

  QuestionSection({@required this.questions});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Divider(),
        ...questions
            .map((question) => [
                  Container(
                    width: double.infinity,
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.overline,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    child: Text(
                      question.answer,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 4),
                ])
            .expand((i) => i)
            .toList()
              ..removeLast()
      ],
    );
  }
}

class Location extends StatelessWidget {
  final String location;

  Location({@required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        Container(
          width: double.infinity,
          child: Text(
            "Location",
            style: Theme.of(context).textTheme.overline,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          child: Text(
            location,
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class SocialIcons extends StatelessWidget {
  final Map<String, SocialAccount> socialAccounts;

  SocialIcons({@required this.socialAccounts});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: socialAccounts.entries
          .map((e) => CircularButton(
                assetPath: AssetImages.socialAssets(e.key),
                alignment: Alignment.center,
                width: 40,
                height: 40,
                applyElevation: false,
                onPressFunction: () => _launchURL(e.value.urlAccount),
              ))
          .toList(),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class LoadingUserProfile extends StatefulWidget {
  const LoadingUserProfile();

  @override
  _LoadingUserProfileState createState() => _LoadingUserProfileState();
}

class _LoadingUserProfileState extends State<LoadingUserProfile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    gradientPosition = Tween<double>(
      begin: -2,
      end: 4,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      double maxHeight = ScopedModel.of<AvailableSizes>(context).height;

      return AnimatedBuilder(
        animation: gradientPosition,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: <Widget>[
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: TopButtons(width: constraints.maxWidth * 0.85),
                ),
                Container(
                  width: constraints.maxWidth * 0.9,
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    elevation: 8,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        minHeight: maxHeight - 12 * 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(24.0)),
                      ),
                      child: const Center(
                        child: const LoadingAnimated(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              child: Container(
                alignment: Alignment.center,
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 2.0,
                      offset: Offset(2.0, 2.0),
                    )
                  ],
                ),
                child: const Center(),
              ),
            ),
          ],
        ),
        builder: (ctx, child) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              final gradient = LinearGradient(
                begin: Alignment(gradientPosition.value, 0),
                end: Alignment(gradientPosition.value - 2, 0.5),
                colors: [
                  Colors.white,
                  ThemeProvider.primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
              );

              // using bounds directly doesn't work because the shader origin is translated already
              // so create a new rect with the same size at origin
              return gradient.createShader(Offset.zero & bounds.size);
            },
            child: child,
          );
        },
      );
    });
  }
}
