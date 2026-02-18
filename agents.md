# Aplicación Móvil de Rastreo de Rutas - Agentes de Desarrollo

## 📋 Descripción General

Aplicación móvil Flutter para rastrear vehículos en tiempo real de rutas seleccionadas mediante WebSocket, con integración flexible de servicios de mapas (Google Maps o Leaflet) y gestión de estados con BLoC siguiendo Clean Architecture.

---

## 🎯 Requisitos Principales

### Configuración Técnica
- **Framework**: Flutter 3.41.1
- **Gestor de Estados**: BLoC
- **Arquitectura**: Clean Architecture
- **Gestor de Versiones**: FVM
- **Mapas**: Adaptable (Google Maps / Leaflet)
- **Comunicación en Tiempo Real**: WebSocket

### Versiones de Android

| Parámetro | Versión Recomendada | Razón |
|-----------|-------------------|-------|
| **compileSdk** | 36 | Requerido por las dependencias modernas de Android (androidx.core:core >= 1.17.0) |
| **targetSdk** | 35 | Obligatorio para nuevas apps y actualizaciones en 2026 |
| **minSdk** | 24 | Soporta aproximadamente el 94% de los dispositivos activos (Android 7.0+) |
| **ndkVersion** | 27.0.12077973 | Compatible con Android 15 y todas las arquitecturas arm64 |
| **Java** | 21 | Versión más reciente, soporte a largo plazo (LTS), mejor rendimiento |

### Funcionalidades

1. **Permisos de Ubicación**
   - Solicitar al abrir la app
   - Necesario para mostrar la posición del usuario en el mapa

2. **Mapa Interactivo**
   - Mostrar ubicación actual del usuario
   - Marcar posiciones de vehículos en tiempo real
   - Adaptable entre Google Maps y Leaflet sin cambios mayores

3. **Selector de Rutas**
   - Dropdown con placeholder "Seleccionar ruta"
   - Datos provenientes de API
   - Mock de API para pruebas

4. **WebSocket en Tiempo Real**
   - Desconectado por defecto
   - Se conecta al seleccionar una ruta
   - Recibe: latitud, longitud, placa del vehículo
   - Se desconecta al volver a "Seleccionar ruta"

5. **Mensajes al Usuario**
   - "Selecciona la ruta que estás esperando" (estado inicial)
   - Se oculta al seleccionar una ruta

6. **Splash Screen**
   - Pantalla inicial con ícono de bus centrado y texto "Enrutados"
   - Se muestra durante la inicialización (2s) antes de entrar a la app
   - Sirve como transición hacia el flujo de onboarding / permisos

7. **Onboarding Guiado (Slides)**
   - Solo se muestra al ingresar por primera vez
   - Slide 1: habilitar servicios/permisos de ubicación con botón "Activar" que dispara la solicitud real de permisos
   - Slide 2: seleccionar la ruta en el buscador
   - Slide 3: visualizar vehículos en tiempo real sobre el mapa
   - Se marca como completado en `SharedPreferences` para no mostrarlo nuevamente

---

## 🏗️ Estructura de Carpetas

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── map_constants.dart
│   │   └── websocket_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── websocket_service.dart
│   │   └── api_client.dart
│   ├── permissions/
│   │   └── location_permission_service.dart
│   └── usecases/
│       └── usecase.dart
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── local_datasource.dart
│   │   ├── remote/
│   │   │   ├── routes_api_datasource.dart
│   │   │   ├── websocket_datasource.dart
│   │   │   └── mock/
│   │   │       └── mock_routes_datasource.dart
│   │   └── websocket/
│   │       └── websocket_datasource_impl.dart
│   ├── models/
│   │   ├── route_model.dart
│   │   ├── vehicle_location_model.dart
│   │   └── user_location_model.dart
│   └── repositories/
│       ├── routes_repository_impl.dart
│       └── vehicle_location_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── route_entity.dart
│   │   ├── vehicle_location_entity.dart
│   │   └── user_location_entity.dart
│   ├── repositories/
│   │   ├── routes_repository.dart
│   │   └── vehicle_location_repository.dart
│   └── usecases/
│       ├── get_routes_usecase.dart
│       ├── select_route_usecase.dart
│       └── listen_vehicle_locations_usecase.dart
│
├── presentation/
│   ├── bloc/
│   │   ├── route_selection/
│   │   │   ├── route_selection_bloc.dart
│   │   │   ├── route_selection_event.dart
│   │   │   └── route_selection_state.dart
│   │   ├── vehicle_location/
│   │   │   ├── vehicle_location_bloc.dart
│   │   │   ├── vehicle_location_event.dart
│   │   │   └── vehicle_location_state.dart
│   │   ├── user_location/
│   │   │   ├── user_location_bloc.dart
│   │   │   ├── user_location_event.dart
│   │   │   └── user_location_state.dart
│   │   └── websocket/
│   │       ├── websocket_bloc.dart
│   │       ├── websocket_event.dart
│   │       └── websocket_state.dart
 │   ├── pages/
