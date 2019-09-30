import 'package:flutter/material.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../models/users/mentor.dart';
import '../button_styled.dart';
import '../expandable_widget.dart';
import '../show_grid.dart';

class MentorCard extends StatefulWidget {
  final Mentor mentor;

  const MentorCard({
    @required this.mentor,
  });

  @override
  _MentorCardState createState() => _MentorCardState();
}

class _MentorCardState extends State<MentorCard> {
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
          child: Text(text),
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
          Text(
            experience.haveDone + " @",
            style: Theme.of(context).textTheme.overline,
            textAlign: TextAlign.center,
          ),
          Text(
            experience.at,
            style: Theme.of(context).textTheme.overline.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
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
        child: FractionallySizedBox(
          widthFactor: 0.90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  CompanyInformationBar(mentor: widget.mentor),
                  Divider(),
                  MentorBasicInformation(mentor: widget.mentor),
                  SizedBox(height: 8),
                  MentorBio(mentor: widget.mentor),
                  Divider(),
                  ShowGrid<String>(
                    list: widget.mentor.workingSpecialization,
                    height: 31,
                    durationExpansion: 300,
                    builder: _workingSpecializationBadge,
                  ),
                  Divider(),
                  FavoriteLanguages(mentor: widget.mentor),
                  Divider(),
                  ShowGrid<PastExperience>(
                    list: widget.mentor.academicDegrees,
                    height: 70,
                    durationExpansion: 300,
                    builder: _pastExperienceBadge,
                  ),
                ],
              ),
              Container(
                child: ButtonStyled(
                  onPressFunction: () {},
                  fractionalWidthDimension: 0.99,
                  text: "Contact him!",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyInformationBar extends StatelessWidget {
  final Mentor mentor;

  const CompanyInformationBar({
    @required this.mentor,
  });

  @override
  Widget build(BuildContext context) {
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
      title: Text(
        mentor.company,
        style: Theme.of(context).textTheme.display2,
      ),
      trailing: Text(
        mentor.location,
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }
}

class MentorBasicInformation extends StatelessWidget {
  final Mentor mentor;

  const MentorBasicInformation({
    @required this.mentor,
  });

  @override
  Widget build(BuildContext context) {
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

class MentorBio extends StatelessWidget {
  final Mentor mentor;

  MentorBio({@required this.mentor});

  @override
  Widget build(BuildContext context) {
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

class FavoriteLanguages extends StatelessWidget {
  final Mentor mentor;

  FavoriteLanguages({@required this.mentor});

  @override
  Widget build(BuildContext context) {
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
