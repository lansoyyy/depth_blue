import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/auth_service.dart';
import 'detect.dart';

class FloodEvents extends StatefulWidget {
  const FloodEvents({super.key});

  @override
  State<FloodEvents> createState() => _FloodEventsState();
}

class _FloodEventsState extends State<FloodEvents> {
  final AuthService _authService = AuthService();
  bool sortByDateDescending = true;
  String selectedCategory = 'all';

  List<DocumentSnapshot> reportedEvents = [];
  List<DocumentSnapshot> doneEvents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          buildBody(context),
          Positioned(
            bottom: 5.0,
            left: (MediaQuery.of(context).size.width / 2) - 28.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FloodDetect(),
                  ),
                );
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
      ),
    );
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
          child: StreamBuilder(
            stream: getFloodEventsStream(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<DocumentSnapshot> documents = snapshot.data!.docs;

              List<DocumentSnapshot> filteredDocuments = documents
                  .where((doc) =>
                      selectedCategory == 'all' ||
                      (doc['waterlevel'] != null &&
                          doc['waterlevel'] == selectedCategory))
                  .toList();

              if (filteredDocuments.isEmpty) {
                return const Center(
                  child: Text('No Data'),
                );
              }

              sortDocuments(filteredDocuments);

              return buildEventListView(filteredDocuments);
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
              value: 'all',
              child: Center(
                child: Text('All'),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'low',
              child: Center(
                child: Text('Low', style: TextStyle(color: Colors.green)),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'medium',
              child: Center(
                child: Text('Moderate', style: TextStyle(color: Colors.yellow)),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'high',
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
    User? currentUser = await _authService.getCurrentUser();

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
                      downloadUrl, dateTime, warning, location);
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
      String downloadUrl, DateTime dateTime, String warning, String location) {
    return AlertDialog(
      title: const Text("Details"),
      content: IntrinsicHeight(
        child: Column(
          children: [
            Text("Date: ${DateFormat('d/M/yyyy hh:mm a').format(dateTime)}"),
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
}
