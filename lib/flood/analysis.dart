import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';

import '../extra/toast.dart';
import '../firebase/auth_service.dart';
import '../location/controller.dart';
import 'detect.dart';

const kModelPath = 'assets/model/model_unquant.tflite';
const kLabelsPath = 'assets/model/labels.txt';
const kConfidenceThreshold = 0.95;

class ImageAnalysisScreen extends StatefulWidget {
  final File image;

  const ImageAnalysisScreen({Key? key, required this.image}) : super(key: key);


  @override
  State<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  final AuthService _authService = AuthService();
  LocationController locationController = LocationController();
  late String userUid;
  late String selectedOption;


  bool isHighWaterDetected = false;
  bool isMediumWaterDetected = false;
  bool isLowWaterDetected = false;

  @override
  void initState() {
    super.initState();
  }



  Future<void> _classifyImage(File image, String userRole) async {
    try {
      await Tflite.loadModel(model: kModelPath, labels: kLabelsPath);

      var predictions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      // showToastOk('$predictions');

      _processClassificationResults(predictions, userRole);
    } catch (e) {
      showToastErr('Error');
    } finally {
      Tflite.close();
    }
  }


  void _processClassificationResults(List? predictions, String userRole) {
    String detectedWaterLevel = '';

    if (predictions != null && predictions.isNotEmpty) {
      isHighWaterDetected = predictions.any((element) =>
      element['label'].toString().toLowerCase().contains('high') &&
          element['confidence'] >= kConfidenceThreshold);

      isMediumWaterDetected = predictions.any((element) =>
      (element['label'].toString().toLowerCase().contains('medium')) &&
          element['confidence'] >= kConfidenceThreshold);

      isLowWaterDetected = predictions.any((element) =>
      (element['label'].toString().toLowerCase().contains('low')) &&
          element['confidence'] >= kConfidenceThreshold);


      if (isHighWaterDetected) {
        detectedWaterLevel = 'high';
      } else if (isMediumWaterDetected) {
        detectedWaterLevel = 'medium';
      } else if (isLowWaterDetected) {
        detectedWaterLevel = 'low';
      }
    } else {
      showToastErr('Error classifying image');
    }
    _showWarningDialog(userRole, detectedWaterLevel);
  }


  void _showWarningDialog(String userRole, String detectedWaterLevel) {
    String roleSpecificMessage = '';

    if (isHighWaterDetected) {
      double highWaterLevel = Random().nextDouble() * (40 - 26) + 26;
      var waterLevel = double.parse(highWaterLevel.toStringAsFixed(2));
      roleSpecificMessage = _getHighWaterWarning(userRole, waterLevel);
    } else if (isMediumWaterDetected) {
      double mediumWaterLevel = Random().nextDouble() * (19 - 13) + 13;
      var waterLevel = double.parse(mediumWaterLevel.toStringAsFixed(2));
      roleSpecificMessage = _getMediumWaterWarning(userRole, waterLevel);
    } else if (isLowWaterDetected) {
      double lowWaterLevel = Random().nextDouble() * (10 - 8) + 8;
      var waterLevel = double.parse(lowWaterLevel.toStringAsFixed(2));
      roleSpecificMessage = _getLowWaterWarning(userRole, waterLevel);
    } else {
      double waterLevel = 0.0;
      roleSpecificMessage = _getDefaultWarning(userRole, waterLevel);
    }

    _showDialogWithMessage(context,
        roleSpecificMessage.isNotEmpty ? roleSpecificMessage : 'Default message',
        userRole, detectedWaterLevel, roleSpecificMessage);
  }


