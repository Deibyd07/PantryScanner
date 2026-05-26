# PantryScanner

![Flutter](https://img.shields.io/badge/Flutter-3.41%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-40A2D8?style=for-the-badge)
![Drift](https://img.shields.io/badge/Drift-Offline%20Database-5A2CA0?style=for-the-badge)
![SQLite](https://img.shields.io/badge/SQLite-Local%20Storage-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![GoRouter](https://img.shields.io/badge/GoRouter-Navigation-00ADD8?style=for-the-badge)
![Dio](https://img.shields.io/badge/Dio-HTTP%20Client-1F6FEB?style=for-the-badge)
![License](https://img.shields.io/badge/License-Private-orange?style=for-the-badge)

App movil en Flutter para gestionar inventario de despensa usando escaneo de codigo de barras, persistencia offline y alertas inteligentes de vencimiento/stock.

## Tabla de contenido

- [Vision del producto](#vision-del-producto)
- [Estado del proyecto](#estado-del-proyecto)
- [Stack tecnico](#stack-tecnico)
- [Arquitectura](#arquitectura)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Instalacion y ejecucion](#instalacion-y-ejecucion)
- [Scripts utiles](#scripts-utiles)
- [Roadmap de desarrollo](#roadmap-de-desarrollo)
- [Contribucion](#contribucion)

## Vision del producto

PantryScanner resuelve un problema cotidiano: no saber que hay en casa, comprar duplicado o descubrir productos vencidos demasiado tarde.

Objetivos principales:

- Escanear productos rapido desde camara.
- Guardar inventario local como fuente de verdad.
- Alertar con tiempo sobre vencimientos y stock bajo.
- Ofrecer experiencia simple, visual y confiable.

## Estado del proyecto

Base tecnica y visual lista para empezar HU del Sprint 1:

- UI de inventario estilo editorial (modulo redisenado y refactorizado en componentes reutilizables).
- Flujo base de formulario para alta de producto.
- Persistencia local con Drift (tabla `products`, repositorio, mappers y casos de uso).
- Providers con Riverpod para exponer stream reactivo de inventario.
- Estructura Flutter completa multiplataforma: Android, iOS, Web, Windows, macOS y Linux.
- Analisis y pruebas base en verde.

## Stack tecnico

- Flutter + Dart
- Estado: Riverpod
- Ruteo: GoRouter
- Persistencia: Drift + SQLite
- Networking: Dio
- Escaneo: mobile_scanner / ML Kit (en progreso HU)
- Notificaciones: flutter_local_notifications + WorkManager (en progreso HU)

## Arquitectura

El proyecto sigue enfoque Clean Architecture por feature:

- `presentation`: pantallas, widgets, providers
- `domain`: entidades, contratos, casos de uso
- `data`: repositorios concretos, mappers, acceso a DB/API

Patrones aplicados:

- Source of truth local (offline-first)
- Inversion de dependencias (domain no depende de data)
- Flujo reactivo con streams hacia UI

## Estructura del repositorio

```text
PantryScanner/
	android/
	ios/
	web/
	windows/
	macos/
	linux/
	lib/
		app/
		core/
			constants/
			database/
			theme/
		features/
			inventory/
			product_form/
			scanner/
	docs/
	test/
```

## Instalacion y ejecucion

### 1) Requisitos

- Flutter SDK estable (3.41.x o superior recomendado)
- Android SDK configurado (si vas a correr en Android)
- Xcode (si vas a correr en iOS/macOS)

Valida entorno:

```bash
flutter doctor -v
```

### 2) Instalar dependencias

```bash
flutter pub get
```

### 3) Generar codigo Drift

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4) Ejecutar app

```bash
flutter run
```

Ejemplo para web:

```bash
flutter run -d chrome
```

## Scripts utiles

```bash
# Analisis estatico
flutter analyze

# Pruebas
flutter test

# Regenerar codigo Drift al cambiar tablas
dart run build_runner build --delete-conflicting-outputs
```

## Roadmap de desarrollo

Prioridad inmediata (HU Sprint 1):

1. HU-02: permisos de camara + estado denegado + fallback manual
2. HU-01: escaneo EAN-13 / UPC-A con feedback visual/haptico
3. HU-04: alta/edicion robusta de producto (validaciones + persistencia completa)
4. HU-06: listado reactivo completo con estados `loading`, `empty`, `error`

Siguientes bloques:

- Integracion APIs (OpenFoodFacts + fallback UPC)
- Notificaciones inteligentes por vencimiento/stock
- Filtros, busqueda y ordenamiento avanzados

## Contribucion

Flujo sugerido:

1. Crear rama por HU (`feature/hu-xx-nombre-corto`)
2. Commits pequenos y claros
3. Ejecutar `flutter analyze` y `flutter test` antes de PR
4. Documentar cambios tecnicos relevantes en `docs/`

Si quieres colaborar, abre un Issue con contexto funcional/tecnico y propuesta de solucion.
