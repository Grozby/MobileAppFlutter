import 'package:flutter/cupertino.dart';
import 'package:mobile_application/models/users/user.dart';
import 'package:mobile_application/widgets/general/user_profile_edit_widgets.dart';

class EditProfileControllerProvider extends ChangeNotifier {
  TextEditingController nameController;
  TextEditingController surnameController;
  TextEditingController bioController;
  TextEditingController locationController;

  JobController currentJobController;

  bool haveQuestions;
  List<String> _availableQuestions = [
    'What are your favourite programming languages?',
    'What inspires you the most in your work?',
  ];
  Map<String, QuestionController> questionsController = {};

  int indexJobExperiences = 0;
  Map<int, JobController> jobExperiences = {};
  int indexAcademicExperiences = 0;
  Map<int, AcademicDegreeController> academicExperiences = {};

  EditProfileControllerProvider(User user) {
    nameController = TextEditingController(text: user.name);
    surnameController = TextEditingController(text: user.surname);
    bioController = TextEditingController(text: user.bio);
    locationController = TextEditingController(text: user.location);

    currentJobController = JobController();


    haveQuestions = user.questions.isNotEmpty;
    user.questions.forEach((q) {
      questionsController[q.question] = QuestionController(
        question: q.question,
        answer: q.answer,
      );
    });

    user.jobExperiences.forEach((j) {
      jobExperiences[indexJobExperiences] = JobController(
        index: indexJobExperiences,
        imageUrl: j?.pictureUrl,
        nameInstitution: j?.at,
        workingRole: j.workingRole,
        fromDate: j?.fromDate,
        toDate: j?.toDate,
      );

      indexJobExperiences++;
    });

    user.academicExperiences.forEach((a) {
      academicExperiences[indexAcademicExperiences] = AcademicDegreeController(
        index: indexAcademicExperiences,
        imageUrl: a?.pictureUrl,
        nameInstitution: a?.at,
        degreeLevel: a.degreeLevel,
        fieldOfStudy: a.fieldOfStudy,
        fromDate: a?.fromDate,
        toDate: a?.toDate,
      );

      indexAcademicExperiences++;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    bioController.dispose();
    locationController.dispose();

    currentJobController.dispose();

    questionsController.forEach((index, controller) => controller.dispose());
    jobExperiences.forEach((index, controller) => controller.dispose());
    academicExperiences.forEach((index, controller) => controller.dispose());

    super.dispose();
  }

  void addJobExperience() {
    jobExperiences[indexJobExperiences] = JobController(
      index: indexJobExperiences,
    );
    indexJobExperiences++;
    notifyListeners();
  }

  void addAcademicExperience() {
    academicExperiences[indexAcademicExperiences] = AcademicDegreeController(
      index: indexAcademicExperiences,
    );
    indexAcademicExperiences++;
    notifyListeners();
  }

  void addQuestion(String question) {
    questionsController[question] = QuestionController(
      question: question,
      isExpanded: true,
    );

    notifyListeners();
  }

  void removeQuestion(String question) {
    questionsController.remove(question)..dispose();
    notifyListeners();
  }

  Map<String, dynamic> retrievePatchBody() {
    Map<String, dynamic> patchData = {};
    patchData["name"] = nameController.text;
    patchData["surname"] = surnameController.text;
    patchData["bio"] = bioController.text;
    patchData["location"] = locationController.text;

    if (currentJobController.nameInstitution != "") {
      patchData["currentJob"] = getJobExperience(currentJobController);
    }

    if(haveQuestions){
      patchData["questions"] = [];
    }
    if(questionsController.isNotEmpty){
      patchData["questions"] = questionsController.values
          .map<Map<String, dynamic>>((entry) => getQuestion(entry))
          .toList();
    }

    if (indexJobExperiences > 0) {
      patchData["experienceList"] = [];
    }
    if (jobExperiences.isNotEmpty) {
      patchData["experienceList"] = jobExperiences.values
          .map<Map<String, dynamic>>((entry) => getJobExperience(entry))
          .toList();
    }

    if (indexAcademicExperiences > 0) {
      patchData["educationList"] = [];
    }
    if (academicExperiences.isNotEmpty) {
      patchData["educationList"] = academicExperiences.values
          .map<Map<String, dynamic>>((entry) => getAcademicExperience(entry))
          .toList();
    }

    return patchData;
  }

  Map<String, dynamic> getJobExperience(JobController job) {
    return {
      "kind": "Job",
      "institution": {
        "name": job.nameInstitution,
        "pictureUrl": job?.institutionImage
      },
      "workingRole": job.workingRole,
      "fromDate": job.fromDate,
      "toDate": job.toDate,
    };
  }

  Map<String, dynamic> getAcademicExperience(AcademicDegreeController a) {
    return {
      "kind": "Education",
      "institution": {
        "name": a.nameInstitution,
        "pictureUrl": a?.institutionImage
      },
      "degreeLevel": a.degreeLevel,
      "fieldOfStudy": a.fieldOfStudy,
      "fromDate": a.fromDate,
      "toDate": a.toDate,
    };
  }

  Map<String, dynamic> getQuestion(QuestionController q){
    return {
      "question": q.question,
      "answer": q.answer,
    };
  }

  List<String> get currentAvailableQuestions => _availableQuestions.toList()
    ..removeWhere((e) => questionsController.keys.toList().contains(e));
}
