# Trabajo hecho por Juan Clímaco #06, Gabriel Segovoia #26 
#  Accommodations Tourism Database

Base de datos relacional en **PostgreSQL** para la gestión de una plataforma de reservas de alojamientos turísticos (estilo Airbnb/Booking). Modela propietarios, alojamientos, habitaciones, huéspedes, reservas, pagos y reseñas.

##  Descripción general

El proyecto simula el backend de datos de un sistema de reservas turísticas. Permite:

- Registrar **propietarios** (`owners`) y los **alojamientos** (`accommodations`) que publican.
- Clasificar alojamientos por **tipo** (`accommodation_types`: Hotel, Hostel, Apartment, House, Villa, Cabin, Resort, Guesthouse) y **ubicación** (`locations`).
- Definir **habitaciones** (`rooms`) dentro de cada alojamiento y las **amenidades** que ofrecen (`amenities` / `accommodation_amenities`).
- Registrar **huéspedes** (`guests`) y sus **reservas** (`bookings`), incluyendo huéspedes adicionales por reserva (`booking_guests`).
- Controlar el **estado de las reservas** (`booking_statuses`: Pending, Confirmed, CheckedIn, CheckedOut, Cancelled, NoShow).
- Gestionar **pagos** (`payments`) y **reseñas** (`reviews`) asociadas a cada reserva.
- Administrar usuarios internos del staff (`staff_users`) con roles (Manager, Admin, Receptionist, Accountant).

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `accommodation_database_restore_ORIGINAL.pdf` / `.sql` | Script completo de restauración: crea la base de datos, secuencias, tablas, llaves, índices, triggers y carga datos de ejemplo (dataset dummy). |
| Script de consultas (20 ejercicios) | Colección de sentencias `INSERT`, `SELECT`, `UPDATE`, `DELETE` y consultas avanzadas (`JOIN`, `GROUP BY`, subconsultas) sobre el esquema. |
| Diagramas ER (imágenes) | Modelo entidad-relación de las 13 tablas y sus llaves foráneas. |

## Modelo de datos (tablas principales)

```
owners ──< accommodations >── locations
                │
                ├──< accommodation_types
                ├──< accommodation_amenities >── amenities
                ├──< rooms
                └──< bookings >── guests
                        │            
                        ├──< booking_guests
                        ├──< booking_statuses
                        ├──< payments
                        └──< reviews
```

### Resumen de tablas

- **owners** — Propietarios de alojamientos (datos de contacto, empresa, dirección).
- **locations** — Direcciones geográficas (país, estado, ciudad, coordenadas).
- **accommodation_types** — Catálogo de tipos de alojamiento.
- **accommodations** — Alojamiento publicado (precio/noche, capacidad, check-in/out, etc.). FK a `owners`, `accommodation_types` y `locations`.
- **amenities** / **accommodation_amenities** — Catálogo de comodidades y su relación N:M con alojamientos.
- **rooms** — Habitaciones de un alojamiento (capacidad, precio, disponibilidad).
- **guests** — Huésped principal que realiza la reserva.
- **bookings** — Reserva (fechas, huéspedes, montos, estado). Columna calculada `total_nights`. FK a `guests`, `accommodations`, `rooms` y `booking_statuses`.
- **booking_guests** — Huéspedes adicionales incluidos en una reserva.
- **booking_statuses** — Catálogo de estados de reserva.
- **payments** — Pagos asociados a una reserva (método, estado, referencia de transacción).
- **reviews** — Reseña de un huésped sobre un alojamiento (rating 1–5), ligada 1:1 a una reserva.
- **staff_users** — Usuarios del sistema (personal interno) con rol y credenciales.

### Integridad y automatización

- Llaves primarias `serial`/`bigserial` con secuencias dedicadas por tabla.
- `CHECK` constraints para validar montos ≥ 0, ratings entre 1 y 5, fechas de salida posteriores a la de entrada, etc.
- `ON DELETE CASCADE` en relaciones dependientes (ej. `booking_guests`, `payments`, `reviews` respecto a `bookings`).
- Triggers `set_updated_at()` que actualizan automáticamente `updated_at` en `accommodations`, `bookings`, `guests`, `owners`, `rooms` y `staff_users`.
- Índices en columnas de búsqueda/join frecuentes (fechas de reserva, `guest_id`, `accommodation_id`, `booking_status_id`, etc.).

##  Requisitos

- PostgreSQL 14 o superior (dump generado con formato custom v1.16 sobre PG 18.3).

##  Instalación / Restauración

```bash
# 1. Crear la base de datos
psql -U postgres -c "CREATE DATABASE accommodations_tourism \
WITH TEMPLATE=template0 ENCODING='UTF8' LOCALE_PROVIDER=libc LOCALE='en_US.UTF-8';"

# 2. Ejecutar el script de restauración (schema + datos de ejemplo)
psql -U postgres -d accommodations_tourism -f accommodation_database_restore.sql
```

El script incluye datos de prueba (dummy/faker) para todas las tablas: 20 propietarios, 20 ubicaciones, 20 alojamientos, 77 habitaciones, 100 huéspedes, 100 reservas, 90 pagos, 60 reseñas y 10 usuarios de staff.

##  Consultas de ejemplo incluidas

El script de consultas cubre 20 casos de uso típicos sobre el esquema, agrupados por tipo de operación:

1. **INSERT** — Alta de propietario, alojamiento, huésped/reserva y pago.
2. **SELECT con filtros** — Alojamientos activos, huéspedes por nacionalidad, reservas por rango de fechas.
3. **UPDATE** — Actualizar precio de un alojamiento y estado de una reserva.
4. **DELETE** — Eliminar una reseña.
5. **JOIN** — `INNER JOIN` simple y múltiple (reservas + huésped, alojamiento + tipo, pagos + reserva).
6. **LEFT JOIN** — Alojamientos sin reseñas y alojamientos sin reservas.
7. **Funciones de agregación** — `SUM` de ingresos totales, `AVG` de rating.
8. **GROUP BY / HAVING** — Top 5 alojamientos más reservados y alojamientos con más de 3 reservas.
9. **Subconsultas** — Alojamiento con el precio por noche más alto.

##  Notas

- Los montos, correos, teléfonos y direcciones del set de datos son **ficticios**, generados automáticamente para fines de prueba.
- El campo `currency_code` permite manejar alojamientos en distintas monedas (USD, EUR, MXN, BRL, GBP).
- `total_nights` en `bookings` es una columna **generada** (`GENERATED ALWAYS AS`), no se inserta manualmente.
