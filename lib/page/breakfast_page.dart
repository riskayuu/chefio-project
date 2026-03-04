import 'package:chefio/models/recipe_model.dart';
import 'package:chefio/services/recipe_service.dart';
import 'package:chefio/widgets/recipe_card.dart'; 
import 'package:flutter/material.dart';

class BreakfastPage extends StatefulWidget {
  const BreakfastPage({Key? key}) : super(key: key);

  @override
  State<BreakfastPage> createState() => _BreakfastPageState();
}

class _BreakfastPageState extends State<BreakfastPage> {
  late Future<List<Recipe>> _breakfastRecipesFuture;

  @override
  void initState() {
    super.initState();
    _breakfastRecipesFuture = RecipeService().getRecipesByCategory('Breakfast');
  }

  Future<void> _refreshData() async {
    setState(() {
      _breakfastRecipesFuture = RecipeService().getRecipesByCategory('Breakfast');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breakfast', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Recipe>>(
          future: _breakfastRecipesFuture,
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
                    Icon(Icons.free_breakfast_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No breakfast recipes found.'),
                  ],
                ),
              );
            }

            final recipes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(recipe: recipes[index]);
              },
            );
          },
        ),
      ),
    );
  }
}