import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import 'image_upload_service.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  /// Fetch recipes for home feed (paginated)
  Future<List<Recipe>> fetchHomeRecipes({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return Recipe.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  /// Create a new recipe
  Future<void> createRecipe(Recipe recipe) async {
    await _firestore.collection('recipes').add(recipe.toFirestore());
  }

  /// Update an existing recipe
  Future<void> updateRecipe(Recipe recipe) async {
    await _firestore
        .collection('recipes')
        .doc(recipe.id)
        .update(recipe.toFirestore());
  }

  /// Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection('recipes').doc(recipeId).delete();
  }

  /// Get image upload service for uploading recipe images
  ImageUploadService get imageUploadService => _imageUploadService;
}
