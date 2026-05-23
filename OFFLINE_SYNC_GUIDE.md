# Sincronización Offline - Guía Completa

## 📋 Archivos Modificados/Creados

### Creados
1. **`lib/data/services/sync_service.dart`** - Servicio de sincronización
2. **`lib/data/services/connectivity_service.dart`** - Detección de conectividad
3. **`lib/widgets/app_initializer.dart`** - Widget inicializador

### Modificados
1. **`lib/data/recipe_repository.dart`** - Métodos para obtener detalles desde local
2. **`lib/main.dart`** - Setup de providers y servicios
3. **`pubspec.yaml`** - Agrega `connectivity_plus: ^6.0.0`

## 🔄 Flujo de Sincronización

```
┌─────────────────────────────────────────────────────────┐
│                    APP INICIA                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
         ┌─────────────────────────┐
         │   AppInitializer        │
         │   (500ms delay)         │
         └────────────┬────────────┘
                      │
                      ▼
         ┌──────────────────────────────┐
         │  syncService.performFullSync()
         │        (Background)          │
         └────────────┬─────────────────┘
                      │
          ┌───────────┴──────────┐
          │                      │
          ▼                      ▼
    ┌──────────────┐      ┌──────────────┐
    │ syncAllRecipes│      │syncFavorites │
    │ GET /api/recipes
    │  + detalles  │      │GET /api/favorites
    └──────┬───────┘      └──────┬───────┘
           │                      │
           ▼                      ▼
    ┌──────────────┐      ┌──────────────┐
    │ BD Local:    │      │ BD Local:    │
    │• Recetas     │      │• isFavorite  │
    │• Ingredientes│      │ flag update  │
    │• Pasos       │      └──────────────┘
    └──────────────┘
           │
           ▼
    ✅ Listo para usar offline
```

## 🛜 Detectar Cambios de Conectividad

```
    ONLINE → OFFLINE
         (sin acción)
    
    OFFLINE → ONLINE ✅
         │
         ▼
    ConnectivityService detecta
         │
         ▼
    Dispara performFullSync()
    automáticamente
         │
         ▼
    BD local se actualiza
```

## 📲 Acceso Offline

Cuando **NO hay conexión**, el usuario puede:

✅ Ver **todas las recetas descargadas**
✅ Ver **ingredientes y pasos** de cualquier receta
✅ Buscar por **categoría**
✅ Filtrar por **tiempo de preparación**
✅ Ver **mis recetas**
✅ Ver **favoritos**

## 🔧 Cómo Funciona Internamente

### Sincronización Inicial
```dart
// Se ejecuta automáticamente al iniciar la app
await syncService.performFullSync();

// 1. Descarga TODAS las recetas con detalles
//    GET /api/recipes 
//    → List<RecipeDetailDto> (1 sola llamada)

// 2. Para cada receta, guarda:
//    - Datos principales en RecipeEntity
//    - Ingredientes en IngredientEntity  
//    - Pasos en StepEntity

// 3. Sincroniza favoritos
//    GET /api/favorites
//    → Actualiza isFavorite flag
```

### Acceso a Receta Offline
```dart
// En RecipeDetailView, al obtener detalles:
RecipeDetailDto? detail = await recipeRepository.getRecipeDetail(id);

// Si hay error de conexión, automáticamente:
// → getRecipeDetailFromLocal(id)
// → Retorna receta con ingredientes y pasos desde BD local
```

### Reconexión Automática
```dart
// ConnectivityService monitorea:
_connectivity.onConnectivityChanged.listen((result) {
  if (wasOffline && nowOnline) {
    // ✅ Automáticamente sincroniza todo
    _syncService?.performFullSync();
  }
});
```

## 📊 Estructura de BD Local

```
┌─ RecipeEntity
│  ├─ id (PrimaryKey)
│  ├─ title
│  ├─ category
│  ├─ preparationTime
│  ├─ image
│  ├─ isFavorite (booleano)
│  └─ isMine (booleano)
│
├─ IngredientEntity
│  ├─ id (PrimaryKey autoGenerate)
│  ├─ recipeId (ForeignKey → Recipe)
│  ├─ name
│  ├─ quantity
│  └─ unit
│
└─ StepEntity
   ├─ id (PrimaryKey autoGenerate)
   ├─ recipeId (ForeignKey → Recipe)
   ├─ stepNum
   └─ instruction
```

## 🚀 Prueba de Funcionamiento

1. **Primera carga (online)**
   - La app sincroniza automáticamente
   - Verifica en logs: `🎉 Sincronización completa exitosa`

2. **Activa modo avión**
   - Todas las recetas siguen funcionando
   - Ingredientes y pasos se ven normalmente

3. **Desactiva modo avión**
   - ConnectivityService detecta conexión
   - Logs: `🔄 Reconectado, iniciando sincronización...`
   - Datos se actualizan automáticamente

## ⚙️ Configuración en main.dart

Los providers están configurados en este orden:
1. `AppDatabase` - BD local
2. `ApiClient` - Cliente HTTP
3. `SyncService` - Sincronización (depende de ApiClient)
4. `ConnectivityService` - Monitoreo (depende de SyncService)
5. Rest de ViewModels

Esto asegura que todas las dependencias estén disponibles cuando se necesitan.

## 🐛 Logs para Debugging

Activa la consola y busca estos logs:

```
🚀 Iniciando sincronización automática
🔄 Iniciando sincronización de todas las recetas
📥 Descargadas X recetas con detalles
💾 Guardada receta N: "Nombre Receta"
✅ Sincronización de recetas completada
🔄 Sincronizando favoritos...
✅ Sincronización de favoritos completada
🎉 Sincronización completa exitosa
📡 Conectividad: ONLINE ✅ / OFFLINE ❌
🔄 Reconectado, iniciando sincronización...
```

## 📝 Notas Importantes

- La sincronización se ejecuta en **background** sin bloquear la UI
- Si hay error en sincronización, la app sigue funcionando offline normalmente
- Los flags `isFavorite` e `isMine` se preservan durante actualizaciones
- No se duplican recetas (actualiza si ya existe)
