# Rutas App - Aplicación Móvil de Rastreo de Rutas

Una aplicación móvil Flutter para rastrear vehículos en tiempo real de rutas seleccionadas mediante WebSocket, con integración flexible de servicios de mapas (Google Maps o Leaflet).

## 🚀 Características

- **Rastreo en Tiempo Real**: Recibe ubicaciones de vehículos a través de WebSocket
- **Mapas Adaptables**: Soporta tanto Google Maps como Leaflet sin cambios mayores en el código
- **Gestión de Ubicación**: Solicita y utiliza la ubicación del usuario automáticamente
- **Selector de Rutas**: Interfaz intuitiva para seleccionar rutas disponibles
- **Clean Architecture**: Arquitectura limpia y mantenible
- **BLoC Pattern**: Gestión de estado con BLoC para mejor separación de responsabilidades
- **Mock API**: Incluye datos de prueba para desarrollo sin servidor

## 📋 Requisitos

- **Flutter**: 3.41.1 (gestión con FVM)
- **Dart**: 3.11.0 o superior
- **Android SDK**: Para compilar para Android
- **Xcode**: Para compilar para iOS

## 🛠️ Instalación

### 1. Clonar el repositorio

```bash
cd /home/zeit/Repositorios/github/movi/rutas/cliente
```

### 2. Instalar dependencias

```bash
fvm flutter pub get
```

### 3. Generar archivos de serialización (opcional)

```bash
fvm flutter pub run build_runner build
```

## ▶️ Ejecución

### Desarrollo

```bash
# Para Android
fvm flutter run -d android

# Para iOS
fvm flutter run -d ios

# Para Web
fvm flutter run -d chrome
```

### Compilar APK

```bash
fvm flutter build apk --release
```

### Compilar Bundle para Google Play

```bash
fvm flutter build appbundle --release
```

## 🏗️ Estructura del Proyecto

```
lib/
├── core/                          # Capa de núcleo
│   ├── constants/                # Constantes de la aplicación
│   ├── errors/                   # Excepciones y fallos
│   ├── network/                  # Servicios de red
│   ├── permissions/              # Gestión de permisos
│   └── usecases/                 # Clase base para casos de uso
│
├── data/                          # Capa de datos
│   ├── datasources/              # Fuentes de datos (API, WebSocket, Mock)
│   ├── models/                   # Modelos de datos
│   └── repositories/             # Implementación de repositorios
│
├── domain/                        # Capa de dominio
│   ├── entities/                 # Entidades de negocio
│   ├── repositories/             # Interfaces de repositorios
│   └── usecases/                 # Casos de uso de negocio
│
├── presentation/                  # Capa de presentación
│   ├── bloc/                     # Gestión de estado con BLoC
│   ├── pages/                    # Páginas principales
│   ├── widgets/                  # Componentes reutilizables
│   └── utils/                    # Utilidades de UI
│
└── config/                        # Configuración de la aplicación
    └── service_locator.dart      # Inyección de dependencias
```

## 🔄 Flujo de Datos

### 1. Inicio de la Aplicación
- Solicita permisos de ubicación
- Carga lista de rutas disponibles
- Muestra mensaje "Selecciona la ruta que estás esperando"

### 2. Selección de Ruta
- Usuario selecciona una ruta del dropdown
- Se establece conexión WebSocket
- Comienza a escuchar ubicaciones de vehículos
- Se muestran marcadores en tiempo real

### 3. Deselección de Ruta
- Usuario selecciona "Seleccionar ruta"
- Se desconecta del WebSocket
- Se limpian los marcadores de vehículos
- Se muestra el mensaje inicial

## 🗺️ Cambiar Proveedor de Mapas

Para cambiar entre Google Maps y Leaflet, edita `lib/presentation/utils/map_provider.dart`:

```dart
// Para Google Maps
MapProviderConfig.setProvider(MapProvider.googleMaps);

// Para Leaflet
MapProviderConfig.setProvider(MapProvider.leaflet);
```

## 🔐 Configuración de Google Maps

Para usar Google Maps en Android:

1. Edita `android/app/src/main/AndroidManifest.xml`
2. Agrega tu API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

## 🌐 Configuración de WebSocket

Las URLs de WebSocket están configuradas en:
- `lib/core/constants/app_constants.dart` - URL base
- `lib/data/datasources/remote/mock_routes_datasource.dart` - URLs de prueba

Por defecto usa: `ws://192.168.1.100:3000`

Edita estas URLs según tu configuración del servidor.

## 📍 Datos Mock

La aplicación incluye datos de prueba:

**Rutas disponibles:**
- Ruta Centro-Norte
- Ruta Sureste
- Ruta Occidente
- Ruta Oriente

Estos datos se cargan automáticamente sin necesidad de servidor.

## 🧪 Testing

