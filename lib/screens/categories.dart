import 'package:flutter/material.dart';

import 'package:multi_screen_app/data/dummy_data.dart';
import 'package:multi_screen_app/models/meal.dart';
import 'package:multi_screen_app/widgets/category_grid_item.dart';
import 'package:multi_screen_app/screens/meals.dart';
import 'package:multi_screen_app/models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    required this.availableMeals,
  });

  final List<Meal> availableMeals;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

//01.02. naucili smo da moze da se doda jos jedan dependency za klasu -
// SingleTickerProviderStateMixin
class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  //01.02.
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // sa this, iz SingleTickerProviderStateMixin uzima se framerate
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );

    // pokretanje animacije
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectCategory(BuildContext context, Category category) {
    final filteredMeals = widget.availableMeals
        .where((meal) => meal.categories.contains(category.id))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealsScreen(
          title: category.title,
          meals: filteredMeals,
        ),
      ),
    ); // Navigator.push(context, route)
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: [
          // availableCategories.map((category) => CategoryGridItem(category: category)).toList()
          for (final category in availableCategories)
            CategoryGridItem(
              category: category,
              onSelectCategory: () {
                _selectCategory(context, category);
              },
            )
        ],
      ),
      // Uzima se GridView kao child ali nece biti ceo GridView re-builded, nego
      // samo Padding jer je stavljen kao return u builder-u
      // builder: (ctx, child) => Padding(
      //       padding: EdgeInsets.only(top: 100 - (_animationController.value * 100)),
      //       child: child,
      //     ));

      // Sa drive komandom override-ujemo inicijalne lowerBound i upperBound
      // na vrednosti koje nama trebaju. U ovom slucaju nam treba offset
      //   builder: (ctx, child) => SlideTransition(position: _animationController.drive(
      //     Tween(
      //       begin: const Offset(0, 0.3),
      //       end: const Offset(0, 0),
      //     ),
      //   ), child: child,),);

      // Ubacujemo radi optimizacije i lepse animacije CurvedAnimation sa
      // vrstom animacije
      builder: (ctx, child) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.3),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        ),
        child: child,
      ),
    );
  }
}
