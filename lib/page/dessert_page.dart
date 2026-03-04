import 'package:chefio/models/recipe_model.dart';
import 'package:chefio/services/recipe_service.dart';
import 'package:chefio/widgets/recipe_card.dart'; 
import 'package:flutter/material.dart';

class DessertPage extends StatefulWidget {
  const DessertPage({Key? key}) : super(key: key);

  @override
  State<DessertPage> createState() => _DessertPageState();
}

class _DessertPageState extends State<DessertPage> {
  late Future<List<Recipe>> _dessertRecipesFuture;

  @override
  void initState() {
    super.initState();
    _dessertRecipesFuture = RecipeService().getRecipesByCategory('Dessert');
  }

  Future<void> _refreshData() async {
    setState(() {
      _dessertRecipesFuture = RecipeService().getRecipesByCategory('Dessert');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dessert', style: TextStyle(fontWeight: FontWeight.bold)),
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
          future: _dessertRecipesFuture,
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
                    Icon(Icons.cake_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No dessert recipes found.'),
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