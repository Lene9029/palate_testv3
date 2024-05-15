import 'package:flutter/material.dart';
import 'package:newobjectdetectionyolov5/SQLHelper.dart';

class RecipeList extends StatefulWidget {
  final resultData;

  RecipeList({Key? key, required this.resultData}) : super(key: key);

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = getIngredients(widget.resultData);
  }

  Future<List<Map<String, dynamic>>> getIngredients(result) async {
    return await SQLHelper.getItem(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
        backgroundColor: Colors.pink,
        centerTitle: true,        
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Map<String, dynamic>> recipes = snapshot.data!;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeItem(recipe: recipe);
              },
            );
          }
        },
      ),
    );
  }
}

class RecipeItem extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeItem({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${recipe['title']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Ingredients: ${recipe['ingredients']}'),
            SizedBox(height: 4),
            Text('Instructions: ${recipe['instructions']}'),
          ],
        ),
      ),
    );
  }
}
