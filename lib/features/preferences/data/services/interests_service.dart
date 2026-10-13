import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InterestsService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get _userId {
    return _auth.currentUser?.uid;
  }

  DocumentReference<Map<String, dynamic>>?
      get _interestsDocument {
    final uid = _userId;

    if (uid == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('preferences')
        .doc('interests');
  }

  Future<void> saveSelectedInterests(
    Set<String> interests,
  ) async {
    final document =
        _interestsDocument;

    if (document == null) {
      throw Exception(
        'User is not signed in.',
      );
    }

    await document.set(
      {
        'selectedInterests':
            interests.toList(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<List<String>>
      getSelectedInterests() async {
    final document =
        _interestsDocument;

    if (document == null) {
      return [];
    }

    final snapshot =
        await document.get();

    if (!snapshot.exists) {
      return [];
    }

    final data =
        snapshot.data();

    if (data == null) {
      return [];
    }

    final rawInterests =
        data['selectedInterests'];

    if (rawInterests is! List) {
      return [];
    }

    return rawInterests
        .map(
          (interest) =>
              interest.toString(),
        )
        .toList();
  }

  Future<void> clearInterests() async {
    final document =
        _interestsDocument;

    if (document == null) {
      return;
    }

    await document.delete();
  }
}