import 'package:flutter/cupertino.dart';
import 'package:mobile_application/models/users/user.dart';
import 'package:mobile_application/widgets/general/user_profile_edit_widgets.dart';

class EditProfileControllerProvider extends ChangeNotifier {
  TextEditingController nameController;
  TextEditingController surnameController;
  TextEditingController bioController;
  TextEditingController locationController;

  int indexJobExperiences = 0;
  Map<int, JobController> jobExperiences = {};


  EditProfileControllerProvider(User user) {nameController = TextEditingController(text: user.name);
    surnameController = TextEditingController(text: user.surname);
    bioController = TextEditingController(text: user.bio);
    locationController = TextEditingController(text: user.location);

    user.jobExperiences.forEach(
          (j) {
        jobExperiences[indexJobExperiences] = JobController(
          index: indexJobExperiences,
          imageUrl: j?.pictureUrl,
          nameInstitution: j?.at,
          workingRole: j.workingRole,
          fromDate: j?.fromDate,
          toDate: j?.toDate,
        );

        indexJobExperiences++;
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    bioController.dispose();
    locationController.dispose();

    jobExperiences.forEach((index, controller) => controller.dispose());

    super.dispose();
  }

  void addJobExperience() {
    jobExperiences[indexJobExperiences] = JobController();
    indexJobExperiences++;
    notifyListeners();
  }

  Map<String, dynamic> retrievePatchBody() {
    Map<String, dynamic> patchData = {};
    patchData["name"] = nameController.text;
    patchData["surname"] = surnameController.text;
    patchData["bio"] = bioController.text;
    patchData["location"] = locationController.text;
    if (jobExperiences.isNotEmpty) {
      patchData["experienceList"] = jobExperiences.values
          .map<Map<String, dynamic>>((entry) => getJobExperience(entry))
          .toList();
    }

    return patchData;
  }

  Map<String, dynamic> getJobExperience(JobController job) {
    return {
      "kind": "Job",
      "institution": {
        "name": job.nameInstitutionController.text,
        "pictureUrl": job?.institutionImage
      },
      "workingRole": job.workingRoleController.text,
      "fromDate": job.fromDate.toIso8601String(),
      "toDate": job.toDate?.toIso8601String(),
    };
  }
}