import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/providers/explore/questions_provider.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/widgets/general/custom_alert_dialog.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import '../../../providers/explore/should_collapse_provider.dart';
import '../../../widgets/general/expandable_widget.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../models/users/experiences/past_experience.dart';
import '../../../models/users/mentor.dart';
import '../../../providers/explore/card_provider.dart';
import '../../general/button_styled.dart';
import '../../faded_list_view.dart';
import '../../transition/rotation_transition_upgraded.dart';
import 'card_container.dart';
import 'explore_card.dart';

///
/// Mentor card used in the explored. In order to retrieve the data,
/// we use a [CardProvider] to fetch the mentor data. Then, we use the
/// associated [IndexUser] model to know which mentor the card refers to.
///
class MentorCard extends StatefulWidget {
  const MentorCard();

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
      duration: const Duration(milliseconds: 1000),
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
          ? _FrontCardMentor(key: const ValueKey(1), rotateCard: rotateCard)
          : _BackCardMentor(key: const ValueKey(2), rotateCard: rotateCard),
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

  const _FrontCardMentor({@required this.rotateCard, key}) : super(key: key);

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
      startingColor: mentor.cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              const _CompanyInformationBar(),
              const Divider(),
              const _MentorBasicInformation(
                isVertical: true,
              ),
              const SizedBox(height: 8),
              const _MentorBio(
                height: 80,
              ),
              const Divider(),
              FadedListView<String>(
                list: mentor.workingSpecialization,
                height: 31,
                builder: _workingSpecializationBadge,
              ),
              const Divider(),
              const _FavoriteLanguages(
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
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: const BorderRadius.all(const Radius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
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
  const _CompanyInformationBar();

  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(const Radius.circular(100)),
            child: ImageWrapper(
              imageUrl: mentor.currentJob.companyImageUrl,
              assetPath: "message.png",
            ),
          ),
        ),
      ),
      title: AutoSizeText(
        mentor.currentJob.company,
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

  const _MentorBasicInformation({@required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return isVertical
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const _MentorBasicInformationAvatar(),
              const SizedBox(height: 4),
              const _MentorBasicInformationText(
                alignment: Alignment.center,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const _MentorBasicInformationAvatar(),
              const _MentorBasicInformationText(
                alignment: Alignment.centerLeft,
              ),
            ],
          );
  }
}

