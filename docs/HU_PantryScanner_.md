# PantryScanner
## Historias de Usuario y Sub-issues Técnicas

> **24 HU • 89 Sub-issues • 6 Épicas • 168 Story Points**

---

## ÉPICA 1: Escaneo y Registro de Productos

---

### HU-01 · Escanear código de barras básico
**Prioridad:** High | **Puntos:** 8 | **Sprint:** Sprint 1 | **Etiquetas:** `mvp` `camera` `ml-kit`

**Descripción**

*Como usuario de la aplicación, quiero escanear el código de barras de un producto con mi cámara, para agregarlo rápidamente a mi inventario sin escribir manualmente.*

**Criterios de Aceptación**
- El usuario puede acceder a la cámara desde la pantalla principal
- La app detecta automáticamente códigos EAN-13 y UPC-A
- Se muestra un indicador visual cuando se detecta un código
- Se reproduce un sonido/vibración al escanear exitosamente
- El código escaneado se procesa en menos de 2 segundos
- Si no se reconoce el código, se muestra mensaje de error

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-01.1 | Frontend | Implementar pantalla del escáner de cámara | Crear la UI de la vista de escaneo con visor, marco guía y botón de cierre. |
| SUB-01.2 | Frontend | Integrar ML Kit / Vision para detección de códigos | Configurar la librería de visión artificial para detectar EAN-13 y UPC-A en tiempo real. |
| SUB-01.3 | Frontend | Feedback visual y háptico al escanear | Implementar animación de confirmación, sonido y vibración al detectar un código exitosamente. |
| SUB-01.4 | Frontend | Manejo de estado de error por código no reconocido | Mostrar mensaje de error con opción de reintentar cuando el código no pueda procesarse. |

---

### HU-02 · Manejo de permisos de cámara
**Prioridad:** High | **Puntos:** 3 | **Sprint:** Sprint 1 | **Etiquetas:** `mvp` `permisos`

**Descripción**

*Como usuario de la aplicación, quiero que se me soliciten los permisos de cámara de forma clara, para entender por qué la app necesita acceso a mi cámara.*

**Criterios de Aceptación**
- Se solicita permiso antes del primer uso de la cámara
- El mensaje explica claramente para qué se usa la cámara
- Si se deniega, se muestra cómo activarlo en configuración
- La app funciona parcialmente sin permisos (entrada manual)
- Se sigue la guía de UX de la plataforma (Material/HIG)

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-02.1 | Frontend | Solicitar permiso de cámara en primer uso | Implementar el flujo de solicitud de permiso siguiendo las guías de Material Design / HIG. |
| SUB-02.2 | Frontend | Pantalla de permiso denegado con instrucciones | Mostrar vista explicativa con pasos para activar el permiso desde la configuración del sistema. |
| SUB-02.3 | Frontend | Modo de entrada manual como fallback | Habilitar formulario de ingreso manual de código de barras cuando no hay permisos de cámara. |

---

### HU-03 · Buscar información de producto por código
**Prioridad:** Medium | **Puntos:** 13 | **Sprint:** Sprint 3 | **Etiquetas:** `api` `integracion`

**Descripción**

*Como usuario que escanea un producto, quiero que la app busque automáticamente información del producto, para no tener que ingresar manualmente nombre, categoría e imagen.*

**Criterios de Aceptación**
- Al escanear, se consulta una API de productos (OpenFoodFacts, UPC Database)
- Se muestra nombre, marca, imagen y categoría si están disponibles
- Si no hay datos online, se permite entrada manual
- Se cachean los resultados para uso offline
- Tiempo de respuesta < 3 segundos

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-03.1 | Backend | Integrar API OpenFoodFacts | Implementar cliente HTTP para consultar nombre, marca, imagen y categoría por código de barras. |
| SUB-03.2 | Backend | Integrar API UPC Database como fuente secundaria | Añadir fallback a UPC Database si OpenFoodFacts no devuelve resultados. |
| SUB-03.3 | BD | Implementar caché local de productos consultados | Guardar respuestas de la API en base de datos local para disponibilidad offline. |
| SUB-03.4 | Frontend | Mostrar resultados de búsqueda con estado de carga | Implementar skeleton loader mientras se consulta la API y mostrar datos al recibir respuesta. |

