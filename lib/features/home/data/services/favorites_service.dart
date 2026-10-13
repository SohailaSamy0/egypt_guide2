import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:egypt_guide/features/home/data/models/favorite_place.dart';
import 'package:egypt_guide/features/home/data/models/nearby_place.dart';

class FavoritesService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get _userId {
    return _auth.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>>?
      get _favoritesCollection {
    final uid = _userId;

    if (uid == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites');
  }

  Future<List<FavoritePlace>>
      getFavorites() async {
    final collection =
        _favoritesCollection;

    if (collection == null) {
      return [];
    }

    final snapshot =
        await collection.get();

    final favorites =
        <FavoritePlace>[];

    for (final document
        in snapshot.docs) {
      final data =
          document.data();

      favorites.add(
        FavoritePlace(
          id: (data['id'] as num?)
                  ?.toInt() ??
              0,
          name:
              data['name']
                      ?.toString() ??
                  '',
          latitude:
              (data['latitude'] as num?)
                      ?.toDouble() ??
                  0,
          longitude:
              (data['longitude'] as num?)
                      ?.toDouble() ??
                  0,
          category:
              data['category']
                      ?.toString() ??
                  'Place',
        ),
      );
    }

    return favorites;
  }

  Future<bool> isFavorite(
    int placeId,
  ) async {
    final collection =
        _favoritesCollection;

    if (collection == null) {
      return false;
    }

    final document =
        await collection
            .doc(
              placeId.toString(),
            )
            .get();

    return document.exists;
  }

  Future<void> addFavorite(
    Object place,
  ) async {
    final collection =
        _favoritesCollection;

    if (collection == null) {
      throw Exception(
        'User is not signed in.',
      );
    }

    late final int id;
    late final String name;
    late final double latitude;
    late final double longitude;
    late final String category;

    if (place is NearbyPlace) {
      id = place.id;
      name = place.name;
      latitude = place.latitude;
      longitude = place.longitude;
      category = place.category;
    } else if (place is FavoritePlace) {
      id = place.id;
      name = place.name;
      latitude = place.latitude;
      longitude = place.longitude;
      category = place.category;
    } else {
      throw ArgumentError(
        'Unsupported place type.',
      );
    }

    await collection
        .doc(
          id.toString(),
        )
        .set(
      {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'createdAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> removeFavorite(
    Object placeOrId,
  ) async {
    final collection =
        _favoritesCollection;

    if (collection == null) {
      return;
    }

    late final int id;

    if (placeOrId is int) {
      id = placeOrId;
    } else if (placeOrId
        is FavoritePlace) {
      id = placeOrId.id;
    } else if (placeOrId
        is NearbyPlace) {
      id = placeOrId.id;
    } else {
      throw ArgumentError(
        'Unsupported favorite type.',
      );
    }

    await collection
        .doc(
          id.toString(),
        )
        .delete();
  }

  Future<void> toggleFavorite(
    NearbyPlace place,
  ) async {
    final favorite =
        await isFavorite(
      place.id,
    );

    if (favorite) {
      await removeFavorite(
        place.id,
      );
    } else {
      await addFavorite(
        place,
      );
    }
  }
}