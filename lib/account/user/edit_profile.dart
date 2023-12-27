import 'package:flutter/material.dart';
import '../../firebase/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const EditProfileScreen({Key? key, required this.userData, required this.userId}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameController.text = getUserDataValue(widget.userData, 'username');
    firstNameController.text = getUserDataValue(widget.userData, 'firstname');
    lastNameController.text = getUserDataValue(widget.userData, 'lastname');
    genderController.text = getUserDataValue(widget.userData, 'gender');
    phoneController.text = getUserDataValue(widget.userData, 'phone');
    emailController.text = getUserDataValue(widget.userData, 'email');
    locationController.text = getUserDataValue(widget.userData, 'location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTextField('Username', usernameController, validateUsername),
              buildTextField('First Name', firstNameController, validateName),
              buildTextField('Last Name', lastNameController, validateName),
              buildTextField('Gender', genderController, validateGender),
              buildTextField('Phone', phoneController, validatePhone),
              buildTextField('Email', emailController),
              buildTextField('Location', locationController),
              ElevatedButton(
                onPressed: () {
                  if (validateAllFields()) {
                    saveProfileData();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, [Function(String)? validator]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: validator != null ? (value) => validator(value) : null,
      ),
    );
  }


bool validateUsername(String value) {
    if (value.length < 6) {
      return false;
    }
    return true;
  }

  bool validateName(String value) {
    return !RegExp(r'[0-9]').hasMatch(value);
  }

  bool validateGender(String value) {
    return value == 'Male' || value == 'Female' || value == 'Others';
  }

  bool validatePhone(String value) {
    return RegExp(r'^\+63\d{9}$').hasMatch(value);
  }

  bool validateAllFields() {
    return validateUsername(usernameController.text) &&
        validateName(firstNameController.text) &&
        validateName(lastNameController.text) &&
        validateGender(genderController.text) &&
        validatePhone(phoneController.text);
  }

  void saveProfileData() {
    Map<String, dynamic> updatedData = {
      'username': usernameController.text,
      'firstname': firstNameController.text,
      'lastname': lastNameController.text,
      'gender': genderController.text,
      'phone': phoneController.text,
      'email': emailController.text,
      'location': locationController.text,
    };
    AuthService authService = AuthService();
    authService.updateProfileData(widget.userId, updatedData);
  }

}