---

### HU-04 · Agregar producto al inventario
**Prioridad:** High | **Puntos:** 5 | **Sprint:** Sprint 1 | **Etiquetas:** `mvp` `crud`

**Descripción**

*Como usuario que ha escaneado un producto, quiero confirmar y agregar el producto a mi inventario, para mantener un registro de lo que tengo en casa.*

**Criterios de Aceptación**
- Se muestra pantalla de confirmación con datos del producto
- Permite editar nombre, cantidad, fecha de vencimiento y categoría
- Tiene valor por defecto de cantidad = 1
- Permite agregar notas opcionales
- El producto se guarda en la base de datos local
- Se muestra confirmación visual al guardar

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-04.1 | Frontend | Crear pantalla de confirmación/edición de producto | Formulario con campos: nombre, cantidad, fecha de vencimiento, categoría y notas. |
| SUB-04.2 | BD | Crear esquema de tabla productos en base de datos local | Definir modelo de datos con todos los campos necesarios (código, nombre, cantidad, vencimiento, categoría, notas). |
| SUB-04.3 | Backend | Implementar caso de uso: guardar producto | Lógica de negocio para persistir un producto nuevo validando campos obligatorios. |
| SUB-04.4 | Frontend | Confirmación visual (toast/snackbar) al guardar | Mostrar feedback de éxito y navegar de regreso al inventario tras guardar. |

---

### HU-05 · Escaneo con flash en ambientes oscuros
**Prioridad:** Low | **Puntos:** 2 | **Sprint:** Backlog | **Etiquetas:** `enhancement`

**Descripción**

*Como usuario que escanea en ambientes con poca luz, quiero activar el flash de la cámara, para poder escanear códigos de barras correctamente.*

**Criterios de Aceptación**
- Botón visible para activar/desactivar flash
- Estado del flash se mantiene entre escaneos
- Funciona solo si el dispositivo tiene flash
- Se desactiva automáticamente al salir del escáner

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-05.1 | Frontend | Botón toggle de flash en la pantalla del escáner | Añadir ícono de flash con estado activo/inactivo visible sobre el visor de cámara. |
| SUB-05.2 | Frontend | Controlar la antorcha del dispositivo vía API nativa | Usar la API de la plataforma para encender/apagar el flash y detectar si el dispositivo lo soporta. |

---

## ÉPICA 2: Gestión de Inventario

---

### HU-06 · Ver lista completa de productos
**Prioridad:** High | **Puntos:** 8 | **Sprint:** Sprint 1 | **Etiquetas:** `mvp` `listado`

**Descripción**

*Como usuario de la aplicación, quiero ver todos mis productos en una lista organizada, para conocer rápidamente lo que tengo en mi alacena.*

**Criterios de Aceptación**
- Se muestran todos los productos con imagen, nombre y cantidad
- Indicadores de color según estado (normal, por vencer, vencido, sin stock)
- La lista carga en menos de 1 segundo
- Soporta scroll infinito si hay más de 50 productos
- Se actualiza en tiempo real al agregar/eliminar productos

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-06.1 | Frontend | Crear componente de tarjeta de producto | Diseñar e implementar el item de lista con imagen, nombre, cantidad e indicador de estado por color. |
| SUB-06.2 | Backend | Implementar caso de uso: obtener todos los productos | Query a BD local ordenada por defecto, con soporte de paginación para scroll infinito. |
| SUB-06.3 | Frontend | Implementar scroll infinito (paginación) | Cargar productos en lotes de 50 y añadir más al llegar al final de la lista. |
| SUB-06.4 | Frontend | Actualización reactiva de la lista en tiempo real | Suscribirse a cambios en la BD para reflejar altas y bajas sin recargar manualmente. |

---

### HU-07 · Búsqueda en tiempo real
**Prioridad:** Medium | **Puntos:** 5 | **Sprint:** Sprint 3 | **Etiquetas:** `busqueda` `filtros`

**Descripción**

*Como usuario con muchos productos, quiero buscar productos por nombre o categoría, para encontrar rápidamente lo que necesito.*

