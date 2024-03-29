import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryfy/models/chat/contact_mentor.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/users/experiences/past_experience.dart';
import '../../../models/users/mentee.dart';
import '../../../models/users/mentor.dart';
import '../../../models/users/user.dart';
import '../../../providers/explore/card_provider.dart';
import '../../../providers/explore/questions_provider.dart';
import '../../../providers/explore/should_collapse_provider.dart';
import '../../../providers/theming/theme_provider.dart';
import '../../../providers/user/user_data_provider.dart';
import '../../../screens/user_profile_screen.dart';
import '../../../widgets/general/audio_widget.dart';
import '../../../widgets/general/custom_alert_dialog.dart';
import '../../../widgets/general/expandable_widget.dart';
import '../../../widgets/general/image_wrapper.dart';
import '../../faded_list_view.dart';
import '../../general/button_styled.dart';
import '../../transition/rotation_transition_upgraded.dart';
import 'card_container.dart';
import 'circular_button.dart';

class ExploreCard extends StatefulWidget {
  final int indexUser;

  ExploreCard({@required this.indexUser, Key key}) : super(key: key);

  @override
  _ExploreCardState createState() => _ExploreCardState();
}

class _ExploreCardState extends State<ExploreCard>
    with AutomaticKeepAliveClientMixin<ExploreCard> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    CardProvider cardProvider =
        Provider.of<CardProvider>(context, listen: false);

    /// The [ScopedModel][IndexUser] is used for determining which user
    /// we are referring to.
    /// The [ShouldCollapseProvider] instead is used for aesthetic purposes.
    /// When we turn the card, we close all the already expanded sections.
    switch (cardProvider.getUser(widget.indexUser).runtimeType) {
      case Mentee:
        return ScopedModel<IndexUser>(
          model: IndexUser(widget.indexUser),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ShouldCollapseProvider(),
              ),
              ChangeNotifierProvider.value(
                value: cardProvider.getQuestionProvider(widget.indexUser),
              ),
            ],
            child: ExploreCardContent(
              frontCard: _FrontCardContent(key: const ValueKey(1)),
              backCard: _BackCardContentMentee(key: const ValueKey(2)),
            ),
          ),
        );

      case Mentor:
        return ScopedModel<IndexUser>(
          model: IndexUser(widget.indexUser),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ShouldCollapseProvider(),
              ),
              ChangeNotifierProvider.value(
                value: cardProvider.getQuestionProvider(widget.indexUser),
              ),
            ],
            child: ExploreCardContent(
              frontCard: _FrontCardContent(key: const ValueKey(1)),
              backCard: _BackCardContentMentor(key: const ValueKey(2)),
            ),
          ),
        );
      default:
        throw Exception("Not a user!");
    }
  }
}

class IndexUser extends Model {
  final int indexUser;

  IndexUser(this.indexUser);

  static IndexUser of(BuildContext context) =>
      ScopedModel.of<IndexUser>(context);
}

///
/// Content of the card used in the explore section. In order to retrieve the data,
/// we use a [CardProvider] to fetch the mentor data. Then, we use the
/// associated [IndexUser] model to know which user the card refers to.
///
class ExploreCardContent extends StatefulWidget {
  final Widget frontCard;
  final Widget backCard;

  ExploreCardContent({
    @required this.frontCard,
    @required this.backCard,
  });

  @override
  _ExploreCardContentState createState() => _ExploreCardContentState();
}

class _ExploreCardContentState extends State<ExploreCardContent> {
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
    Provider.of<ShouldCollapseProvider>(context, listen: false)
        .shouldCollapseElements();
  }

  void rotateCard() {
    collapseElementInsideCard();
    setState(() {
      _isFrontCardShowing = !_isFrontCardShowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        transitionBuilder: (child, animation) {
          bool isShowing = _isFrontCardShowing && child.key == ValueKey(1) ||
              !_isFrontCardShowing && child.key == ValueKey(2);
          return RotationTransitionUpgraded(
            child: child,
            turns: animation,
            isShowing: isShowing,
          );
        },
        child: _isFrontCardShowing ? widget.frontCard : widget.backCard,
      ),
    );
  }
}

/// //////////////////////////////////////////////////////
///                                                    ///
/// Support Widget for the creation of the front card. ///
///                                                    ///
/// //////////////////////////////////////////////////////

