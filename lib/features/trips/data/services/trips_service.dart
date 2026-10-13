import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:egypt_guide/features/trips/data/models/trip.dart';
import 'package:egypt_guide/features/trips/data/models/trip_place.dart';

class TripsService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get _userId {
    return _auth.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>>?
      get _tripsCollection {
    final uid = _userId;

    if (uid == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips');
  }

  // =========================================================
  // GET ALL TRIPS
  // =========================================================

  Future<List<Trip>> getTrips() async {
    final collection =
        _tripsCollection;

    if (collection == null) {
      return [];
    }

    final snapshot =
        await collection.get();

    final trips = <Trip>[];

    for (final document
        in snapshot.docs) {
      try {
        final data =
            Map<String, dynamic>.from(
          document.data(),
        );

        data['id'] =
            document.id;

        trips.add(
          Trip.fromJson(
            data,
          ),
        );
      } catch (_) {
        // Ignore invalid documents.
      }
    }

    trips.sort(
      (a, b) =>
          a.startDate.compareTo(
        b.startDate,
      ),
    );

    return trips;
  }

  // =========================================================
  // GET ONE TRIP
  // =========================================================

  Future<Trip?> getTripById(
    String tripId,
  ) async {
    final collection =
        _tripsCollection;

    if (collection == null) {
      return null;
    }

    final snapshot =
        await collection
            .doc(tripId)
            .get();

    if (!snapshot.exists) {
      return null;
    }

    final data =
        snapshot.data();

    if (data == null) {
      return null;
    }

    final tripData =
        Map<String, dynamic>.from(
      data,
    );

    tripData['id'] =
        snapshot.id;

    return Trip.fromJson(
      tripData,
    );
  }

  // =========================================================
  // ADD TRIP
  // =========================================================

  Future<void> addTrip(
    Trip trip,
  ) async {
    final collection =
        _tripsCollection;

    if (collection == null) {
      throw Exception(
        'User is not signed in.',
      );
    }

    await collection
        .doc(trip.id)
        .set(
      {
        ...trip.toJson(),
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  // =========================================================
  // UPDATE TRIP
  // =========================================================

  Future<void> updateTrip(
    Trip updatedTrip,
  ) async {
    final collection =
        _tripsCollection;

    if (collection == null) {
      throw Exception(
        'User is not signed in.',
      );
    }

    await collection
        .doc(
          updatedTrip.id,
        )
        .set(
      {
        ...updatedTrip.toJson(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  // =========================================================
  // DELETE TRIP
  // =========================================================

  Future<void> deleteTrip(
    String tripId,
  ) async {
    final collection =
        _tripsCollection;

    if (collection == null) {
      return;
    }

    await collection
        .doc(tripId)
        .delete();
  }

  // =========================================================
  // ADD PLACE TO TRIP
  // =========================================================

  Future<bool> addPlaceToTrip({
    required String tripId,
    required TripPlace place,
  }) async {
    final trip =
        await getTripById(
      tripId,
    );

    if (trip == null) {
      return false;
    }

    final alreadyExists =
        trip.places.any(
      (savedPlace) =>
          savedPlace.id ==
          place.id,
    );

    if (alreadyExists) {
      return false;
    }

    final updatedPlaces =
        List<TripPlace>.from(
      trip.places,
    )
          ..add(
            place,
          );

    final updatedTrip =
        trip.copyWith(
      places: updatedPlaces,
    );

    await updateTrip(
      updatedTrip,
    );

    return true;
  }

  // =========================================================
  // REMOVE PLACE FROM TRIP
  // =========================================================

  Future<void> removePlaceFromTrip({
    required String tripId,
    required int placeId,
  }) async {
    final trip =
        await getTripById(
      tripId,
    );

    if (trip == null) {
      return;
    }

    final updatedPlaces =
        List<TripPlace>.from(
      trip.places,
    )
          ..removeWhere(
            (place) =>
                place.id ==
                placeId,
          );

    final updatedTrip =
        trip.copyWith(
      places: updatedPlaces,
    );

    await updateTrip(
      updatedTrip,
    );
  }
}