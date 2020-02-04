import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import 'package:mobile_application/widgets/phone/explore/circular_button.dart';
import 'package:provider/provider.dart';

class AddPhotoWidget extends StatefulWidget {
  final double width, height;
  final void Function(File) setImage;

  AddPhotoWidget({
    @required this.width,
    @required this.height,
    @required this.setImage,
  });

  @override
  _AddPhotoWidgetState createState() => _AddPhotoWidgetState();
}

class _AddPhotoWidgetState extends State<AddPhotoWidget> {
  File image;

  void setImage(File image) {
    if (image != null) {
      setState(() {
        this.image = image;
      });
      Navigator.pop(context);
      widget.setImage(image);
    }
  }

  void showSelection() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => BottomSheetSelection(setImage, ctx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircularButton(
          height: widget.height,
          width: widget.width,
          alignment: Alignment.center,
          assetPath: AssetImages.camera,
          onPressFunction: showSelection,
        ),
        if (image != null)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              child: Image.file(
                image,
                height: widget.height,
                width: widget.width,
                fit: BoxFit.cover,
              ),
            ),
          )
      ],
    );
  }
}

class BottomSheetSelection extends StatefulWidget {
  final void Function(File) setImage;
  final BuildContext ctx;

  BottomSheetSelection(this.setImage, this.ctx);

  @override
  _BottomSheetSelectionState createState() => _BottomSheetSelectionState();
}

class _BottomSheetSelectionState extends State<BottomSheetSelection> {
  File selectedImage;
  ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  void pickImageFromCamera() async {
    widget.setImage(await ImagePicker.pickImage(source: ImageSource.camera));
  }

  void pickImageFromGallery() async {
    widget.setImage(await FilePicker.getFile(type: FileType.IMAGE));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
        ),
        height: constraints.maxHeight / 2,
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
    });
  }
}
