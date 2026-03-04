import 'package:chefio/models/recipe_model.dart';
import 'package:chefio/services/recipe_service.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}


class _RecipeCardState extends State<RecipeCard> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('[RecipeCard] initState for: ${widget.recipe.title}, ID: ${widget.recipe.id}');
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    if (!mounted || widget.recipe.id == null) return;
    
    setState(() => _isLoading = true);
    try {
      final bookmarked = await RecipeService().isBookmarked(widget.recipe.id!);
      if (mounted) {
        setState(() {
          _isBookmarked = bookmarked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBookmark() async {
    print('[RecipeCard] Bookmark button clicked! Recipe ID: ${widget.recipe.id}');

    if (_isLoading || widget.recipe.id == null) {
      print('[RecipeCard] Toggle aborted. Is loading: $_isLoading, Is ID null: ${widget.recipe.id == null}');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isBookmarked) {
        print('[RecipeCard] Attempting to REMOVE bookmark...');
        await RecipeService().removeBookmark(widget.recipe.id!);
      } else {
        print('[RecipeCard] Attempting to ADD bookmark...');
        await RecipeService().addBookmark(widget.recipe.id!);
      }
      
      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
          print('[RecipeCard] SUCCESS! UI state changed to: $_isBookmarked');
        });
      }
    } catch (e) {
      print('[RecipeCard] !!! AN ERROR OCCURRED: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling bookmark: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24.0),
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              widget.recipe.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.recipe.category ?? 'General'} • ${widget.recipe.cookingTime}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _buildBookmarkButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return _isLoading
        ? Container(
            padding: const EdgeInsets.all(12),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            onPressed: _toggleBookmark,
          );
  }
}