mixin GetUser {
  User getUser(BuildContext context) =>
      Provider.of<CardProvider>(context, listen: false)
          .getUser(ScopedModel.of<IndexUser>(context).indexUser);

  QuestionsProvider getQuestionProvider(BuildContext context) =>
      Provider.of<CardProvider>(context, listen: false)
          .getQuestionProvider(ScopedModel.of<IndexUser>(context).indexUser);
}

mixin GetMentor {
  Mentor getMentor(BuildContext context) =>
      Provider.of<CardProvider>(context, listen: false)
          .getMentor(ScopedModel.of<IndexUser>(context).indexUser);
}

mixin GetMentee {
  Mentee getMentee(BuildContext context) =>
      Provider.of<CardProvider>(context, listen: false)
          .getMentee(ScopedModel.of<IndexUser>(context).indexUser);
}

///
/// Front card containing all the information about the [Mentor].
///
class _FrontCardContent extends StatefulWidget {
  const _FrontCardContent({key}) : super(key: key);

  @override
  _FrontCardContentState createState() => _FrontCardContentState();
}

class _FrontCardContentState extends State<_FrontCardContent> with GetUser {
  void goToProfilePage(BuildContext context) {
    Navigator.of(context).pushNamed(
      UserProfileScreen.routeName,
      arguments: UserProfileArguments(
        Provider.of<CardProvider>(context, listen: false)
            .getUser(ScopedModel.of<IndexUser>(context).indexUser)
            .id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = getUser(context);

    return CardContainer(
      onLongPress: () => goToProfilePage(context),
      startingColor: user.cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              const _CompanyInformationBar(),
              const Divider(),
              _UserBasicInformation(
                isVertical: true,
                onImageMentorLongPress: () => goToProfilePage(context),
              ),
              const SizedBox(height: 8),
              const _MentorBio(
                height: 80,
              ),
              const Divider(),
              FadedListView<String>(
                list: user.workingSpecialization,
                height: 31,
                builder: _workingSpecializationBadge,
              ),
              if (user.workingSpecialization.isNotEmpty) const Divider(),
              const _FavoriteLanguages(height: 37),
              if (user.questions.isNotEmpty) const Divider(),
              FadedListView<PastExperience>(
                list: user.experiences,
                height: 73,
                builder: _pastExperienceBadge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            child: ButtonStyled(
              onPressFunction:
                  Provider.of<_ExploreCardContentState>(context).rotateCard,
              fractionalWidthDimension: 0.99,
              text: Provider.of<UserDataProvider>(context)
                  .behavior
                  .frontCardButtonText,
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
          color: Theme.of(context).primaryColorLight,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 25,
          width: 40,
          child: ImageWrapper(assetPath: experience.assetPath),
        ),
        AutoSizeText(
          "${experience.haveDone} @",
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
class _CompanyInformationBar extends StatelessWidget with GetUser {
  const _CompanyInformationBar();

  @override
  Widget build(BuildContext context) {
    User user = getUser(context);

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
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            child: ImageWrapper(
              imageUrl: user.currentJob?.pictureUrl,
              assetPath: AssetImages.work,
            ),
          ),
        ),
      ),
      title: AutoSizeText(
        user.currentJob != null ? user.currentJob.at : "Not working",
        maxLines: 1,
        style: Theme.of(context).textTheme.display2,
      ),
      subtitle: AutoSizeText(
        user.currentJob != null ? user.location : "",
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }
}

///
/// Widget that shows the profile picture of the mentor, together with
/// its name and working position.
///
class _UserBasicInformation extends StatelessWidget {
  final bool isVertical;
  final Function onImageMentorLongPress;

  const _UserBasicInformation({
    @required this.isVertical,
    this.onImageMentorLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return isVertical
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _BasicInformationAvatar(
                onImageMentorLongPress: onImageMentorLongPress,
              ),
              const SizedBox(height: 4),
              const _MentorBasicInformationText(
                alignment: Alignment.center,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _BasicInformationAvatar(
                onImageMentorLongPress: onImageMentorLongPress,
              ),
              const _MentorBasicInformationText(
                alignment: Alignment.centerLeft,
              ),
            ],
          );
  }
}

class _BasicInformationAvatar extends StatelessWidget with GetUser {
  final Function onImageMentorLongPress;

  _BasicInformationAvatar({@required this.onImageMentorLongPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: CircularButton(
        assetPath: AssetImages.user,
        imageUrl: getUser(context).pictureUrl,
        alignment: Alignment.center,
        onPressFunction: onImageMentorLongPress,
        width: 120,
        height: 120,
      ),
    );
  }
}

class _MentorBasicInformationText extends StatelessWidget with GetUser {
  final Alignment alignment;

  const _MentorBasicInformationText({@required this.alignment});

  @override
  Widget build(BuildContext context) {
    User user = getUser(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: alignment,
          child: AutoSizeText(
            user.completeName,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        const SizedBox(height: 4),
        if (user.currentJob != null)
          Container(
            alignment: alignment,
            child: AutoSizeText.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: "${user.currentJob.workingRole} @ ",
                    style: Theme.of(context).textTheme.overline,
                  ),
                  TextSpan(
                    text: user.currentJob.at,
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
class _MentorBio extends StatelessWidget with GetUser {
  final double height;

  const _MentorBio({@required this.height});

  @override
  Widget build(BuildContext context) {
    return ExpandableWidget(
      height: height,
      durationInMilliseconds: 300,
      child: Container(
        alignment: Alignment.topCenter,
        child: Text(
          getUser(context).bio,
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
class _FavoriteLanguages extends StatelessWidget with GetUser {
  final double height;

  const _FavoriteLanguages({@required this.height});

  @override
  Widget build(BuildContext context) {
    return ExpandableWidget(
      height: height,
      durationInMilliseconds: 300,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: getUser(context).questions.map((question) {
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

class _BackCardContentMentor extends StatefulWidget {
  _BackCardContentMentor({Key key}) : super(key: key);

  @override
  _BackCardContentMentorState createState() => _BackCardContentMentorState();
}

class _BackCardContentMentorState extends State<_BackCardContentMentor>
    with GetUser {
  int questionIndex = 0;
  Color color;

  @override
  void initState() {
    super.initState();
    color = getUser(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: context,
      child: CardContainer(
        canExpand: false,
        onLongPress: () {},
        startingColor: color,
        child: Column(
          children: <Widget>[
            const _CompanyInformationBar(),
            const Divider(),
            Selector<QuestionsProvider, bool>(
              selector: (_, qProvider) => qProvider.noMoreQuestions,
              builder: (ctx, noMoreQuestions, child) {
                return noMoreQuestions
                    ? Expanded(
                        child: ContactMentor(),
                      )
                    : Expanded(
                        child: QuestionsWidget(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionsWidget extends StatefulWidget {
  const QuestionsWidget();

  @override
  QuestionsWidgetState createState() => QuestionsWidgetState();
}

class QuestionsWidgetState extends State<QuestionsWidget>
    with TimeConverter, GetMentor {
  TextEditingController textController;
  String audioPath;
  bool canWriteAnswer = true;
  bool hasStartedAnswering = false;
  StreamController notifier;

  @override
  void initState() {
    super.initState();
    notifier = StreamController.broadcast();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController?.dispose();
    notifier.close();
    super.dispose();
  }

  int getQuestionTime() {
    return getMentor(context)
        .getMentorQuestionAt(
          Provider.of<QuestionsProvider>(context, listen: false).currentIndex,
        )
        .availableTime;
  }

  void startAnswering() {
    setState(() {
      hasStartedAnswering = true;
    });
  }

  void notifyMeToStopAnswering() {
    notifier.add(null);
    setState(() => canWriteAnswer = false);
  }

  void saveAnswerAndContinue() async {
    notifier.add(null);
    await Provider.of<QuestionsProvider>(context, listen: false).insertAnswer(
      question: getMentor(context)
          .getMentorQuestionAt(
            Provider.of<QuestionsProvider>(context, listen: false).currentIndex,
          )
          .question,
      textAnswer: textController.text,
      audioFilePath: audioPath,
      context: Provider.of<BuildContext>(context, listen: false),
    );

    setState(() {
      canWriteAnswer = true;
      hasStartedAnswering = false;
      textController.clear();
    });
  }

  String getRemainingQuestionsText(int numberQuestionAnswered, Mentor mentor) {
    if (numberQuestionAnswered == 0) {
      return "To contact ${mentor.name} you have to answer "
          "${mentor.howManyQuestionsToAnswer}"
          " question${mentor.howManyQuestionsToAnswer > 1 ? "s" : ""}.\n"
          "Answer the first question in:";
    } else if (mentor.howManyQuestionsToAnswer - numberQuestionAnswered == 1) {
      return "Last question to answer for contactacting ${mentor.name}!\n"
          "You have to answer it in:";
    } else {
      return "To contact ${mentor.name} you need to answer other "
          "${mentor.howManyQuestionsToAnswer} "
          "question${mentor.howManyQuestionsToAnswer > 1 ? "s" : ""}.\n"
          "Answer the next question in:";
    }
  }

  String timeToShow(int seconds) {
    String time = timeToString(seconds * 1000).substring(0, 5);
    String timeToShow = "";
    int parsedSeconds = int.tryParse(time.substring(3, 5));
    int parsedMinutes = int.tryParse(time.substring(0, 2));

    if (parsedMinutes != 0) {
      timeToShow += "$parsedMinutes minute${parsedMinutes != 1 ? "s" : ""}";
    }

    if (int.tryParse(time.substring(3, 5)) != 0) {
      timeToShow += "${timeToShow != "" ? " and " : ""}"
          "$parsedSeconds second"
          "${(parsedSeconds != 1 ? "s" : "")}";
    }
    return timeToShow != null ? timeToShow : "1 minute";
  }

  @override
  Widget build(BuildContext context) {
    Mentor mentor = getMentor(context);

    return hasStartedAnswering

        /// This is the section in which the user can answer to the question
        /// of the mentor.
        ? Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  "${mentor.completeName} is asking you:",
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                alignment: Alignment.centerLeft,
                child: Consumer<QuestionsProvider>(
                  builder: (ctx, questionProvider, child) {
                    return AutoSizeText(
                      mentor
                          .getMentorQuestionAt(questionProvider.currentIndex)
                          .question,
                      style: Theme.of(context).textTheme.body1,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TimeCounter(
                startingCounter: getQuestionTime(),
                notifyParent: notifyMeToStopAnswering,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
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
              const SizedBox(height: 8),
              AudioWidget(
                audioFilePath: Provider.of<QuestionsProvider>(
                  context,
                  listen: false,
                ).getAudioFilePath(),
                notifier: notifier.stream,
                setPathInParent: (String newPath) => audioPath = newPath,
              ),
              const SizedBox(height: 16),
              Container(
                child: ButtonStyled(
                  onPressFunction: () => saveAnswerAndContinue(),
                  fractionalWidthDimension: 0.99,
                  text: "Continue",
                ),
              ),
            ],
          )

        /// This instead is the section where the user can see the question
        /// overview.
        : Column(
            children: <Widget>[
              const _UserBasicInformation(
                isVertical: false,
              ),
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
                  child: AutoSizeText(
                    timeToShow(getQuestionTime()),
                    style: Theme.of(context).textTheme.display3.copyWith(
                          color: ThemeProvider.primaryColor,
                        ),
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text("Start when you are ready!"),
              ),
              const SizedBox(height: 16),
              Container(
                child: ButtonStyled(
                  onPressFunction: startAnswering,
                  fractionalWidthDimension: 0.99,
                  text: "Start",
                ),
              ),
              Container(
                child: ButtonStyled(
                  onPressFunction:
                      Provider.of<_ExploreCardContentState>(context).rotateCard,
                  fractionalWidthDimension: 0.99,
                  text: "Back",
                  color: Theme.of(context).primaryColorLight,
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
  final Function notifyParent;

  const TimeCounter({
    @required this.startingCounter,
    @required this.notifyParent,
  });

  @override
  _TimeCounterState createState() => _TimeCounterState();
}

class _TimeCounterState extends State<TimeCounter> {
  int startingCounter;
  bool isCountDownActive = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    startingCounter = widget.startingCounter;
    startCounter();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startCounter() async {
    if (isCountDownActive) return;

    isCountDownActive = true;

    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        setState(() {
          startingCounter--;
        });

        if (startingCounter == 0) {
          widget.notifyParent();
          timer.cancel();
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
          child: AutoSizeText(
            "Answer in:",
            style: Theme.of(context)
                .textTheme
                .display1
                .copyWith(color: ThemeProvider.primaryColor),
          ),
        ),
        Container(
          child: AutoSizeText(
            startingCounter > 0
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
/// Widget in which the mentee can write the message for the mentor.
/// This widget will be the one that will send the request to the server.
///
class ContactMentor extends StatefulWidget {
  const ContactMentor();

  @override
  _ContactMentorState createState() => _ContactMentorState();
}

class _ContactMentorState extends State<ContactMentor> with GetMentor {
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendRequestToMentor(BuildContext context) async {
    //TODO complete exception
    try {
      await Provider.of<CardProvider>(
        context,
        listen: false,
      ).sendRequestToMentor(
        Provider.of<QuestionsProvider>(context, listen: false),
        messageController.text,
      );
    } on Exception catch (_) {
      showErrorDialog(context, "Something went wrong!");
    }
  }

  @override
  Widget build(BuildContext context) {
    Mentor mentor = getMentor(context);

    return Column(
      children: <Widget>[
        const _UserBasicInformation(isVertical: false),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
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
        Container(
          child: ButtonStyled(
            onPressFunction:
                Provider.of<_ExploreCardContentState>(context).rotateCard,
            fractionalWidthDimension: 0.99,
            text: "Back",
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ],
    );
  }
}

class _BackCardContentMentee extends StatefulWidget {
  _BackCardContentMentee({Key key}) : super(key: key);

  @override
  __BackCardContentMenteeState createState() => __BackCardContentMenteeState();
}

class __BackCardContentMenteeState extends State<_BackCardContentMentee>
    with GetUser {
  Color color;

  void decideMenteeRequest(
    BuildContext context,
    StatusRequest statusRequest,
  ) async {
    //TODO complete exception
    try {
      await Provider.of<CardProvider>(
        context,
        listen: false,
      ).decideMenteeRequest(
        Provider.of<QuestionsProvider>(context, listen: false),
        statusRequest,
      );
    } on Exception catch (_) {
      showErrorDialog(context, "Something went wrong!");
    }
  }

  @override
  void initState() {
    super.initState();
    color = getUser(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    int answerCount = 0;

    return CardContainer(
      canExpand: false,
      onLongPress: () {},
      startingColor: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const _UserBasicInformation(isVertical: false),
          Expanded(
            child: ListView(
              children: <Widget>[
                ...getQuestionProvider(context)
                    .answers
                    .map<Widget>(
                      (a) => ExpansionTile(
                        title: AutoSizeText("Question ${answerCount + 1}"),
                        children: <Widget>[
                          const Divider(),
                          Container(
                            width: double.infinity,
                            child: AutoSizeText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Question: ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  TextSpan(text: a.question),
                                ],
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          if (a.textAnswer != null || a.textAnswer != "")
                            const SizedBox(height: 8),
                          if (a.textAnswer != null || a.textAnswer != "")
                            Container(
                              width: double.infinity,
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Answer: ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    TextSpan(text: a.textAnswer),
                                  ],
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          if (a.audioAnswer != null) const SizedBox(height: 8),
                          if (a.audioAnswer != null)
                            AudioFromBufferWidget(
                              id: "${getQuestionProvider(context).userId}${answerCount++}",
                              buffer: a.audioAnswer,
                            ),
                          if (a.audioAnswer == null && a.textAnswer == null)
                            const SizedBox(height: 8),
                          if (a.audioAnswer == null && a.textAnswer == null)
                            Container(
                              width: double.infinity,
                              child: AutoSizeText("No answer given."),
                            ),
                          const SizedBox(height: 8)
                        ],
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: ButtonStyled(
                      onPressFunction: () => decideMenteeRequest(
                        context,
                        StatusRequest.accepted,
                      ),
                      fractionalWidthDimension: 0.8,
                      text: "Accept",
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: ButtonStyled(
                      onPressFunction: () => decideMenteeRequest(
                        context,
                        StatusRequest.refused,
                      ),
                      fractionalWidthDimension: 0.8,
                      text: "Decline",
                    ),
                  )
                ],
              ),
              Container(
                child: ButtonStyled(
                  onPressFunction:
                      Provider.of<_ExploreCardContentState>(context).rotateCard,
                  fractionalWidthDimension: 0.99,
                  text: "Back",
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
