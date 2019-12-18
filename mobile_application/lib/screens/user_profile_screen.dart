import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/models/users/question.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../helpers/asset_images.dart';
import '../models/users/experiences/past_experience.dart';
import '../models/users/user.dart';
import '../models/utility/available_sizes.dart';
import '../providers/user/user_data_provider.dart';
import '../screens/settings_screen.dart';
import '../widgets/general/expandable_widget.dart';
import '../widgets/general/image_wrapper.dart';
import '../widgets/phone/explore/card_container.dart';
import '../widgets/phone/explore/circular_button.dart';

class UserProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  final User user;

  UserProfileScreen({this.user});

  @override
  Widget build(BuildContext context) {
    User user = this.user == null
        ? Provider.of<UserDataProvider>(context).user
        : this.user;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (ctx, constraints) {
          return ScopedModel<AvailableSizes>(
            model: AvailableSizes(constraints.maxHeight),
            child: SingleChildScrollView(
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
                      CardContent(
                        user: user,
                        width: constraints.maxWidth * 0.9,
                      ),
                    ],
                  ),
                  UserImage(userPictureUrl: user.pictureUrl),
                ],
              ),
            ),
          );
        }),
      ),
    );
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
            if (user.questions.isNotEmpty)
              QuestionSection(questions: user.questions),
            if (user.questions.isNotEmpty)
              QuestionSection(questions: user.questions),
            if (user.location != null) ...[
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
                  user.location,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
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
                  )
                ])
            .expand((i) => i)
            .toList()
      ],
    );
  }
}
