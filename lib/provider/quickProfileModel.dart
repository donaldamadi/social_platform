import 'package:flutter/material.dart';

class QuickProfileChangeNotifierModel extends ChangeNotifier {
  String? email;
  String? firstName;
  String? lastName;
  String? username;
  String? password;
  String? studentType;
  String? countryOfResidence;
  String? faculty;
  String? department;
  String? institution;
  String? yearOfGrad;
  List? communities;

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void setFirstName(String firstName) {
    this.firstName = firstName;
    notifyListeners();
  }

  void setLastName(String lastName) {
    this.lastName = lastName;
    notifyListeners();
  }

  void setUsername(String username) {
    this.username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  void setStudentType(String studentType) {
    this.studentType = studentType;
    notifyListeners();
  }

  void setCountryOfResidence(String countryOfResidence) {
    this.countryOfResidence = countryOfResidence;
    notifyListeners();
  }

  void setFaculty(String faculty) {
    this.faculty = faculty;
    notifyListeners();
  }

  void setDepartment(String department) {
    this.department = department;
    notifyListeners();
  }

  void setInstitution(String institution) {
    this.institution = institution;
    notifyListeners();
  }

  void setYearOfGrad(String yearOfGrad) {
    this.yearOfGrad = yearOfGrad;
    notifyListeners();
  }

  void setCommunities(List communities) {
    this.communities = communities;
  }

  void resetProfileDetails() {
    email = null;
    firstName = null;
    lastName = null;
    username = null;
    password = null;
    studentType = null;
    countryOfResidence = null;
    faculty = null;
    department = null;
    institution = null;
    yearOfGrad = null;
    communities = null;
  }
}