│   │   ├── home_page.dart
│   │   └── splash_page.dart
│   ├── widgets/
│   │   ├── map/
│   │   │   ├── abstract_map_widget.dart
│   │   │   ├── google_map_widget.dart
│   │   │   └── leaflet_map_widget.dart
│   │   ├── route_selector/
│   │   │   └── route_selector_widget.dart
│   │   └── status_message/
│   │       └── status_message_widget.dart
│   └── utils/
│       └── map_provider.dart
│
├── config/
│   ├── routes.dart
│   ├── theme.dart
│   └── service_locator.dart
│
└── main.dart
```

---

## 📦 Dependencias Recomendadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Estado
  flutter_bloc: ^8.1.0
  
  # Mapas (abstraído)
  google_maps_flutter: ^2.5.0
  flutter_map: ^6.0.0
  
  # Ubicación
  geolocator: ^9.0.0
  
  # Networking
  dio: ^5.2.0
  web_socket_channel: ^2.4.0
  
  # DTO y Serialización
  json_serializable: ^6.7.0
  json_annotation: ^4.8.0
  
  # Service Locator
  get_it: ^7.6.0
  
  # Utilidades
  equatable: ^2.0.5
   dartz: ^0.10.1
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  mockito: ^5.4.0
```

---

## ⚙️ Configuración de Android

### Archivo: `android/app/build.gradle.kts`

```gradle
android {
    namespace = "com.movi.rutas"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        applicationId = "com.movi.rutas"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

### Archivo: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos de ubicación -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="Rutas App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Actividades y configuración aquí -->
    </application>
</manifest>
```

### Tabla de Versiones Android

| Parámetro | Valor | Justificación |
|-----------|-------|---------------|
| **compileSdk** | 36 | Requerido por androidx.core:core:1.17.0+ |
| **targetSdk** | 35 | Requerido para nuevas apps en 2026 |
| **minSdk** | 24 | Soporta 94% de dispositivos (Android 7.0+) |
| **ndkVersion** | 27.0.12077973 | Compatible con Android 15 y todas las arquitecturas |
| **Java** | 21 (LTS) | Mejor rendimiento y soporte a largo plazo |
| **applicationId** | com.movi.rutas | ID único de la aplicación |

---

## 🔄 Flujo de Estados (BLoC)

### 1. **RouteSelectionBloc**
```
Estados:
- RouteSelectionInitial
- RouteSelectionLoading
- RouteSelectionLoaded (lista de rutas)
- RouteSelectionError

Eventos:
- LoadRoutesEvent
- SelectRouteEvent
- DeselectRouteEvent
```

### 2. **WebSocketBloc**
```
Estados:
- WebSocketInitial
- WebSocketConnecting
- WebSocketConnected
- WebSocketDisconnected
- WebSocketError

Eventos:
- ConnectWebSocketEvent(routeId)
- DisconnectWebSocketEvent
- WebSocketMessageReceivedEvent(data)
```

### 3. **VehicleLocationBloc**
```
Estados:
- VehicleLocationInitial
- VehicleLocationUpdated (lista de ubicaciones)
- VehicleLocationError

Eventos:
- UpdateVehicleLocationEvent(data)
- ClearLocationsEvent
```

