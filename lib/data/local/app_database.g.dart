// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RecipeDao? _recipeDaoInstance;

  IngredientDao? _ingredientDaoInstance;

  StepDao? _stepDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RecipeEntity` (`id` INTEGER NOT NULL, `title` TEXT NOT NULL, `category` TEXT NOT NULL, `preparationTime` INTEGER NOT NULL, `image` TEXT, `isFavorite` INTEGER NOT NULL, `isMine` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ingredients` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `recipeId` INTEGER NOT NULL, `name` TEXT NOT NULL, `quantity` TEXT NOT NULL, `unit` TEXT NOT NULL, FOREIGN KEY (`recipeId`) REFERENCES `RecipeEntity` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `steps` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `recipeId` INTEGER NOT NULL, `stepNum` INTEGER NOT NULL, `instruction` TEXT NOT NULL, FOREIGN KEY (`recipeId`) REFERENCES `RecipeEntity` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE INDEX `index_ingredients_recipeId` ON `ingredients` (`recipeId`)');
        await database.execute(
            'CREATE INDEX `index_steps_recipeId` ON `steps` (`recipeId`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RecipeDao get recipeDao {
    return _recipeDaoInstance ??= _$RecipeDao(database, changeListener);
  }

  @override
  IngredientDao get ingredientDao {
    return _ingredientDaoInstance ??= _$IngredientDao(database, changeListener);
  }

  @override
  StepDao get stepDao {
    return _stepDaoInstance ??= _$StepDao(database, changeListener);
  }
}