**Criterios de Aceptación**
- Barra de búsqueda visible en la parte superior
- Filtrado en tiempo real mientras se escribe (debounce 300ms)
- Búsqueda insensible a mayúsculas/minúsculas
- Busca en nombre, marca y categoría
- Muestra mensaje si no hay resultados
- Se puede limpiar la búsqueda con un botón

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-07.1 | Frontend | Implementar barra de búsqueda con debounce (300ms) | Campo de texto en la parte superior que filtra la lista tras 300ms de inactividad. |
| SUB-07.2 | Backend | Implementar caso de uso: buscar productos por texto | Query insensible a mayúsculas/minúsculas sobre nombre, marca y categoría. |
| SUB-07.3 | Frontend | Estado vacío cuando no hay resultados | Mostrar ilustración y mensaje cuando la búsqueda no arroja productos. |
| SUB-07.4 | Frontend | Botón de limpiar búsqueda | Ícono de X dentro del campo que borra el texto y restaura la lista completa. |

---

### HU-08 · Filtrar por categoría
**Prioridad:** Medium | **Puntos:** 5 | **Sprint:** Sprint 5 | **Etiquetas:** `filtros`

**Descripción**

*Como usuario organizado, quiero filtrar productos por categoría (lácteos, enlatados, etc.), para ver solo los productos de un tipo específico.*

**Criterios de Aceptación**
- Menú desplegable o chips con categorías disponibles
- Muestra contador de productos por categoría
- Se puede seleccionar 'Todas las categorías'
- El filtro persiste hasta que se cambie manualmente
- Se combina con la búsqueda si está activa

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-08.1 | Frontend | Implementar chips/selector de categorías | Fila horizontal de chips o menú desplegable con las categorías disponibles. |
| SUB-08.2 | Backend | Implementar caso de uso: filtrar productos por categoría | Query con cláusula WHERE por categoría, combinable con búsqueda de texto activa. |
| SUB-08.3 | Backend | Obtener conteo de productos por categoría | Query agregada para mostrar el número de items junto a cada categoría en el selector. |

---

### HU-09 · Ordenar lista de productos
**Prioridad:** Low | **Puntos:** 5 | **Sprint:** Sprint 5 | **Etiquetas:** `sorting`

**Descripción**

*Como usuario, quiero ordenar mis productos por diferentes criterios, para priorizar lo que vence pronto o está bajo en stock.*

**Criterios de Aceptación**
- Opciones: Fecha de vencimiento, Nombre A-Z, Cantidad, Categoría
- Orden ascendente/descendente
- Se guarda la preferencia de ordenamiento
- Indicador visual del ordenamiento activo
- Transición suave al reordenar

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-09.1 | Frontend | Implementar selector de criterio de ordenamiento | Menú o bottom sheet con opciones: vencimiento, nombre, cantidad, categoría y dirección. |
| SUB-09.2 | Backend | Implementar caso de uso: obtener productos ordenados | Query dinámica con ORDER BY según el criterio y dirección seleccionados. |
| SUB-09.3 | BD | Persistir preferencia de ordenamiento del usuario | Guardar el criterio activo en preferencias locales (SharedPreferences / UserDefaults). |

---

### HU-10 · Editar producto existente
**Prioridad:** High | **Puntos:** 5 | **Sprint:** Sprint 1 | **Etiquetas:** `mvp` `crud`

**Descripción**

*Como usuario, quiero editar la información de un producto, para corregir errores o actualizar cantidades/fechas.*

**Criterios de Aceptación**
- Al tocar un producto, se abre pantalla de edición
- Se pueden modificar todos los campos excepto el código de barras
- Validación de fechas (no puede ser anterior a hoy)
- Botón de guardar y cancelar
- Confirmación visual al guardar cambios

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-10.1 | Frontend | Crear pantalla de edición de producto | Reutilizar formulario de HU-04 con campos precargados y validación de fecha. |
| SUB-10.2 | Backend | Implementar caso de uso: actualizar producto | Lógica para modificar un registro existente en la BD por su ID. |
| SUB-10.3 | Frontend | Confirmación visual al guardar cambios | Toast/snackbar de éxito y retorno a la vista anterior tras actualizar. |

---

