# Proyecto Final - Tecnología de Bases de Datos I

## Migración y verificación de `employees`: MariaDB → PostgreSQL 18

**Estudiante:** Anderson Carvajal Romero\
**Materia:** Tecnología de Bases de Datos I\
**Docente:** Jared Lopez Leaños\
**Gestión:** 2026

## Descripción

Este proyecto documenta la migración y verificación de la base de datos
`employees` desde MariaDB hacia PostgreSQL 18.

La migración de las tablas fue realizada con pgLoader hacia la base
`pdb_employees`. Posteriormente se adaptaron las vistas originales de
MariaDB a PostgreSQL y se realizaron verificaciones mediante conteos de
registros, checksum e integridad referencial.

Finalmente, se generó y validó un backup de la base migrada.

## Tecnologías utilizadas

-   MariaDB 11.8.9
-   PostgreSQL 18.6
-   Docker
-   pgLoader
-   `psql`
-   `pg_dump`
-   `pg_restore`

## Objetos migrados

### Tablas

-   `departments`
-   `dept_emp`
-   `dept_manager`
-   `employees`
-   `salaries`
-   `titles`

### Vistas

-   `dept_emp_latest_date`
-   `current_dept_emp`

## Resultados

  Verificación                      Resultado
  --------------------------------- -------------
  Tablas migradas                   6
  Vistas migradas                   2
  Registros en MariaDB              3.919.015
  Registros en PostgreSQL           3.919.015
  Diferencia de registros           0
  Errores reportados por pgLoader   0
  Checksum de `departments`         Coincidente
  Relaciones verificadas            6
  Registros huérfanos               0
  Backup PostgreSQL                 Validado

### Conteos por tabla

  Tabla                  MariaDB    PostgreSQL
  ---------------- ------------- -------------
  `departments`                9             9
  `dept_emp`              331603        331603
  `dept_manager`              24            24
  `employees`             300024        300024
  `salaries`             2844047       2844047
  `titles`                443308        443308
  **Total**          **3919015**   **3919015**

## Verificación

La consistencia de la migración se comprobó mediante:

1.  Comparación de conteos entre MariaDB y PostgreSQL.
2.  Comparación de un checksum MD5 de la tabla `departments`.
3.  Verificación de las seis relaciones referenciales mediante búsqueda
    de registros huérfanos.
4.  Consultas de prueba sobre las dos vistas migradas.
5.  Validación del backup mediante `pg_restore -l`.

El checksum obtenido para `departments` fue el mismo en ambos gestores:

``` text
39929f56c0dbcadfc702b03004c7daa3
```

Las seis comprobaciones de integridad referencial devolvieron **0
registros huérfanos**.

## Backup

El backup de PostgreSQL se generó con `pg_dump` en formato
personalizado:

``` bash
pg_dump -h localhost -U anderson -d pdb_employees -Fc -f backup_pdb_employees.dump
```

El archivo resultante tiene un tamaño aproximado de 35 MB y fue validado
con:

``` bash
pg_restore -l backup_pdb_employees.dump
```

La validación identificó correctamente el esquema `employees`, las seis
tablas y las dos vistas.

## Archivos principales

``` text
ProyectoFinal/
├── ProyectoFinal_Anderson_Carvajal.md
├── ProyectoFinal_Anderson_Carvajal.pdf
├── README.md
├── backup_pdb_employees.dump
├── employees-postgresql.sql
├── pgloader_pdb_evidencia.txt
├── vistas_mariadb.txt
├── verificacion_vistas_postgresql.txt
├── conteos_mariadb.txt
├── conteos_postgresql.txt
├── checksum_departments.txt
├── integridad_referencial.txt
└── verificacion_backup.txt
```

## Evidencias

Los archivos `.txt` incluidos contienen las salidas utilizadas para
documentar y verificar el proceso:

-   `pgloader_pdb_evidencia.txt`: resultado de la migración con
    pgLoader.
-   `vistas_mariadb.txt`: definiciones originales de las vistas.
-   `verificacion_vistas_postgresql.txt`: existencia y consultas de
    prueba de las vistas.
-   `conteos_mariadb.txt` y `conteos_postgresql.txt`: comparación de
    registros.
-   `checksum_departments.txt`: checksum comparativo.
-   `integridad_referencial.txt`: resultado de las comprobaciones de
    registros huérfanos.
-   `verificacion_backup.txt`: validación del backup con `pg_restore`.

## Conclusión

La migración de `employees` hacia PostgreSQL 18 conservó los 3.919.015
registros de las seis tablas. Las dos vistas fueron adaptadas y
verificadas, los conteos coincidieron entre ambos gestores, el checksum
evaluado fue idéntico y no se encontraron registros huérfanos en las
relaciones comprobadas.

El backup final de `pdb_employees` también fue generado y validado
correctamente.
