# Sprint 1 Bootstrap Plan

Goal: leave PantryScanner in a runnable baseline with scanner-entry, product form, and inventory list foundation.

## Implemented in this starter

- App entry point with Riverpod provider scope
- GoRouter routes for inventory, scanner, and product form
- Initial app theme and constants
- Domain entity for inventory item with simple status rules
- Inventory module UI refactored into reusable components
- Drift v1 database with products table and generated code
- Inventory repository, mappers, and use cases
- Riverpod providers wired for database and inventory stream
- Product form save flow persisted to local database

## Next coding tasks (high priority)

1. Scanner flow
- Add camera permission request and denied state screen
- Integrate barcode scanner stream and parse EAN-13 / UPC-A
- Add scan success haptic and visual feedback

2. External product lookup
- Add Dio datasource for OpenFoodFacts
- Add fallback datasource for UPC Database
- Cache fetched product metadata locally

3. Inventory UI state
- Tune empty state visuals for design consistency
- Add retry action on error state
- Add category filtering over live stream data

4. Edit / delete flow
- Add update and delete use cases with repository methods
- Wire product detail/edit actions from inventory card
- Add undo snackbar for delete action
