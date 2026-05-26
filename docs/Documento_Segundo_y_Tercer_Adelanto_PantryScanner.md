# PantryScanner — Segundo y Tercer Adelanto de Proyecto

> **Equipo de Desarrollo**  
> **Fecha de entrega:** 16 de mayo de 2026  
> **Asignatura / Campus:** _[Desarrollo de aplicaciones moviles]_

---

## Tabla de Contenido

1. [Descripción del Avance](#1-descripción-del-avance)
2. [Estado del Repositorio GitHub](#2-estado-del-repositorio-github)
3. [Gestión de Historias de Usuario](#3-gestión-de-historias-de-usuario)
4. [Historias de Usuario Implementadas (Sprints 2 y 3)](#4-historias-de-usuario-implementadas-sprints-2-y-3)
5. [Sub-actividades Técnicas](#5-sub-actividades-técnicas)
6. [Evolución de la Interfaz (Screenshots y Flujos)](#6-evolución-de-la-interfaz-screenshots-y-flujos)
7. [Resumen del Segundo y Tercer Adelanto](#7-resumen-del-segundo-y-tercer-adelanto)

---

## 1. Descripción del Avance

Este documento detalla el progreso de los **Sprints 2 y 3** del proyecto **PantryScanner**. Durante estos ciclos, la app evolucionó desde un MVP con persistencia local hacia un producto **Cloud-Ready**, incorporando autenticación, notificaciones y una interfaz premium.

### Objetivos del avance
- Consolidar la **gestión de inventario** (búsqueda, eliminación, rendimiento).
- Implementar **notificaciones reales** por vencimiento de productos.
- Incorporar **autenticación segura** con Firebase.
- Elevar la **calidad visual y experiencia de usuario** con un rediseño completo.

### Hitos logrados
- **Rediseño Premium UI (Picnic Theme):** Estilo "Glassmorphism", fondos *food doodle* y componentes unificados (HU-22).
- **Autenticación (Firebase Auth):** Login por correo y Google Sign-In, con sesiones persistentes (HU-25).
- **Notificaciones reales:** Scheduler local y permisos del sistema (HU-13).
- **Gestión avanzada:** Búsqueda en tiempo real con *debounce* y *swipe-to-delete* con deshacer (HU-07, HU-11).
- **Persistencia híbrida:** SQLite consolidado y configuración inicial para sincronización Cloud (HU-20).
- **Integración de información de productos:** Autocompletado desde API externa por código de barras (HU-03).

---

## 2. Estado del Repositorio GitHub

### URL del Repositorio

🔗 **https://github.com/Deibyd07/PantryScanner.git**

### Estrategia de Ramas

Se mantiene el flujo Git Flow con integración continua:

| Rama | Propósito | Estado |
|---|---|---|
| **`main`** | Versiones estables (Producción). | ✅ Activa |
| **`develop`** | Integración de features. | ✅ Activa (rama de trabajo actual) |
| **`staging`** | Pruebas de integración. | ✅ Activa |

### Flujo de trabajo

```
feature/hu-xx  →  develop  →  staging  →  main
```

### Commits principales de Sprints 2 y 3

| Commit | Descripción |
|---|---|
| `f014bb7` | **HU-13:** Scheduler real y permisos del sistema de notificaciones |
| `d390978` | **HU-07:** Búsqueda en tiempo real con debounce 300ms y botón de limpieza |
| `93718a7` | **HU-22:** Rediseño UI "Picnic Theme" y fondos "food doodle" |
| `eaaaac0` | **HU-20:** Persistencia offline completa |
| `689bf99` | **HU-11:** Eliminación con swipe, confirmación y deshacer |
| *(Merge)* | **HU-25:** Autenticación con Firebase y Google Sign-In |

---

## 3. Gestión de Historias de Usuario

Las historias planeadas para los Sprints 2 y 3 fueron completadas, incluyendo la incorporación estratégica de **HU-25** para seguridad y preparación Cloud.

🔗 **Board del proyecto:** https://correounivalle-team-qflnikc9.atlassian.net/jira/software/projects/PPS/boards/35/backlog

### Resumen por Sprint

| Sprint | Historias de Usuario Ejecutadas |
|---|---|
| **Sprint 2** | **HU-11:** Eliminar producto<br>**HU-20:** Funcionamiento offline<br>**HU-25:** Autenticación con Firebase |
| **Sprint 3** | **HU-03:** Buscar información por código<br>**HU-07:** Búsqueda en tiempo real<br>**HU-13:** Notificaciones reales<br>**HU-22:** Rediseño UI |

---

## 4. Historias de Usuario Implementadas (Sprints 2 y 3)

### HU-11 · Eliminar producto (Sprint 2)
- **Épica:** Gestión de Inventario | **Prioridad:** Alta | **Etiquetas:** `crud`
- **Descripción:** Implementación de gesto *swipe-to-delete* con confirmación y opción de deshacer.
- **Criterios de Aceptación:**
	- ✅ El usuario puede eliminar un producto con un gesto lateral.
	- ✅ Se muestra un Snackbar con opción de **Deshacer**.
	- ✅ La lista y la BD se actualizan en tiempo real.
	- ✅ No se elimina de forma accidental sin feedback visual.

### HU-20 · Funcionamiento offline completo (Sprint 2)
- **Épica:** Persistencia y Sincronización | **Prioridad:** Alta | **Etiquetas:** `database`
- **Descripción:** La app funciona sin conexión manteniendo lectura, guardado y edición de productos con SQLite.
- **Criterios de Aceptación:**
	- ✅ Las operaciones CRUD funcionan sin internet.
	- ✅ Los datos persisten tras reiniciar la app.
	- ✅ El rendimiento del inventario se mantiene estable offline.

### HU-25 · Autenticación con Firebase (Sprint 2)
- **Épica:** Experiencia de Usuario / Persistencia | **Prioridad:** Crítica | **Etiquetas:** `auth` `firebase`
- **Descripción:** Autenticación segura con Firebase Auth y Google Sign-In, con rutas protegidas.
- **Criterios de Aceptación:**
	- ✅ Inicio de sesión con correo y Google.
	- ✅ Sesión persistente y cierre de sesión.
	- ✅ Rutas protegidas por estado de autenticación.
	- ✅ Mensajes claros ante errores de login.

### HU-03 · Buscar información de producto por código (Sprint 3)
- **Épica:** Escaneo y Registro de Productos | **Prioridad:** Media | **Etiquetas:** `api` `integracion`
- **Descripción:** Al escanear un código de barras, la app consulta una API y completa la información del producto.
- **Criterios de Aceptación:**
	- ✅ Se consulta la API al escanear el código.
	- ✅ Se prellena nombre, categoría e imagen si existe.
	- ✅ Se informa cuando no hay coincidencias.

### HU-07 · Búsqueda en tiempo real (Sprint 3)
- **Épica:** Gestión de Inventario | **Prioridad:** Media | **Etiquetas:** `busqueda`
- **Descripción:** Barra de búsqueda con filtro dinámico y *debounce* para mejorar rendimiento.
- **Criterios de Aceptación:**
	- ✅ El inventario se filtra mientras el usuario escribe.
	- ✅ *Debounce* evita recargas excesivas.
	- ✅ Botón para limpiar búsqueda y restaurar lista.

### HU-13 · Sistema de Notificaciones Reales (Sprint 3)
- **Épica:** Notificaciones Inteligentes | **Prioridad:** Alta | **Etiquetas:** `notificaciones`
- **Descripción:** Scheduler de notificaciones locales con permisos del sistema para alertas de vencimiento.
- **Criterios de Aceptación:**
	- ✅ Se programan notificaciones basadas en fechas de vencimiento.
	- ✅ Se solicitan permisos requeridos por el SO.
	- ✅ El usuario puede activar/desactivar alertas.

### HU-22 · Rediseño UI Premium "Picnic Theme" (Sprint 3)
- **Épica:** Experiencia de Usuario | **Prioridad:** Media | **Etiquetas:** `ui` `ux`
- **Descripción:** Rediseño completo con estética premium, coherencia visual y componentes reutilizables.
- **Criterios de Aceptación:**
	- ✅ Componentes y tipografías unificados en el tema global.
	- ✅ Nuevo estilo visual aplicado en pantallas clave.
	- ✅ Fondos ilustrados y paleta consistente.

---

## 5. Sub-actividades Técnicas

### Sub-actividades — HU-11: Eliminar producto

| ID | Área | Título | Descripción |
|---|---|---|---|
| SUB-11.1 | Frontend | Implementar gesto de *swipe-to-delete* | UI de tarjeta con acción lateral y animaciones. |
| SUB-11.2 | Frontend | Snackbar con opción de deshacer | Feedback visual y reversión controlada. |
| SUB-11.3 | Backend/Domain | Caso de uso: eliminar producto | Sincronización con BD local y actualización del estado. |

### Sub-actividades — HU-20: Funcionamiento offline completo

| ID | Área | Título | Descripción |
|---|---|---|---|
| SUB-20.1 | Data | Consolidar esquema SQLite | Ajuste de tablas y migraciones con Drift. |
| SUB-20.2 | Backend/Domain | Repositorio offline-first | Orquestar lectura/escritura local sin red. |
| SUB-20.3 | Backend/Domain | Manejo de errores sin conexión | Fallbacks y mensajes de estado offline. |

### Sub-actividades — HU-25: Autenticación con Firebase

| ID | Área | Título | Descripción |
|---|---|---|---|
| SUB-25.1 | Frontend | Pantalla de login | UI de correo + Google Sign-In con validaciones. |
| SUB-25.2 | Data | Integración Firebase Auth | Configuración de SDK y flujo de autenticación. |
| SUB-25.3 | Backend/Domain | Estado de sesión y guardas | Control de rutas y persistencia de sesión. |
| SUB-25.4 | Backend/Domain | Manejo de errores y logout | Feedback de errores y cierre seguro. |

### Sub-actividades — HU-03: Buscar información por código

| ID | Área | Título | Descripción |
|---|---|---|---|
| SUB-03.1 | Data | Integración de API externa | Consumo de endpoint con `Dio`. |
| SUB-03.2 | Backend/Domain | Mapeo a entidad de producto | Normalización de datos y validaciones. |
| SUB-03.3 | Frontend | Prellenar formulario | Carga automática y fallback si no hay datos. |

### Sub-actividades — HU-07: Búsqueda en tiempo real

| ID | Área | Título | Descripción |
|---|---|---|---|
| SUB-07.1 | Frontend | SearchBar reactivo | Barra superior con estado controlado. |
| SUB-07.2 | Backend/Domain | Filtro con debounce | Lógica de búsqueda eficiente en memoria. |
| SUB-07.3 | Frontend | UX de limpieza | Botón "limpiar" y estado vacío. |

### Sub-actividades — HU-13: Notificaciones reales

| ID | Área | Título | Descripción |
|---|---|---|---|
| SUB-13.1 | Data | Configurar `flutter_local_notifications` | Canales, prioridad y programación básica. |
| SUB-13.2 | Backend/Domain | Scheduler y umbrales | Reglas de vencimiento y frecuencia. |
| SUB-13.3 | Frontend | UI de preferencias | Activar/desactivar y mensajes informativos. |
| SUB-13.4 | Backend/Domain | Permisos del SO | Solicitud de `POST_NOTIFICATIONS` y fallback. |

### Sub-actividades — HU-22: Rediseño UI "Picnic Theme"

| ID | Área | Título | Descripción |
|---|---|---|---|
| SUB-22.1 | Frontend | Definir sistema visual | Paleta, tipografías y tokens de diseño. |
| SUB-22.2 | Frontend | Refactor de componentes | Cards, chips, app bar y botones unificados. |
| SUB-22.3 | Frontend | Fondos e ilustraciones | Integración de assets "food doodle". |

### Resumen de Sub-actividades (Sprints 2 y 3)

| Área | Total |
|---|---|
| **Frontend** | **10** |
| **Backend/Domain** | **9** |
| **Data** | **4** |
| **Total** | **23** |

---

## 6. Evolución de la Interfaz (Screenshots y Flujos)

A continuación se describe la evolución visual durante el segundo y tercer adelanto:

### 6.1 Pantalla de Login (Autenticación)
- Fondo cálido con identidad de marca.
- Botón principal **"Continuar con Google"** y alternativa por correo.
- Mensajes de error consistentes con el tema.

### 6.2 Inventario con Búsqueda y Swipe
- Barra de búsqueda fija con respuesta instantánea.
- Tarjetas rediseñadas con indicadores de vencimiento.
- Animación fluida al eliminar una tarjeta con opción de deshacer.

### 6.3 Notificaciones y Preferencias
- Vista de configuración con switches claros.
- Permisos nativos integrados con explicación contextual.

> **Nota:** Las capturas finales del Sprint 3 se adjuntarán en la carpeta de documentación.

---

## 7. Resumen del Segundo y Tercer Adelanto

| Aspecto | Estado | Detalle |
|---|---|---|
| **Repositorio GitHub** | ✅ Actualizado | Flujo Git Flow activo con merges por HU |
| **Historias de Usuario** | ✅ Implementadas | 7 HU completadas en Sprints 2 y 3 |
| **Autenticación** | ✅ Integrada | Firebase Auth + Google Sign-In |
| **Notificaciones** | ✅ Programadas | Scheduler local y permisos del SO |
| **Búsqueda y UX** | ✅ Mejoradas | Debounce, swipe-to-delete y rediseño UI |
| **Persistencia Offline** | ✅ Estable | SQLite consolidado y base cloud preparada |

---

> **Documento preparado como segundo y tercer entregable del proyecto PantryScanner.**  
> **Repositorio:** https://github.com/Deibyd07/PantryScanner.git
