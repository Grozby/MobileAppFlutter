import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/providers/explore/should_collapse_provider.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../models/users/experiences/past_experience.dart';
import '../../../models/users/mentor.dart';
import '../../../providers/explore/card_provider.dart';
import '../../button_styled.dart';
import '../../expandable_widget.dart';
import '../../faded_list_view.dart';
import '../../transition/rotation_transition_upgraded.dart';
import 'card_container.dart';
import 'explore_card.dart';
import 'explore_screen_widgets.dart';

///
/// Mentor card used in the explored. In order to retrieve the data,
/// we use a [CardProvider] to fetch the mentor data. Then, we use the
/// associated [IndexUser] model to know which mentor the card refers to.
///
class MentorCard extends StatefulWidget {
  @override
  _MentorCardState createState() => _MentorCardState();
}

class _MentorCardState extends State<MentorCard> {
  bool _isFrontCardShowing;

  @override
  void initState() {
    super.initState();
    _isFrontCardShowing = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void collapseElementInsideCard() {
    Provider.of<ShouldCollapseProvider>(context).shouldCollapseElements();
  }

  void rotateCard() {
    collapseElementInsideCard();
    setState(() {
      _isFrontCardShowing = !_isFrontCardShowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 1000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        bool isShowing = _isFrontCardShowing && child.key == ValueKey(1) ||
            !_isFrontCardShowing && child.key == ValueKey(2);
        return RotationTransitionUpgraded(
          child: child,
          turns: animation,
          isShowing: isShowing,
        );
      },
      child: _isFrontCardShowing
          ? _FrontCardMentor(key: ValueKey(1), rotateCard: rotateCard)
          : _BackCardMentor(key: ValueKey(2), rotateCard: rotateCard),
    );
  }
}

/// /////////////////////////////////////////////////////////////////////// ///
///                                                                         ///
/// Support Widget for the creation of the front card of the mentor.        ///
///                                                                         ///
/// /////////////////////////////////////////////////////////////////////// ///

///
/// Front card containing all the information about the [Mentor].
///
class _FrontCardMentor extends StatefulWidget {
  final Function rotateCard;

  _FrontCardMentor({@required this.rotateCard, key}) : super(key: key);

  @override
  _FrontCardMentorState createState() => _FrontCardMentorState();
}

class _FrontCardMentorState extends State<_FrontCardMentor> {
  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(context).getMentor(index);

    return CardContainer(
      rotateCard: widget.rotateCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              _CompanyInformationBar(),
              const Divider(),
              _MentorBasicInformation(
                isVertical: true,
              ),
              const SizedBox(height: 8),
              _MentorBio(
                height: 80,
              ),
              const Divider(),
              FadedListView<String>(
                list: mentor.workingSpecialization,
                height: 31,
                builder: _workingSpecializationBadge,
              ),
              const Divider(),
              _FavoriteLanguages(
                height: 30,
              ),
              const Divider(),
              FadedListView<PastExperience>(
                list: mentor.pastExperiences,
                height: 73,
                builder: _pastExperienceBadge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            child: ButtonStyled(
              onPressFunction: widget.rotateCard,
              fractionalWidthDimension: 0.99,
              text: "Contact him!",
            ),
          ),
        ],
      ),
    );
  }

  Widget _workingSpecializationBadge(String text) {
    return Container(
      padding: EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        child: AutoSizeText(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _pastExperienceBadge(PastExperience experience) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          experience.assetPath,
          height: 25,
          width: 40,
        ),
        AutoSizeText(
          experience.haveDone + " @",
          style: Theme.of(context).textTheme.overline,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        AutoSizeText(
          experience.at,
          style: Theme.of(context).textTheme.overline.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}

///
/// Top bar of the card that shows the information about the company in which
/// the mentor is currently working.
///
class _CompanyInformationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.all(0),
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Center(
          child: FadeInImage.memoryNetwork(
            image: mentor.urlCompanyImage,
            placeholder: kTransparentImage,
          ),
        ),
      ),
      title: AutoSizeText(
        mentor.company,
        maxLines: 1,
        style: Theme.of(context).textTheme.display2,
      ),
      subtitle: AutoSizeText(
        mentor.location,
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }
}

///
/// Widget that shows the profile picture of the mentor, together with
/// its name and working position.
///
class _MentorBasicInformation extends StatelessWidget {
  final bool isVertical;

  _MentorBasicInformation({@required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return isVertical
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _MentorBasicInformationAvatar(),
              SizedBox(height: 4),
              _MentorBasicInformationText(
                alignment: Alignment.center,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _MentorBasicInformationAvatar(),
              _MentorBasicInformationText(
                alignment: Alignment.centerLeft,
              ),
            ],
          );
  }
}

class _MentorBasicInformationAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              type: MaterialType.circle,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.white,
              elevation: 0,
              type: MaterialType.circle,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: FadeInImage.memoryNetwork(
              width: 80,
              height: 80,
              image: mentor.pictureUrl,
              placeholder: kTransparentImage,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorBasicInformationText extends StatelessWidget {
  final Alignment alignment;

  _MentorBasicInformationText({@required this.alignment});

  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: alignment,
          child: Text(
            mentor.completeName,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        SizedBox(height: 4),
        Container(
          alignment: alignment,
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                new TextSpan(
                  text: mentor.jobType + " @ ",
                  style: Theme.of(context).textTheme.overline,
                ),
                TextSpan(
                  text: mentor.company,
                  style: Theme.of(context).textTheme.overline.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

///
/// Widget that allows to show the biography of the mentor, and automatically
/// collapses it in case the biography text is to long thanks to
/// [ExpandableWidget]
///
class _MentorBio extends StatelessWidget {
  final double height;

  _MentorBio({@required this.height});

  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return ExpandableWidget(
      height: height,
      durationInMilliseconds: 300,
      child: Container(
        alignment: Alignment.topCenter,
        child: Text(
          mentor.bio,
          style: Theme.of(context).textTheme.body1,
        ),
      ),
    );
  }
}

///
/// Widget that simply shows which are the favorite programming languages
/// of the mentor.
///
class _FavoriteLanguages extends StatelessWidget {
  final double height;

  _FavoriteLanguages({@required this.height});

  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return ExpandableWidget(
      height: height,
      durationInMilliseconds: 300,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: mentor.questions.map((question) {
            return Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: Text(
                    question.question,
                    style: Theme.of(context).textTheme.overline,
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
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
              ],
            );
          }).toList()),
    );
  }
}

/// /////////////////////////////////////////////////////////////////////// ///
///                                                                         ///
/// Support Widget for the creation of the back card of the mentor.         ///
///                                                                         ///
/// /////////////////////////////////////////////////////////////////////// ///

class _BackCardMentor extends StatelessWidget {
  final Function rotateCard;

  _BackCardMentor({@required this.rotateCard, key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return CardContainer(
      canExpand: false,
      rotateCard: () {},
      child: Column(
        children: <Widget>[
          _CompanyInformationBar(),
          const Divider(),
          _MentorBasicInformation(
            isVertical: false,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.withOpacity(0.8),
                  )),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Send a message to ${mentor.name}',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            child: ButtonStyled(
              onPressFunction: rotateCard,
              fractionalWidthDimension: 0.99,
              text: "Send",
            ),
          ),
        ],
      ),
    );
  }
}

class HowToContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return Container();
  }
}
