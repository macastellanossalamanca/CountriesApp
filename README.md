# 🌍 CountriesApp

iOS application built with Swift and SwiftUI, showcasing a modular and testable architecture with modern async networking, data persistence, and UI state management. This project demonstrates a scalable, MVVM + Coordinator architecture with dependency injection, logging for different purposes, and Core Data integration.

---

## 🔍 App Images
| 1  | 2 | 3 | 4 |
|---|---|---|---|
| <img width="448" height="963" alt="Captura de pantalla 2025-07-22 a la(s) 2 54 14 p m" src="https://github.com/user-attachments/assets/d4767037-a37c-434d-9a8d-2ffde145b787" /> | <img width="445" height="953" alt="Captura de pantalla 2025-07-22 a la(s) 2 55 54 p m" src="https://github.com/user-attachments/assets/05ef0acf-7824-41c5-88b1-dd6ac6f3ac72" /> | <img width="446" height="959" alt="Captura de pantalla 2025-07-22 a la(s) 2 56 24 p m" src="https://github.com/user-attachments/assets/b7cfa35a-8b46-48e9-8e2e-ab9bd39a247e" /> | <img width="446" height="965" alt="Captura de pantalla 2025-07-22 a la(s) 2 57 16 p m" src="https://github.com/user-attachments/assets/491f6153-b195-4c7d-a068-82c1051fe942" /> |


## 🚀 Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Architecture:** MVVM + Coordinator + DI (Dependency Injection)
- **Local Storage:** Core Data
- **Networking:** `URLSession` via abstracted service layer
- **Logging:** Custom Logger using `os.Logger` to be aware of every stage of the app
- **Testing:** XCTest with unit and integration tests
- **Async Handling:** Native `async/await`
- **Favorites:** Locally persisted using Core Data

---

## 🧠 Architecture Overview

### MVVM

- Clear separation between UI (`View`), business logic (`ViewModel`), and models.
- ViewModels are fully testable and decoupled from Views.
- Reactive UI updates using `@Published` and `@MainActor`.

### Coordinator Pattern

- Coordinators manage all navigation flows.
- Decouples navigation from Views and ViewModels.

### Services & Abstractions

- Networking layer abstracted via `APIServiceProtocol`.
- Injected via `DIManager`, enabling flexible mocking and testing.
- Supports error decoding and retry strategies.

### Custom Logger

- `AppLogger` is a centralized logger built with `os.Logger`.
- Categorized by domain: networking, UI, lifecycle, etc.

---

## ✅ Testability

- Protocol-oriented design for all core services.
- Dependencies injected via constructor (ideal for unit testing).
- ViewModel tests cover:
  - Loading states (`idle`, `loading`, `success`, `error`)
  - Fetching and filtering countries
  - Favorite management

---

## 💾 Persistence: Core Data

- `CoreDataManager` manages all persistence logic.
- Safely handles save operations and context updates.
- Entities modeled cleanly for long-term scalability.

---

## ⚙️ Performance Optimizations

- Use of `final` in all applicable classes/structs to avoid dynamic dispatch.
- Safe use of `[weak self]` in closures to avoid retain cycles.
- UI updated exclusively on main thread via `@MainActor`.
- Lightweight views and deferred image loading.
- Async operations managed efficiently with structured concurrency.

---

## 🧵 Asynchronous Architecture

- All networking and data flows handled using `async/await`.
- ViewModels update state reactively and predictably.
- No nested callbacks, ensuring code clarity and flow.


