import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';
import '../../widgets/button_styled.dart';

class ExploreCard extends StatelessWidget {
  final User user;

  ExploreCard({
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    switch (user.runtimeType) {
      case Mentee:
        Mentee m = user as Mentee;
        return Card();
      case Mentor:
        return MentorCard(
          mentor: user as Mentor,
        );
      default:
        throw Exception();
    }
  }
}

///
/// Mentor Explore Card
///
class MentorCard extends StatefulWidget {
  final Mentor mentor;

  const MentorCard({
    @required this.mentor,
  });

  @override
  _MentorCardState createState() => _MentorCardState();
}

class _MentorCardState extends State<MentorCard> with TickerProviderStateMixin {
  bool _isExpanded;
  final double _heightText = 100;
  GlobalKey _keyFoldChild;
  double _childWidth;
  AnimationController _controller;
  Animation<double> _sizeAnimation;

  void _afterLayout(_) {
    final RenderBox renderBox = _keyFoldChild.currentContext.findRenderObject();
    _sizeAnimation =
        Tween<double>(begin: _heightText, end: renderBox.size.height).animate(_controller);
    _childWidth = renderBox.size.width;
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _keyFoldChild = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  CompanyInformationBar(
                    mentor: widget.mentor,
                  ),
                  Divider(),
                  MentorBasicInformation(
                    mentor: widget.mentor,
                  ),
                  SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _controller,

                    builder: (context, child) {
                      return ClipRect(
                        child: SizedOverflowBox(
                          alignment: Alignment.topCenter,
                          size: Size(double.infinity, _sizeAnimation?.value ?? _heightText ),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: _keyFoldChild,
                      child: InkWell(
                        hoverColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                            if (_isExpanded) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: Text(
                            widget.mentor.bio,
                            style: Theme.of(context).textTheme.body1,
                          ),
                        )
                      ),
                    ),
                  ),
                  Divider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Favourite programming languages...",
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
                          widget.mentor.favoriteLanguagesString,
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                  Divider(),
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
