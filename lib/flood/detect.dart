import 'dart:async';

import 'package:depthblue3/extra/toast.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

import 'dart:io';

import '../extra/slider.dart';
import 'analysis.dart';

class FloodDetect extends StatefulWidget {
  const FloodDetect({super.key});

  @override
  State<FloodDetect> createState() => _FloodDetectState();
}

class _FloodDetectState extends State<FloodDetect> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  late List _output;

  bool isCapturing = false;
  bool isCameraInitialized = false;
  bool loading = false;
  bool _sliderVisible = false;

  double _threshold = 0.5;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras[0];

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      await _cameraController.initialize();
      await _cameraController.setFlashMode(FlashMode.off);

      setState(() {
        isCameraInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          'Error initializing camera',
          Colors.red,
          Colors.white,
          bottom: 100,
          horizontal: {'left': 100.0, 'right': 100.0},
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  loadmodel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model/model_unquant.tflite',
        labels: 'assets/model/labels.txt',
      );
    } catch (e) {
      showToastErr('Error loading model');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Detector'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: isCameraInitialized
                    ? _cameraController.value.aspectRatio
                    : 16 / 9,
                child: isCameraInitialized
                    ? CameraPreview(_cameraController)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          if (_sliderVisible)
            // Padding(
            //   // padding: const EdgeInsets.all(16.0),
            //   child:
            DiscreteSlider(
              value: _threshold,
              onChanged: (value) {
                setState(() {
                  _threshold = value;
                });
              },
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: 'Threshold',
            ),
          // ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _toggleFlashlight,
                        icon: const Icon(
                          Icons.flash_on,
                          size: 30,
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: 'flood1',
                        onPressed: isCameraInitialized && !loading
                            ? _captureAndAnalyze
                            : null,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.camera,
                                size: 36,
                              ),
                      ),
                      IconButton(
                        onPressed: () {
                          _toggleSliderVisibility();
                        },
                        icon: const Icon(Icons.switch_access_shortcut,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSliderVisibility() {
    setState(() {
      _sliderVisible = !_sliderVisible;
    });
  }

  void _toggleFlashlight() {
    try {
      if (_cameraController.value.flashMode == FlashMode.off) {
        _cameraController.setFlashMode(FlashMode.torch);
        showToast(
          context,
          'Flashlight on',
          Colors.blueGrey,
          Colors.white,
          top: 100,
          horizontal: {'left': 130.0, 'right': 130.0},
        );
      } else {
        _cameraController.setFlashMode(FlashMode.off);
        showToast(
          context,
          'Flashlight off',
          Colors.blueGrey,
          Colors.white,
          top: 100,
          horizontal: {'left': 130.0, 'right': 130.0},
        );
      }
    } catch (e) {
      showToast(
        context,
        'Error toggling flashlight',
        Colors.red,
        Colors.white,
        bottom: 100,
        horizontal: {'left': 100.0, 'right': 100.0},
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<bool> _detectForFlooding(File image) async {
    try {
      setState(() {
        loading = true;
      });

      var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: _threshold,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _output = prediction!;
        loading = false;
      });

      bool isFloodDetected = _output.any(
        (element) =>
            (element['label']
                    .toString()
                    .toLowerCase()
                    .contains('inundated flood') ||
                element['label'].toString().toLowerCase().contains('low') ||
                element['label'].toString().toLowerCase().contains('medium')) &&
            element['confidence'] >= 0.95,
      );

      return isFloodDetected;
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          'Error',
          Colors.red,
          Colors.white,
          top: 100,
          horizontal: {'left': 150.0, 'right': 150.0},
          duration: const Duration(seconds: 2),
        );
      }
      setState(() {
        loading = false;
      });
      if (mounted) {
        showToast(
          context,
          'Error processing image',
          Colors.red,
          Colors.white,
          bottom: 100,
          horizontal: {'left': 100.0, 'right': 100.0},
          duration: const Duration(seconds: 2),
        );
      }
      return false;
    }
  }

  Future<void> _captureAndAnalyze() async {
    try {
      if (isCapturing) {
        showToast(
          context,
          'Don\'t tap too fast..',
          Colors.red,
          Colors.white,
          bottom: 100,
          horizontal: {'left': 120.0, 'right': 120.0},
          duration: const Duration(seconds: 2),
        );
        return;
      }
      setState(() {
        loading = true;
      });
      isCapturing = true;

      XFile imageFile = await _cameraController.takePicture();
      File image = File(imageFile.path);

      bool isFloodDetected = await _detectForFlooding(image);

      if (isFloodDetected) {
        if (mounted) {
          showToast(
            context,
            'Flood Detected',
            Colors.green,
            Colors.white,
            top: 350,
            horizontal: {'left': 123.0, 'right': 123.0},
            duration: const Duration(seconds: 2),
          );

          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageAnalysisScreen(image: image),
            ),
          );
        }
      } else {
        if (mounted) {
          showToast(
            context,
            'No Flood Detected',
            Colors.red,
            Colors.white,
            top: 350,
            horizontal: {'left': 115.0, 'right': 115.0},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          'Error',
          Colors.red,
          Colors.white,
          bottom: 140,
          horizontal: {'left': 150.0, 'right': 150.0},
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      setState(() {
        loading = false;
      });
      isCapturing = false;
    }
  }
}
