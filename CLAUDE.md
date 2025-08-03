# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter web application for the Digimon Card Game, providing a comprehensive deck builder and collection manager. The app is primarily designed for web deployment and includes features for deck building, card collection tracking, game simulation, and user authentication.

## Development Commands

### Core Flutter Commands
- `flutter run -d chrome --web-port=50000` - Run the web app on port 50000
- `flutter build web` - Build for web production
- `flutter test` - Run all tests
- `flutter analyze` - Static code analysis using flutter_lints
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Update dependencies

### Code Generation
- `dart run build_runner build` - Generate auto_route and JSON serialization code
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files

### Mobile Web Testing
- Use `run_mobile_web_test.bat` for Android emulator testing
- Access via `http://10.0.2.2:50000` in emulator Chrome browser

## Architecture

### State Management
- **Provider pattern** with multiple specialized providers:
  - `UserProvider` - Authentication and user state
  - `DeckProvider` - Deck building and management
  - `CollectProvider` - Card collection tracking (proxy provider dependent on UserProvider)
  - `LimitProvider` - Format limitations and restrictions
  - `HeaderToggleProvider`, `DeckSortProvider`, `TextSimplifyProvider`, etc.

### Routing
- **AutoRoute** for declarative routing with nested routes
- Route guards for deck-specific pages (`DeckGuard`)
- Main shell page with tab-based navigation

### Data Layer
- **Dio** HTTP client with centralized auth error handling
- Local JSON assets for card data (`assets/data/`)
- API services in `/api/` directory
- Model classes with JSON serialization

### UI Architecture
- **Responsive design** with defined breakpoints (mobile/tablet/desktop/4K)
- Material 3 design system with custom theme
- Service layer for UI concerns (dialog, orientation, color, size)
- Widget composition with specialized directories

## Key Directories

### `/lib/`
- `/api/` - HTTP API service classes
- `/model/` - Data models and DTOs with JSON serialization
- `/page/` - Top-level page widgets corresponding to routes
- `/provider/` - State management providers
- `/service/` - Business logic and utility services
- `/widget/` - Reusable UI components organized by feature
- `/theme/` - Design system and theming
- `/util/` - Utilities (Dio client configuration)

### `/assets/`
- `/data/` - Static JSON data files (cards, keywords, notes)
- `/fonts/` - Custom fonts (JalnanGothic, MPLUSC)
- `/images/` - App icons and images

## Technical Details

### Authentication
- OAuth-based login system with window message listeners
- User session persistence and auth error handling
- Kakao login integration

### Data Management
- Card data initialization on app startup (`CardDataService`)
- Local storage for user settings and collection data
- Real-time updates between providers

### Code Generation
- Auto-generated routes (`router.gr.dart`)
- JSON serialization for model classes
- Build runner integration for development workflow

## Development Notes

### Testing
- Widget tests in `/test/` directory
- Basic smoke test exists but may need updating for actual app functionality
- Use `flutter test` to run tests

### Code Style
- Flutter lints enabled in `analysis_options.yaml`
- Korean comments and UI text throughout codebase
- Consistent Material 3 theming with custom color scheme

### Dependencies
- Core: Flutter SDK, Provider, AutoRoute, Dio
- UI: ResponsiveFramework, ColorPicker, QR code generation
- Platform: Web-specific packages for image handling and storage