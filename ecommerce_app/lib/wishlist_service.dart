
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please log in to use your wishlist.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _wishlistCollection {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('wishlist');
  }

  // Kunin ang wishlist ng current user.
  Stream<QuerySnapshot<Map<String, dynamic>>> getWishlist() {
    return _wishlistCollection.snapshots();
  }

  // Tingnan kung nasa wishlist na ang product.
  Future<bool> isInWishlist(String productId) async {
    final doc = await _wishlistCollection.doc(productId).get();
    return doc.exists;
  }

  // Idagdag ang product sa wishlist.
  Future<void> addToWishlist({
    required String productId,
    required String productName,
    required num price,
    String? imageUrl,
  }) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    await _wishlistCollection.doc(productId).set({
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Alisin ang product sa wishlist.
  Future<void> removeFromWishlist(String productId) async {
    await _wishlistCollection.doc(productId).delete();
  }

  // Toggle: idagdag kung wala pa, alisin kung mayroon na.
  Future<bool> toggleWishlist({
    required String productId,
    required String productName,
    required num price,
    String? imageUrl,
  }) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    final ref = _wishlistCollection.doc(productId);

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(ref);

      if (snapshot.exists) {
        transaction.delete(ref);
        return false;
      }

      transaction.set(ref, {
        'productId': productId,
        'productName': productName,
        'price': price,
        'imageUrl': imageUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }
}
