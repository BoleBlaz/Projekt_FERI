import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:projekt/screens/previewPage.dart';
import 'package:projekt/models/user.dart';

class AddFace extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final int userfa;
  const AddFace({Key? key, required this.cameras, required this.userfa})
      : super(key: key);

  @override
  _AddFaceState createState() => _AddFaceState();
}

class _AddFaceState extends State<AddFace> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  List<XFile> pictureList = [];
  int imageCount = 0;

  @override
  void dispose() {
    _cameraController.dispose();
    pictureList.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![1]);
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      setState(() {
        pictureList.add(picture);
      });
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera error $e");
    }
  }

  Future takePicturesRepeatedly() async {
    for (int i = 0; i < 20; i++) {
      //await Future.delayed(Duration(milliseconds: 500));
      await takePicture();
      setState(() {
        imageCount = pictureList.length;
      });
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewPage(
                  pictureList: pictureList,
                )));
  }

  Future takePictureLogin() async {
    await takePicture();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewPage(
                  pictureList: pictureList,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        icon: Icon(
                          _isRearCameraSelected
                              ? CupertinoIcons.switch_camera
                              : CupertinoIcons.switch_camera_solid,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() =>
                              _isRearCameraSelected = !_isRearCameraSelected);
                          initCamera(
                              widget.cameras![_isRearCameraSelected ? 0 : 1]);
                        },
                      ),
                    ),
                    Text(
                      imageCount.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Expanded(
                      child: widget.userfa == 1
                          ? IconButton(
                              onPressed: takePictureLogin,
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.circle, color: Colors.red),
                            )
                          : IconButton(
                              onPressed: takePicturesRepeatedly,
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon:
                                  const Icon(Icons.circle, color: Colors.white),
                            ),
                    ),
                    Expanded(
                      child: widget.userfa == 1
                          ? Text(
                              "<-- CLICK TO ADD 1 LOGIN IMAGES",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            )
                          : 
                          Text(
                              "<-- CLICK TO ADD 20 REGISTER IMAGES",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
