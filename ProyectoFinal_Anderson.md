# PROYECTO FINAL

## MIGRACIÓN Y VERIFICACIÓN DE EMPLOYEES

## MARIADB → POSTGRESQL 18

**NOMBRE DEL ESTUDIANTE**\
Anderson Carvajal Romero

**MATERIA**\
Tecnología de Bases de Datos I

**DOCENTE**\
Jared Lopez Leaños

**Santa Cruz de la Sierra - Bolivia**\
**2026**

------------------------------------------------------------------------

# Contenido

1.  Introducción\
2.  Entorno de trabajo\
3.  Migración de tablas\
    3.1 Ejecución de pgLoader\
    3.2 Resultado de la migración\
    3.3 Comparación de conteos\
4.  Migración de vistas\
    4.1 Definiciones originales en MariaDB\
    4.2 Adaptación a PostgreSQL\
    4.3 Creación y verificación de las vistas\
5.  Verificación de la migración\
    5.1 Conteos de registros\
    5.2 Checksum comparativo\
    5.3 Integridad referencial\
    5.4 Análisis de resultados\
6.  Backup de PostgreSQL\
    6.1 Generación del backup\
    6.2 Validación del backup\
7.  Resultados\
8.  Conclusiones\
9.  Archivos de entrega\
10. Referencias

# 1. Introducción

El proyecto final consistió en completar y verificar la migración de la
base de datos `employees` desde MariaDB hacia PostgreSQL 18. El trabajo
continuó sobre la migración desarrollada previamente, utilizando la base
destino `pdb_employees`.

Se verificó la migración de las seis tablas principales, se adaptaron y
crearon las dos vistas de MariaDB en PostgreSQL, y se realizaron
consultas de comprobación mediante conteos, checksum e integridad
referencial. Finalmente, se generó un backup en formato personalizado de
PostgreSQL y se validó su contenido con `pg_restore`.

# 2. Entorno de trabajo

El proyecto se ejecutó en una máquina virtual Linux con los servicios
desplegados mediante Docker.

  Servicio     Versión / imagen      Puerto
  ------------ ------------------- --------
  MariaDB      11.8.9                  3306
  PostgreSQL   18.6                    5432
  Adminer      contenedor Docker       8080

La base de datos de origen fue `employees` en MariaDB y la base de datos
de destino fue `pdb_employees` en PostgreSQL.

# 3. Migración de tablas

## 3.1 Ejecución de pgLoader

La migración de las tablas fue realizada mediante pgLoader. La evidencia
de ejecución utilizada para verificar el proceso fue
`pgloader_pdb_evidencia.txt`.

``` text
2026-09-25T17:57:57.008000Z LOG pgloader version "3.6.10~devel"
2026-09-25T17:57:57.012000Z LOG Parsing commands from file #P"/home/anderson/Actividad5/migracion_pdb.load"
2026-09-25T17:57:57.204001Z LOG Migrating from #<MYSQL-CONNECTION mysql://root@localhost:3306/employees {1006AB5BB3}>
2026-09-25T17:57:57.204001Z LOG Migrating into #<PGSQL-CONNECTION pgsql://anderson@localhost:5432/pdb_employees {1006AB5DC3}>
2026-09-25T17:58:10.368048Z LOG report summary reset
             table name     errors       rows      bytes      total time
-----------------------  ---------  ---------  ---------  --------------
        fetch meta data          0         21                     0.140s
         Create Schemas          0          0                     0.004s
       Create SQL Types          0          0                     0.008s
          Create tables          0         12                     0.032s
         Set Table OIDs          0          6                     0.004s
-----------------------  ---------  ---------  ---------  --------------
     employees.salaries          0    2844047    94.2 MB         10.212s
       employees.titles          0     443308    16.9 MB          3.032s
     employees.dept_emp          0     331603    10.7 MB          3.328s
  employees.departments          0          9     0.1 kB          0.568s
 employees.dept_manager          0         24     0.8 kB          0.024s
    employees.employees          0     300024    13.2 MB          2.304s
-----------------------  ---------  ---------  ---------  --------------
COPY Threads Completion          0          8                    10.152s
         Create Indexes          0          9                     2.448s
 Index Build Completion          0          9                     1.352s
        Reset Sequences          0          0                     0.096s
           Primary Keys          0          6                     0.008s
    Create Foreign Keys          0          6                     1.080s
        Create Triggers          0          0                     0.000s
        Set Search Path          0          1                     0.004s
       Install Comments          0          0                     0.000s
-----------------------  ---------  ---------  ---------  --------------
      Total import time          ✓    3919015   134.9 MB         15.140s
```