class _MentorBasicInformationAvatar extends StatelessWidget {
  const _MentorBasicInformationAvatar();

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
          const Positioned.fill(
            child: const Material(
              color: Colors.transparent,
              elevation: 8,
              type: MaterialType.circle,
            ),
          ),
          const Positioned.fill(
            child: const Material(
              color: Colors.white,
              elevation: 0,
              type: MaterialType.circle,
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.all(const Radius.circular(100)),
            child: Container(
              width: 80,
              height: 80,
              child: ImageWrapper(
                assetPath: "user.png",
                imageUrl: mentor.pictureUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorBasicInformationText extends StatelessWidget {
  final Alignment alignment;

  const _MentorBasicInformationText({@required this.alignment});

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
        const SizedBox(height: 4),
        Container(
          alignment: alignment,
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: mentor.currentJob.workingRole + " @ ",
                  style: Theme.of(context).textTheme.overline,
                ),
                TextSpan(
                  text: mentor.currentJob.company,
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

  const _MentorBio({@required this.height});

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

  const _FavoriteLanguages({@required this.height});

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
                const SizedBox(height: 2),
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

class _BackCardMentor extends StatefulWidget {
  final Function rotateCard;

  _BackCardMentor({@required this.rotateCard, key}) : super(key: key);

  @override
  __BackCardMentorState createState() => __BackCardMentorState();
}

class __BackCardMentorState extends State<_BackCardMentor> {
  int questionIndex = 0;
  Color color;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      int index = ScopedModel.of<IndexUser>(context).indexUser;
      color = Provider.of<CardProvider>(
        context,
        listen: false,
      ).getMentor(index).cardColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      canExpand: false,
      rotateCard: widget.rotateCard,
      startingColor: color,
      child: Column(
        children: <Widget>[
          const _CompanyInformationBar(),
          const Divider(),
          Selector<QuestionsProvider, bool>(
            selector: (_, qProvider) => qProvider.noMoreQuestions,
            builder: (ctx, noMoreQuestions, child) {
              return noMoreQuestions
                  ? const Expanded(child: const ContactMentor())
                  : const Expanded(child: const QuestionsWidget());
            },
          ),
        ],
      ),
    );
  }
}

class QuestionsWidget extends StatefulWidget {
  const QuestionsWidget();

  @override
  _QuestionsWidgetState createState() => _QuestionsWidgetState();
}

class _QuestionsWidgetState extends State<QuestionsWidget> {
  StreamController timeStreamNotifier;
  final textController = TextEditingController();
  bool canWriteAnswer = true;
  bool hasStartedAnswering = false;
  int startingCounter = 120;

  @override
  void initState() {
    super.initState();
    timeStreamNotifier = StreamController.broadcast();
    Future.delayed(Duration.zero, () {
      int index = ScopedModel.of<IndexUser>(context).indexUser;
      Mentor mentor = Provider.of<CardProvider>(
        context,
        listen: false,
      ).getMentor(index);
      startingCounter = mentor
          .getMentorQuestionAt(
            Provider.of<QuestionsProvider>(context).currentIndex,
          )
          .availableTime;
    });
  }

  @override
  void dispose() {
    timeStreamNotifier.close();
    textController.dispose();
    super.dispose();
  }

  void startAnswering() {
    setState(() {
      hasStartedAnswering = true;
    });
  }

  void notifyMeToStopAnswering() {
    setState(() => canWriteAnswer = false);
  }

  void notifyMeAndContinue() {
    Provider.of<QuestionsProvider>(context).insertAnswer(textController.text);

    setState(() {
      canWriteAnswer = true;
      hasStartedAnswering = false;
      textController.clear();
    });
  }

  String getRemainingQuestionsText(int numberQuestionAnswered, Mentor mentor) {
    if (numberQuestionAnswered == 0) {
      return "To contact ${mentor.name} you have to answer "
          "${mentor.howManyQuestionsToAnswer} "
          "question${mentor.howManyQuestionsToAnswer > 1 ? "s" : ""}."
          "Answer the first question in:";
    } else if (mentor.howManyQuestionsToAnswer - numberQuestionAnswered == 1) {
      return "Last question to answer for contactacting ${mentor.name}!"
          "You have to answer it in:";
    } else {
      return "To contact ${mentor.name} you need to answer other "
          "${mentor.howManyQuestionsToAnswer} "
          "question${mentor.howManyQuestionsToAnswer > 1 ? "s" : ""}"
          "Answer the next question in:";
    }
  }

  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    //Send an event into the timeStreamNotifier, in order to start the
    //timer. We delay it in order to first build the widgets, then call the
    //stream.
    Future.delayed(Duration.zero, () => timeStreamNotifier.sink.add(null));

    return hasStartedAnswering

        /// This is the section in which the user can answer to the question
        /// of the mentor.
        ? Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${mentor.completeName} is asking you:",
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                alignment: Alignment.centerLeft,
                child: Consumer<QuestionsProvider>(
                  builder: (ctx, provider, child) {
                    return Text(
                      mentor
                          .getMentorQuestionAt(provider.currentIndex)
                          .question,
                      style: Theme.of(context).textTheme.body1,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TimeCounter(
                startingCounter: startingCounter,
                startCounterStream: timeStreamNotifier.stream,
                notifyParent: notifyMeToStopAnswering,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(12)),
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Answer here...',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    enabled: canWriteAnswer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                child: ButtonStyled(
                  onPressFunction: notifyMeAndContinue,
                  fractionalWidthDimension: 0.99,
                  text: "Continue",
                ),
              ),
            ],
          )

        /// This instead is the section where the user can answer to the
        /// question
        : Column(
            children: <Widget>[
              const _MentorBasicInformation(isVertical: false),
              const SizedBox(height: 16),
              Consumer<QuestionsProvider>(
                builder: (ctx, qProvider, child) {
                  return Container(
                    child: Text(
                      getRemainingQuestionsText(
                        qProvider.currentIndex,
                        mentor,
                      ),
                      style: Theme.of(context).textTheme.body1,
                    ),
                  );
                },
              ),
              Expanded(
                flex: 4,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${(startingCounter / 60).floor()} minutes",
                    style: Theme.of(context).textTheme.display3.copyWith(
                          color: ThemeProvider.primaryColor,
                        ),
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: const Text("Start when you are ready!"),
              ),
              const SizedBox(height: 16),
              Container(
                child: ButtonStyled(
                  onPressFunction: startAnswering,
                  fractionalWidthDimension: 0.99,
                  text: "Start",
                ),
              ),
            ],
          );
  }
}

///
/// Widget that shows a countdown. The number of seconds for the countdown is
/// given by the [startingCounter] parameter. [startCounterStream] is the stream
/// that dictates when the counter should start. [notifyParent] on the other
/// end is the callback function that notifies the parent that the countdown as
/// ended.
///
class TimeCounter extends StatefulWidget {
  final int startingCounter;
  final Stream startCounterStream;
  final Function notifyParent;

  const TimeCounter({
    @required this.startingCounter,
    @required this.startCounterStream,
    @required this.notifyParent,
  }) : assert(startCounterStream != null);

  @override
  _TimeCounterState createState() => _TimeCounterState();
}

class _TimeCounterState extends State<TimeCounter> {
  int startingCounter = 120;
  bool isCountDownActive = false;
  StreamSubscription streamSubscription;
  Stream startCounterStream;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    startingCounter = widget.startingCounter;
    startCounterStream = widget.startCounterStream;
    streamSubscription = startCounterStream.listen((_) => startCounter());
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    _timer.cancel();
    super.dispose();
  }

  void startCounter() async {
    if (isCountDownActive) return;

    isCountDownActive = true;

    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (startingCounter > 0) {
          setState(() {
            startingCounter--;
          });
        } else {
          timer.cancel();
          widget.notifyParent();
        }
      },
    );
  }

