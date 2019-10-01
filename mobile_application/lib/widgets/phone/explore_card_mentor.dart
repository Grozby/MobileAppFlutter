import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';
import 'package:mobile_application/providers/explore/card_provider.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../models/users/mentor.dart';
import '../button_styled.dart';
import '../expandable_widget.dart';
import '../show_grid.dart';
import 'explore_card.dart';

class MentorCard extends StatefulWidget {
  MentorCard();

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
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: _isFrontCardShowing
          ? FrontCardMentor()
          : Container(
              color: Colors.red,
            ),
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
class FrontCardMentor extends StatefulWidget {
  @override
  _FrontCardMentorState createState() => _FrontCardMentorState();
}

class _FrontCardMentorState extends State<FrontCardMentor> {
  @override
  Widget build(BuildContext context) {
    CardProvider cardProvider = Provider.of<CardProvider>(context);
    int index = ScopedModel.of<IndexUser>(context).indexUser;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4],
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.10),
              const Color(0xFFFFFF),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                CompanyInformationBar(),
                Divider(),
                MentorBasicInformation(),
                SizedBox(height: 8),
                MentorBio(),
                Divider(),
                ShowGridInPairs<String>(
                  list: cardProvider.getMentor(index).workingSpecialization,
                  height: 31,
                  durationExpansion: 300,
                  builder: _workingSpecializationBadge,
                ),
                Divider(),
                FavoriteLanguages(),
                Divider(),
                ShowGridInPairs<PastExperience>(
                  list: cardProvider.getMentor(index).pastExperiences,
                  height: 70,
                  durationExpansion: 300,
                  builder: _pastExperienceBadge,
                ),
              ],
            ),
            SizedBox(height: 4),
            Container(
              child: ButtonStyled(
                onPressFunction: () {
                  cardProvider.changeSelectedUser(Verse.RIGHT);
                },
                fractionalWidthDimension: 0.99,
                text: "Contact him!",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workingSpecializationBadge(String text) {
    return Expanded(
      child: Container(
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
      ),
    );
  }

  Widget _pastExperienceBadge(PastExperience experience) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Image.asset(
            experience.assetPath,
            scale: 1.5,
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
      ),
    );
  }
}

///
/// Top bar of the card that shows the information about the company in which
/// the mentor is currently working.
///
class CompanyInformationBar extends StatelessWidget {
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
class MentorBasicInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
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
        ),
        SizedBox(height: 4),
        Container(
          alignment: Alignment.center,
          child: Text(
            mentor.completeName,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        SizedBox(height: 4),
        Container(
          alignment: Alignment.center,
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
class MentorBio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return ExpandableWidget(
      height: 80,
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
class FavoriteLanguages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Text(
            "Favorite programming languages...",
            style: Theme.of(context).textTheme.overline,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          width: double.infinity,
          child: Text(
            mentor.favoriteLanguagesString,
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
        )
      ],
    );
  }
}
