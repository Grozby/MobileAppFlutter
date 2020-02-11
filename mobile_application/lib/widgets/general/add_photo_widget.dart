import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/theming/theme_provider.dart';
import '../../widgets/general/image_wrapper.dart';

class AddPhotoWidget extends StatefulWidget {
  final double width, height;
  final void Function(File) setImage;
  final String startingImage;
  final String assetPath;

  AddPhotoWidget({
    @required this.width,
    @required this.height,
    @required this.setImage,
    @required this.startingImage,
    @required this.assetPath,
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
    return GestureDetector(
      onTap: showSelection,
      child: Stack(
        children: <Widget>[
          Container(
            height: widget.height,
            width: widget.width,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(1000)),
              child: ImageWrapper(
                assetPath: widget.assetPath,
                boxFit: BoxFit.cover,
              ),
            ),
          ),
          if (image == null)
            Container(
              height: widget.height,
              width: widget.width,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(1000)),
                child: ImageWrapper(
                  assetPath: widget.assetPath,
                  boxFit: BoxFit.cover,
                  imageUrl: widget.startingImage,
                ),
              ),
            ),
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(1000)),
              child: Image.file(
                image,
                height: widget.height,
                width: widget.width,
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            top: widget.height * (2 / 3),
            left: widget.width * (2 / 3),
            child: Container(
              height: widget.height / 3,
              width: widget.width / 3,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColorLight,
              ),
              child: Icon(Icons.add, size: 20),
            ),
          )
        ],
      ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Wrap(
        children: <Widget>[
          ListTile(
            title: Text(
              'Choose photo',
              style: Theme.of(context).textTheme.display2,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.camera_alt,
              color: Theme.of(context).primaryColorLight,
            ),
            title: Text(
              'From camera',
              style: Theme.of(context).textTheme.title.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: pickImageFromCamera,
          ),
          ListTile(
            leading: Icon(
              Icons.photo_library,
              color: Theme.of(context).primaryColorLight,
            ),
            title: Text(
              'From gallery',
              style: Theme.of(context).textTheme.title.copyWith(
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
              style: Theme.of(context).textTheme.title.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: deleteImage,
          )
        ],
      ),
    );
  }
}
