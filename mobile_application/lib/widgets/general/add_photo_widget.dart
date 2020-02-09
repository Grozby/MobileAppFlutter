import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/theming/theme_provider.dart';
import '../../widgets/general/image_wrapper.dart';
import '../../widgets/phone/explore/circular_button.dart';

class AddPhotoWidget extends StatefulWidget {
  final double width, height;
  final void Function(File) setImage;
  final String startingImage;

  AddPhotoWidget({
    @required this.width,
    @required this.height,
    @required this.setImage,
    @required this.startingImage,
  });

  @override
  _AddPhotoWidgetState createState() => _AddPhotoWidgetState();
}

class _AddPhotoWidgetState extends State<AddPhotoWidget> {
  File image;
  String startingImage;

  @override
  void initState() {
    super.initState();
    startingImage = widget.startingImage;
  }

  void setImage(File image) {
    setState(() {
      startingImage = null;
      this.image = image;
    });
    Navigator.pop(context);
    widget.setImage(image);
  }

  void showSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
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
          reduceFactor: 1,
        ),
        if (image == null && widget.startingImage != null)
          GestureDetector(
            onTap: showSelection,
            child: Container(
              height: widget.height,
              width: widget.width,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                child: ImageWrapper(
                  assetPath: AssetImages.camera,
                  boxFit: BoxFit.cover,
                  imageUrl: widget.startingImage,
                ),
              ),
            ),
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

  void deleteImage() {
    widget.setImage(null);
  }

  void pickImageFromCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      widget.setImage(image);
    }
  }

  void pickImageFromGallery() async {
    File image = await FilePicker.getFile(type: FileType.IMAGE);
    if (image != null) {
      widget.setImage(image);
    }
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
        height: constraints.maxHeight * (2 / 3),
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
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: Text(
                'Delete',
                style: themeProvider.getTheme().textTheme.title.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
              onTap: deleteImage,
            )
          ],
        ),
      );
    });
  }
}
