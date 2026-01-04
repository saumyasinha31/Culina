import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;

  // Core info
  final String title;
  final String description;
  final String imageUrl;

  // Metadata
  final String cuisine;        // Indian, Italian, etc.
  final String difficulty;     // Easy, Medium, Hard
  final int cookingTime;       // in minutes
  final int servings;

  // Content
  final List<String> ingredients;
  final List<String> steps;

  // Author (denormalized for performance)
  final String authorId;
  final String authorName;
  final String authorPhotoUrl;

  // Social
  final int likesCount;
  final int savedCount;

  // Timestamps
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cuisine,
    required this.difficulty,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.likesCount,
    required this.savedCount,
    required this.createdAt,
  });

  // ----------------------------
  // Firestore → Recipe
  // ----------------------------
  factory Recipe.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return Recipe(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      cuisine: data['cuisine'] ?? '',
      difficulty: data['difficulty'] ?? '',
      cookingTime: (data['cookingTime'] ?? 0) as int,
      servings: (data['servings'] ?? 1) as int,
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      likesCount: (data['likesCount'] ?? 0) as int,
      savedCount: (data['savedCount'] ?? 0) as int,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  // ----------------------------
  // Recipe → Firestore
  // ----------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'cuisine': cuisine,
      'difficulty': difficulty,
      'cookingTime': cookingTime,
      'servings': servings,
      'ingredients': ingredients,
      'steps': steps,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'likesCount': likesCount,
      'savedCount': savedCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ----------------------------
  // Immutable updates (IMPORTANT)
  // ----------------------------
  Recipe copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? cuisine,
    String? difficulty,
    int? cookingTime,
    int? servings,
    List<String>? ingredients,
    List<String>? steps,
    int? likesCount,
    int? savedCount,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      cuisine: cuisine ?? this.cuisine,
      difficulty: difficulty ?? this.difficulty,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      likesCount: likesCount ?? this.likesCount,
      savedCount: savedCount ?? this.savedCount,
      createdAt: createdAt,
    );
  }
}