### HU-11 · Eliminar producto
**Prioridad:** High | **Puntos:** 3 | **Sprint:** Sprint 2 | **Etiquetas:** `mvp` `crud`

**Descripción**

*Como usuario, quiero eliminar un producto que ya no tengo, para mantener mi inventario actualizado.*

**Criterios de Aceptación**
- Opción de eliminar mediante swipe o menú contextual
- Diálogo de confirmación antes de eliminar
- Opción de 'Deshacer' durante 5 segundos (Snackbar)
- El producto se elimina permanentemente de la BD
- Se actualiza la lista inmediatamente

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-11.1 | Frontend | Implementar swipe-to-delete en el item de lista | Gesto de deslizamiento que revela la acción de eliminar con color rojo. |
| SUB-11.2 | Frontend | Diálogo de confirmación antes de eliminar | Modal con opciones "Eliminar" y "Cancelar" para evitar borrados accidentales. |
| SUB-11.3 | Frontend | Snackbar de "Deshacer" con temporizador de 5s | Mostrar acción de deshacer tras eliminar; revertir si el usuario la toca antes del timeout. |
| SUB-11.4 | Backend | Implementar caso de uso: eliminar producto | Borrar el registro de la BD y revertirlo si se ejecuta la acción de deshacer. |

---

### HU-12 · Incrementar/decrementar cantidad rápidamente
**Prioridad:** Medium | **Puntos:** 3 | **Sprint:** Sprint 5 | **Etiquetas:** `ux`

**Descripción**

*Como usuario, quiero ajustar la cantidad de un producto con botones +/-, para actualizar el stock sin entrar a editar.*

**Criterios de Aceptación**
- Botones +/- visibles en cada item de la lista
- Al tocar +, incrementa en 1
- Al tocar -, decrementa en 1 (mínimo 0)
- Si llega a 0, pregunta si desea eliminar el producto
- Actualización inmediata en UI y BD

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-12.1 | Frontend | Añadir botones +/- en el item de lista | Controles compactos visibles directamente en la tarjeta de cada producto. |
| SUB-12.2 | Backend | Implementar caso de uso: actualizar cantidad | Actualizar el campo cantidad en la BD de forma atómica al pulsar +/-. |
| SUB-12.3 | Frontend | Diálogo de eliminación cuando cantidad llega a 0 | Preguntar al usuario si desea eliminar el producto al decrementar hasta cero. |

---

## ÉPICA 3: Notificaciones Inteligentes

---

### HU-13 · Configurar umbrales de notificación
**Prioridad:** High | **Puntos:** 8 | **Sprint:** Sprint 3 | **Etiquetas:** `notificaciones` `config`

**Descripción**

*Como usuario, quiero definir cuándo recibir alertas de vencimiento, para personalizar según mis necesidades (3 días antes, 1 día, etc.).*

**Criterios de Aceptación**
- Pantalla de configuración con opciones: 1, 3, 7 días antes
- Se puede activar/desactivar notificaciones globalmente
- Configuración por categoría opcional (lácteos 2 días, enlatados 7)
- Horario preferido de notificaciones (ej: 9:00 AM)
- Los cambios se aplican inmediatamente

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-13.1 | Frontend | Crear pantalla de configuración de notificaciones | Vista con toggles, selects y time picker para personalizar umbrales y horario. |
| SUB-13.2 | BD | Crear esquema de tabla configuracion_notificaciones | Modelo para guardar umbrales globales, configuraciones por categoría y horario preferido. |
| SUB-13.3 | Backend | Caso de uso: guardar y leer configuración de notificaciones | CRUD de preferencias de notificación, aplicando cambios de forma inmediata al scheduler. |

---

### HU-14 · Recibir notificación de vencimiento próximo
**Prioridad:** High | **Puntos:** 13 | **Sprint:** Sprint 4 | **Etiquetas:** `notificaciones` `workmanager`

**Descripción**

*Como usuario, quiero recibir una notificación cuando un producto esté próximo a vencer, para usarlo antes de que se eche a perder.*

