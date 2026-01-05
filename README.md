# Height Map

A modern Flutter application that displays altitude information from multiple sensors and allows exploring elevations on an interactive world map.

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)

## Features

### 🏔️ Multi-Sensor Altitude Display
- **GPS Altitude**: Satellite-based elevation reading
- **Barometer**: Atmospheric pressure-based altitude (where hardware is available)
- **Elevation API**: Terrain elevation data from Open Topo Data

### 🗺️ Interactive World Map
- OpenStreetMap-based tile rendering
- Real-time location tracking
- Tap anywhere to see elevation at that point
- Elevation comparison showing height difference from your current position

### 📊 Detailed Sensor Information
- Individual sensor readings with accuracy indicators
- Reliability status for each data source
- Conversion between meters and feet
- Last update timestamps

## Screenshots

| Map View | Height Details | Elevation Comparison |
|----------|---------------|---------------------|
| Main map with location marker | All sensor readings | Selected point info |

## Architecture

This app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and configuration
│   ├── constants/           # App-wide constants
│   ├── di/                  # Dependency injection (GetIt)
│   ├── extensions/          # Dart extensions
│   ├── router/              # Navigation (go_router)
│   ├── theme/               # App theming
│   └── utils/               # Utilities (Result, Failure)
├── data/                    # Data layer
│   ├── datasources/         # Data sources (sensors, API)
│   ├── models/              # Data models
│   └── repositories/        # Repository implementations
└── presentation/            # Presentation layer
    ├── blocs/               # BLoC state management
    │   ├── height/          # Height/altitude BLoC
    │   ├── location/        # Location tracking BLoC
    │   └── map/             # Map interactions BLoC
    ├── pages/               # App screens
    └── widgets/             # Reusable widgets
```

## Dependencies

### State Management & Architecture
- `flutter_bloc` - State management using BLoC pattern
- `equatable` - Value equality for states and events
- `get_it` - Dependency injection
- `dartz` - Functional programming utilities

### Navigation
- `go_router` - Declarative routing

### Maps & Location
- `flutter_map` - OpenStreetMap-based map widget
- `latlong2` - Geographical coordinates
- `geolocator` - GPS location services

### Sensors
- `sensors_plus` - Access to device sensors (barometer)

### Networking
- `dio` - HTTP client for elevation API

### UI
- `flutter_animate` - Smooth animations
- `google_fonts` - Typography

## Getting Started

### Prerequisites

- Flutter SDK 3.35.4 or later
- Dart SDK 3.9.2 or later
- Android Studio / VS Code with Flutter extensions
- Physical device recommended (for sensor access)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/height_map.git
   cd height_map
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Configuration

### Elevation API

The app uses [Open Topo Data](https://www.opentopodata.org/) for elevation queries. The free API provides:
- SRTM 90m resolution worldwide coverage
- Up to 100 points per request
- Rate limiting applies for public API

For production use, consider hosting your own Open Topo Data instance.

### Permissions

#### Android
- `ACCESS_FINE_LOCATION` - GPS access
- `ACCESS_COARSE_LOCATION` - Network-based location
- `INTERNET` - Elevation API access

#### iOS
- `NSLocationWhenInUseUsageDescription` - Location access while using app
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Background location (optional)

## Usage

### Main Screen
1. Grant location permission when prompted
2. Your current location appears on the map with a blue marker
3. Current altitude is shown in the top-right corner
4. Tap the altitude indicator to see detailed sensor readings

### Exploring Elevations
1. Tap anywhere on the map to place a marker
2. The elevation at that point will be fetched
3. A card shows the elevation and difference from your position
4. Tap the X to clear the selection

### Height Details Page
- View all available sensor readings
- See accuracy and reliability information
- Understand how each sensor works

## API Reference

### BLoCs

#### HeightBloc
Manages altitude data from all sensors.

Events:
- `StartHeightMonitoring` - Begin sensor monitoring
- `StopHeightMonitoring` - Stop sensor monitoring
- `FetchApiElevation` - Fetch elevation for a position

States:
- `HeightInitial` - Initial state
- `HeightLoading` - Loading sensor data
- `HeightLoaded` - Data available with all measurements
- `HeightError` - Error state

#### LocationBloc
Manages GPS location tracking.

Events:
- `StartLocationTracking` - Begin location updates
- `StopLocationTracking` - Stop location updates
- `GetCurrentLocation` - Get location once

States:
- `LocationInitial` - Initial state
- `LocationLoading` - Fetching location
- `LocationLoaded` - Location available
- `LocationPermissionDenied` - Permission not granted
- `LocationServiceDisabled` - GPS disabled

#### MapBloc
Manages map interactions and elevation comparisons.

Events:
- `MapTapped` - User tapped on map
- `ClearSelectedPoint` - Clear selection
- `UpdateUserPosition` - Update user location on map

States:
- `MapInitial` - Initial state
- `MapReady` - Map ready with optional selected point

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Open Topo Data](https://www.opentopodata.org/) for elevation data
- [OpenStreetMap](https://www.openstreetmap.org/) for map tiles
- Flutter team for the amazing framework
