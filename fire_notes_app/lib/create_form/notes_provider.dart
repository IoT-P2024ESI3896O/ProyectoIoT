import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotesProvider with ChangeNotifier {
  bool isLoading = false;
  File? _selectedPicture;
  File? get getSelectedImage => _selectedPicture;
  Future<void> getAllNotes() async {}
  Future<bool> createNewNote(Map<String, dynamic> noteContent) async {
    try {
      isLoading = true;
      notifyListeners();
      // TODO: _uploadPictureToStorage
      await FirebaseFirestore.instance.collection("notes").add(noteContent);
      isLoading = false;
      https: //firebase.google.com/docs/android/setup?hl=es&authuser=0&_gl=1*1vo6l63*_ga*MTA0OTUzNTUwNi4xNzEyMDYzNzI1*_ga_CW55HF8NVT*MTcxNDA4NTUxNS4yNC4xLjE3MTQwODYzNTQuMjAuMC4w
      notifyListeners();
      return true;
    } catch (e) {
      print("Error: ${e.toString()}");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> editExistingNote(String noteReference) async {}
  Future<void> removeExistingNote(String noteReference) async {}
  Future<String> _uploadPictureToStorage() async {
    // TODO: implementar logica para guardar imagen en storage y obtener su url
    return "";
  }

  Future<void> _takePicture() async {
    // TODO: implementar logica para tomar foto con la camara
  }

  Future<void> _getImage() async {
    // TODO: implementar logica para generar file con la foto tomada
  }
}