**Criterios de Aceptación**
- Notificación local se dispara según umbral configurado
- Muestra nombre del producto y días restantes
- Al tocar la notificación, abre el detalle del producto
- No duplica notificaciones para el mismo producto/día
- Funciona aunque la app esté cerrada

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-14.1 | Backend | Implementar scheduler con WorkManager / BGTaskScheduler | Tarea periódica en background que evalúa productos próximos a vencer según el umbral configurado. |
| SUB-14.2 | Backend | Lógica de deduplicación de notificaciones | Registrar qué notificaciones ya se enviaron para no repetirlas el mismo día por el mismo producto. |
| SUB-14.3 | Frontend | Construir y lanzar notificación local | Crear la notificación con título, cuerpo y deep link al detalle del producto. |
| SUB-14.4 | Frontend | Implementar deep link desde notificación al producto | Al tocar la notificación, navegar directamente a la pantalla de detalle del producto correspondiente. |

---

### HU-15 · Notificación de stock bajo
**Prioridad:** Medium | **Puntos:** 8 | **Sprint:** Sprint 5 | **Etiquetas:** `notificaciones`

**Descripción**

*Como usuario, quiero recibir alertas cuando un producto llegue a cantidad mínima, para recordar comprarlo en mi próxima ida al supermercado.*

**Criterios de Aceptación**
- Se puede definir 'stock mínimo' por producto (default: 1)
- Notificación cuando cantidad <= stock mínimo
- Se agrupa si hay múltiples productos con stock bajo
- Incluye lista de productos en la notificación expandida
- Opción de marcar como 'ya lo compré'

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-15.1 | Frontend | Campo de stock mínimo en pantalla de edición de producto | Input numérico opcional con valor por defecto 1 en el formulario de producto. |
| SUB-15.2 | BD | Agregar campo stock_minimo a la tabla productos | Migración de esquema para soportar el umbral de stock por producto. |
| SUB-15.3 | Backend | Lógica de detección de stock bajo en el scheduler | Evaluar productos cuya cantidad <= stock_minimo y agruparlos en una sola notificación. |
| SUB-15.4 | Frontend | Notificación expandible con lista de productos | Construir notificación con estilo BigTextStyle / rich notification con la lista agrupada. |

---

### HU-16 · Centro de notificaciones dentro de la app
**Prioridad:** Low | **Puntos:** 5 | **Sprint:** Backlog | **Etiquetas:** `enhancement`

**Descripción**

*Como usuario, quiero ver un historial de todas las notificaciones, para revisar alertas pasadas que quizás ignoré.*

**Criterios de Aceptación**
- Sección 'Notificaciones' en el menú
- Lista de notificaciones con fecha y hora
- Marcado de leídas/no leídas
- Navegación al producto relacionado
- Opción de limpiar historial

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-16.1 | BD | Crear tabla historial_notificaciones | Persistir cada notificación enviada con fecha, tipo, producto relacionado y estado leído/no leído. |
| SUB-16.2 | Backend | Caso de uso: registrar notificación al enviarla | Insertar registro en la tabla al momento de lanzar cada notificación local. |
| SUB-16.3 | Frontend | Crear pantalla de historial de notificaciones | Lista ordenada por fecha con indicador visual de leído/no leído y opción de limpiar todo. |
| SUB-16.4 | Frontend | Navegación al producto desde el historial | Al tocar un item del historial, navegar al detalle del producto relacionado. |

---

## ÉPICA 4: Categorización y Organización

---

### HU-17 · Asignación automática de categoría
**Prioridad:** Low | **Puntos:** 5 | **Sprint:** Backlog | **Etiquetas:** `ia` `categorias`

**Descripción**

*Como usuario, quiero que la app sugiera categorías al escanear, para no tener que categorizarlas manualmente.*

**Criterios de Aceptación**
- API externa (OpenFoodFacts) proporciona categoría
- Se mapea a categorías predefinidas en la app
- El usuario puede aceptar o cambiar la categoría
- Si no hay datos, se asigna 'Sin categoría'

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-17.1 | Backend | Mapear categorías de OpenFoodFacts a categorías internas | Tabla de equivalencias entre las categorías de la API y las categorías predefinidas de la app. |
| SUB-17.2 | Frontend | Mostrar categoría sugerida con opción de cambiarla | En la pantalla de confirmación de producto, preseleccionar la categoría mapeada y permitir edición. |

---

