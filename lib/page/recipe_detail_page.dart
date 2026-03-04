import 'package:flutter/material.dart';
import 'package:chefio/models/recipe_model.dart';
import 'package:chefio/services/recipe_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool _isShowingIngredients = true;
  
  bool _isBookmarked = false;
  bool _isLoadingBookmark = true;

  Future<void> _checkBookmarkStatus() async {
    if (!mounted || widget.recipe.id == null) return;
    setState(() => _isLoadingBookmark = true);
    try {
      final bookmarked = await RecipeService().isBookmarked(widget.recipe.id!);
      if (mounted) {
        setState(() {
          _isBookmarked = bookmarked;
          _isLoadingBookmark = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBookmark = false);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isLoadingBookmark || widget.recipe.id == null) return;
    setState(() => _isLoadingBookmark = true);
    try {
      if (_isBookmarked) {
        await RecipeService().removeBookmark(widget.recipe.id!);
      } else {
        await RecipeService().addBookmark(widget.recipe.id!);
      }
      if (mounted) setState(() => _isBookmarked = !_isBookmarked);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingBookmark = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: theme.cardColor.withOpacity(0.8),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: theme.cardColor.withOpacity(0.8),
              child: _isLoadingBookmark
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? theme.colorScheme.primary : theme.iconTheme.color,
                      ),
                      onPressed: _toggleBookmark,
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurfaceColor.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCookingTime(context),
                  const SizedBox(height: 24),
                  _buildToggleButtons(context),
                  const SizedBox(height: 24),
                  _isShowingIngredients
                      ? _buildNumberedList(widget.recipe.ingredients, context)
                      : _buildNumberedList(widget.recipe.steps, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final theme = Theme.of(context);
    final isNetworkImage = widget.recipe.imageUrl.startsWith('http');

    return isNetworkImage
        ? Image.network(
            widget.recipe.imageUrl,
            width: double.infinity,
            height: 350, 
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 350,
              color: theme.colorScheme.surface,
              child: Icon(Icons.image_not_supported_outlined, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 60),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 350,
                color: theme.colorScheme.surface,
                child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary))),
              );
            },
          )
        : Image.asset( 
            widget.recipe.imageUrl,
            width: double.infinity,
            height: 350,
            fit: BoxFit.cover,
          );
  }

  Widget _buildCookingTime(BuildContext context) {
    final theme = Theme.of(context);
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor, 
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15), 
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_outlined, color: onSurfaceColor.withOpacity(0.7), size: 20), 
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cooking time',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onSurfaceColor.withOpacity(0.7), 
                ),
              ),
              Text(
                widget.recipe.cookingTime,
                style: theme.textTheme.titleSmall?.copyWith( 
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor, 
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    final theme = Theme.of(context);
    final Color activeColor = theme.colorScheme.primary;
    final Color inactiveColor = theme.cardColor;
    final Color onInactiveColor = theme.colorScheme.onSurface; 

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (!_isShowingIngredients) {
                setState(() => _isShowingIngredients = true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isShowingIngredients ? activeColor : inactiveColor,
              foregroundColor: _isShowingIngredients ? theme.colorScheme.onPrimary : onInactiveColor, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: activeColor), 
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: _isShowingIngredients ? 4 : 0,
            ),
            child: Text('Ingredient', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)), 
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_isShowingIngredients) {
                setState(() => _isShowingIngredients = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isShowingIngredients ? activeColor : inactiveColor,
              foregroundColor: !_isShowingIngredients ? theme.colorScheme.onPrimary : onInactiveColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: activeColor), 
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: !_isShowingIngredients ? 4 : 0,
            ),
            child: Text('Steps', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)), 
          ),
        ),
      ],
    );
  }

  Widget _buildNumberedList(List<String> items, BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.bodySmall?.copyWith( 
                    color: primaryColor, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    items[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurfaceColor, 
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}