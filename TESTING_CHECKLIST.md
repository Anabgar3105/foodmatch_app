# Checklist de Verificación - Sincronización Offline

## ✅ Antes de Ejecutar la App

- [ ] Se agregó `connectivity_plus: ^6.0.0` a `pubspec.yaml`
- [ ] Ejecutar: `flutter pub get`
- [ ] Ejecutar: `flutter pub run build_runner build --delete-conflicting-outputs` (para regenerar DB si es necesario)

## ✅ Configuración de Permisos (Si es necesario)

### Android
Los permisos de conectividad normalmente están incluidos en `connectivity_plus`, pero verifica en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
```

### iOS
Normalmente no requiere permisos adicionales para leer estado de conectividad.

## 🧪 Pruebas Funcionales

### Test 1: Sincronización Inicial
**Precondición:** App conectada a internet

1. Limpiar BD local (o reinstalar app)
2. Abrir app
3. **Verificar en Logs:**
   - `🚀 Iniciando sincronización automática de la app...`
   - `🔄 Iniciando sincronización de todas las recetas...`
   - `📥 Descargadas X recetas con detalles`
   - `💾 Guardada receta [id]: [Nombre]` (múltiples líneas)
   - `✅ Sincronización de recetas completada`
   - `✅ Sincronización de favoritos completada`
   - `🎉 Sincronización completa exitosa`

**Resultado esperado:** Todas las recetas disponibles en la app

### Test 2: Acceso Offline Completo
**Precondición:** Sincronización completada exitosamente

1. Activar **Modo Avión**
2. Navegar a:
   - [ ] Home: Ver todas las recetas (deben aparecer en la lista)
   - [ ] Recipe Detail: Seleccionar una receta y ver detalles
     - [ ] Ingredientes visibles
     - [ ] Pasos de elaboración visibles
   - [ ] Buscar: Filtrar por categoría
   - [ ] Buscar: Filtrar por tiempo máximo
   - [ ] Favoritos: Ver recetas favoritas
   - [ ] Mis Recetas: Ver recetas creadas

**Resultado esperado:** Todo funciona sin errores de conexión

### Test 3: Sincronización al Reconectar
**Precondición:** App en modo offline, en detalle de una receta

1. Desactivar Modo Avión
2. Esperar 2-3 segundos
3. **Verificar en Logs:**
   - `📡 Conectividad: ONLINE ✅`
   - `🔄 Reconectado, iniciando sincronización...`
   - `🔄 Iniciando sincronización de todas las recetas...`
   - `🎉 Sincronización completa exitosa`

**Resultado esperado:** Sincronización automática sin intervención del usuario

### Test 4: Favoritos Sincronizados
**Precondición:** Usuario con favoritos en el servidor

1. Línea base: App online
2. Agregar/quitar favoritos en el servidor desde otra sesión
3. Activar Modo Avión + Desactivar (para forzar reconexión)
4. Esperar sincronización automática
5. **Verificar:** Los cambios en favoritos se reflejan en BD local

**Resultado esperado:** Favoritos sincronizados correctamente

### Test 5: Manejo de Errores
**Precondición:** App en offline

1. Desconectar conexión mientras sincronización está en curso
2. Reconectar
3. **Verificar:** No debería haber crashes, solo mensajes de error en logs

**Resultado esperado:** La app recupera sincronización sin problemas

## 🐛 Troubleshooting

### "connectivity_plus is not found"
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Sincronización no ocurre automáticamente
- Verificar en Logs que `AppInitializer` se está ejecutando
- Verificar que `ConnectivityService.init()` fue llamado
- Comprobar que hay conexión realmente (Modo Avión OFF)

### BD local parece vacía
- Verificar que `dbPath` es correcto en `AppInitializer`
- Borrar app y reinstalar
- Ejecutar: `flutter pub run build_runner build --delete-conflicting-outputs`

### Sincronización lenta
- Aceptable: Primero tiende a ser más lenta (descargando todo)
- Las siguientes son más rápidas (solo actualizaciones)
- En conexiones lentas, puede tomar varios segundos

### Ver BD Local (Debugging)
Para inspeccionar la BD local usando Android Studio:
1. Device File Explorer → `/data/data/com.example.foodmatch_app/databases/`
2. Descargar `foodmatch_app.db`
3. Abrir con SQLite Browser

## 📊 Monitoreo en Logs

Búsqueda de logs útil:
```
grep "🔄" logs  # Ver sincronizaciones
grep "✅" logs  # Ver completados
grep "❌" logs  # Ver errores
grep "📡" logs  # Ver estado conectividad
```

## 🎯 Expectativas de Rendimiento

| Operación | Tiempo Esperado | Notas |
|-----------|-----------------|-------|
| Sincronización inicial | 5-10s | Depende de # de recetas |
| Sincronización posterior | 1-3s | Solo cambios |
| Acceso recipe offline | < 100ms | Instantáneo desde BD local |
| Búsqueda offline | < 200ms | Muy rápido |

## 📋 Validación Final

- [ ] Logs muestran sincronización exitosa
- [ ] Acceso offline funciona completamente
- [ ] Reconexión automática dispara sincronización
- [ ] Ingredientes y pasos disponibles offline
- [ ] Favoritos sincronizados correctamente
- [ ] Sin crashes al cambiar conectividad
- [ ] Búsqueda/filtrado offline funciona