### HU-18 · Crear categorías personalizadas
**Prioridad:** Low | **Puntos:** 8 | **Sprint:** Backlog | **Etiquetas:** `categorias` `crud`

**Descripción**

*Como usuario con necesidades específicas, quiero crear mis propias categorías, para organizar productos según mi criterio.*

**Criterios de Aceptación**
- Pantalla de gestión de categorías
- Botón para agregar nueva categoría con nombre e ícono/color
- Validación de nombres duplicados
- Editar/eliminar categorías existentes
- Al eliminar, reasignar productos a 'Sin categoría'

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-18.1 | BD | Crear tabla categorias | Esquema con campos: id, nombre, ícono, color y flag de categoría de sistema vs. personalizada. |
| SUB-18.2 | Backend | CRUD de categorías | Casos de uso para crear, leer, actualizar y eliminar categorías, con reasignación de productos al borrar. |
| SUB-18.3 | Frontend | Crear pantalla de gestión de categorías | Lista de categorías con botón de añadir, opciones de editar/eliminar por item y validación de duplicados. |
| SUB-18.4 | Frontend | Selector de ícono y color al crear categoría | Bottom sheet o diálogo con paleta de colores y set de íconos seleccionables. |

---

### HU-19 · Ver estadísticas de consumo
**Prioridad:** Very Low | **Puntos:** 13 | **Sprint:** Backlog | **Etiquetas:** `analytics` `charts`

**Descripción**

*Como usuario analítico, quiero ver gráficos de qué categorías consumo más, para optimizar mis compras.*

**Criterios de Aceptación**
- Pantalla de estadísticas con gráficos (barras/torta)
- Productos más consumidos (por cantidad reducida)
- Categorías con más productos
- Productos vencidos en último mes
- Filtro por rango de fechas

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-19.1 | BD | Crear tabla movimientos_inventario | Registrar cada cambio de cantidad (alta, baja, vencimiento) con fecha para alimentar las estadísticas. |
| SUB-19.2 | Backend | Queries de agregación para estadísticas | Consultas para: productos más consumidos, categorías con más items y productos vencidos por mes. |
| SUB-19.3 | Frontend | Implementar gráfico de barras por categoría | Visualización con librería de charts del consumo agrupado por categoría. |
| SUB-19.4 | Frontend | Implementar filtro por rango de fechas | Date range picker que acota el período de las estadísticas mostradas. |

---

## ÉPICA 5: Persistencia y Sincronización

---

### HU-20 · Funcionamiento offline completo
**Prioridad:** High | **Puntos:** 8 | **Sprint:** Sprint 2 | **Etiquetas:** `mvp` `offline` `database`

**Descripción**

*Como usuario, quiero usar la app sin conexión a internet, para escanear productos en cualquier lugar.*

**Criterios de Aceptación**
- Todas las funciones principales funcionan sin internet
- Se usa base de datos local (SQLite/Room/Core Data)
- Búsqueda de productos por código usa caché local
- Notificaciones siguen funcionando offline
- Indicador visual cuando no hay conexión

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-20.1 | BD | Configurar base de datos local (Room / Core Data / SQLite) | Setup inicial del ORM/framework de persistencia con migraciones versionadas. |
| SUB-20.2 | Backend | Implementar repositorio con estrategia offline-first | Toda operación de lectura/escritura va primero a la BD local; la red es opcional. |
| SUB-20.3 | Frontend | Banner de estado de conectividad | Indicador no intrusivo que aparece cuando no hay conexión a internet. |

---

### HU-21 · Respaldo y restauración de datos
**Prioridad:** Low | **Puntos:** 8 | **Sprint:** Backlog | **Etiquetas:** `backup` `export`

**Descripción**

*Como usuario, quiero exportar mi inventario a un archivo, para tener un respaldo o transferirlo a otro dispositivo.*