## 3.2 Resultado de la migración

pgLoader finalizó la migración con **0 errores** y transfirió
**3.919.015 registros**, equivalentes a **134,9 MB** de información.

El proceso también creó los índices, las seis claves primarias y las
seis claves foráneas correspondientes.

## 3.3 Comparación de conteos

### MariaDB

``` text
tabla   registros
departments 9
dept_emp    331603
dept_manager    24
employees   300024
salaries    2844047
titles  443308
```

### PostgreSQL

``` text
tabla     | registros 
--------------+-----------
 departments  |         9
 dept_emp     |    331603
 dept_manager |        24
 employees    |    300024
 salaries     |   2844047
 titles       |    443308
(6 filas)
```

  Tabla                MariaDB    PostgreSQL   Diferencia
  -------------- ------------- ------------- ------------
  departments                9             9            0
  dept_emp              331603        331603            0
  dept_manager              24            24            0
  employees             300024        300024            0
  salaries             2844047       2844047            0
  titles                443308        443308            0
  **Total**        **3919015**   **3919015**        **0**

Los conteos son idénticos en ambos gestores, por lo que no se detectó
pérdida de registros durante la migración.

# 4. Migración de vistas

MariaDB contenía dos vistas que debían ser adaptadas y creadas en
PostgreSQL:

-   `dept_emp_latest_date`
-   `current_dept_emp`

## 4.1 Definiciones originales en MariaDB

Las definiciones originales fueron obtenidas mediante
`SHOW CREATE VIEW`.

``` text
===== VISTA: dept_emp_latest_date =====
*************************** 1. row ***************************
                View: dept_emp_latest_date
         Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `dept_emp_latest_date` AS select `dept_emp`.`emp_no` AS `emp_no`,max(`dept_emp`.`from_date`) AS `from_date`,max(`dept_emp`.`to_date`) AS `to_date` from `dept_emp` group by `dept_emp`.`emp_no`
character_set_client: utf8mb3
collation_connection: utf8mb3_uca1400_ai_ci

===== VISTA: current_dept_emp =====
*************************** 1. row ***************************
                View: current_dept_emp
         Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `current_dept_emp` AS select `l`.`emp_no` AS `emp_no`,`d`.`dept_no` AS `dept_no`,`l`.`from_date` AS `from_date`,`l`.`to_date` AS `to_date` from (`dept_emp` `d` join `dept_emp_latest_date` `l` on(`d`.`emp_no` = `l`.`emp_no` and `d`.`from_date` = `l`.`from_date` and `l`.`to_date` = `d`.`to_date`))
character_set_client: utf8mb3
collation_connection: utf8mb3_uca1400_ai_ci
```

La sintaxis original contiene elementos específicos de MariaDB como
`ALGORITHM=UNDEFINED`, `DEFINER`, `SQL SECURITY DEFINER` y backticks.

## 4.2 Adaptación a PostgreSQL

Para PostgreSQL se eliminaron los elementos específicos de MariaDB y se
mantuvo la lógica de las consultas.

### Vista `dept_emp_latest_date`

``` sql
CREATE OR REPLACE VIEW employees.dept_emp_latest_date AS
SELECT emp_no,
       MAX(from_date) AS from_date,
       MAX(to_date) AS to_date
FROM employees.dept_emp
GROUP BY emp_no;
```

### Vista `current_dept_emp`

``` sql
CREATE OR REPLACE VIEW employees.current_dept_emp AS
SELECT l.emp_no,
       d.dept_no,
       l.from_date,
       l.to_date
FROM employees.dept_emp d
JOIN employees.dept_emp_latest_date l
  ON d.emp_no = l.emp_no
 AND d.from_date = l.from_date
 AND l.to_date = d.to_date;
```

