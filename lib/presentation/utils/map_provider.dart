enum MapProvider { googleMaps, leaflet }

class MapProviderConfig {
  static MapProvider currentProvider = MapProvider.leaflet;

  static void setProvider(MapProvider provider) {
    currentProvider = provider;
  }

  static bool isGoogleMaps() => currentProvider == MapProvider.googleMaps;
  static bool isLeaflet() => currentProvider == MapProvider.leaflet;
}
