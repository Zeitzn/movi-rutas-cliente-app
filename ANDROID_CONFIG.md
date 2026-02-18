# Guía de Configuración Android - Rutas App

## 📱 Versiones Configuradas

| Parámetro | Versión | Estado |
|-----------|---------|--------|
| **compileSdk** | 36 | ✅ Configurado |
| **targetSdk** | 35 | ✅ Configurado |
| **minSdk** | 24 | ✅ Configurado |
| **ndkVersion** | 27.0.12077973 | ✅ Configurado |
| **Java** | 21 (LTS) | ✅ Configurado |
| **Namespace** | com.movi.rutas | ✅ Configurado |

## 🔧 Archivos Modificados

### 1. `android/app/build.gradle.kts`
- compileSdk actualizado a **36**
- targetSdk actualizado a **35**
- minSdk configurado a **24**
- ndkVersion actualizado a **27.0.12077973**
- Java actualizado a **21 (LTS)**
- namespace cambiado a **com.movi.rutas**
- applicationId actualizado a **com.movi.rutas**

### 2. `android/app/src/main/AndroidManifest.xml`
- Agregados permisos de ubicación:
  - `ACCESS_FINE_LOCATION` - Ubicación precisa
  - `ACCESS_COARSE_LOCATION` - Ubicación aproximada
  - `INTERNET` - Conexión a WebSocket y mapas
- Label actualizado a **Rutas App**

## 📋 Requisitos Previos

- Android SDK 35 instalado
- NDK versión 28.x.x instalado
- API Level 35 (Android 15) disponible en el emulador/dispositivo

## 🚀 Compilación

### Generar APK Debug
```bash
fvm flutter build apk --debug
```

### Generar APK Release
```bash
fvm flutter build apk --release
```

### Generar Bundle para Play Store
```bash
fvm flutter build appbundle --release
```

## 🎯 Compatibilidad

Con estas configuraciones:
- **Soporta Android 7.0 (API 24) a Android 15 (API 35)**
- **Alcanza aproximadamente 94% de los dispositivos activos**
- **Compatible con páginas de memoria de 16KB en Android 15+**

## 🔐 Google Maps API Key

Para usar Google Maps, agregar la clave en `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

Ubicación: Dentro de la etiqueta `<application>`

## 📦 Dependencias Nativas

El proyecto requiere:
- **geolocator** - Para acceso a ubicación
- **web_socket_channel** - Para WebSocket
- **google_maps_flutter** - Para mapas
- **flutter_map** - Para mapas alternativos

Todas están instaladas en el `pubspec.yaml`

## ⚠️ Notas Importantes

1. **Permisos en Runtime**: Los permisos de ubicación requieren aprobación del usuario en tiempo de ejecución (Android 6.0+)
2. **NDK 28**: Es obligatorio para nuevas compilaciones en Android 15
3. **compileSdk 35**: Necesario para usar las últimas APIs de Android
4. **Namespace único**: Cada aplicación debe tener un `namespace` único

## 🧪 Testing

```bash
# Conectar dispositivo Android
adb devices

# Ejecutar en dispositivo
fvm flutter run -d <device_id>

# Ver logs
fvm flutter logs
```

## 🐛 Troubleshooting

### Error: "compileSdk 35 not found"
```bash
# Actualizar Android SDK
sdkmanager "platforms;android-36"
```

### Error: "NDK 27 not found"
```bash
# Instalar NDK 27.0.12077973
sdkmanager "ndk;27.0.12077973"
```

### Permisos no funcionan
- Verificar que los permisos están en `AndroidManifest.xml`
- En tiempo de ejecución, la app solicita permisos al usuario
- En settings del dispositivo, habilitar permisos de ubicación

### WebSocket no conecta
- Verificar que `INTERNET` permiso está configurado
- Comprobar firewall del dispositivo
- Validar URL del servidor WebSocket

## 📖 Referencias

- [Android Developers - Manifest](https://developer.android.com/guide/topics/manifest/manifest-intro)
- [Android Studio - Build Configuration](https://developer.android.com/studio/build)
- [Flutter - Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Google Play - Target API Requirements](https://developer.android.com/google-play/requirements/target-api)

## ✅ Checklist Previo a Producción

- [ ] compileSdk = 36
- [ ] targetSdk = 35
- [ ] minSdk = 24
- [ ] ndkVersion = 27.0.12077973
- [ ] Java = 21 (LTS)
- [ ] Permisos de ubicación en AndroidManifest.xml
- [ ] INTERNET permiso configurado
- [ ] Google Maps API Key configurada (si aplica)
- [ ] Firma de release configurada
- [ ] Versión y versionCode actualizados
- [ ] Probado en múltiples dispositivos

---

**Fecha de actualización**: 17 de febrero de 2026