PostgreSQL confirmó la creación de ambas vistas mediante los mensajes
`CREATE VIEW`.

## 4.3 Creación y verificación de las vistas

Después de crearlas se verificó su existencia y se realizaron consultas
de prueba con cinco registros de cada vista.

``` text
Listado de vistas
  Esquema  |        Nombre        | Tipo  |  Dueño   
-----------+----------------------+-------+----------
 employees | current_dept_emp     | vista | anderson
 employees | dept_emp_latest_date | vista | anderson
(2 filas)

 emp_no | from_date  |  to_date   
--------+------------+------------
  10001 | 1986-06-26 | 9999-01-01
  10002 | 1996-08-03 | 9999-01-01
  10003 | 1995-12-03 | 9999-01-01
  10004 | 1986-12-01 | 9999-01-01
  10005 | 1989-09-12 | 9999-01-01
(5 filas)

 emp_no | dept_no | from_date  |  to_date   
--------+---------+------------+------------
  10004 | d004    | 1986-12-01 | 9999-01-01
  10286 | d009    | 1994-12-24 | 1999-01-24
  10287 | d005    | 1997-09-05 | 9999-01-01
  10293 | d004    | 1992-12-12 | 9999-01-01
  10295 | d002    | 1995-06-19 | 9999-01-01
(5 filas)
```

Las dos vistas devolvieron información correctamente, por lo que la
adaptación conservó su funcionamiento.

# 5. Verificación de la migración

La verificación se realizó mediante tres mecanismos: conteo de
registros, checksum comparativo e integridad referencial.

## 5.1 Conteos de registros

Los conteos mostrados anteriormente dieron un total de **3.919.015
registros tanto en MariaDB como en PostgreSQL**, con diferencia igual a
cero en las seis tablas.

## 5.2 Checksum comparativo

Se calculó un checksum MD5 sobre el contenido ordenado de la tabla
`departments` en ambos gestores.

``` text
===== CHECKSUM DEPARTMENTS - MARIADB =====
checksum_departments
39929f56c0dbcadfc702b03004c7daa3

===== CHECKSUM DEPARTMENTS - POSTGRESQL =====
       checksum_departments       
----------------------------------
 39929f56c0dbcadfc702b03004c7daa3
(1 fila)
```

Resultado:

``` text
MariaDB:    39929f56c0dbcadfc702b03004c7daa3
PostgreSQL: 39929f56c0dbcadfc702b03004c7daa3
```

Los valores son idénticos, verificando que los datos considerados para
esta comprobación mantienen el mismo contenido después de la migración.

## 5.3 Integridad referencial

Se verificaron las seis relaciones de claves foráneas mediante consultas
de registros huérfanos.

``` text
VERIFICACIÓN DE INTEGRIDAD REFERENCIAL - PostgreSQL
Base de datos: pdb_employees

Relación                              Huérfanos
------------------------------------------------
dept_emp -> employees                 0
dept_emp -> departments               0
dept_manager -> employees             0
dept_manager -> departments           0
salaries -> employees                 0
titles -> employees                   0

Resultado:
No se encontraron registros huérfanos en ninguna de las seis relaciones verificadas.
```

Todas las relaciones devolvieron **0 registros huérfanos**.

## 5.4 Análisis de resultados

Las verificaciones realizadas no mostraron diferencias en los conteos de
las tablas. El checksum comparativo de `departments` fue idéntico en
MariaDB y PostgreSQL y las seis comprobaciones de integridad referencial
devolvieron cero registros huérfanos.

En conjunto, estos resultados muestran que la migración conservó la
cantidad de registros y las relaciones referenciales verificadas. Las
dos vistas adaptadas también pudieron consultarse correctamente en
PostgreSQL.

# 6. Backup de PostgreSQL

## 6.1 Generación del backup

Se generó un backup de `pdb_employees` mediante `pg_dump` en formato
personalizado:

``` bash
PGPASSWORD=123456 pg_dump \
-h localhost \
-U anderson \
-d pdb_employees \
-Fc \
-f ~/ProyectoFinal/backup_pdb_employees.dump
```