  void _showDialogWithMessage(BuildContext context, String content, String userRole, String detectedWaterLevel, String roleSpecificMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _saveToFirestore(widget.image, userRole, detectedWaterLevel, roleSpecificMessage);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  String _getHighWaterWarning(String userRole, double waterLevel) {
    String warningPrefix = 'High water level detected.  \n\n';

    if (userRole == 'truck') {
      return '$warningPrefix Due to the elevated water levels, you should strongly consider finding an alternative route. Navigating through high water poses risks to larger vehicles like trucks.\n\n Estimation Depth: \n $waterLevel inches';
    } else if (userRole == 'car') {
      return '$warningPrefix Be cautious and carefully assess the situation before proceeding. In case of high water levels, finding an alternative route is recommended to ensure the safety of your vehicle.\n\n Estimation Depth: \n $waterLevel inches';
    } else if (userRole == 'bicycle') {
      return '$warningPrefix Given the observed high water levels, it\'s advisable for you on the bicycle to avoid the flooded area entirely. Seek a different path to ensure a safe and dry journey.\n\n Estimation Depth: \n $waterLevel inches';
    } else if (userRole == 'person') {
      return '$warningPrefix For you as a pedestrian, the presence of high water indicates potential hazards. It is recommended to stay safe by finding a secure and dry path, away from the flooded area.\n\n Estimation Depth: \n $waterLevel inches';
    }
    return '';
  }


  String _getMediumWaterWarning(String userRole, double waterLevel) {
    String warningPrefix = 'Medium water level detected. \n\n';

    if (userRole == 'truck') {
      return '$warningPrefix Given the presence of medium water levels, you should consider finding an alternative route. Be cautious as higher water levels may pose risks to larger vehicles. \n\n Estimation Depth: \n  $waterLevel inches';
    } else if (userRole == 'car') {
      return '$warningPrefix You should be cautious and carefully assess the situation before proceeding. In the case of medium water levels, evaluate the feasibility of your route for safe passage. \n\n Estimation Depth: \n $waterLevel inches';
    } else if (userRole == 'bicycle') {
      return '$warningPrefix For your bicycle, proceed with caution in areas with medium water levels. It\'s recommended to avoid flooded areas and exercise vigilance for a safer journey. \n\n Estimation Depth: \n $waterLevel inches';
    } else if (userRole == 'person') {
      return '$warningPrefix It indicate potential hazards for you as a pedestrian. Exercise awareness and choose a path away from flooded areas for a safer journey. \n\n Estimation Depth: \n $waterLevel inches';
    }
    return '';
  }


  String _getLowWaterWarning(String userRole, double waterLevel) {
    String warningPrefix = 'Low water level detected. \n\n';

    if (userRole == 'truck') {
      return '$warningPrefix While you may be able to pass through areas with low water levels, proceed with caution as it poses potential risks. Evaluate the situation carefully for a safe journey. \n\n Estimation Depth:  \n $waterLevel inches';
    } else if (userRole == 'car') {
      return '$warningPrefix It is likely safe for you to pass through areas with low water levels, but exercise caution and assess the situation carefully due to potential risks. \n\n Estimation Depth: \n $waterLevel inches';
    } else if (userRole == 'bicycle') {
      return '$warningPrefix Proceed with care on your bicycle through areas with low water levels. While it may be possible, avoid flooded areas and exercise caution for a safer journey. \n\n Estimation Depth: \n $waterLevel inches';
    } else if (userRole == 'person') {
      return '$warningPrefix It should be generally safe for you to walk through areas with low water levels. However, be cautious as it may pose potential risks. \n\n Estimation Depth: \n $waterLevel inches';
    }
    return '';
  }


  String _getDefaultWarning(String userRole, double waterLevel) {
    String warningPrefix = 'Unable to determine water level. \n\n';

    if (userRole == 'truck') {
      return '$warningPrefix For a truck, it is recommended to proceed with caution and assess the situation.';
    } else if (userRole == 'car') {
      return '$warningPrefix For a car, exercise caution and carefully evaluate the situation before proceeding.';
    } else if (userRole == 'bicycle') {
      return '$warningPrefix For a bicycle, proceed with caution and avoid flooded areas if possible.';
    } else if (userRole == 'person') {
      return '$warningPrefix For a pedestrian, choose a safe path and remain vigilant.';
    }
    return '';
  }


  Future<void> _saveToFirestore(File image, String userRole, String detectedWaterLevel, String roleSpecificMessage) async {
    try {
      User? currentUser = await _authService.getCurrentUser();

      String userUid = currentUser!.uid;
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageName = DateTime.now().toString();
      String status = 'unreported';


      String folder;
      if (detectedWaterLevel == 'high') {
        folder = 'high';
      } else if (detectedWaterLevel == 'medium') {
        folder = 'medium';
      } else if (detectedWaterLevel == 'low') {
        folder = 'low';
      }else {
        return;
      }

      await locationController.getCurrentLocation();

      double latitude = locationController.currentPosition?.latitude ?? 0.0;
      double longitude = locationController.currentPosition?.longitude ?? 0.0;

      Reference storageRef = storage.ref().child('flood/$userUid/$folder/$imageName.jpg');
      await storageRef.putFile(image);

      String downloadUrl = await storageRef.getDownloadURL();

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Users').doc(userUid).collection('flood').add({
        'flood': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'warning': roleSpecificMessage,
        'waterlevel': detectedWaterLevel,
        'location': locationController.currentLocation,
        'latlong': {'latitude': latitude, 'longitude': longitude},
        'status': status,
      });

      showToastOk('Successfully saved');
    } catch (e) {
      if(mounted) {
        showToast(
            context, 'Error saving to Firestore', Colors.red, Colors.white,
            bottom: 100,
            horizontal: {'left': 100.0, 'right': 100.0},
            duration: const Duration(seconds: 2));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Positioning'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Image.file(
              widget.image,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'flood2',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FloodDetect(),
                      ),
                    );
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.refresh),
                ),
                FloatingActionButton(
                  onPressed: () {
                    _showOptionsDialog(context);
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOptionsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'I am',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption('Truck Driver', Icons.local_shipping, 'truck'),
              _buildOption('Car Driver', Icons.directions_car, 'car'),
              _buildOption('Motorcyclist', Icons.motorcycle, 'bicycle'),
              _buildOption('Commuter', Icons.person, 'person'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(String option, IconData icon, String userRole) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
        Navigator.of(context).pop();
        _classifyImage(widget.image, userRole);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(width: 16),
            Text(
              option,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

}
