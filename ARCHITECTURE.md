# Architecture

## Flow

```
Repository → Provider → ActionUtils → Page/UI
```

Data moves one way. No skipping layers.

---

## Layers

### Repository
- Data access: API, DB, local storage
- Core business logic
- Data transformation and mapping
- No Flutter widgets, no UI imports
- No state management

### Provider
- Single source of truth for feature state
- Calls Repository only
- Exposes prepared, UI-ready data
- Owns loading, error, and empty states
- No navigation, no dialogs, no snackbars

### ActionUtils
- Entry point for all user-initiated actions
- Calls Provider methods
- Handles side effects: navigation, dialogs, snackbars, toasts
- Coordinates multi-step flows
- Keeps UI handlers thin and testable

### Page / UI
- Render only
- Reads state from Provider (via watch/select)
- Calls ActionUtils for every user action
- No business logic
- No Repository access
- No direct state mutation

---

## Feature Structure

```
feature/
├── repository/
│   └── feature_repository.dart
├── provider/
│   └── feature_provider.dart
├── action_utils/
│   └── feature_action_utils.dart
└── ui/
    ├── pages/
    │   └── feature_page.dart
    └── widgets/
        └── feature_card.dart
```

---

## New Feature Checklist

1. **Repository** — define data access + logic
2. **Provider** — define state + call repository
3. **ActionUtils** — wire user actions + side effects
4. **Page** — build UI, read provider, call action utils
5. **Widgets** — extract reusable UI into separate widget classes

Do not skip steps. Do not merge layers.

---

## Widget Rules

- `StatelessWidget` or `StatefulWidget` only
- No `_buildX()` helper functions — extract into widget classes instead
- Prefer `const` constructors everywhere possible
- Reusable UI → separate file in `widgets/`
- No logic inside `build()` beyond conditional rendering

---

## Provider Rules

- One provider per feature
- Keep providers focused — split if growing beyond one responsibility
- Expose only what UI needs
- Never expose Repository directly to UI through provider

---

## Repository Rules

- One repository per feature or data domain
- Returns clean models, not raw responses
- Handles all error mapping
- No awareness of UI state or navigation

---

## ActionUtils Rules

- Stateless — no local state, no fields beyond injected deps
- Takes Provider + optional services (router, dialog service) via constructor
- One method per user action
- Never called from Repository or Provider

---

## Strict Rules

| Rule                          | Enforced |
|-------------------------------|----------|
| No Repository calls from UI   | ✅        |
| No business logic in UI       | ✅        |
| No navigation from Provider   | ✅        |
| No state mutation from Page   | ✅        |
| No `_buildX` helper functions | ✅        |
| One-way data flow             | ✅        |
| Layers never skip             | ✅        |

---

## Violations to Flag on `arch review`

- UI calling Repository directly
- Provider triggering navigation or showing dialogs
- Business logic inside `build()` or widget classes
- `_buildX` helper functions anywhere
- Providers with mixed responsibilities (data + navigation + formatting)
- ActionUtils holding state
- Repository importing Flutter/UI packages

---

## Avoid

- Business logic in UI
- Direct Repository access from UI or ActionUtils
- Oversized Providers handling multiple unrelated concerns
- Mixed responsibilities across layers
- Helper functions disguised as widget builders (`_buildHeader`, `_buildRow`, etc.)
- Skipping ActionUtils and calling Provider from UI directly