El archivo generado fue:

``` text
backup_pdb_employees.dump
```

con un tamaño aproximado de **35 MB**.

## 6.2 Validación del backup

El backup fue validado leyendo su catálogo mediante `pg_restore -l`.

``` text
===== BACKUP POSTGRESQL =====
-rw-r--r-- 1 anderson anderson 35M sep 27 10:44 /home/anderson/ProyectoFinal/backup_pdb_employees.dump

===== VALIDACION CON PG_RESTORE =====
;
; Archive created at 2026-09-27 10:44:04 -04
;     dbname: pdb_employees
;     TOC Entries: 35
;     Compression: gzip
;     Dump Version: 1.16-0
;     Format: CUSTOM
;     Integer: 4 bytes
;     Offset: 8 bytes
;     Dumped from database version: 18.6 (Debian 18.6-1.pgdg13+2)
;     Dumped by pg_dump version: 18.6 (Debian 18.6-1.pgdg12+2)
;
;
; Selected TOC Entries:
;
6; 2615 16484 SCHEMA - employees anderson
223; 1259 16490 TABLE employees dept_emp anderson
228; 1259 16678 VIEW employees dept_emp_latest_date anderson
229; 1259 16682 VIEW employees current_dept_emp anderson
222; 1259 16485 TABLE employees departments anderson
224; 1259 16497 TABLE employees dept_manager anderson
225; 1259 16504 TABLE employees employees anderson
226; 1259 16515 TABLE employees salaries anderson
227; 1259 16522 TABLE employees titles anderson
3489; 0 16485 TABLE DATA employees departments anderson
```

La validación identificó correctamente la base `pdb_employees`, el
esquema `employees`, las seis tablas y las dos vistas. El archivo
utiliza formato `CUSTOM` y compresión gzip.

# 7. Resultados

  Elemento verificado               Resultado
  --------------------------------- -----------------------------
  Base origen                       MariaDB `employees`
  Base destino                      PostgreSQL `pdb_employees`
  PostgreSQL                        18.6
  Tablas migradas                   6
  Vistas migradas                   2
  Registros MariaDB                 3.919.015
  Registros PostgreSQL              3.919.015
  Diferencia de registros           0
  Errores reportados por pgLoader   0
  Checksum `departments`            Coincidente
  Relaciones verificadas            6
  Registros huérfanos               0
  Backup                            `backup_pdb_employees.dump`
  Tamaño del backup                 35 MB
  Validación con pg_restore         Correcta

# 8. Conclusiones

La migración de la base de datos `employees` desde MariaDB hacia
PostgreSQL 18 fue completada y verificada satisfactoriamente. Las seis
tablas conservaron exactamente la misma cantidad de registros en ambos
gestores, alcanzando un total de **3.919.015 registros**.

Las vistas `dept_emp_latest_date` y `current_dept_emp` fueron adaptadas
desde la sintaxis de MariaDB y creadas correctamente en PostgreSQL. Las
consultas de prueba confirmaron que ambas vistas devuelven información.

Las verificaciones complementarias reforzaron la validación de la
migración: el checksum calculado para `departments` coincidió en ambos
motores y las seis relaciones evaluadas presentaron **0 registros
huérfanos**.

Finalmente, se generó `backup_pdb_employees.dump` y se comprobó su
lectura mediante `pg_restore`, verificando que contiene las tablas y
vistas de la base migrada.

# 9. Archivos de entrega

-   `ProyectoFinal_Anderson_Carvajal.md`
-   `ProyectoFinal_Anderson_Carvajal.pdf`
-   `backup_pdb_employees.dump`
-   `README.md`
-   `employees-postgresql.sql`
-   `pgloader_pdb_evidencia.txt`
-   `vistas_mariadb.txt`
-   `verificacion_vistas_postgresql.txt`
-   `conteos_mariadb.txt`
-   `conteos_postgresql.txt`
-   `checksum_departments.txt`
-   `integridad_referencial.txt`
-   `verificacion_backup.txt`

# 10. Referencias

-   PostgreSQL Documentation.
-   MariaDB Server Documentation.
-   pgLoader Documentation.
