import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depthblue3/firebase/services/add_flood.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class FloodEvents extends StatefulWidget {
  const FloodEvents({super.key});

  @override
  State<FloodEvents> createState() => _FloodEventsState();
}

class _FloodEventsState extends State<FloodEvents> {
  @override
  void initState() {
    super.initState();
    determinePosition();
    getLocation();
    getUserData();
  }

  String email = '';
  String name = '';

  bool hasLoaded = false;

  double lat = 0;
  double long = 0;

  getUserData() {
    FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        setState(() {
          email = doc['email'];
          name = doc['firstname'] + ' ' + doc['lastname'];
        });
      }
    });
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = position.latitude;
      long = position.longitude;
      hasLoaded = true;
    });
  }

  late String fileName = '';

  late File imageFile;

  late String imageURL = '';

  Future<void> uploadPicture(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName = path.basename(pickedImage.path);
      imageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Floods/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Floods/$fileName')
            .getDownloadURL();

        addFlood(name, email, imageURL, lat, long);

        // showToast(context, 'Flood reported!', Colors.blue, Colors.black);
        Navigator.of(context).pop();
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  final AuthService _authService = AuthService();
  bool sortByDateDescending = true;
  String selectedCategory = 'All';

  List<DocumentSnapshot> reportedEvents = [];
  List<DocumentSnapshot> doneEvents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: hasLoaded
            ? Stack(
                children: [
                  buildBody(context),
                  Positioned(
                    bottom: 5.0,
                    left: (MediaQuery.of(context).size.width / 2) - 28.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        uploadPicture('camera');
                      },
                      // backgroundColor: Theme.of(context).brightness == Brightness.dark
                      //     ? Colors.grey // Change to your preferred color for dark mode
                      //     : Colors.white,
                      // foregroundColor: Theme.of(context).brightness == Brightness.dark
                      //     ? Colors.white
                      //     : Colors.black,
                      child: const Icon(Icons.camera),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Flood Events",
        // style: TextStyle(
        //   color: Theme.of(context).brightness == Brightness.dark
        //       ? Colors.white
        //       : Colors.black,
        // ),
      ),
      // backgroundColor: Colors.white38,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications,
            // color: Theme.of(context).brightness == Brightness.dark
            //     ? Colors.white
            //     : Colors.black,
          ),
          onPressed: () {
            // Handle notifications icon tap
          },
        ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        buildCategoryDropdown(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: selectedCategory == 'All'
                ? FirebaseFirestore.instance
                    .collection('Floods')
                    .where('type', isEqualTo: 'Pending')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('Floods')
                    .where('type', isEqualTo: 'Pending')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .where('status', isEqualTo: selectedCategory)
                    .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text('Error'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                  )),
                );
              }

              final data = snapshot.requireData;

              return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (context, index) {
                  String formattedDate = DateFormat('d/M/yyyy hh:mm a')
                      .format(data.docs[index]['dateTime'].toDate());
                  return Card(
                    margin: const EdgeInsets.all(5.0),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return buildDetailsDialog(
                                    data.docs[index]['img'],
                                    formattedDate,
                                    '',
                                    '');
                              },
                            );
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 150.0,
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                Image.network(
                                  data.docs[index]['img'],
                                  width: double.infinity,
                                  height: 150.0,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Placeholder();
                                  },
                                ),
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  child: Container(
                                    color: Colors.black,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      formattedDate,
                                      style: GoogleFonts.roboto(
                                        fontSize: 10.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // Add the document to the reported list
                                        // setState(() {
                                        //   reportedEvents
                                        //       .add(filteredDocuments[index]);
                                        // });
                                      },
                                      child: const Text('Report'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('Floods')
                                            .doc(data.docs[index].id)
                                            .update({'type': 'Completed'});
                                        // Add the document to the done list
                                        // setState(() {
                                        //   doneEvents
                                        //       .add(filteredDocuments[index]);
                                        // });
                                      },
                                      child: const Text('Done'),
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
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Row buildCategoryDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text("Sort by: "),
        DropdownButton<String>(
          value: selectedCategory,
          onChanged: (String? newValue) {
            filterByCategory(newValue!);
          },
          items: const [
            DropdownMenuItem<String>(
              value: 'All',
              child: Center(
                child: Text('All'),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Low',
              child: Center(
                child: Text('Low', style: TextStyle(color: Colors.green)),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Medium',
              child: Center(
                child: Text('Moderate', style: TextStyle(color: Colors.yellow)),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'High',
              child: Center(
                child: Text('High', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            setState(() {
              sortByDateDescending = !sortByDateDescending;
            });
          },
          icon: Icon(
            sortByDateDescending ? Icons.arrow_downward : Icons.arrow_upward,
            // color: Theme.of(context).brightness == Brightness.dark
            //     ? Colors.white
            //     : Colors.black,
            size: 24.0,
          ),
        ),
      ],
    );
  }

  ElevatedButton buildCategoryButtons(String text, String category,
      {Color? backgroundColor}) {
    return ElevatedButton(
      onPressed: () => filterByCategory(category),
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
      child: Text(text),
    );
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Stream<QuerySnapshot> getFloodEventsStream() async* {
    var currentUser = await _authService.getCurrentUser();

    yield* FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('flood')
        .snapshots();
  }

  Future<void> sortDocuments(List<DocumentSnapshot> filteredDocuments) async {
    filteredDocuments.sort((a, b) {
      Timestamp? timestampA = a['timestamp'];
      Timestamp? timestampB = b['timestamp'];

      if (timestampA == null || timestampB == null) {
        return 0;
      }

      int result = timestampB.compareTo(timestampA);
      return sortByDateDescending ? result : -result;
    });
  }

  Widget buildEventListView(List<DocumentSnapshot> filteredDocuments) {
    return ListView.separated(
      itemCount: filteredDocuments.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        var documentData =
            filteredDocuments[index].data() as Map<String, dynamic>?;

        if (documentData == null ||
            !documentData.containsKey('flood') ||
            !documentData.containsKey('timestamp')) {
          return Container();
        }

        String documentId = filteredDocuments[index].id;
        String downloadUrl = documentData['flood'];

        // Handle the case where 'timestamp' is null
        Timestamp? timestamp = documentData['timestamp'];
        if (timestamp == null) {
          return Container();
        }

        String warning = documentData['warning'] ?? '';
        String location = documentData['location'] ?? 'Unable to locate.';

        return buildCard(context, documentId, downloadUrl, timestamp, warning,
            location, filteredDocuments, index);
      },
    );
  }

  Widget buildCard(
      BuildContext context,
      String documentId,
      String downloadUrl,
      Timestamp timestamp,
      String warning,
      String location,
      List<DocumentSnapshot> filteredDocuments,
      int index) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('d/M/yyyy hh:mm a').format(dateTime);

    return Card(
      margin: const EdgeInsets.all(5.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          GestureDetector(
            onTap: () {
              // Show a dialog here with more details
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return buildDetailsDialog(
                      downloadUrl, formattedDate, warning, location);
                },
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150.0,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Image.network(
                    downloadUrl,
                    width: double.infinity,
                    height: 150.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Placeholder();
                    },
                  ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        formattedDate,
                        style: GoogleFonts.roboto(
                          fontSize: 10.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Add the document to the reported list
                          setState(() {
                            reportedEvents.add(filteredDocuments[index]);
                          });
                        },
                        child: const Text('Report'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add the document to the done list
                          setState(() {
                            doneEvents.add(filteredDocuments[index]);
                          });
                        },
                        child: const Text('Done'),
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

  AlertDialog buildDetailsDialog(
      String downloadUrl, String dateTime, String warning, String location) {
    return AlertDialog(
      title: const Text("Details"),
      content: SizedBox(
        height: 300,
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dateTime),
            Image.network(
              downloadUrl,
              width: double.infinity,
              height: 150.0,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Placeholder();
              },
            ),
            Text(location),
            Text(warning),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
