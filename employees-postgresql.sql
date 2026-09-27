-- ============================================================
-- ACTIVIDAD 5 - TECNOLOGIA DE BASE DE DATOS I
-- DDL adaptado de MariaDB a PostgreSQL
-- Base de datos destino: pdb_employees
-- ============================================================

CREATE SCHEMA IF NOT EXISTS employees;

SET search_path TO employees, public;

-- ============================================================
-- TABLA: departments
-- ============================================================

CREATE TABLE departments (
    dept_no CHAR(4) NOT NULL,
    dept_name VARCHAR(40) NOT NULL,
    CONSTRAINT departments_pkey PRIMARY KEY (dept_no),
    CONSTRAINT departments_dept_name_key UNIQUE (dept_name)
);

-- ============================================================
-- TABLA: employees
-- ============================================================

CREATE TABLE employees (
    emp_no BIGINT NOT NULL,
    birth_date DATE NOT NULL,
    first_name VARCHAR(14) NOT NULL,
    last_name VARCHAR(16) NOT NULL,
    gender TEXT NOT NULL,
    hire_date DATE NOT NULL,
    CONSTRAINT employees_pkey PRIMARY KEY (emp_no),
    CONSTRAINT employees_gender_check CHECK (gender IN ('M', 'F'))
);

-- ============================================================
-- TABLA: dept_emp
-- ============================================================

CREATE TABLE dept_emp (
    emp_no BIGINT NOT NULL,
    dept_no CHAR(4) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,

    CONSTRAINT dept_emp_pkey
        PRIMARY KEY (emp_no, dept_no),

    CONSTRAINT dept_emp_ibfk_1
        FOREIGN KEY (emp_no)
        REFERENCES employees(emp_no)
        ON DELETE CASCADE,

    CONSTRAINT dept_emp_ibfk_2
        FOREIGN KEY (dept_no)
        REFERENCES departments(dept_no)
        ON DELETE CASCADE
);

CREATE INDEX dept_emp_dept_no_idx
    ON dept_emp(dept_no);

-- ============================================================
-- TABLA: dept_manager
-- ============================================================

CREATE TABLE dept_manager (
    emp_no BIGINT NOT NULL,
    dept_no CHAR(4) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,

    CONSTRAINT dept_manager_pkey
        PRIMARY KEY (emp_no, dept_no),

    CONSTRAINT dept_manager_ibfk_1
        FOREIGN KEY (emp_no)
        REFERENCES employees(emp_no)
        ON DELETE CASCADE,

    CONSTRAINT dept_manager_ibfk_2
        FOREIGN KEY (dept_no)
        REFERENCES departments(dept_no)
        ON DELETE CASCADE
);

CREATE INDEX dept_manager_dept_no_idx
    ON dept_manager(dept_no);

-- ============================================================
-- TABLA: salaries
-- ============================================================

CREATE TABLE salaries (
    emp_no BIGINT NOT NULL,
    salary BIGINT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,

    CONSTRAINT salaries_pkey
        PRIMARY KEY (emp_no, from_date),

    CONSTRAINT salaries_ibfk_1
        FOREIGN KEY (emp_no)
        REFERENCES employees(emp_no)
        ON DELETE CASCADE
);

-- ============================================================
-- TABLA: titles
-- ============================================================

CREATE TABLE titles (
    emp_no BIGINT NOT NULL,
    title VARCHAR(50) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE DEFAULT NULL,

    CONSTRAINT titles_pkey
        PRIMARY KEY (emp_no, title, from_date),

    CONSTRAINT titles_ibfk_1
        FOREIGN KEY (emp_no)
        REFERENCES employees(emp_no)
        ON DELETE CASCADE
);

-- ============================================================
-- VISTA: dept_emp_latest_date
-- ============================================================

CREATE VIEW dept_emp_latest_date AS
SELECT
    emp_no,
    MAX(from_date) AS from_date,
    MAX(to_date) AS to_date
FROM dept_emp
GROUP BY emp_no;

-- ============================================================
-- VISTA: current_dept_emp
-- ============================================================

CREATE VIEW current_dept_emp AS
SELECT
    l.emp_no,
    d.dept_no,
    l.from_date,
    l.to_date
FROM dept_emp d
JOIN dept_emp_latest_date l
    ON d.emp_no = l.emp_no
   AND d.from_date = l.from_date
   AND l.to_date = d.to_date;