**Criterios de Aceptación**
- Opción 'Exportar datos' en configuración
- Genera archivo JSON o CSV
- Se comparte mediante menú de compartir del sistema
- Opción 'Importar datos' que lee el archivo
- Validación del formato antes de importar
- Confirmación antes de sobrescribir datos existentes

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-21.1 | Backend | Caso de uso: exportar inventario a JSON/CSV | Serializar todos los productos de la BD local al formato elegido y retornar el archivo. |
| SUB-21.2 | Frontend | Integrar menú de compartir del sistema al exportar | Invocar el share sheet nativo con el archivo generado para que el usuario lo guarde o envíe. |
| SUB-21.3 | Backend | Caso de uso: importar inventario desde archivo | Parsear y validar el archivo JSON/CSV y persistir los productos, con confirmación antes de sobrescribir. |
| SUB-21.4 | Frontend | Selector de archivo para importar | Usar el file picker nativo para que el usuario seleccione el archivo de respaldo. |

---

## ÉPICA 6: Experiencia de Usuario

---

### HU-22 · Onboarding interactivo
**Prioridad:** Medium | **Puntos:** 5 | **Sprint:** Sprint 3 | **Etiquetas:** `onboarding` `ux`

**Descripción**

*Como usuario nuevo, quiero ver un tutorial rápido al iniciar la app, para entender cómo usarla correctamente.*

**Criterios de Aceptación**
- Tutorial de 3-4 pantallas con ilustraciones
- Explica: escaneo, gestión de inventario, notificaciones
- Opción de saltar el tutorial
- Se muestra solo la primera vez
- Opción de verlo nuevamente desde configuración

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-22.1 | Frontend | Crear flujo de 3-4 pantallas de onboarding | Implementar ViewPager / PageViewController con ilustraciones, textos y botón de saltar. |
| SUB-22.2 | BD | Persistir flag de onboarding completado | Guardar en preferencias locales si el usuario ya vio el tutorial para no mostrarlo de nuevo. |
| SUB-22.3 | Frontend | Opción de ver el tutorial desde configuración | Enlace en la pantalla de ajustes que reinicia y muestra el onboarding nuevamente. |

---

### HU-23 · Modo oscuro
**Prioridad:** Low | **Puntos:** 5 | **Sprint:** Sprint 6 | **Etiquetas:** `theme` `ui`

**Descripción**

*Como usuario que usa la app de noche, quiero activar un tema oscuro, para no cansar la vista.*

**Criterios de Aceptación**
- Toggle en configuración para modo oscuro/claro
- Opción 'Automático' según configuración del sistema
- Todos los componentes se adaptan correctamente
- Iconos y texto siguen siendo legibles
- Preferencia se guarda persistentemente

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-23.1 | Frontend | Definir tokens de color para tema claro y oscuro | Crear sistema de design tokens (colores, superficies, textos) para ambos temas. |
| SUB-23.2 | Frontend | Implementar toggle de tema en configuración | Opción con tres estados: Claro, Oscuro y Automático (sigue al sistema). |
| SUB-23.3 | BD | Persistir preferencia de tema seleccionado | Guardar la elección del usuario en preferencias locales y aplicarla al iniciar la app. |

---

### HU-24 · Estados vacíos informativos
**Prioridad:** Medium | **Puntos:** 3 | **Sprint:** Sprint 4 | **Etiquetas:** `ux` `empty-states`

**Descripción**

*Como usuario nuevo sin productos, quiero ver mensajes útiles cuando no hay datos, para saber qué hacer a continuación.*

**Criterios de Aceptación**
- Pantalla de inventario vacío muestra ilustración y mensaje
- Botón CTA 'Escanear mi primer producto'
- Búsqueda sin resultados muestra mensaje relevante
- Categoría sin productos muestra sugerencia

**Sub-issues Técnicas**

| ID | Área | Título | Descripción |
|----|------|--------|-------------|
| SUB-24.1 | Frontend | Componente reutilizable de estado vacío | Widget genérico que recibe ilustración, título, descripción y CTA opcional como parámetros. |
| SUB-24.2 | Frontend | Estado vacío en pantalla de inventario | Ilustración y botón "Escanear mi primer producto" cuando no hay ningún producto en la BD. |
| SUB-24.3 | Frontend | Estado vacío en búsqueda sin resultados | Mensaje contextual con el texto buscado cuando la query no retorna productos. |
| SUB-24.4 | Frontend | Estado vacío en categoría sin productos | Mensaje con sugerencia de agregar productos a esa categoría cuando está vacía. |