### 4. **UserLocationBloc**
```
Estados:
- UserLocationInitial
- UserLocationLoading
- UserLocationUpdated (lat, lng)
- UserLocationError
- UserLocationPermissionDenied
- UserLocationServiceDisabled

Eventos:
- RequestPermissionsEvent
- UpdateUserLocationEvent(lat, lng)
- StartListeningLocationEvent
- EnableLocationServicesEvent
```

---

## 🗺️ Patrón de Abstracción de Mapas

### Abstract Map Widget
```dart
abstract class AbstractMapWidget extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final List<VehicleLocationEntity> vehicleLocations;
  
  const AbstractMapWidget({
    required this.userLatitude,
    required this.userLongitude,
    required this.vehicleLocations,
  });
}
```

### Implementaciones Concretas
- **GoogleMapWidget**: Usa `google_maps_flutter`
- **LeafletMapWidget**: Usa `flutter_map`

### Proveedor Configurable
- Factory pattern en `MapProvider` para seleccionar implementación
- Configurable en tiempo de compilación o runtime

---

## 🌐 Integración WebSocket

### WebSocketService (Core)
```
Responsabilidades:
- Conectar a WebSocket
- Desconectar
- Enviar/recibir mensajes
- Manejo de reconexión automática
- Manejo de errores
```

### WebSocketDataSource
```
- Convierte mensajes raw a models
- Emite streams de datos
- Maneja errores específicos del websocket
```

### Flujo de Conexión
1. Usuario selecciona ruta
2. RouteSelectionBloc emite evento SelectRouteEvent
3. WebSocketBloc recibe evento ConnectWebSocketEvent
4. Establece conexión a ws://api/routes/{routeId}
5. Recibe JSON: `{lat, lng, placa}`
6. VehicleLocationBloc actualiza estado
7. UI re-renderiza con nuevas ubicaciones

---

## 📍 Gestión de Ubicación del Usuario

### Flujo de Permisos
1. App inicia
2. UserLocationBloc emite RequestPermissionsEvent
3. LocationPermissionService solicita permisos
4. Si se otorga: obtiene ubicación actual
5. UserLocationBloc emite UserLocationUpdated
6. Mapa se centra en ubicación del usuario

> En el primer arranque, la solicitud de permisos se realiza desde el slide inicial del onboarding al pulsar "Activar ubicación".

### Manejo de Servicios Desactivados
- Si el GPS está apagado, se emite `UserLocationServiceDisabled`
- La UI muestra un mensaje con botón "Activar ubicación" que intenta habilitarla desde la app o abre la configuración
- Tras activarla, se vuelve a disparar `RequestPermissionsEvent`

### Actualización Continua
- Listener activo en background
- Actualiza posición cada X segundos
- Emite UserLocationUpdated solo si hay cambios significativos

---

## 🎨 Interfaz de Usuario

### Estructura de Home Page
```
┌─────────────────────────────────┐
│  [Select] "Seleccionar ruta"    │
├─────────────────────────────────┤
│                                 │
│                                 │
│          MAPA                   │
│    (usuario + vehículos)        │
│                                 │
│   "Selecciona la ruta que      │
│    estás esperando"            │
│                                 │
└─────────────────────────────────┘
```

### Elementos Interactivos
- **Select Dropdown**: Para seleccionar ruta
- **Mapa**: Muestra ubicación del usuario y vehículos
- **Mensaje de Estado**: Mostrar/ocultar según contexto

---

## 🧪 Datos Mock

### Mock Routes Data
```json
[
  {
    "id": "route_001",
    "name": "Ruta Centro-Norte",
    "websocketUrl": "ws://api.example.com/routes/route_001"
  },
  {
    "id": "route_002",
    "name": "Ruta Sureste",
    "websocketUrl": "ws://api.example.com/routes/route_002"
  }
]
```

### Mock Vehicle Location Data (WebSocket)
```json
{
  "latitude": 4.7110,
  "longitude": -74.0721,
  "placa": "ABC-1234",
  "timestamp": "2026-02-17T10:30:00Z"
}
```

---

## 🚀 Plan de Desarrollo

