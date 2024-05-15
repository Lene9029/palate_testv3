import 'package:sqflite/sqflite.dart' as sql;
import 'package:flutter/foundation.dart';

class SQLHelper{
  static Future<void> createRecipeTable(sql.Database database) async {
    await database.execute(""" 
      CREATE TABLE recipe(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT, 
    )""");
  }
  static Future<void> createIngredientsTabele(sql.Database database) async {
    await database.execute("""
      CREATE TABLE ingredients(
       ingredientsID INTEGER,
       recipeID INTEGER,
       name TEXT, 
      )
    """
    );
  }
  static Future<void> createInstructionTable(sql.Database database) async {
    await database.execute("""
    CREATE TABLE instructions(
      instructionsID INTEGER,
      recipeID INTEGER,
      instructions,
    )
    """);
  }


  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'recipes.db',
      version: 1,
      onCreate: (sql.Database database, int version) async{
        await 
        createRecipeTable(database);
      }
    ); 
  }
  
  static Future<int> createItem(String title, String? ingredients, String instructions) async {
    final db = await SQLHelper.db();

    final data  = {'title':title, 'ingredients': ingredients, 'instructions':instructions};
    final id = await db.insert(
      'recipe',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace
      );
      return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db(); 
    return db.query('recipe');
  }

  static Future<List<Map<String, dynamic>>> getItem(List<String> ingredients) async {
  final db = await SQLHelper.db();
  final List<Map<String, dynamic>> recipes = await db.query(
    'recipe',
    where: "ingredients IN (${List.filled(ingredients.length, '?').join(', ')})",
    whereArgs: ingredients,
  );
  return recipes;
}

  static Future<int> updateItem(
    int id, String title, String? ingredients, String instructions) async {
      final db = await SQLHelper.db();

      final data = {
        'title': title,
        'ingredients': ingredients,
        'instructions': instructions,
        'createdAt': DateTime.now().toString()
      };

      final result = 
      await db.update('recipe', data, where: "id = ?", whereArgs: [id]);
      return result;
    }

    static Future <void> deleteItem(int id) async {
      final db = await SQLHelper.db();
      try{
        await db.delete("recipe", where: "id = ?",whereArgs: [id] );
      } catch (error){
        debugPrint("Something Went Wrong $error");
      }

    }
    
} 