```bash
# Ejecutar pruebas unitarias
fvm flutter test

# Ejecutar pruebas con coverage
fvm flutter test --coverage
```

## 📱 Permisos Requeridos

### Android
- `ACCESS_FINE_LOCATION` - Ubicación precisa
- `ACCESS_COARSE_LOCATION` - Ubicación aproximada
- `INTERNET` - Para conectarse a WebSocket y descargar mapas

### iOS
- `NSLocationWhenInUseUsageDescription` - Para solicitar ubicación
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Para uso continuo

## 🎯 BLoCs Principales

### RouteSelectionBloc
Gestiona la carga y selección de rutas disponibles.

**Estados:**
- `RouteSelectionLoading` - Cargando rutas
- `RouteSelectionLoaded` - Rutas cargadas (con ruta seleccionada opcional)
- `RouteSelectionError` - Error al cargar

**Eventos:**
- `LoadRoutesEvent` - Cargar rutas
- `SelectRouteEvent` - Seleccionar una ruta
- `DeselectRouteEvent` - Deseleccionar ruta

### WebSocketBloc
Gestiona la conexión al WebSocket.

**Estados:**
- `WebSocketConnecting` - Conectando
- `WebSocketConnected` - Conectado
- `WebSocketDisconnected` - Desconectado
- `WebSocketError` - Error de conexión

**Eventos:**
- `ConnectWebSocketEvent` - Conectar a WebSocket
- `DisconnectWebSocketEvent` - Desconectar

### VehicleLocationBloc
Gestiona las ubicaciones de vehículos recibidas.

**Estados:**
- `VehicleLocationUpdated` - Ubicaciones actualizadas
- `VehicleLocationError` - Error

**Eventos:**
- `ListenVehicleLocationsEvent` - Comenzar a escuchar
- `UpdateVehicleLocationEvent` - Actualizar ubicaciones
- `ClearLocationsEvent` - Limpiar ubicaciones

### UserLocationBloc
Gestiona la ubicación del usuario.

**Estados:**
- `UserLocationUpdated` - Ubicación actualizada
- `UserLocationError` - Error
- `UserLocationPermissionDenied` - Permiso denegado

**Eventos:**
- `RequestPermissionsEvent` - Solicitar permisos
- `UpdateUserLocationEvent` - Actualizar ubicación
- `StartListeningLocationEvent` - Comenzar a escuchar cambios

## 🔌 Integración con Backend

Para integrar con un servidor real:

1. Edita `lib/core/constants/app_constants.dart` con las URLs correctas
2. Implementa `RoutesRemoteDataSourceImpl` si deseas usar API real
3. Actualiza las URLs de WebSocket en las rutas

Ejemplo formato de datos esperado en WebSocket:
```json
{
  "latitude": 4.7110,
  "longitude": -74.0721,
  "placa": "ABC-1234",
  "timestamp": "2026-02-17T10:30:00Z"
}
```

## 📚 Dependencias Principales

- **flutter_bloc** (8.1.0) - Gestión de estado
- **google_maps_flutter** (2.5.0) - Mapas de Google
- **flutter_map** (6.0.0) - Mapas con Leaflet
- **geolocator** (9.0.0) - Acceso a ubicación
- **web_socket_channel** (2.4.0) - WebSocket
- **dio** (5.2.0) - Cliente HTTP
- **get_it** (7.6.0) - Inyección de dependencias
- **dartz** (0.10.1) - Tipos funcionales (Either, Left, Right)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
2. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
3. Push a la rama (`git push origin feature/AmazingFeature`)
4. Abre un Pull Request

## 📝 Notas de Desarrollo

- La arquitectura sigue **Clean Architecture** para máxima escalabilidad
- Los **BLoCs** se utilizan para separar lógica de negocio de UI
- Los **mapas son abstractos** permitiendo cambiar de proveedor fácilmente
- Los **datos mock** permiten desarrollo sin servidor backend
- El **WebSocket** maneja automáticamente reconexión y errores

## 🐛 Troubleshooting

### Error: "flutter command not found"
Asegúrate de usar FVM correctamente:
```bash
fvm flutter --version
```

### Google Maps no se muestra
- Verifica que tengas la API key configurada
- Comprueba permisos en `AndroidManifest.xml`

### WebSocket no conecta
- Verifica que el servidor esté corriendo
- Revisa la URL configurada en `app_constants.dart`
- Comprueba los logs de Flutter

### Permisos de ubicación denegados
- La app solicitará permisos al abrir
- En settings del dispositivo, habilita permisos de ubicación
- Reinicia la app después de dar permisos

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver archivo LICENSE para más detalles.

## 👤 Autor

Desarrollado por el equipo de MOVI

## 📞 Soporte

Para reportar bugs o solicitar features, abre un issue en el repositorio.

---

**Versión**: 1.0.0  
**Última actualización**: 17 de febrero de 2026