### Fase 1: Configuración Inicial (Día 1)
- [ ] Crear proyecto con FVM versión 3.41.1
- [ ] Instalar y configurar dependencias
- [ ] Configurar estructura de carpetas
- [ ] Configurar Service Locator (GetIt)

### Fase 2: Core y Data Layer (Día 2-3)
- [ ] Implementar LocationPermissionService
- [ ] Crear WebSocketService
- [ ] Crear API Client para rutas
- [ ] Implementar Mock de rutas
- [ ] Crear modelos (Models)
- [ ] Crear DataSources

### Fase 3: Domain Layer (Día 3)
- [ ] Crear Entities
- [ ] Crear Repositories (interfaces)
- [ ] Crear UseCases

### Fase 4: Presentation - BLoCs (Día 4)
- [ ] Implementar RouteSelectionBloc
- [ ] Implementar WebSocketBloc
- [ ] Implementar VehicleLocationBloc
- [ ] Implementar UserLocationBloc

### Fase 5: Presentation - UI (Día 5)
- [ ] Crear AbstractMapWidget
- [ ] Implementar GoogleMapWidget
- [ ] Implementar LeafletMapWidget
- [ ] Crear RouteSelector widget
- [ ] Crear HomePage
- [ ] Conectar BLoCs con UI

### Fase 6: Integración y Testing (Día 6-7)
- [ ] Pruebas de flujo completo
- [ ] Testing de BLoCs
- [ ] Testing de repositorios
- [ ] Manejo de errores y edge cases
- [ ] Optimización

### Fase 7: Refinamiento (Día 8)
- [ ] Polish UI/UX
- [ ] Documentación
- [ ] README con instrucciones

---

## ⚙️ Configuración Inicial con FVM

```bash
# Instalar Flutter 3.41.1 con FVM
fvm install 3.41.1
fvm use 3.41.1

# Crear proyecto
fvm flutter create --org com.example rutas_app

# Entrar al directorio
cd rutas_app

# Instalar dependencias
fvm flutter pub get
```

---

## 🔐 Consideraciones de Seguridad

1. **WebSocket**
   - Validar URLs de WebSocket
   - Usar WSS (WebSocket Secure) en producción
   - Timeout de conexión configurado

2. **Ubicación**
   - Solicitar permisos de manera clara
   - Mostrar indicador cuando se está obteniendo ubicación
   - Manejar rechazo de permisos

3. **Datos**
   - Validar datos recibidos del WebSocket
   - Sanitizar entrada de usuario

---

## 📝 Notas Técnicas

### Por qué Clean Architecture
- Separación de responsabilidades clara
- Fácil de testear
- Desacoplamiento entre capas
- Facilita mantenimiento futuro

### Por qué BLoC
- Gestor de estados robusto y escalable
- Separación entre lógica de negocio y UI
- Fácil de testear
- Comunidad grande y activa

### Por qué abstracción de mapas
- Permite cambiar de proveedor sin afectar lógica
- Evita vendor lock-in
- Facilita testing con mocks

### Por qué WebSocket
- Comunicación bidireccional en tiempo real
- Menor latencia que polling
- Eficiente en uso de recursos
- Ideal para ubicación en tiempo real

---

## 📚 Referencias de Documentación

- [Flutter Official Docs](https://flutter.dev/docs)
- [Bloc Library](https://bloclibrary.dev/)
- [Clean Architecture Flutter](https://medium.com/flutter-community/clean-architecture-and-tdd-in-flutter-dbda8c88852e)
- [FVM Documentation](https://fvm.app/)
- [WebSocket Channel](https://pub.dev/packages/web_socket_channel)
- [Geolocator](https://pub.dev/packages/geolocator)

---

## 🤝 Próximos Pasos

1. Revisar este documento con el equipo
2. Ajustar cronograma según disponibilidad
3. Configurar ambiente de desarrollo
4. Comenzar con Fase 1
5. Realizar daily standups
6. Documentar cambios arquitectónicos que surjan

---

**Última actualización**: 17 de febrero de 2026 (splash + onboarding con slides + servicios de ubicación)  
**Estado**: Documento de planificación inicial
