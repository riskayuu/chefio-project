import 'package:chefio/models/recipe_model.dart';
import 'package:chefio/services/recipe_service.dart';
import 'package:chefio/widgets/recipe_card.dart';
import 'package:flutter/material.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late Future<List<Recipe>> _bookmarkedRecipesFuture;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    _bookmarkedRecipesFuture = RecipeService().getBookmarkedRecipes();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Recipe>>(
          future: _bookmarkedRecipesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                    SizedBox(height: 24),
                    Text('No Bookmarked Recipes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Tap the bookmark icon on any recipe to save it here.', textAlign: TextAlign.center,),
                  ],
                ),
              );
            }

            final recipes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(
                  key: ValueKey(recipes[index].id),
                  recipe: recipes[index]
                );
              },
            );
          },
        ),
      ),
    );
  }
}