# Notes App - BLoC Architecture

A modern Flutter notes application implementing the **BLoC (Business Logic Component)** pattern with dual storage support.

## 🎯 Features

- **BLoC Architecture** - Clean, maintainable code structure
- **Dual Storage** - Switch between Local Storage and API
- **Full CRUD** - Create, Read, Update, Delete notes
- **Bulk Operations** - Delete multiple notes at once
- **Offline Support** - Works without internet
- **Modern UI** - Material 3 design

## 🏗️ Architecture

This app follows **BLoC Pattern** best practices:

- **Bloc** - Business logic and state management
- **Repository** - Data abstraction layer
- **Services** - Local storage & HTTP API
- **Models** - Type-safe data models
- **Screens** - Presentation layer

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed documentation.

## 🚀 Quick Start

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build for Android
flutter build apk
```

## 📦 Storage Options

### Local Storage (Default)
- Data stored on device using SharedPreferences
- No network required
- Perfect for offline use

### API Storage
- Connects to REST API at `http://localhost:8080`
- Syncs data across devices
- Requires backend server

**Switch storage:** Tap the storage icon in the app bar (📦/☁️)

## 🔧 Backend API (Optional)

For API storage, run a backend with these endpoints:
- `GET /notes` - Fetch all notes
- `POST /notes` - Create note
- `PATCH /notes/:id` - Update note
- `DELETE /notes/:id` - Delete note

## 📱 How to Use

1. **Add Note** - Tap the ➕ button
2. **View Note** - Tap any note in the list
3. **Edit Note** - Open note → tap ✏️
4. **Delete Note** - Open note → tap 🗑️
5. **Bulk Delete** - Long-press to select multiple notes

## 🛠️ Tech Stack

- Flutter SDK
- flutter_bloc - State management
- equatable - Value equality
- shared_preferences - Local storage
- http - API calls

## 📄 License

MIT License

---

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md)

