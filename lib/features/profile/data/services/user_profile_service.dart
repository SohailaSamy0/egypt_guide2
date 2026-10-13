import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get userId =>
      _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>?
      get _userDocument {
    final uid = userId;

    if (uid == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(uid);
  }

  Future<void> ensureUserProfile() async {
    final user =
        _auth.currentUser;

    final document =
        _userDocument;

    if (user == null ||
        document == null) {
      return;
    }

    final snapshot =
        await document.get();

    if (!snapshot.exists) {
      await document.set(
        {
          'uid': user.uid,
          'name':
              user.displayName ?? '',
          'email':
              user.email ?? '',
          'emailVerified':
              user.emailVerified,
          'createdAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
      );

      return;
    }

    await document.set(
      {
        'name':
            user.displayName ?? '',
        'email':
            user.email ?? '',
        'emailVerified':
            user.emailVerified,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<void> updateName(
    String name,
  ) async {
    final document =
        _userDocument;

    if (document == null) {
      return;
    }

    await document.set(
      {
        'name': name,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<Map<String, dynamic>?>
      getProfile() async {
    final document =
        _userDocument;

    if (document == null) {
      return null;
    }

    final snapshot =
        await document.get();

    return snapshot.data();
  }
}