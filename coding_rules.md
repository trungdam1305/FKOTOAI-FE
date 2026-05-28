# AI FLUTTER CODING STANDARDS & GENERATION RULES

## 🔴 CRITICAL MANDATORY INSTRUCTION FOR ALL AI AGENTS
You must STRICTLY adhere to the coding standards, naming conventions, and layer separation practices defined in this document for any code generation, file modification, or refactoring tasks within this Flutter project. Any codebase generation violating these explicit directives will be systematically rejected.

---

## 1. STATE MANAGEMENT CONFIGURATION & STACK

### 1.1 Mandatory Riverpod with Code Generation
* All global states, reactive states, and dependence injections must be managed exclusively via **Riverpod using the official Code Generation syntax** (`riverpod_generator`).
* **Strict Ban:** Under no circumstances should legacy, manual Provider declarations be generated. Do NOT write `StateNotifierProvider`, `ChangeNotifierProvider`, `FutureProvider`, or `StreamProvider` explicitly.
* **Framework Restrictions:** Do NOT import or utilize BLoC, GetX, MobX, or the traditional Provider package in this codebase.

### 1.2 State Composition & Synchronization
* **Asynchronous Operations:** Every single asynchronous workflow (fetching REST APIs, Local DB manipulation, delay-based sequences) must be managed using an `AsyncNotifier` (annotated with `@riverpod` or `@Riverpod(keepAlive: true)`).
* **Synchronous Operations:** Localized, transient, or synchronous reactive structures must use standard `Notifier` classes.
* UI components must safely destruct and read async payloads using native pattern matching on `AsyncValue` (`data`, `error`, `loading`).

---

## 2. STRICT NAMING CONVENTIONS & ARCHITECTURAL SUFFIXES

### 2.1 File & Class Syntax
* **Files & Directories:** Every single file and folder must be written strictly in `snake_case`. (e.g., `flashcard_detail_controller.dart`).
* **Classes & Structs:** Every class, mixin, or extension identifier must use `PascalCase`. (e.g., `FlashcardDetailController`).

### 2.2 Layer-Specific Suffix Contracts
Every structural file generated must conclude with its explicitly designated layer suffix:

#### 📂 Data Layer
* **Data Transfer Objects:** Class names must carry the `Model` suffix (e.g., `FlashcardModel`). Every model class must explicitly `extends` or `implements` its corresponding pure core Domain Entity.
* **Repository Implementation:** Concrete structural classes that fulfill data fetching must terminate with the `RepositoryImpl` suffix (e.g., `FlashcardRepositoryImpl`).

#### 📂 Domain Layer
* **Core Business Entities:** Business model representations must hold the pure entity identity name **without any architectural suffix** (e.g., class `Flashcard`).
* **Repository Interfaces:** Abstract interface contracts must begin with a leading capital `I` prefix (e.g., abstract class `IFlashcardRepository`).
* **Application Use Cases:** Files must be explicitly labeled based on their exact micro-service or domain verb action in `snake_case` (e.g., `get_due_flashcards.dart`).

#### 📂 Presentation Layer
* **State Management Units:** State logic drivers must terminate with the `Controller` suffix (e.g., `FlashcardController`). The corresponding immutable layout payload definitions must carry the `State` suffix (e.g., `FlashcardState`).
* **Viewport Containers:** Monolithic view layouts and full screen scaffolds must carry the `Screen` suffix (e.g., `FlashcardStudyScreen`).
* **Modular Interface Pieces:** Localized layout fragments or embedded layout units must end with the `Widget` suffix (e.g., `FlashcardCardWidget`).

---

## 3. ABSOLUTE SEPARATION OF CONCERNS (SoC)

### 3.1 Strict Layer Isolation Flow
```text
[ Presentation Layer (UI) ] ──(ONLY TALKS TO)──> [ Riverpod Controllers ]
                                                        │
                                                        ▼
[ Data Layer (External) ]   <──(IMPLEMENTS)───── [ Domain Layer (Pure Dart) ]