class _$RecipeDao extends RecipeDao {
  _$RecipeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recipeEntityInsertionAdapter = InsertionAdapter(
            database,
            'RecipeEntity',
            (RecipeEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'category': item.category,
                  'preparationTime': item.preparationTime,
                  'image': item.image,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'isMine': item.isMine ? 1 : 0
                }),
        _recipeEntityUpdateAdapter = UpdateAdapter(
            database,
            'RecipeEntity',
            ['id'],
            (RecipeEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'category': item.category,
                  'preparationTime': item.preparationTime,
                  'image': item.image,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'isMine': item.isMine ? 1 : 0
                }),
        _recipeEntityDeletionAdapter = DeletionAdapter(
            database,
            'RecipeEntity',
            ['id'],
            (RecipeEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'category': item.category,
                  'preparationTime': item.preparationTime,
                  'image': item.image,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'isMine': item.isMine ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RecipeEntity> _recipeEntityInsertionAdapter;

  final UpdateAdapter<RecipeEntity> _recipeEntityUpdateAdapter;

  final DeletionAdapter<RecipeEntity> _recipeEntityDeletionAdapter;

  @override
  Future<void> deleteAllRecipes() async {
    await _queryAdapter.queryNoReturn('DELETE FROM RecipeEntity');
  }

  @override
  Future<RecipeEntity?> getRecipeById(int id) async {
    return _queryAdapter.query('SELECT * FROM RecipeEntity WHERE id = ?1',
        mapper: (Map<String, Object?> row) => RecipeEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            category: row['category'] as String,
            preparationTime: row['preparationTime'] as int,
            image: row['image'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            isMine: (row['isMine'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<RecipeEntity>> getAllRecipes() async {
    return _queryAdapter.queryList('SELECT * FROM RecipeEntity ORDER BY title',
        mapper: (Map<String, Object?> row) => RecipeEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            category: row['category'] as String,
            preparationTime: row['preparationTime'] as int,
            image: row['image'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            isMine: (row['isMine'] as int) != 0));
  }

  @override
  Future<List<RecipeEntity>> getRecipesByCategory(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntity WHERE category = ?1 ORDER BY title',
        mapper: (Map<String, Object?> row) => RecipeEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            category: row['category'] as String,
            preparationTime: row['preparationTime'] as int,
            image: row['image'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            isMine: (row['isMine'] as int) != 0),
        arguments: [category]);
  }

  @override
  Future<List<RecipeEntity>> getRecipesByMaxTime(int maxTime) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntity WHERE preparationTime <= ?1 ORDER BY preparationTime',
        mapper: (Map<String, Object?> row) => RecipeEntity(id: row['id'] as int, title: row['title'] as String, category: row['category'] as String, preparationTime: row['preparationTime'] as int, image: row['image'] as String?, isFavorite: (row['isFavorite'] as int) != 0, isMine: (row['isMine'] as int) != 0),
        arguments: [maxTime]);
  }

  @override
  Future<List<RecipeEntity>> getRecipesByCategoryAndTime(
    String category,
    int maxTime,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntity WHERE category = ?1 AND preparationTime <= ?2 ORDER BY preparationTime',
        mapper: (Map<String, Object?> row) => RecipeEntity(id: row['id'] as int, title: row['title'] as String, category: row['category'] as String, preparationTime: row['preparationTime'] as int, image: row['image'] as String?, isFavorite: (row['isFavorite'] as int) != 0, isMine: (row['isMine'] as int) != 0),
        arguments: [category, maxTime]);
  }

  @override
  Future<List<RecipeEntity>> getFavorites() async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntity WHERE isFavorite = 1 ORDER BY title',
        mapper: (Map<String, Object?> row) => RecipeEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            category: row['category'] as String,
            preparationTime: row['preparationTime'] as int,
            image: row['image'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            isMine: (row['isMine'] as int) != 0));
  }

  @override
  Future<List<RecipeEntity>> getMyRecipes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntity WHERE isMine = 1 ORDER BY title',
        mapper: (Map<String, Object?> row) => RecipeEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            category: row['category'] as String,
            preparationTime: row['preparationTime'] as int,
            image: row['image'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            isMine: (row['isMine'] as int) != 0));
  }

  @override
  Future<void> updateFavoriteStatus(
    int id,
    bool isFavorite,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE RecipeEntity SET isFavorite = ?2 WHERE id = ?1',
        arguments: [id, isFavorite ? 1 : 0]);
  }

  @override
  Future<void> updateIsMineStatus(
    int id,
    bool isMine,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE RecipeEntity SET isMine = ?2 WHERE id = ?1',
        arguments: [id, isMine ? 1 : 0]);
  }

  @override
  Future<List<RecipeEntity>> searchRecipesByTitle(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntity WHERE title LIKE ?1 ORDER BY title',
        mapper: (Map<String, Object?> row) => RecipeEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            category: row['category'] as String,
            preparationTime: row['preparationTime'] as int,
            image: row['image'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            isMine: (row['isMine'] as int) != 0),
        arguments: [query]);
  }

  @override
  Future<void> insertRecipe(RecipeEntity recipe) async {
    await _recipeEntityInsertionAdapter.insert(
        recipe, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertRecipes(List<RecipeEntity> recipes) async {
    await _recipeEntityInsertionAdapter.insertList(
        recipes, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecipe(RecipeEntity recipe) async {
    await _recipeEntityUpdateAdapter.update(recipe, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecipe(RecipeEntity recipe) async {
    await _recipeEntityDeletionAdapter.delete(recipe);
  }
}

class _$IngredientDao extends IngredientDao {
  _$IngredientDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _ingredientEntityInsertionAdapter = InsertionAdapter(
            database,
            'ingredients',
            (IngredientEntity item) => <String, Object?>{
                  'id': item.id,
                  'recipeId': item.recipeId,
                  'name': item.name,
                  'quantity': item.quantity,
                  'unit': item.unit
                }),
        _ingredientEntityDeletionAdapter = DeletionAdapter(
            database,
            'ingredients',
            ['id'],
            (IngredientEntity item) => <String, Object?>{
                  'id': item.id,
                  'recipeId': item.recipeId,
                  'name': item.name,
                  'quantity': item.quantity,
                  'unit': item.unit
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<IngredientEntity> _ingredientEntityInsertionAdapter;

  final DeletionAdapter<IngredientEntity> _ingredientEntityDeletionAdapter;

  @override
  Future<void> deleteIngredientsForRecipe(int recipeId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM ingredients WHERE recipeId = ?1',
        arguments: [recipeId]);
  }

  @override
  Future<List<IngredientEntity>> getIngredientsForRecipe(int recipeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ingredients WHERE recipeId = ?1 ORDER BY id',
        mapper: (Map<String, Object?> row) => IngredientEntity(
            id: row['id'] as int?,
            recipeId: row['recipeId'] as int,
            name: row['name'] as String,
            quantity: row['quantity'] as String,
            unit: row['unit'] as String),
        arguments: [recipeId]);
  }

  @override
  Future<void> deleteAllIngredients() async {
    await _queryAdapter.queryNoReturn('DELETE FROM ingredients');
  }

  @override
  Future<void> insertIngredient(IngredientEntity ingredient) async {
    await _ingredientEntityInsertionAdapter.insert(
        ingredient, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertIngredients(List<IngredientEntity> ingredients) async {
    await _ingredientEntityInsertionAdapter.insertList(
        ingredients, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteIngredient(IngredientEntity ingredient) async {
    await _ingredientEntityDeletionAdapter.delete(ingredient);
  }
}

class _$StepDao extends StepDao {
  _$StepDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _stepEntityInsertionAdapter = InsertionAdapter(
            database,
            'steps',
            (StepEntity item) => <String, Object?>{
                  'id': item.id,
                  'recipeId': item.recipeId,
                  'stepNum': item.stepNum,
                  'instruction': item.instruction
                }),
        _stepEntityDeletionAdapter = DeletionAdapter(
            database,
            'steps',
            ['id'],
            (StepEntity item) => <String, Object?>{
                  'id': item.id,
                  'recipeId': item.recipeId,
                  'stepNum': item.stepNum,
                  'instruction': item.instruction
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StepEntity> _stepEntityInsertionAdapter;

  final DeletionAdapter<StepEntity> _stepEntityDeletionAdapter;

  @override
  Future<void> deleteStepsForRecipe(int recipeId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM steps WHERE recipeId = ?1',
        arguments: [recipeId]);
  }

  @override
  Future<List<StepEntity>> getStepsForRecipe(int recipeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM steps WHERE recipeId = ?1 ORDER BY stepNum',
        mapper: (Map<String, Object?> row) => StepEntity(
            id: row['id'] as int?,
            recipeId: row['recipeId'] as int,
            stepNum: row['stepNum'] as int,
            instruction: row['instruction'] as String),
        arguments: [recipeId]);
  }

  @override
  Future<void> deleteAllSteps() async {
    await _queryAdapter.queryNoReturn('DELETE FROM steps');
  }

  @override
  Future<void> insertStep(StepEntity step) async {
    await _stepEntityInsertionAdapter.insert(step, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertSteps(List<StepEntity> steps) async {
    await _stepEntityInsertionAdapter.insertList(
        steps, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteStep(StepEntity step) async {
    await _stepEntityDeletionAdapter.delete(step);
  }
}