  int get minutes => (startingCounter / 60).floor();

  int get seconds => startingCounter % 60;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            "Answer in:",
            style: Theme.of(context)
                .textTheme
                .display1
                .copyWith(color: ThemeProvider.primaryColor),
          ),
        ),
        Container(
          child: Text(
            startingCounter != 0
                ? "$minutes:${seconds.toString().padLeft(2, '0')}"
                : "Time's up!",
            style: Theme.of(context)
                .textTheme
                .display3
                .copyWith(color: ThemeProvider.primaryColor),
          ),
        ),
      ],
    );
  }
}

///
///
/// Widget in which the mentee can write the message for the mentor.
/// This widget will be the one that will send the request to the server.
///
class ContactMentor extends StatefulWidget {
  const ContactMentor();

  @override
  _ContactMentorState createState() => _ContactMentorState();
}

class _ContactMentorState extends State<ContactMentor> {
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendRequestToMentor(BuildContext context) async {
    //TODO complete exception
    try {
      await Provider.of<CardProvider>(context).sendRequestToMentor(
        Provider.of<QuestionsProvider>(context).answers,
        messageController.text,
      );
    } on Exception catch (e) {
      showErrorDialog(context, "Something went wrong!");
    }
  }

  @override
  Widget build(BuildContext context) {
    int index = ScopedModel.of<IndexUser>(context).indexUser;
    Mentor mentor = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getMentor(index);

    return Column(
      children: <Widget>[
        const _MentorBasicInformation(isVertical: false),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(12)),
              border: Border.all(
                width: 1,
                color: Colors.grey.shade300,
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Send a message to ${mentor.name}...',
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
            onPressFunction: () => sendRequestToMentor(context),
            fractionalWidthDimension: 0.99,
            text: "Send",
          ),
        ),
      ],
    );
  }
}
