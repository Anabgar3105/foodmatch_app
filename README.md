# FoodMatch App 📱
![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![Provider](https://img.shields.io/badge/State%20Management-Provider-orange)
![Android](https://img.shields.io/badge/Platform-Android-brightgreen)

> **Aplicación móvil multiplataforma** que revoluciona el descubrimiento de recetas con una interfaz intuitiva tipo "swipe" para navegar por recetas. MVP completamente funcional con autenticación, gestión de favoritos y creación de recetas.

**🔌 Backend Requerido:** Esta app necesita el backend de FoodMatch ejecutándose. Consulta el [README del Backend](https://github.com/Anabgar3105/foodmatch_back)

**⚠️ Estado:** Actualmente funciona **en local**. Consulta la sección de [Instalación](#-instalación) para configurarlo.

## 🎯 Descripción General

La vida moderna y las limitaciones presupuestarias son barreras significativas para mantener comidas diarias variadas y económicas, generando dependencia de comida rápida o servicios de entrega costosos.

**FoodMatch** aborda este problema con una **aplicación móvil multiplataforma que conecta a usuarios con poco tiempo o presupuesto ajustado con recetas fáciles, rápidas y económicas**. La interfaz se basa en gestos intuitivos (swipe cards) para agilizar el descubrimiento de recetas, integrando:

- 🎴 **Navegación Swipe:** Descubre recetas deslizando derecha (para ver más) o izquierda (para pasar a la siguiente receta)
- 👤 **Gestión Personal:** Registro, perfiles personalizados y cambio de contraseña
- ❤️ **Favoritos:** Guarda recetas que te gusten para acceso rápido
- 👨‍🍳 **Contribución Comunitaria:** Crea y comparte tus propias recetas
- 📸 **Multimedia:** Carga imágenes de tus recetas
- 🔍 **Búsqueda Inteligente:** Filtra por categoría, tiempo de preparación
- 🌓 **Temas Personalizables:** Interfaz adaptable (light/dark mode)
- 📲 **Accesibilidad:** Diseño responsive para todos los tamaños de pantalla

La arquitectura implementa un **Cliente-Servidor completo** con Flutter en frontend y Spring Boot en backend, garantizando escalabilidad, seguridad y experiencia de usuario fluida.

## ⭐ Pantallas & Características

### 🔐 Autenticación
- **Login View** - Inicio de sesión con validación JWT
- **Signup View** - Registro de nuevo usuario
- ✅ Persistencia de token (auto-login si token válido)
- ✅ Auto-logout si token expira (60 días)

### 🎴 Descubrimiento de Recetas
- **Recipe Swipe View** ⭐ - Pantalla principal con tarjetas deslizables
  - Swipe → derecha (❤️ Favorito) o izquierda (👎 Siguiente)
  - Visualización de imagen, título, categoría, tiempo de preparación
  - Integración con `flutter_card_swiper` para animaciones fluidas
  - Búsqueda y filtrado en tiempo real:
    - 🏷️ Por categoría (ENTRANTES, SNACKS, PLATOS_COMPLETOS, POSTRES)
    - ⏱️ Por tiempo de preparación máximo

### 🍳 Gestión de Recetas
- **Recipe Detail View** - Detalles completos de una receta
  - Ingredientes con cantidades
  - Pasos de elaboración numerados
  - Información nutricional/de tiempo
  - Botón para guardar como favorito
  
- **My Recipes View** - Listado de tus propias recetas
  - Opciones para editar o eliminar
  - Vista rápida de tus creaciones
  
- **Add Recipe View** - Crear y editar recetas
  - Formulario completo con validación
  - Carga de imágenes con `image_picker`
  - Selección de categoría y tiempo
  - Añadir múltiples ingredientes y pasos

### ❤️ Favoritos
- **Favorites View** - Colección de recetas guardadas
  - Formato tipo tarjetas para quick preview
  - Eliminar de favoritos
  - Acceso rápido a detalles

### 👤 Perfil & Configuración
- **Profile View** - Ver información de perfil
  - Avatar del usuario
  - Nombre, email, fecha de registro
  - Resumen de actividad
  
- **Edit Profile View** - Editar perfil personal
  - Cambiar nombre y email
  - Actualizar avatar con upload a Cloudinary
  - Cambiar contraseña
  
- **Settings View** - Preferencias de la app
  - Toggle de tema (Light/Dark mode) 🌓
  - Persistencia de preferencias
  
- **Help View** - Información y soporte

## 🏗️ Arquitectura Técnica

### Patrón de Arquitectura: Clean Architecture + MVVM

```
lib/
├── main.dart                    # Punto de entrada
├── core/                        # Lógica compartida
│   ├── theme/                   # Temas light/dark
│   └── constants/               # Constantes globales
├── data/
│   ├── api_client.dart         # Cliente HTTP con JWT
│   ├── auth_repository.dart    # Autenticación
│   ├── recipe_repository.dart  # Gestión de recetas
│   └── favorite_repository.dart # Sistema de favoritos
├── models/                      # Modelos de datos
│   ├── user.dart
│   ├── recipe.dart
│   └── favorite.dart
├── viewmodels/                  # Estado (Provider)
│   ├── auth_viewmodel.dart
│   ├── recipe_viewmodel.dart
│   ├── favorite_viewmodel.dart
│   └── theme_viewmodel.dart
└── views/                       # Pantallas UI
    ├── login_view.dart
    ├── signup_view.dart
    ├── home_view.dart
    ├── recipe_swipe_view.dart
    ├── recipe_detail_view.dart
    ├── add_recipe_view.dart
    ├── my_recipes_view.dart
    ├── favorites_view.dart
    ├── profile_view.dart
    ├── edit_profile_view.dart
    ├── settings_view.dart
    └── help_view.dart
```

### State Management: Provider 6.1.2

**Patrón:** ChangeNotifier + Consumer/Provider para reactividad automática

**Inyección de Dependencias (main.dart):**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeViewModel(initialThemeMode)),
    ChangeNotifierProvider(create: (_) => RecipeViewModel()),
    ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
    ChangeNotifierProvider(create: (_) => RecipeDetailViewModel()),
    ChangeNotifierProvider(create: (_) => SignupViewModel()),
    ChangeNotifierProvider(create: (_) => AddRecipeViewModel()),
    ChangeNotifierProvider(create: (_) => ProfileViewModel()),
  ],
  child: FoodMatchApp(initialRoute: initialRoute),
)
```

**⚠️ Nota:** `LoginViewModel` NO es global - se crea localmente en la pantalla de login para mantener aislada la lógica de autenticación.

**ViewModels Implementados:**

1. **LoginViewModel** - Gestión de login (LOCAL, no global)
   - `login(email, password)` → Valida credenciales, obtiene JWT, lo persiste en SharedPreferences
   - Propiedades: `isLoading`, `errorMessage`, `isSuccess`
   - **Almacenamiento:** `auth_token`, `auth_username`, `auth_email`, `auth_full_name`, `auth_avatar`
   - **Creación:** `ChangeNotifierProvider(create: (_) => LoginViewModel())` en LoginView
   - **Uso:** El LoginViewModel es local a LoginView - una vez autenticado, navega a home y nunca se usa de nuevo

2. **SignupViewModel** - Registro de usuarios (GLOBAL)
   - `signup(name, surname, email, username, password)` → Crea usuario, obtiene JWT automáticamente
   - `getErrorMessage()` → Parsea errores del backend
   - Propiedades: `isLoading`, `registrationSuccess`
   - **Uso:** Consumer en SignupView

3. **RecipeViewModel** - Descubrimiento y gestión de recetas (GLOBAL)
   - `fetchRecipes()` → Obtiene todas las recetas
   - `searchRecipes(category, maxTime)` → Filtra por categoría y tiempo
   - `getRecipeDetail(id)` → Detalles completos de una receta
   - `createRecipe(recipeData)` → Crea receta (multipart con imagen)
   - `updateRecipe(id, data)` → Edita receta existente
   - `deleteRecipe(id)` → Elimina receta del usuario
   - `getUserRecipes()` → Lista solo recetas del usuario autenticado
   - Propiedades: `recipes`, `currentRecipe`, `userRecipes`, `isLoading`, `errorMessage`
   - **Uso:** Consumer en RecipeSwiperView, RecipeDetailView, MyRecipesView

4. **FavoritesViewModel** - Gestión de favoritos (GLOBAL)
   - `getFavorites()` → Obtiene recetas marcadas como favoritas
   - `addFavorite(recipeId)` → Guarda receta a favoritos (resultado del swipe derecha)
   - `removeFavorite(recipeId)` → Elimina de favoritos
   - `isFavorite(recipeId)` → Verifica si una receta está en favoritos
   - Propiedades: `favorites`, `favoriteIds` (para búsqueda O(1)), `isLoading`
   - **Uso:** Consumer en RecipeSwiperView (❤️ visual), FavoritesView (listado), RecipeDetailView (botón toggle)

5. **RecipeDetailViewModel** - Detalles y acciones de una receta (GLOBAL)
   - `loadRecipeDetail(recipeId)` → Carga ingredientes, pasos, detalles
   - `toggleFavorite(recipeId)` → Alterna favorito (simplifica código en detalles)
   - Propiedades: `recipe`, `ingredients`, `elaborationSteps`, `isLoading`
   - **Uso:** Consumer en RecipeDetailView

6. **AddRecipeViewModel** - Creación/edición de recetas (GLOBAL)
   - `createRecipe(title, description, category, prepTime, ingredients, steps, image)` → Crea con upload de imagen
   - `updateRecipe(id, ...)` → Edita receta existente
   - `uploadImage(file)` → Sube imagen a Cloudinary (retorna URL)
   - Propiedades: `isLoading`, `successMessage`, `errorMessage`, `uploadProgress`
   - **Uso:** Consumer en AddRecipeView

7. **ProfileViewModel** - Perfil y logout (GLOBAL)
   - `logout()` → **Limpia TODOS los datos de autenticación de SharedPreferences**
   - `updateProfile(name, email, avatar)` → Actualiza perfil del usuario
   - `changePassword(oldPassword, newPassword)` → Cambia contraseña
   - `getProfile()` → Obtiene datos del usuario actual (desde SharedPreferences)
   - Propiedades: `userName`, `userEmail`, `userAvatar`, `isLoading`, `updateSuccess`
   - **Uso:** Consumer en ProfileView, EditProfileView; logout en SettingsView

8. **ThemeViewModel** - Gestión de tema light/dark (GLOBAL)
   - `toggleTheme()` → Cambia entre light/dark mode
   - `initTheme()` → Carga preferencia guardada (`theme_preference_$username`)
   - Propiedades: `isDarkMode`, `themeData`
   - **Uso:** Listener en main.dart; Consumer en SettingsView

**Gestión Centralizada de Autenticación:**

La autenticación NO se maneja en un único ViewModel, sino que se distribuye:
- **Login:** LoginViewModel (local) → persiste token en SharedPreferences
- **Api Client:** Inyecta token automáticamente: `Authorization: Bearer $token`
- **Logout:** ProfileViewModel (global) → limpia SharedPreferences
- **Startup:** main.dart valida JWT (verifica `exp` claim); si expira, elimina token y redirige a `/login`

**Tokens y Persistencia (SharedPreferences):**
- `auth_token` → JWT para autenticación en API
- `auth_username`, `auth_email`, `auth_full_name`, `auth_avatar` → Datos del usuario
- `theme_preference_$username` → Tema personalizado del usuario (ej: `theme_preference_juan` → `true|false`)

**Instanciación de Repositorios:**
Cada ViewModel instancia sus repositorios con un `ApiClient()` fresco que carga automáticamente el token del SharedPreferences:
```dart
class RecipeViewModel extends ChangeNotifier {
  final _repository = RecipeRepository(ApiClient());
  
  Future<void> fetchRecipes() async {
    // ApiClient dentro de RecipeRepository añade token automáticamente
    final recipes = await _repository.getRecipes();
    // ...
  }
}
```

### Gestión de Datos

**API Client Personalizado:**
- Interceptor de JWT tokens en cada petición (`Authorization: Bearer {token}`)
- Manejo automático de errores HTTP → conversión a excepciones legibles
- Validación y parseo de respuestas JSON
- Auto-logout si token expira (invalida sesión y navega a login)
- Timeout de 30 segundos por petición

**Persistencia Local (SharedPreferences):**
- `token` → JWT para autenticación
- `username` → Nombre del usuario conectado
- `theme_mode` → light/dark (booleano)
- `user_email` → Email del usuario
- Sincronización automática cuando cambian datos en ViewModels

## 🛠️ Stack Tecnológico

| Funcionalidad | Paquete | Versión |
|---|---|---|
| **HTTP Client** | `http` | 1.1.0 |
| **State Management** | `provider` | 6.1.2 |
| **Swipe Cards** | `flutter_card_swiper` | 10.0.0 |
| **Image Picker** | `image_picker` | 1.0.0 |
| **Image Caching** | `cached_network_image` | 3.3.0 |
| **Persistencia** | `shared_preferences` | 2.2.0 |
| **URL Launcher** | `url_launcher` | 6.1.0 |

## 🎨 Características de Interfaz

### Responsive Design
- ✅ Adaptación automática a pantallas pequeñas, medianas y grandes
- ✅ Orientación portrait y landscape
- ✅ SafeArea en todo el app

### Temas
- 🌓 **Light Mode** - Interfaz clara y moderna
- 🌙 **Dark Mode** - Tema oscuro para bajo consumo de batería
- ✅ Persistencia de preferencia de tema
- ✅ Contraste accesible (WCAG AA)

### Interactividad
- 🎴 Animaciones suave de swipe en tarjetas
- 🔄 Pull-to-refresh en listados
- ⚡ Loading states con spinners
- 📢 Notificaciones de error con retry automático
- 🎯 Validaciones en tiempo real en formularios

## 📱 Requisitos

- **Flutter 3.x+**
- **Dart 3.x+**
- **iOS:** Xcode 14+ y cocoapods
- **Android:** Android Studio, SDK 23+
- **API Backend:** FoodMatch API ejecutándose

## 🚀 Instalación

### ⚠️ Requisitos Previos

Esta aplicación está configurada para ejecutarse **en ambiente local** únicamente. Asegúrate de:
- Tener el **backend de FoodMatch ejecutándose** en `http://localhost:8080`
- Si usas dispositivo físico o emulador remoto, actualiza la URL en `api_client.dart`

### 1. Clonar repositorio
```bash
git clone https://github.com/tu_usuario/foodmatch_app.git
cd foodmatch_app
```

### 2. Obtener dependencias
```bash
flutter pub get
```

### 3. Configurar la API
Edita `lib/data/api_client.dart` y configura la URL base:
```dart
static const String baseUrl = 'http://localhost:8080/api';
// o para testing real: 'https://tuserver.com/api'
```

### 4. Ejecutar en desarrollo

**En emulador/dispositivo Android:**
```bash
flutter run
```

**En iOS (solo macOS):**
```bash
flutter run -d iPhone
```

**En Web:**
```bash
flutter run -d web
```

### 5. Build para producción

**Android:**
```bash
flutter build apk --release
# o para App Bundle:
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🧪 Testing

### Tests de Integración

```bash
# Ejecutar todos los tests de integración
flutter test integration_test/

# Test específico
flutter test integration_test/app_test.dart
```

**Tests incluidos:**
- ✅ Flujo de navegación completo (Login → App → Profile)
- ✅ Validación de mensajes de error
- ✅ Persistencia de estado
- ✅ Responsividad en diferentes tamaños
- ✅ Cambio de temas
- ✅ Cambio de orientación
- ✅ Gestos de swipe

### Tests Unitarios

```bash
# Ejecutar tests unitarios
flutter test test/

# Con cobertura
flutter test --coverage test/
```

## 📡 Integración con Backend

La app se conecta a la **API REST de FoodMatch** (backend en Spring Boot).

### Flow de Autenticación
1. Usuario se registra/inicia sesión
2. Backend retorna JWT token
3. App lo almacena en `SharedPreferences`
4. Cada petición incluye: `Authorization: Bearer {token}`
5. Si token expira → auto-logout y redirige a login

### Endpoints consumidos

**Públicos:**
```
POST   /api/users/signup          → Registro
POST   /api/users/login           → Login
```

**Protegidos (con token):**
```
GET    /api/recipes               → Listar recetas (swipe)
GET    /api/recipes/search        → Buscar (filtros)
GET    /api/recipes/{id}          → Detalles
GET    /api/recipes/my-recipes    → Mis recetas
POST   /api/recipes               → Crear receta
PUT    /api/recipes/{id}          → Editar receta
DELETE /api/recipes/{id}          → Eliminar receta

GET    /api/favorites             → Mis favoritos
POST   /api/favorites/{id}        → Guardar favorito
DELETE /api/favorites/{id}        → Eliminar favorito

PUT    /api/users/profile         → Editar perfil
PUT    /api/users/password        → Cambiar contraseña
POST   /api/media/upload          → Subir imagen
```

## 📁 Estructura General

```
foodmatch_app/
├── lib/                  # Código fuente Dart
├── test/                 # Tests unitarios
├── integration_test/     # Tests de integración
├── android/              # Configuración Android nativa
├── ios/                  # Configuración iOS nativa
├── web/                  # Configuración Web
├── linux/                # Configuración Linux
├── macos/                # Configuración macOS
├── windows/              # Configuración Windows
├── pubspec.yaml          # Dependencias y configuración
├── analysis_options.yaml # Configuración de análisis
└── README.md
```

## 🎯 Guía de Uso

### Primera vez
1. Abre la app → Pantalla de Login
2. Toca "Registrarse" para crear cuenta
3. Rellena email, nombre de usuario, contraseña
4. Inicia sesión con tus credenciales
5. ¡Empieza a descubrir recetas!

### Descubriendo Recetas
1. En la pantalla principal aparecen tarjetas de recetas
2. Desliza → derecha para guardar como favorito ❤️
3. Desliza ← izquierda para saltar a la siguiente
4. Toca la tarjeta para ver detalles completos
5. Usa filtros para buscar por categoría o tiempo

### Creando Recetas
1. Toca "+" en la navbar
2. Rellena nombre, descripción, categoría
3. Añade ingredientes (cantidad + nombre)
4. Añade pasos de elaboración
5. Sube una imagen bonita
6. ¡Publica para la comunidad!

### Tu Perfil
1. Toca el ícono de perfil
2. Edita tu información
3. Cambia tu avatar
4. Gestiona tus recetas
5. Accede a settings para tema

## 🐛 Troubleshooting

### "Connection refused" o no conecta con API
- Verifica que el backend está ejecutándose en `http://localhost:8080`
- Comprueba la URL en `api_client.dart`
- Si usas dispositivo real: usa IP interna, no localhost

### Los swipes no funcionan suave
- Verifica FPS: Settings → Performance
- Reduce cantidad de recetas en pantalla
- Actualiza `flutter_card_swiper` a última versión

### Las imágenes no se ven
- Comprueba conexión a internet
- Verifica que Cloudinary está configurado en backend
- Intenta descargar caché en Settings

### Token expira y no puedo login
- Cierra la app completamente
- Limpia caché: Settings → Clear cache
- Vuelve a registrarte o intenta login

## 📊 Notas sobre el MVP

✅ **Implementado:**
- Autenticación JWT completa
- Navegación fluida entre pantallas
- Swipe cards funcionales
- CRUD de recetas
- Sistema de favoritos
- Gestión de perfil
- Tema light/dark
- Tests de integración
- Caché de imágenes
- Validaciones de formularios

⚠️ **Futuros:**
- Notificaciones push
- Compartir recetas en redes sociales
- Comentarios y ratings
- Sistema de puntajes y badges
- Búsqueda avanzada (por ingredientes, alérgenos)
- Modo offline

## 🤝 Backend Requerido

Esta app necesita que el backend FoodMatch esté ejecutándose. Consulta el [README del backend](https://github.com/Anabgar3105/foodmatch_back) para instrucciones de instalación.

## 📄 Licencia

Este proyecto es parte del Trabajo de Fin de Ciclo (TFC).
