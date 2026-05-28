# AI ARCHITECTURE & CODE GENERATION RULES

## 🔴 CRITICAL MANDATORY INSTRUCTION FOR ALL AI AGENTS
You must STRICTLY adhere to the Feature-First Clean Architecture pattern outlined below for any code generation, file creation, or system modifications within this Flutter project. Any deviation from this structural layout, file naming conventions, or separation of concerns is considered a system failure.

---

## 1. ABSOLUTE DIRECTORY TREE STRUCTURE
You are forbidden from creating any additional top-level directories inside the `lib/` folder other than `core/` and `features/`. Every single file must map perfectly to this exact tree blueprint:

```text
lib/
├── main.dart                       # App entry point (Initializes ProviderScope, runs app)
├── app.dart                        # Core configuration (MaterialApp, Router, Global Themes)
│
├── core/                           # GLOBAL LAYER (Shared across all features)
│   ├── constants/                  # Immutable values (AppSizes, AppStrings, ApiEndpoints)
│   ├── errors/                     # Exception and Failure handling classes (NetworkFailure, CacheFailure)
│   ├── network/                    # HttpClient configuration (Dio instance, Interceptors, Connection checking)
│   ├── services/                   # App-wide independent systems (LocalStorageService, SecureStorage)
│   ├── theme/                      # UI design system foundations (AppTheme, AppColors, TextStyles)
│   ├── utils/                      # Pure helper functions (Extensions, Formatters, InputValidators)
│   └── widgets/                    # Reusable atomic UI components (CustomButton, LoadingIndicator)
│
└── features/                       # FEATURE LAYER (Modular business domains)
    └── [feature_name]/             # Concrete business feature (e.g., flashcard, dictionary, ocr, quiz)
        ├── data/                   # 1. DATA LAYER (Infrastructure & external communications)
        │   ├── datasources/        # Low-level data retrieval (local/remote data sources)
        │   ├── models/             # Data Transfer Objects (DTOs) with JSON serialization mapping
        │   └── repositories/       # Implementation of domain interfaces (handles mapping Model -> Entity)
        │
        ├── domain/                 # 2. CORE BUSINESS LAYER (Pure Dart domain logic)
        │   ├── entities/           # Lightweight, pure business models used directly by the UI
        │   ├── repositories/       # Contract definitions / Abstract classes for data access
        │   └── usecases/           # Single-responsibility application/user scenarios
        │
        └── presentation/           # 3. PRESENTATION LAYER (UI rendering & state composition)
            ├── controllers/        # Riverpod Notifiers managing UI state and logic
            ├── screens/            # Full monolithic viewports/view containers (Scaffolds)
            └── widgets/            # Feature-scoped localized micro UI components