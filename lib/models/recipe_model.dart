// lib/models/recipe_model.dart

class Recipe {
  final String? id;
  final String? userId;
  final String title;
  final String description;
  final String imageUrl;
  final String cookingTime;
  final List<String> ingredients;
  final List<String> steps;
  final String? category;

  Recipe({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    required this.ingredients,
    required this.steps,
    this.category,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      cookingTime: json['cooking_time'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      steps: List<String>.from(json['steps'] as List),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'cooking_time': cookingTime,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
    };
  }
}