import 'dart:io';
import 'package:chefio/models/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeService {
  final _supabase = Supabase.instance.client;

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      final recipes = (response as List)
          .map((data) => Recipe.fromJson(data))
          .toList();
      
      return recipes;
    } catch (e) {
      print('Error fetching recipes: $e');
      rethrow;
    }
  }

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .order('created_at', ascending: false);

      final recipes = (response as List)
          .map((data) => Recipe.fromJson(data))
          .toList();
      
      return recipes;
    } catch (e) {
      print('Error fetching all recipes: $e');
      return [];
    }
  }

  Future<void> addRecipe({
    required Recipe recipe,
    required File imageFile,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to add a recipe.');
    }

    try {
      final imagePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('recipeimages').upload(
            imagePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage.from('recipeimages').getPublicUrl(imagePath);

      final recipeData = {
        'user_id': user.id,
        'title': recipe.title,
        'description': recipe.description,
        'image_url': imageUrl,
        'cooking_time': recipe.cookingTime,
        'ingredients': recipe.ingredients,
        'steps': recipe.steps,
        'category': recipe.category,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('recipes').insert(recipeData).select();
      
    } catch (e) {
      print('Error adding recipe: $e');
      throw Exception('Failed to add recipe. Please try again.');
    }
  }


  Future<void> addBookmark(String recipeId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User must be logged in to bookmark a recipe.');
    await _supabase.from('bookmarks').insert({'user_id': user.id, 'recipe_id': recipeId});
  }

  Future<void> removeBookmark(String recipeId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User must be logged in to remove a bookmark.');
    await _supabase.from('bookmarks').delete().match({'user_id': user.id, 'recipe_id': recipeId});
  }

  Future<bool> isBookmarked(String recipeId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    final response = await _supabase.from('bookmarks').select('id').match({'user_id': user.id, 'recipe_id': recipeId}).limit(1);
    return response.isNotEmpty;
  }

  Future<List<Recipe>> getBookmarkedRecipes() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final bookmarkResponse = await _supabase.from('bookmarks').select('recipe_id').eq('user_id', user.id);
      if (bookmarkResponse.isEmpty) return [];

      final recipeIds = bookmarkResponse.map((b) => b['recipe_id'] as String).toList();
      if (recipeIds.isEmpty) return [];

      final recipeResponse = await _supabase.from('recipes').select().filter('id', 'in', recipeIds).order('created_at', ascending: false);

      final recipes = (recipeResponse as List).map((data) => Recipe.fromJson(data)).toList();
      return recipes;
    } catch (e) {
      print('Error fetching bookmarked recipes: $e');
      rethrow;
    }
  }
}