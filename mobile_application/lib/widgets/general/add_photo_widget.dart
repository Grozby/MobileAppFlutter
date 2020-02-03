
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_application/models/utility/available_sizes.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import 'package:mobile_application/widgets/phone/explore/circular_button.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

class AddPhotoWidget extends StatefulWidget {
  final double width, height;


  AddPhotoWidget({this.width, this.height});

  @override
  _AddPhotoWidgetState createState() => _AddPhotoWidgetState();
}

class _AddPhotoWidgetState extends State<AddPhotoWidget> {
  File chosenImage;

  void showSelection(){
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => BottomSheetSelection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      height: widget.height,
      width: widget.width,
      alignment: Alignment.center,
      assetPath: AssetImages.camera,
      onPressFunction: showSelection,
    );
  }
}


class BottomSheetSelection extends StatefulWidget {


  @override
  _BottomSheetSelectionState createState() => _BottomSheetSelectionState();
}

class _BottomSheetSelectionState extends State<BottomSheetSelection> {
  File selectedImage;
  ThemeProvider themeProvider;
  double maxHeight;

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    maxHeight = ScopedModel.of<AvailableSizes>(context).height;
  }

  void pickImageFromCamera() async {
    selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
  }

  void pickImageFromGallery() async {
    selectedImage = await FilePicker.getFile(type: FileType.IMAGE);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      height: maxHeight / 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              'Choose photo',
              style: themeProvider.getTheme().textTheme.display2,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.camera_alt,
              color: themeProvider.getTheme().primaryColorLight,
            ),
            title: Text(
              'From camera',
              style: themeProvider.getTheme().textTheme.title.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: pickImageFromCamera,
          ),
          ListTile(
            leading: Icon(
              Icons.photo_library,
              color: themeProvider.getTheme().primaryColorLight,
            ),
            title: Text(
              'From gallery',
              style: themeProvider.getTheme().textTheme.title.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: pickImageFromGallery,
          ),
        ],
      ),
    );
  }
}