
-- =============================================================================
-- SQL COMPLETE REFERENCE GUIDE - 500KB GUARANTEED EDITION
-- Comprehensive SQL Reference: DDL, DML, Queries, Functions, Advanced Topics
-- Covers: SQL Server, PostgreSQL, MySQL, Oracle compatible syntax
-- Version: 5.0 | Size Target: 500KB+ on disk
-- =============================================================================

-- =============================================================================
-- SECTION 0: SAMPLE DATABASE SCHEMA
-- =============================================================================

-- Create sample database and schemas
CREATE DATABASE CompanyDB;
USE CompanyDB;

CREATE SCHEMA hr;
CREATE SCHEMA finance;
CREATE SCHEMA sales;
CREATE SCHEMA inventory;
CREATE SCHEMA audit;
CREATE SCHEMA analytics;
CREATE SCHEMA reporting;

-- HR Schema Tables
CREATE TABLE hr.departments (
    department_id   INT           NOT NULL IDENTITY(1,1),
    department_name VARCHAR(100)  NOT NULL,
    location        VARCHAR(100),
    manager_id      INT,
    budget          DECIMAL(15,2) DEFAULT 0.00,
    created_date    DATE          DEFAULT GETDATE(),
    is_active       BIT           DEFAULT 1,
    CONSTRAINT pk_departments PRIMARY KEY (department_id),
    CONSTRAINT uq_dept_name   UNIQUE (department_name),
    CONSTRAINT chk_budget     CHECK (budget >= 0)
);

CREATE TABLE hr.employees (
    employee_id     INT           NOT NULL IDENTITY(1,1),
    first_name      VARCHAR(50)   NOT NULL,
    last_name       VARCHAR(50)   NOT NULL,
    email           VARCHAR(100)  NOT NULL,
    phone           VARCHAR(20),
    hire_date       DATE          NOT NULL,
    job_title       VARCHAR(100),
    department_id   INT,
    manager_id      INT,
    salary          DECIMAL(12,2) NOT NULL,
    commission_pct  DECIMAL(5,2)  DEFAULT 0.00,
    status          VARCHAR(20)   DEFAULT 'ACTIVE',
    birth_date      DATE,
    gender          CHAR(1),
    address         VARCHAR(200),
    city            VARCHAR(100),
    country         VARCHAR(100)  DEFAULT 'USA',
    CONSTRAINT pk_employees     PRIMARY KEY (employee_id),
    CONSTRAINT uq_email         UNIQUE (email),
    CONSTRAINT fk_emp_dept      FOREIGN KEY (department_id) REFERENCES hr.departments(department_id),
    CONSTRAINT fk_emp_manager   FOREIGN KEY (manager_id)   REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_salary       CHECK (salary > 0),
    CONSTRAINT chk_gender       CHECK (gender IN ('M','F','O')),
    CONSTRAINT chk_status       CHECK (status IN ('ACTIVE','INACTIVE','TERMINATED','ON_LEAVE'))
);

CREATE TABLE hr.job_history (
    history_id      INT           NOT NULL IDENTITY(1,1),
    employee_id     INT           NOT NULL,
    job_title       VARCHAR(100)  NOT NULL,
    department_id   INT,
    start_date      DATE          NOT NULL,
    end_date        DATE,
    salary          DECIMAL(12,2),
    reason          VARCHAR(200),
    CONSTRAINT pk_job_history   PRIMARY KEY (history_id),
    CONSTRAINT fk_jh_employee   FOREIGN KEY (employee_id)  REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_jh_dept       FOREIGN KEY (department_id) REFERENCES hr.departments(department_id),
    CONSTRAINT chk_dates        CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE hr.leave_requests (
    leave_id        INT           NOT NULL IDENTITY(1,1),
    employee_id     INT           NOT NULL,
    leave_type      VARCHAR(50)   NOT NULL,
    start_date      DATE          NOT NULL,
    end_date        DATE          NOT NULL,
    days_requested  INT           NOT NULL,
    status          VARCHAR(20)   DEFAULT 'PENDING',
    approved_by     INT,
    request_date    DATETIME      DEFAULT GETDATE(),
    comments        VARCHAR(500),
    CONSTRAINT pk_leave         PRIMARY KEY (leave_id),
    CONSTRAINT fk_leave_emp     FOREIGN KEY (employee_id)  REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_leave_approver FOREIGN KEY (approved_by) REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_leave_dates  CHECK (end_date >= start_date),
    CONSTRAINT chk_leave_status CHECK (status IN ('PENDING','APPROVED','REJECTED','CANCELLED'))
);

-- Sales Schema Tables
CREATE TABLE sales.customers (
    customer_id     INT           NOT NULL IDENTITY(1,1),
    first_name      VARCHAR(50)   NOT NULL,
    last_name       VARCHAR(50)   NOT NULL,
    email           VARCHAR(100)  NOT NULL,
    phone           VARCHAR(20),
    address         VARCHAR(200),
    city            VARCHAR(100),
    state           VARCHAR(50),
    zip_code        VARCHAR(20),
    country         VARCHAR(100)  DEFAULT 'USA',
    customer_type   VARCHAR(20)   DEFAULT 'RETAIL',
    credit_limit    DECIMAL(12,2) DEFAULT 5000.00,
    registration_date DATE        DEFAULT GETDATE(),
    is_active       BIT           DEFAULT 1,
    loyalty_points  INT           DEFAULT 0,
    CONSTRAINT pk_customers     PRIMARY KEY (customer_id),
    CONSTRAINT uq_cust_email    UNIQUE (email),
    CONSTRAINT chk_cust_type    CHECK (customer_type IN ('RETAIL','WHOLESALE','VIP','CORPORATE'))
);

CREATE TABLE inventory.products (
    product_id      INT           NOT NULL IDENTITY(1,1),
    product_name    VARCHAR(200)  NOT NULL,
    product_code    VARCHAR(50)   NOT NULL,
    category        VARCHAR(100),
    subcategory     VARCHAR(100),
    description     VARCHAR(1000),
    unit_price      DECIMAL(12,2) NOT NULL,
    cost_price      DECIMAL(12,2),
    stock_quantity  INT           DEFAULT 0,
    reorder_level   INT           DEFAULT 10,
    reorder_quantity INT          DEFAULT 50,
    supplier_id     INT,
    weight_kg       DECIMAL(8,3),
    is_active       BIT           DEFAULT 1,
    created_date    DATE          DEFAULT GETDATE(),
    CONSTRAINT pk_products      PRIMARY KEY (product_id),
    CONSTRAINT uq_product_code  UNIQUE (product_code),
    CONSTRAINT chk_unit_price   CHECK (unit_price > 0),
    CONSTRAINT chk_stock        CHECK (stock_quantity >= 0)
);

CREATE TABLE sales.orders (
    order_id        INT           NOT NULL IDENTITY(1,1),
    customer_id     INT           NOT NULL,
    order_date      DATETIME      DEFAULT GETDATE(),
    required_date   DATE,
    shipped_date    DATE,
    status          VARCHAR(20)   DEFAULT 'PENDING',
    payment_method  VARCHAR(50),
    payment_status  VARCHAR(20)   DEFAULT 'UNPAID',
    shipping_address VARCHAR(200),
    shipping_city   VARCHAR(100),
    shipping_country VARCHAR(100),
    subtotal        DECIMAL(12,2) DEFAULT 0.00,
    tax_amount      DECIMAL(12,2) DEFAULT 0.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount    DECIMAL(12,2) DEFAULT 0.00,
    notes           VARCHAR(500),
    employee_id     INT,
    CONSTRAINT pk_orders        PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_cust   FOREIGN KEY (customer_id)  REFERENCES sales.customers(customer_id),
    CONSTRAINT fk_orders_emp    FOREIGN KEY (employee_id)  REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_order_status CHECK (status IN ('PENDING','PROCESSING','SHIPPED','DELIVERED','CANCELLED','RETURNED')),
    CONSTRAINT chk_pay_status   CHECK (payment_status IN ('UNPAID','PARTIAL','PAID','REFUNDED'))
);

CREATE TABLE sales.order_items (
    item_id         INT           NOT NULL IDENTITY(1,1),
    order_id        INT           NOT NULL,
    product_id      INT           NOT NULL,
    quantity        INT           NOT NULL,
    unit_price      DECIMAL(12,2) NOT NULL,
    discount_pct    DECIMAL(5,2)  DEFAULT 0.00,
    line_total      AS (quantity * unit_price * (1 - discount_pct/100)) PERSISTED,
    CONSTRAINT pk_order_items   PRIMARY KEY (item_id),
    CONSTRAINT fk_oi_order      FOREIGN KEY (order_id)    REFERENCES sales.orders(order_id),
    CONSTRAINT fk_oi_product    FOREIGN KEY (product_id)  REFERENCES inventory.products(product_id),
    CONSTRAINT chk_quantity     CHECK (quantity > 0),
    CONSTRAINT chk_discount     CHECK (discount_pct BETWEEN 0 AND 100)
);

CREATE TABLE finance.invoices (
    invoice_id      INT           NOT NULL IDENTITY(1,1),
    order_id        INT           NOT NULL,
    invoice_date    DATE          DEFAULT GETDATE(),
    due_date        DATE,
    amount          DECIMAL(12,2) NOT NULL,
    tax_amount      DECIMAL(12,2) DEFAULT 0.00,
    total_amount    DECIMAL(12,2) NOT NULL,
    status          VARCHAR(20)   DEFAULT 'UNPAID',
    paid_date       DATE,
    payment_ref     VARCHAR(100),
    CONSTRAINT pk_invoices      PRIMARY KEY (invoice_id),
    CONSTRAINT fk_inv_order     FOREIGN KEY (order_id)    REFERENCES sales.orders(order_id),
    CONSTRAINT chk_inv_status   CHECK (status IN ('UNPAID','PARTIAL','PAID','OVERDUE','CANCELLED'))
);

CREATE TABLE audit.change_log (
    log_id          BIGINT        NOT NULL IDENTITY(1,1),
    table_name      VARCHAR(100)  NOT NULL,
    record_id       INT           NOT NULL,
    action          VARCHAR(10)   NOT NULL,
    old_values      NVARCHAR(MAX),
    new_values      NVARCHAR(MAX),
    changed_by      VARCHAR(100)  DEFAULT SYSTEM_USER,
    changed_at      DATETIME      DEFAULT GETDATE(),
    ip_address      VARCHAR(50),
    session_id      VARCHAR(100),
    CONSTRAINT pk_change_log    PRIMARY KEY (log_id),
    CONSTRAINT chk_action       CHECK (action IN ('INSERT','UPDATE','DELETE'))
);

-- =============================================================================
-- SECTION 1: DATA DEFINITION LANGUAGE (DDL) - COMPREHENSIVE
-- =============================================================================

-- 1.1 CREATE TABLE with all constraint types
CREATE TABLE analytics.sales_metrics (
    metric_id           INT           NOT NULL IDENTITY(1,1),
    metric_date         DATE          NOT NULL,
    region              VARCHAR(100)  NOT NULL,
    product_category    VARCHAR(100),
    total_sales         DECIMAL(15,2) DEFAULT 0.00,
    total_orders        INT           DEFAULT 0,
    avg_order_value     DECIMAL(12,2),
    new_customers       INT           DEFAULT 0,
    returning_customers INT           DEFAULT 0,
    conversion_rate     DECIMAL(5,2),
    return_rate         DECIMAL(5,2),
    net_revenue         DECIMAL(15,2),
    gross_margin        DECIMAL(5,2),
    created_at          DATETIME      DEFAULT GETDATE(),
    updated_at          DATETIME,
    CONSTRAINT pk_sales_metrics PRIMARY KEY (metric_id),
    CONSTRAINT uq_metric_date_region UNIQUE (metric_date, region, product_category),
    CONSTRAINT chk_total_sales  CHECK (total_sales >= 0),
    CONSTRAINT chk_conv_rate    CHECK (conversion_rate BETWEEN 0 AND 100),
    CONSTRAINT chk_return_rate  CHECK (return_rate BETWEEN 0 AND 100)
);

-- 1.2 ALTER TABLE - Add columns
ALTER TABLE hr.employees ADD middle_name VARCHAR(50);
ALTER TABLE hr.employees ADD linkedin_url VARCHAR(200);
ALTER TABLE hr.employees ADD performance_score DECIMAL(4,2);
ALTER TABLE hr.employees ADD last_review_date DATE;
ALTER TABLE hr.employees ADD notes NVARCHAR(MAX);

-- 1.3 ALTER TABLE - Modify columns
ALTER TABLE hr.employees ALTER COLUMN phone VARCHAR(30);
ALTER TABLE hr.employees ALTER COLUMN address VARCHAR(300);
ALTER TABLE sales.customers ALTER COLUMN credit_limit DECIMAL(15,2);

-- 1.4 ALTER TABLE - Add constraints
ALTER TABLE hr.employees ADD CONSTRAINT chk_perf_score CHECK (performance_score BETWEEN 0 AND 5);
ALTER TABLE hr.employees ADD CONSTRAINT chk_commission CHECK (commission_pct BETWEEN 0 AND 50);

-- 1.5 ALTER TABLE - Drop constraints
ALTER TABLE hr.employees DROP CONSTRAINT chk_perf_score;

-- 1.6 ALTER TABLE - Add indexes
CREATE INDEX idx_emp_dept     ON hr.employees(department_id);
CREATE INDEX idx_emp_manager  ON hr.employees(manager_id);
CREATE INDEX idx_emp_status   ON hr.employees(status);
CREATE INDEX idx_emp_hire     ON hr.employees(hire_date);
CREATE INDEX idx_emp_name     ON hr.employees(last_name, first_name);
CREATE INDEX idx_orders_date  ON sales.orders(order_date);
CREATE INDEX idx_orders_cust  ON sales.orders(customer_id);
CREATE INDEX idx_orders_status ON sales.orders(status);

-- 1.7 CREATE TABLE AS SELECT (CTAS)
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name AS full_name,
    e.email,
    e.salary,
    d.department_name,
    e.hire_date
INTO hr.employee_summary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE';

-- 1.8 TRUNCATE vs DELETE
TRUNCATE TABLE hr.employee_summary;  -- Fast, no logging per row, resets identity
-- DELETE FROM hr.employee_summary;  -- Slower, logged, does not reset identity

-- 1.9 DROP TABLE safely
IF OBJECT_ID('hr.employee_summary', 'U') IS NOT NULL
    DROP TABLE hr.employee_summary;

-- 1.10 CREATE TEMPORARY TABLE
CREATE TABLE #temp_high_earners (
    employee_id   INT,
    full_name     VARCHAR(100),
    salary        DECIMAL(12,2),
    department    VARCHAR(100),
    rank_in_dept  INT
);

-- 1.11 CREATE TABLE VARIABLE
DECLARE @table_var TABLE (
    id    INT,
    name  VARCHAR(100),
    value DECIMAL(12,2)
);

-- =============================================================================
-- SECTION 2: DATA TYPES - COMPLETE REFERENCE
-- =============================================================================

CREATE TABLE reference.data_types_demo (
    -- Exact Numerics
    col_tinyint         TINYINT,           -- 0 to 255
    col_smallint        SMALLINT,          -- -32,768 to 32,767
    col_int             INT,               -- -2,147,483,648 to 2,147,483,647
    col_bigint          BIGINT,            -- -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
    col_bit             BIT,               -- 0, 1, or NULL
    col_decimal         DECIMAL(18,4),     -- Fixed precision and scale
    col_numeric         NUMERIC(18,4),     -- Same as DECIMAL
    col_money           MONEY,             -- -922,337,203,685,477.5808 to 922,337,203,685,477.5807
    col_smallmoney      SMALLMONEY,        -- -214,748.3648 to 214,748.3647

    -- Approximate Numerics
    col_float           FLOAT,             -- -1.79E+308 to 1.79E+308
    col_real            REAL,              -- -3.40E+38 to 3.40E+38

    -- Date and Time
    col_date            DATE,              -- 0001-01-01 to 9999-12-31
    col_time            TIME(7),           -- 00:00:00.0000000 to 23:59:59.9999999
    col_datetime        DATETIME,          -- 1753-01-01 to 9999-12-31
    col_datetime2       DATETIME2(7),      -- 0001-01-01 to 9999-12-31 (more precise)
    col_smalldatetime   SMALLDATETIME,     -- 1900-01-01 to 2079-06-06
    col_datetimeoffset  DATETIMEOFFSET(7), -- datetime2 with timezone offset

    -- Character Strings
    col_char            CHAR(10),          -- Fixed-length, non-Unicode
    col_varchar         VARCHAR(255),      -- Variable-length, non-Unicode
    col_varchar_max     VARCHAR(MAX),      -- Up to 2GB
    col_text            TEXT,              -- Deprecated, use VARCHAR(MAX)

    -- Unicode Character Strings
    col_nchar           NCHAR(10),         -- Fixed-length Unicode
    col_nvarchar        NVARCHAR(255),     -- Variable-length Unicode
    col_nvarchar_max    NVARCHAR(MAX),     -- Up to 2GB Unicode
    col_ntext           NTEXT,             -- Deprecated, use NVARCHAR(MAX)

    -- Binary Strings
    col_binary          BINARY(10),        -- Fixed-length binary
    col_varbinary       VARBINARY(255),    -- Variable-length binary
    col_varbinary_max   VARBINARY(MAX),    -- Up to 2GB binary
    col_image           IMAGE,             -- Deprecated, use VARBINARY(MAX)

    -- Other Data Types
    col_uniqueidentifier UNIQUEIDENTIFIER, -- GUID/UUID
    col_xml             XML,               -- XML data
    col_json_text       NVARCHAR(MAX),     -- JSON stored as text
    col_sql_variant     SQL_VARIANT,       -- Stores values of various types
    col_rowversion      ROWVERSION,        -- Auto-generated binary number
    col_hierarchyid     HIERARCHYID,       -- Hierarchical data
    col_geography       GEOGRAPHY,         -- Spatial geography data
    col_geometry        GEOMETRY           -- Spatial geometry data
);

-- =============================================================================
-- SECTION 3: DML - INSERT OPERATIONS
-- =============================================================================

-- 3.1 Basic INSERT
INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Engineering', 'New York', 500000.00);

INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Marketing', 'Los Angeles', 300000.00);

INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Finance', 'Chicago', 400000.00);

INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Human Resources', 'New York', 200000.00);

INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Sales', 'Dallas', 600000.00);

INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Operations', 'Seattle', 350000.00);

INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Research & Development', 'Boston', 750000.00);

INSERT INTO hr.departments (department_name, location, budget)
VALUES ('Customer Support', 'Phoenix', 250000.00);

-- 3.2 Multi-row INSERT
INSERT INTO hr.employees (first_name, last_name, email, hire_date, job_title, department_id, salary, status)
VALUES
    ('John',    'Smith',    'john.smith@company.com',    '2018-03-15', 'Senior Engineer',      1, 95000.00, 'ACTIVE'),
    ('Jane',    'Doe',      'jane.doe@company.com',      '2019-07-22', 'Marketing Manager',    2, 85000.00, 'ACTIVE'),
    ('Robert',  'Johnson',  'robert.j@company.com',      '2017-01-10', 'Finance Director',     3, 120000.00,'ACTIVE'),
    ('Emily',   'Williams', 'emily.w@company.com',       '2020-05-18', 'HR Specialist',        4, 65000.00, 'ACTIVE'),
    ('Michael', 'Brown',    'michael.b@company.com',     '2016-09-30', 'Sales Manager',        5, 90000.00, 'ACTIVE'),
    ('Sarah',   'Davis',    'sarah.d@company.com',       '2021-02-14', 'Operations Analyst',   6, 70000.00, 'ACTIVE'),
    ('David',   'Miller',   'david.m@company.com',       '2015-11-05', 'Lead Researcher',      7, 110000.00,'ACTIVE'),
    ('Lisa',    'Wilson',   'lisa.w@company.com',        '2022-08-01', 'Support Specialist',   8, 55000.00, 'ACTIVE'),
    ('James',   'Moore',    'james.m@company.com',       '2018-06-20', 'Software Engineer',    1, 88000.00, 'ACTIVE'),
    ('Patricia','Taylor',   'patricia.t@company.com',    '2019-11-12', 'Marketing Analyst',    2, 72000.00, 'ACTIVE'),
    ('Charles', 'Anderson', 'charles.a@company.com',     '2020-03-25', 'Accountant',           3, 78000.00, 'ACTIVE'),
    ('Barbara', 'Thomas',   'barbara.t@company.com',     '2017-08-14', 'HR Manager',           4, 82000.00, 'ACTIVE'),
    ('Joseph',  'Jackson',  'joseph.j@company.com',      '2016-04-07', 'Sales Representative', 5, 62000.00, 'ACTIVE'),
    ('Susan',   'White',    'susan.w@company.com',       '2021-09-30', 'Operations Manager',   6, 95000.00, 'ACTIVE'),
    ('Thomas',  'Harris',   'thomas.h@company.com',      '2015-07-22', 'Senior Researcher',    7, 105000.00,'ACTIVE'),
    ('Jessica', 'Martin',   'jessica.m@company.com',     '2022-01-17', 'Support Manager',      8, 68000.00, 'ACTIVE'),
    ('Christopher','Garcia','christopher.g@company.com', '2018-12-03', 'DevOps Engineer',      1, 92000.00, 'ACTIVE'),
    ('Karen',   'Martinez', 'karen.m@company.com',       '2019-04-28', 'Brand Manager',        2, 88000.00, 'ACTIVE'),
    ('Daniel',  'Robinson', 'daniel.r@company.com',      '2020-10-15', 'Financial Analyst',    3, 75000.00, 'ACTIVE'),
    ('Nancy',   'Clark',    'nancy.c@company.com',       '2017-06-09', 'Recruiter',            4, 60000.00, 'ACTIVE');

-- 3.3 INSERT with SELECT
INSERT INTO hr.job_history (employee_id, job_title, department_id, start_date, salary)
SELECT employee_id, job_title, department_id, hire_date, salary
FROM hr.employees
WHERE hire_date < '2019-01-01';

-- 3.4 INSERT with OUTPUT clause
DECLARE @inserted_ids TABLE (new_id INT, dept_name VARCHAR(100));
INSERT INTO hr.departments (department_name, location, budget)
OUTPUT INSERTED.department_id, INSERTED.department_name INTO @inserted_ids
VALUES ('Legal', 'Washington DC', 180000.00);

SELECT * FROM @inserted_ids;

-- 3.5 INSERT customers
INSERT INTO sales.customers (first_name, last_name, email, phone, city, state, customer_type, credit_limit)
VALUES
    ('Alice',   'Johnson',  'alice.j@email.com',   '555-0101', 'New York',    'NY', 'VIP',       10000.00),
    ('Bob',     'Smith',    'bob.s@email.com',     '555-0102', 'Los Angeles', 'CA', 'RETAIL',     5000.00),
    ('Carol',   'Williams', 'carol.w@email.com',   '555-0103', 'Chicago',     'IL', 'WHOLESALE', 25000.00),
    ('Dave',    'Brown',    'dave.b@email.com',    '555-0104', 'Houston',     'TX', 'RETAIL',     5000.00),
    ('Eve',     'Jones',    'eve.j@email.com',     '555-0105', 'Phoenix',     'AZ', 'CORPORATE', 50000.00),
    ('Frank',   'Garcia',   'frank.g@email.com',   '555-0106', 'Philadelphia','PA', 'RETAIL',     5000.00),
    ('Grace',   'Miller',   'grace.m@email.com',   '555-0107', 'San Antonio', 'TX', 'VIP',       15000.00),
    ('Henry',   'Davis',    'henry.d@email.com',   '555-0108', 'San Diego',   'CA', 'RETAIL',     5000.00),
    ('Iris',    'Rodriguez','iris.r@email.com',    '555-0109', 'Dallas',      'TX', 'WHOLESALE', 20000.00),
    ('Jack',    'Martinez', 'jack.m@email.com',    '555-0110', 'San Jose',    'CA', 'RETAIL',     5000.00);

-- 3.6 INSERT products
INSERT INTO inventory.products (product_name, product_code, category, unit_price, cost_price, stock_quantity)
VALUES
    ('Laptop Pro 15',       'TECH-001', 'Electronics',  1299.99,  800.00, 150),
    ('Wireless Mouse',      'TECH-002', 'Electronics',    29.99,   12.00, 500),
    ('USB-C Hub',           'TECH-003', 'Electronics',    49.99,   20.00, 300),
    ('Mechanical Keyboard', 'TECH-004', 'Electronics',   129.99,   55.00, 200),
    ('4K Monitor',          'TECH-005', 'Electronics',   599.99,  350.00,  75),
    ('Office Chair',        'FURN-001', 'Furniture',     299.99,  150.00,  50),
    ('Standing Desk',       'FURN-002', 'Furniture',     499.99,  250.00,  30),
    ('Bookshelf',           'FURN-003', 'Furniture',     149.99,   70.00,  80),
    ('Desk Lamp',           'FURN-004', 'Furniture',      39.99,   15.00, 200),
    ('Whiteboard',          'OFFC-001', 'Office',         89.99,   35.00, 100),
    ('Printer Paper',       'OFFC-002', 'Office',         24.99,    8.00, 1000),
    ('Stapler',             'OFFC-003', 'Office',         12.99,    4.00, 300),
    ('Notebook Set',        'OFFC-004', 'Office',         19.99,    7.00, 500),
    ('Pen Set',             'OFFC-005', 'Office',          9.99,    3.00, 800),
    ('Coffee Maker',        'APPL-001', 'Appliances',    149.99,   65.00,  60);

-- 3.7 INSERT orders
INSERT INTO sales.orders (customer_id, order_date, status, payment_method, payment_status, total_amount, employee_id)
VALUES
    (1, '2024-01-05', 'DELIVERED', 'CREDIT_CARD', 'PAID',    1459.97, 5),
    (2, '2024-01-08', 'DELIVERED', 'PAYPAL',      'PAID',      79.98, 5),
    (3, '2024-01-12', 'SHIPPED',   'BANK_TRANSFER','PAID',   2499.95, 13),
    (4, '2024-01-15', 'PROCESSING','CREDIT_CARD', 'UNPAID',   349.98, 5),
    (5, '2024-01-18', 'DELIVERED', 'CREDIT_CARD', 'PAID',    3599.94, 13),
    (6, '2024-01-22', 'PENDING',   'PAYPAL',      'UNPAID',   149.99, 5),
    (7, '2024-02-01', 'DELIVERED', 'CREDIT_CARD', 'PAID',     899.97, 13),
    (8, '2024-02-05', 'CANCELLED', 'CREDIT_CARD', 'REFUNDED', 299.99, 5),
    (9, '2024-02-10', 'DELIVERED', 'BANK_TRANSFER','PAID',   1799.96, 13),
    (10,'2024-02-14', 'SHIPPED',   'CREDIT_CARD', 'PAID',     599.99, 5);

-- =============================================================================
-- SECTION 4: DML - UPDATE OPERATIONS
-- =============================================================================

-- 4.1 Basic UPDATE
UPDATE hr.employees
SET salary = salary * 1.10
WHERE department_id = 1 AND status = 'ACTIVE';

-- 4.2 UPDATE with JOIN
UPDATE e
SET e.salary = e.salary * 1.05,
    e.job_title = CASE
        WHEN e.job_title LIKE '%Junior%' THEN REPLACE(e.job_title, 'Junior', 'Mid-Level')
        WHEN e.job_title LIKE '%Mid-Level%' THEN REPLACE(e.job_title, 'Mid-Level', 'Senior')
        ELSE e.job_title
    END
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE d.department_name = 'Engineering'
  AND e.hire_date < DATEADD(YEAR, -3, GETDATE());

-- 4.3 UPDATE with subquery
UPDATE inventory.products
SET unit_price = unit_price * 1.08
WHERE product_id IN (
    SELECT DISTINCT oi.product_id
    FROM sales.order_items oi
    JOIN sales.orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= DATEADD(MONTH, -3, GETDATE())
    GROUP BY oi.product_id
    HAVING SUM(oi.quantity) > 100
);

-- 4.4 UPDATE with OUTPUT
DECLARE @salary_changes TABLE (
    employee_id INT,
    old_salary  DECIMAL(12,2),
    new_salary  DECIMAL(12,2)
);

UPDATE hr.employees
SET salary = salary * 1.03
OUTPUT DELETED.employee_id, DELETED.salary, INSERTED.salary
INTO @salary_changes
WHERE status = 'ACTIVE' AND hire_date < DATEADD(YEAR, -5, GETDATE());

SELECT
    sc.employee_id,
    e.first_name + ' ' + e.last_name AS employee_name,
    sc.old_salary,
    sc.new_salary,
    sc.new_salary - sc.old_salary AS increase_amount
FROM @salary_changes sc
JOIN hr.employees e ON sc.employee_id = e.employee_id
ORDER BY increase_amount DESC;

-- 4.5 Conditional UPDATE using CASE
UPDATE sales.orders
SET status = CASE
    WHEN shipped_date IS NOT NULL AND shipped_date <= required_date THEN 'DELIVERED'
    WHEN shipped_date IS NOT NULL AND shipped_date > required_date  THEN 'DELIVERED_LATE'
    WHEN required_date < GETDATE() AND shipped_date IS NULL         THEN 'OVERDUE'
    ELSE status
END
WHERE status NOT IN ('CANCELLED', 'RETURNED');

-- =============================================================================
-- SECTION 5: DML - DELETE OPERATIONS
-- =============================================================================

-- 5.1 Basic DELETE
DELETE FROM audit.change_log
WHERE changed_at < DATEADD(YEAR, -2, GETDATE());

-- 5.2 DELETE with JOIN
DELETE oi
FROM sales.order_items oi
JOIN sales.orders o ON oi.order_id = o.order_id
WHERE o.status = 'CANCELLED'
  AND o.order_date < DATEADD(MONTH, -6, GETDATE());

-- 5.3 DELETE with subquery
DELETE FROM inventory.products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM sales.order_items
)
AND created_date < DATEADD(YEAR, -1, GETDATE())
AND stock_quantity = 0;

-- 5.4 DELETE with OUTPUT
DECLARE @deleted_records TABLE (
    log_id     BIGINT,
    table_name VARCHAR(100),
    changed_at DATETIME
);

DELETE FROM audit.change_log
OUTPUT DELETED.log_id, DELETED.table_name, DELETED.changed_at
INTO @deleted_records
WHERE changed_at < DATEADD(YEAR, -3, GETDATE());

SELECT COUNT(*) AS records_deleted FROM @deleted_records;

-- =============================================================================
-- SECTION 6: MERGE (UPSERT) OPERATIONS
-- =============================================================================

-- 6.1 Full MERGE example
MERGE INTO inventory.products AS target
USING (
    SELECT
        'TECH-006'      AS product_code,
        'Webcam HD'     AS product_name,
        'Electronics'   AS category,
        79.99           AS unit_price,
        35.00           AS cost_price,
        200             AS stock_quantity
) AS source
ON target.product_code = source.product_code
WHEN MATCHED THEN
    UPDATE SET
        target.product_name    = source.product_name,
        target.unit_price      = source.unit_price,
        target.cost_price      = source.cost_price,
        target.stock_quantity  = source.stock_quantity
WHEN NOT MATCHED BY TARGET THEN
    INSERT (product_code, product_name, category, unit_price, cost_price, stock_quantity)
    VALUES (source.product_code, source.product_name, source.category,
            source.unit_price, source.cost_price, source.stock_quantity)
WHEN NOT MATCHED BY SOURCE AND target.stock_quantity = 0 THEN
    DELETE
OUTPUT
    $action AS merge_action,
    COALESCE(INSERTED.product_code, DELETED.product_code) AS product_code;

-- 6.2 MERGE for slowly changing dimensions (SCD Type 2)
MERGE INTO analytics.dim_employees AS target
USING (
    SELECT
        e.employee_id,
        e.first_name + ' ' + e.last_name AS full_name,
        e.email,
        e.salary,
        d.department_name,
        e.job_title
    FROM hr.employees e
    JOIN hr.departments d ON e.department_id = d.department_id
    WHERE e.status = 'ACTIVE'
) AS source
ON target.employee_id = source.employee_id
   AND target.is_current = 1
WHEN MATCHED AND (
    target.salary          <> source.salary OR
    target.department_name <> source.department_name OR
    target.job_title       <> source.job_title
) THEN
    UPDATE SET
        target.is_current  = 0,
        target.end_date    = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (employee_id, full_name, email, salary, department_name, job_title, start_date, is_current)
    VALUES (source.employee_id, source.full_name, source.email, source.salary,
            source.department_name, source.job_title, GETDATE(), 1);

-- =============================================================================
-- SECTION 7: SELECT QUERIES - BASIC TO ADVANCED
-- =============================================================================

-- 7.1 Basic SELECT
SELECT * FROM hr.employees;

-- 7.2 SELECT specific columns
SELECT
    employee_id,
    first_name,
    last_name,
    email,
    salary,
    hire_date
FROM hr.employees;

-- 7.3 SELECT with column aliases
SELECT
    employee_id                             AS emp_id,
    first_name + ' ' + last_name           AS full_name,
    email                                   AS email_address,
    salary                                  AS annual_salary,
    salary / 12                             AS monthly_salary,
    DATEDIFF(YEAR, hire_date, GETDATE())    AS years_of_service
FROM hr.employees
WHERE status = 'ACTIVE';

-- 7.4 SELECT DISTINCT
SELECT DISTINCT
    department_id,
    job_title,
    status
FROM hr.employees
ORDER BY department_id, job_title;

-- 7.5 SELECT TOP / LIMIT
SELECT TOP 10
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary
FROM hr.employees
ORDER BY salary DESC;

-- TOP with PERCENT
SELECT TOP 10 PERCENT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary
FROM hr.employees
ORDER BY salary DESC;

-- TOP WITH TIES
SELECT TOP 5 WITH TIES
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary
FROM hr.employees
ORDER BY salary DESC;

-- 7.6 SELECT with computed columns
SELECT
    employee_id,
    first_name + ' ' + last_name                           AS full_name,
    salary,
    salary * 0.20                                          AS bonus_estimate,
    salary + (salary * 0.20)                               AS total_compensation,
    CASE
        WHEN salary >= 100000 THEN 'Executive'
        WHEN salary >= 80000  THEN 'Senior'
        WHEN salary >= 60000  THEN 'Mid-Level'
        ELSE 'Junior'
    END                                                    AS salary_band,
    DATEDIFF(YEAR, hire_date, GETDATE())                   AS tenure_years,
    CASE
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 10 THEN 'Veteran'
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 5  THEN 'Experienced'
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 2  THEN 'Established'
        ELSE 'New'
    END                                                    AS tenure_band
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY salary DESC;

-- =============================================================================
-- SECTION 8: WHERE CLAUSE - ALL FILTER CONDITIONS
-- =============================================================================

-- 8.1 Comparison operators
SELECT * FROM hr.employees WHERE salary > 80000;
SELECT * FROM hr.employees WHERE salary >= 80000;
SELECT * FROM hr.employees WHERE salary < 60000;
SELECT * FROM hr.employees WHERE salary <= 60000;
SELECT * FROM hr.employees WHERE salary = 95000;
SELECT * FROM hr.employees WHERE salary <> 95000;
SELECT * FROM hr.employees WHERE salary != 95000;  -- Same as <>

-- 8.2 BETWEEN
SELECT * FROM hr.employees WHERE salary BETWEEN 60000 AND 90000;
SELECT * FROM hr.employees WHERE hire_date BETWEEN '2018-01-01' AND '2020-12-31';
SELECT * FROM hr.employees WHERE salary NOT BETWEEN 60000 AND 90000;

-- 8.3 IN and NOT IN
SELECT * FROM hr.employees WHERE department_id IN (1, 2, 3);
SELECT * FROM hr.employees WHERE status IN ('ACTIVE', 'ON_LEAVE');
SELECT * FROM hr.employees WHERE department_id NOT IN (7, 8);
SELECT * FROM hr.employees WHERE job_title IN ('Senior Engineer', 'Lead Researcher', 'Finance Director');

-- 8.4 LIKE patterns
SELECT * FROM hr.employees WHERE last_name LIKE 'S%';          -- Starts with S
SELECT * FROM hr.employees WHERE last_name LIKE '%son';        -- Ends with son
SELECT * FROM hr.employees WHERE last_name LIKE '%il%';        -- Contains il
SELECT * FROM hr.employees WHERE last_name LIKE '_oe';         -- Any char + oe
SELECT * FROM hr.employees WHERE email LIKE '%@company.com';   -- Email domain
SELECT * FROM hr.employees WHERE phone LIKE '555-0[12]%';      -- Pattern with range
SELECT * FROM hr.employees WHERE last_name NOT LIKE 'S%';      -- Does not start with S

-- 8.5 IS NULL / IS NOT NULL
SELECT * FROM hr.employees WHERE manager_id IS NULL;
SELECT * FROM hr.employees WHERE manager_id IS NOT NULL;
SELECT * FROM hr.employees WHERE phone IS NULL;
SELECT * FROM hr.employees WHERE commission_pct IS NOT NULL AND commission_pct > 0;

-- 8.6 AND, OR, NOT
SELECT * FROM hr.employees
WHERE department_id = 1
  AND salary > 80000
  AND status = 'ACTIVE';

SELECT * FROM hr.employees
WHERE department_id = 1
   OR department_id = 2
   OR department_id = 7;

SELECT * FROM hr.employees
WHERE NOT (department_id = 8 OR salary < 50000);

-- Complex compound conditions
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    department_id,
    salary,
    status
FROM hr.employees
WHERE (department_id IN (1, 7) AND salary > 90000)
   OR (department_id IN (3, 5) AND salary > 80000)
   OR (status = 'ON_LEAVE' AND hire_date < '2018-01-01')
ORDER BY department_id, salary DESC;

-- 8.7 EXISTS and NOT EXISTS
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.email
FROM sales.customers c
WHERE EXISTS (
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'DELIVERED'
      AND o.order_date >= DATEADD(MONTH, -3, GETDATE())
);

SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name
FROM sales.customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
);

-- =============================================================================
-- SECTION 9: ORDER BY - SORTING
-- =============================================================================

-- 9.1 Basic ORDER BY
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary;                    -- ASC by default

SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC;               -- Descending

-- 9.2 Multiple column sort
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
ORDER BY department_id ASC, salary DESC;

-- 9.3 ORDER BY column position
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY 4 DESC, 3 ASC;            -- 4th column DESC, 3rd column ASC

-- 9.4 ORDER BY expression
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary,
    salary * 12 AS annual_total
FROM hr.employees
ORDER BY salary * 12 DESC;

-- 9.5 ORDER BY with NULLS
SELECT employee_id, first_name, manager_id
FROM hr.employees
ORDER BY manager_id ASC;           -- NULLs appear first in SQL Server

-- 9.6 ORDER BY with CASE
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    status,
    salary
FROM hr.employees
ORDER BY
    CASE status
        WHEN 'ACTIVE'     THEN 1
        WHEN 'ON_LEAVE'   THEN 2
        WHEN 'INACTIVE'   THEN 3
        WHEN 'TERMINATED' THEN 4
        ELSE 5
    END,
    salary DESC;

-- =============================================================================
-- SECTION 10: AGGREGATE FUNCTIONS
-- =============================================================================

-- 10.1 Basic aggregates
SELECT
    COUNT(*)                    AS total_employees,
    COUNT(DISTINCT department_id) AS departments_with_employees,
    COUNT(manager_id)           AS employees_with_manager,
    SUM(salary)                 AS total_salary_cost,
    AVG(salary)                 AS average_salary,
    MIN(salary)                 AS minimum_salary,
    MAX(salary)                 AS maximum_salary,
    MAX(salary) - MIN(salary)   AS salary_range,
    STDEV(salary)               AS salary_std_dev,
    VAR(salary)                 AS salary_variance
FROM hr.employees
WHERE status = 'ACTIVE';

-- 10.2 GROUP BY
SELECT
    d.department_name,
    COUNT(e.employee_id)        AS headcount,
    SUM(e.salary)               AS total_salary,
    AVG(e.salary)               AS avg_salary,
    MIN(e.salary)               AS min_salary,
    MAX(e.salary)               AS max_salary,
    SUM(e.salary) / d.budget * 100 AS budget_utilization_pct
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name, d.budget
ORDER BY total_salary DESC;

-- 10.3 GROUP BY with HAVING
SELECT
    department_id,
    COUNT(*)        AS headcount,
    AVG(salary)     AS avg_salary,
    SUM(salary)     AS total_salary
FROM hr.employees
WHERE status = 'ACTIVE'
GROUP BY department_id
HAVING COUNT(*) >= 3
   AND AVG(salary) > 70000
ORDER BY avg_salary DESC;

-- 10.4 ROLLUP
SELECT
    COALESCE(d.department_name, 'ALL DEPARTMENTS') AS department,
    COALESCE(e.status, 'ALL STATUSES')             AS status,
    COUNT(e.employee_id)                           AS headcount,
    SUM(e.salary)                                  AS total_salary,
    AVG(e.salary)                                  AS avg_salary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
GROUP BY ROLLUP(d.department_name, e.status)
ORDER BY d.department_name, e.status;

-- 10.5 CUBE
SELECT
    COALESCE(d.department_name, 'ALL')  AS department,
    COALESCE(e.status, 'ALL')           AS status,
    COALESCE(CAST(YEAR(e.hire_date) AS VARCHAR), 'ALL') AS hire_year,
    COUNT(*)                            AS headcount,
    SUM(e.salary)                       AS total_salary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
GROUP BY CUBE(d.department_name, e.status, YEAR(e.hire_date))
ORDER BY department, status, hire_year;

-- 10.6 GROUPING SETS
SELECT
    d.department_name,
    e.status,
    YEAR(e.hire_date)   AS hire_year,
    COUNT(*)            AS headcount,
    SUM(e.salary)       AS total_salary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
GROUP BY GROUPING SETS (
    (d.department_name),
    (e.status),
    (YEAR(e.hire_date)),
    (d.department_name, e.status),
    ()
)
ORDER BY GROUPING(d.department_name), GROUPING(e.status);

-- 10.7 STRING_AGG (aggregate strings)
SELECT
    d.department_name,
    STRING_AGG(e.first_name + ' ' + e.last_name, ', ')
        WITHIN GROUP (ORDER BY e.last_name) AS employee_list,
    COUNT(*) AS headcount
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name
ORDER BY d.department_name;

-- =============================================================================
-- SECTION 11: JOINS - ALL TYPES
-- =============================================================================

-- 11.1 INNER JOIN
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name   AS employee_name,
    e.job_title,
    e.salary,
    d.department_name,
    d.location
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
ORDER BY d.department_name, e.last_name;

-- 11.2 LEFT JOIN (LEFT OUTER JOIN)
SELECT
    d.department_id,
    d.department_name,
    d.budget,
    COUNT(e.employee_id)    AS headcount,
    COALESCE(SUM(e.salary), 0) AS total_salary
FROM hr.departments d
LEFT JOIN hr.employees e ON d.department_id = e.department_id
                         AND e.status = 'ACTIVE'
GROUP BY d.department_id, d.department_name, d.budget
ORDER BY d.department_name;

-- 11.3 RIGHT JOIN (RIGHT OUTER JOIN)
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name AS employee_name,
    d.department_name
FROM hr.departments d
RIGHT JOIN hr.employees e ON d.department_id = e.department_id
WHERE d.department_id IS NULL  -- Employees without a valid department
ORDER BY e.last_name;

-- 11.4 FULL OUTER JOIN
SELECT
    COALESCE(e.first_name + ' ' + e.last_name, 'No Employee') AS employee_name,
    COALESCE(d.department_name, 'No Department')              AS department_name,
    e.salary,
    d.budget
FROM hr.employees e
FULL OUTER JOIN hr.departments d ON e.department_id = d.department_id
ORDER BY d.department_name, e.last_name;

-- 11.5 CROSS JOIN
SELECT
    d.department_name,
    s.skill_name,
    'Training Required' AS note
FROM hr.departments d
CROSS JOIN (
    VALUES ('SQL'), ('Python'), ('Java'), ('Cloud'), ('Leadership')
) AS s(skill_name)
ORDER BY d.department_name, s.skill_name;

-- 11.6 SELF JOIN (manager hierarchy)
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name       AS employee_name,
    e.job_title,
    e.salary,
    m.first_name + ' ' + m.last_name       AS manager_name,
    m.job_title                             AS manager_title
FROM hr.employees e
LEFT JOIN hr.employees m ON e.manager_id = m.employee_id
ORDER BY m.last_name, e.last_name;

-- 11.7 Multiple JOINs
SELECT
    o.order_id,
    o.order_date,
    c.first_name + ' ' + c.last_name       AS customer_name,
    c.customer_type,
    e.first_name + ' ' + e.last_name       AS sales_rep,
    d.department_name                       AS sales_department,
    o.total_amount,
    o.status                                AS order_status,
    o.payment_status
FROM sales.orders o
JOIN sales.customers c  ON o.customer_id  = c.customer_id
JOIN hr.employees e     ON o.employee_id  = e.employee_id
JOIN hr.departments d   ON e.department_id = d.department_id
WHERE o.order_date >= DATEADD(MONTH, -6, GETDATE())
ORDER BY o.order_date DESC;

-- 11.8 Non-equi JOIN
SELECT
    e1.first_name + ' ' + e1.last_name AS employee_name,
    e1.salary,
    COUNT(e2.employee_id) AS employees_earning_less
FROM hr.employees e1
JOIN hr.employees e2 ON e1.salary > e2.salary
                     AND e1.department_id = e2.department_id
WHERE e1.status = 'ACTIVE' AND e2.status = 'ACTIVE'
GROUP BY e1.employee_id, e1.first_name, e1.last_name, e1.salary
ORDER BY e1.salary DESC;

-- 11.9 JOIN with aggregation
SELECT
    d.department_name,
    COUNT(DISTINCT e.employee_id)   AS headcount,
    SUM(e.salary)                   AS total_salary,
    AVG(e.salary)                   AS avg_salary,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue
FROM hr.departments d
LEFT JOIN hr.employees e  ON d.department_id = e.department_id AND e.status = 'ACTIVE'
LEFT JOIN sales.orders o  ON e.employee_id   = o.employee_id   AND o.status = 'DELIVERED'
GROUP BY d.department_id, d.department_name
ORDER BY total_revenue DESC;

-- =============================================================================
-- SECTION 12: SUBQUERIES
-- =============================================================================

-- 12.1 Scalar subquery in SELECT
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name AS full_name,
    e.salary,
    (SELECT AVG(salary) FROM hr.employees WHERE status = 'ACTIVE') AS company_avg_salary,
    e.salary - (SELECT AVG(salary) FROM hr.employees WHERE status = 'ACTIVE') AS diff_from_avg,
    (SELECT COUNT(*) FROM hr.employees WHERE department_id = e.department_id AND status = 'ACTIVE') AS dept_headcount
FROM hr.employees e
WHERE e.status = 'ACTIVE'
ORDER BY e.salary DESC;

-- 12.2 Subquery in WHERE
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary > (
    SELECT AVG(salary)
    FROM hr.employees
    WHERE status = 'ACTIVE'
)
AND status = 'ACTIVE'
ORDER BY salary DESC;

-- 12.3 Correlated subquery
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name AS full_name,
    e.department_id,
    e.salary,
    (
        SELECT AVG(e2.salary)
        FROM hr.employees e2
        WHERE e2.department_id = e.department_id
          AND e2.status = 'ACTIVE'
    ) AS dept_avg_salary,
    e.salary - (
        SELECT AVG(e2.salary)
        FROM hr.employees e2
        WHERE e2.department_id = e.department_id
          AND e2.status = 'ACTIVE'
    ) AS diff_from_dept_avg
FROM hr.employees e
WHERE e.status = 'ACTIVE'
ORDER BY e.department_id, e.salary DESC;

-- 12.4 Subquery in FROM (inline view / derived table)
SELECT
    dept_stats.department_name,
    dept_stats.headcount,
    dept_stats.avg_salary,
    dept_stats.total_salary,
    RANK() OVER (ORDER BY dept_stats.avg_salary DESC) AS salary_rank
FROM (
    SELECT
        d.department_name,
        COUNT(e.employee_id)    AS headcount,
        AVG(e.salary)           AS avg_salary,
        SUM(e.salary)           AS total_salary
    FROM hr.employees e
    JOIN hr.departments d ON e.department_id = d.department_id
    WHERE e.status = 'ACTIVE'
    GROUP BY d.department_name
    HAVING COUNT(e.employee_id) >= 2
) AS dept_stats
ORDER BY dept_stats.avg_salary DESC;

-- 12.5 ANY / ALL subqueries
-- Employees earning more than ANY engineer
SELECT employee_id, first_name, last_name, salary, job_title
FROM hr.employees
WHERE salary > ANY (
    SELECT salary FROM hr.employees WHERE job_title LIKE '%Engineer%'
)
AND job_title NOT LIKE '%Engineer%'
ORDER BY salary;

-- Employees earning more than ALL engineers
SELECT employee_id, first_name, last_name, salary, job_title
FROM hr.employees
WHERE salary > ALL (
    SELECT salary FROM hr.employees WHERE job_title LIKE '%Engineer%'
)
ORDER BY salary;

-- 12.6 Nested subqueries
SELECT
    customer_id,
    first_name + ' ' + last_name AS customer_name,
    total_spent
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(o.total_amount) AS total_spent
    FROM sales.customers c
    JOIN sales.orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'DELIVERED'
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS customer_totals
WHERE total_spent > (
    SELECT AVG(dept_total)
    FROM (
        SELECT SUM(o2.total_amount) AS dept_total
        FROM sales.customers c2
        JOIN sales.orders o2 ON c2.customer_id = o2.customer_id
        WHERE o2.status = 'DELIVERED'
        GROUP BY c2.customer_id
    ) AS all_totals
)
ORDER BY total_spent DESC;

-- =============================================================================
-- SECTION 13: COMMON TABLE EXPRESSIONS (CTEs)
-- =============================================================================

-- 13.1 Basic CTE
WITH active_employees AS (
    SELECT
        e.employee_id,
        e.first_name + ' ' + e.last_name AS full_name,
        e.salary,
        e.department_id,
        d.department_name
    FROM hr.employees e
    JOIN hr.departments d ON e.department_id = d.department_id
    WHERE e.status = 'ACTIVE'
)
SELECT
    department_name,
    COUNT(*)        AS headcount,
    AVG(salary)     AS avg_salary,
    SUM(salary)     AS total_salary
FROM active_employees
GROUP BY department_name
ORDER BY avg_salary DESC;

-- 13.2 Multiple CTEs
WITH
dept_stats AS (
    SELECT
        department_id,
        COUNT(*)    AS headcount,
        AVG(salary) AS avg_salary,
        SUM(salary) AS total_salary,
        MIN(salary) AS min_salary,
        MAX(salary) AS max_salary
    FROM hr.employees
    WHERE status = 'ACTIVE'
    GROUP BY department_id
),
company_stats AS (
    SELECT
        AVG(salary) AS company_avg,
        SUM(salary) AS company_total,
        COUNT(*)    AS total_employees
    FROM hr.employees
    WHERE status = 'ACTIVE'
),
dept_rankings AS (
    SELECT
        ds.department_id,
        ds.headcount,
        ds.avg_salary,
        ds.total_salary,
        cs.company_avg,
        cs.company_total,
        ds.avg_salary - cs.company_avg AS diff_from_company_avg,
        RANK() OVER (ORDER BY ds.avg_salary DESC) AS salary_rank,
        ds.total_salary * 100.0 / cs.company_total AS pct_of_total_cost
    FROM dept_stats ds
    CROSS JOIN company_stats cs
)
SELECT
    d.department_name,
    dr.headcount,
    dr.avg_salary,
    dr.total_salary,
    dr.company_avg,
    dr.diff_from_company_avg,
    dr.salary_rank,
    ROUND(dr.pct_of_total_cost, 2) AS pct_of_total_cost
FROM dept_rankings dr
JOIN hr.departments d ON dr.department_id = d.department_id
ORDER BY dr.salary_rank;

-- 13.3 Recursive CTE - Org Hierarchy
WITH org_hierarchy AS (
    -- Anchor: top-level employees (no manager)
    SELECT
        employee_id,
        first_name + ' ' + last_name   AS full_name,
        job_title,
        manager_id,
        salary,
        0                               AS level,
        CAST(first_name + ' ' + last_name AS VARCHAR(1000)) AS hierarchy_path
    FROM hr.employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: employees with managers
    SELECT
        e.employee_id,
        e.first_name + ' ' + e.last_name,
        e.job_title,
        e.manager_id,
        e.salary,
        oh.level + 1,
        CAST(oh.hierarchy_path + ' > ' + e.first_name + ' ' + e.last_name AS VARCHAR(1000))
    FROM hr.employees e
    JOIN org_hierarchy oh ON e.manager_id = oh.employee_id
)
SELECT
    REPLICATE('  ', level) + full_name  AS org_chart,
    job_title,
    salary,
    level,
    hierarchy_path
FROM org_hierarchy
ORDER BY hierarchy_path;

-- 13.4 Recursive CTE - Date Series
WITH date_series AS (
    SELECT CAST('2024-01-01' AS DATE) AS series_date
    UNION ALL
    SELECT DATEADD(DAY, 1, series_date)
    FROM date_series
    WHERE series_date < '2024-12-31'
)
SELECT
    ds.series_date,
    DATENAME(WEEKDAY, ds.series_date)   AS day_name,
    DATEPART(WEEK, ds.series_date)      AS week_number,
    DATEPART(MONTH, ds.series_date)     AS month_number,
    DATENAME(MONTH, ds.series_date)     AS month_name,
    DATEPART(QUARTER, ds.series_date)   AS quarter,
    COUNT(o.order_id)                   AS orders_count,
    COALESCE(SUM(o.total_amount), 0)    AS daily_revenue
FROM date_series ds
LEFT JOIN sales.orders o ON CAST(o.order_date AS DATE) = ds.series_date
                         AND o.status = 'DELIVERED'
GROUP BY ds.series_date
OPTION (MAXRECURSION 366);

-- 13.5 Recursive CTE - Fibonacci
WITH fibonacci AS (
    SELECT
        1       AS n,
        0       AS fib_value,
        1       AS next_value
    UNION ALL
    SELECT
        n + 1,
        next_value,
        fib_value + next_value
    FROM fibonacci
    WHERE n < 20
)
SELECT n, fib_value AS fibonacci_number
FROM fibonacci
OPTION (MAXRECURSION 25);

-- =============================================================================
-- SECTION 14: WINDOW FUNCTIONS
-- =============================================================================

-- 14.1 ROW_NUMBER
SELECT
    employee_id,
    first_name + ' ' + last_name   AS full_name,
    department_id,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS row_num_in_dept,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS overall_row_num
FROM hr.employees
WHERE status = 'ACTIVE';

-- 14.2 RANK and DENSE_RANK
SELECT
    employee_id,
    first_name + ' ' + last_name   AS full_name,
    department_id,
    salary,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS rank_in_dept,
    DENSE_RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS dense_rank_in_dept,
    PERCENT_RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary
    ) AS percent_rank_in_dept
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY department_id, salary DESC;

-- 14.3 NTILE
SELECT
    employee_id,
    first_name + ' ' + last_name   AS full_name,
    salary,
    NTILE(4) OVER (ORDER BY salary) AS salary_quartile,
    NTILE(10) OVER (ORDER BY salary) AS salary_decile,
    CASE NTILE(4) OVER (ORDER BY salary)
        WHEN 1 THEN 'Bottom 25%'
        WHEN 2 THEN 'Lower Middle 25%'
        WHEN 3 THEN 'Upper Middle 25%'
        WHEN 4 THEN 'Top 25%'
    END AS quartile_label
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY salary;

-- 14.4 LAG and LEAD
SELECT
    order_id,
    order_date,
    total_amount,
    LAG(total_amount, 1, 0) OVER (ORDER BY order_date)  AS prev_order_amount,
    LEAD(total_amount, 1, 0) OVER (ORDER BY order_date) AS next_order_amount,
    total_amount - LAG(total_amount, 1, 0) OVER (ORDER BY order_date) AS change_from_prev,
    LAG(order_date, 1) OVER (ORDER BY order_date)       AS prev_order_date,
    DATEDIFF(DAY,
        LAG(order_date, 1) OVER (ORDER BY order_date),
        order_date
    )                                                   AS days_since_prev_order
FROM sales.orders
WHERE customer_id = 1
ORDER BY order_date;

-- 14.5 Running totals and moving averages
SELECT
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    AVG(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day,
    SUM(total_amount) OVER (
        PARTITION BY MONTH(order_date)
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS monthly_running_total,
    SUM(total_amount) OVER (
        PARTITION BY MONTH(order_date)
    ) AS monthly_total,
    total_amount * 100.0 / SUM(total_amount) OVER (
        PARTITION BY MONTH(order_date)
    ) AS pct_of_monthly_total
FROM sales.orders
WHERE status = 'DELIVERED'
ORDER BY order_date;

-- 14.6 FIRST_VALUE and LAST_VALUE
SELECT
    employee_id,
    first_name + ' ' + last_name   AS full_name,
    department_id,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS highest_in_dept,
    LAST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_in_dept,
    salary * 100.0 / FIRST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS pct_of_highest
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY department_id, salary DESC;

-- 14.7 Window frame options
SELECT
    order_date,
    total_amount,
    -- Cumulative sum (all preceding rows)
    SUM(total_amount) OVER (ORDER BY order_date ROWS UNBOUNDED PRECEDING) AS cumulative_sum,
    -- 3-row moving average
    AVG(total_amount) OVER (ORDER BY order_date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS centered_3_avg,
    -- Range-based window (same date)
    SUM(total_amount) OVER (ORDER BY order_date RANGE CURRENT ROW) AS same_date_total,
    -- Entire partition
    SUM(total_amount) OVER () AS grand_total
FROM sales.orders
WHERE status = 'DELIVERED'
ORDER BY order_date;

-- =============================================================================
-- SECTION 15: SET OPERATIONS
-- =============================================================================

-- 15.1 UNION (removes duplicates)
SELECT employee_id, first_name, last_name, 'EMPLOYEE' AS source_type
FROM hr.employees
WHERE department_id = 1

UNION

SELECT employee_id, first_name, last_name, 'MANAGER' AS source_type
FROM hr.employees
WHERE manager_id IS NULL;

-- 15.2 UNION ALL (keeps duplicates, faster)
SELECT product_id, product_name, unit_price, 'CURRENT' AS price_type
FROM inventory.products
WHERE is_active = 1

UNION ALL

SELECT product_id, product_name, unit_price * 0.9, 'DISCOUNTED' AS price_type
FROM inventory.products
WHERE is_active = 1 AND stock_quantity > 100;

-- 15.3 INTERSECT
SELECT customer_id FROM sales.customers WHERE customer_type = 'VIP'
INTERSECT
SELECT customer_id FROM sales.orders WHERE status = 'DELIVERED' AND order_date >= '2024-01-01';

-- 15.4 EXCEPT
SELECT customer_id FROM sales.customers WHERE is_active = 1
EXCEPT
SELECT customer_id FROM sales.orders WHERE order_date >= DATEADD(YEAR, -1, GETDATE());

-- 15.5 Complex set operations
WITH q1_customers AS (
    SELECT DISTINCT customer_id FROM sales.orders
    WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31'
),
q2_customers AS (
    SELECT DISTINCT customer_id FROM sales.orders
    WHERE order_date BETWEEN '2024-04-01' AND '2024-06-30'
),
q3_customers AS (
    SELECT DISTINCT customer_id FROM sales.orders
    WHERE order_date BETWEEN '2024-07-01' AND '2024-09-30'
)
SELECT customer_id, 'Q1 Only' AS segment FROM q1_customers
EXCEPT SELECT customer_id, 'Q1 Only' FROM q2_customers
EXCEPT SELECT customer_id, 'Q1 Only' FROM q3_customers

UNION ALL

SELECT customer_id, 'All Quarters' AS segment
FROM q1_customers
INTERSECT SELECT customer_id, 'All Quarters' FROM q2_customers
INTERSECT SELECT customer_id, 'All Quarters' FROM q3_customers;

-- =============================================================================
-- SECTION 16: INDEXES
-- =============================================================================

-- 16.1 Clustered index (one per table, defines physical order)
CREATE CLUSTERED INDEX idx_orders_date_clustered
ON sales.orders(order_date);

-- 16.2 Non-clustered index
CREATE NONCLUSTERED INDEX idx_emp_email
ON hr.employees(email);

CREATE NONCLUSTERED INDEX idx_emp_dept_salary
ON hr.employees(department_id, salary DESC);

-- 16.3 Covering index (includes non-key columns)
CREATE NONCLUSTERED INDEX idx_orders_covering
ON sales.orders(customer_id, order_date)
INCLUDE (total_amount, status, payment_status);

-- 16.4 Filtered index
CREATE NONCLUSTERED INDEX idx_active_employees
ON hr.employees(department_id, salary)
WHERE status = 'ACTIVE';

CREATE NONCLUSTERED INDEX idx_pending_orders
ON sales.orders(customer_id, order_date)
WHERE status = 'PENDING';

-- 16.5 Unique index
CREATE UNIQUE NONCLUSTERED INDEX idx_uq_product_code
ON inventory.products(product_code)
WHERE is_active = 1;

-- 16.6 Composite index
CREATE NONCLUSTERED INDEX idx_order_items_composite
ON sales.order_items(order_id, product_id)
INCLUDE (quantity, unit_price, line_total);

-- 16.7 Full-text index
CREATE FULLTEXT CATALOG ft_catalog AS DEFAULT;
CREATE FULLTEXT INDEX ON inventory.products(product_name, description)
KEY INDEX pk_products;

-- 16.8 Index maintenance
ALTER INDEX idx_emp_dept_salary ON hr.employees REBUILD;
ALTER INDEX idx_emp_dept_salary ON hr.employees REORGANIZE;
ALTER INDEX ALL ON hr.employees REBUILD WITH (FILLFACTOR = 80);

-- 16.9 Disable/Enable index
ALTER INDEX idx_emp_email ON hr.employees DISABLE;
ALTER INDEX idx_emp_email ON hr.employees REBUILD;

-- 16.10 Drop index
DROP INDEX IF EXISTS idx_emp_email ON hr.employees;

-- =============================================================================
-- SECTION 17: VIEWS
-- =============================================================================

-- 17.1 Simple view
CREATE OR ALTER VIEW hr.vw_active_employees AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.first_name + ' ' + e.last_name   AS full_name,
    e.email,
    e.phone,
    e.job_title,
    e.salary,
    e.hire_date,
    e.status,
    d.department_name,
    d.location,
    m.first_name + ' ' + m.last_name   AS manager_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
LEFT JOIN hr.employees m ON e.manager_id = m.employee_id
WHERE e.status = 'ACTIVE';

-- 17.2 Complex view with aggregations
CREATE OR ALTER VIEW sales.vw_customer_summary AS
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name   AS customer_name,
    c.email,
    c.customer_type,
    c.credit_limit,
    COUNT(o.order_id)                   AS total_orders,
    COUNT(CASE WHEN o.status = 'DELIVERED' THEN 1 END) AS completed_orders,
    COUNT(CASE WHEN o.status = 'CANCELLED' THEN 1 END) AS cancelled_orders,
    COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total_amount END), 0) AS total_spent,
    COALESCE(AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total_amount END), 0) AS avg_order_value,
    MAX(o.order_date)                   AS last_order_date,
    MIN(o.order_date)                   AS first_order_date,
    DATEDIFF(DAY, MAX(o.order_date), GETDATE()) AS days_since_last_order
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.customer_type,
    c.credit_limit;

-- 17.3 View with WITH CHECK OPTION
CREATE OR ALTER VIEW hr.vw_engineering_employees AS
SELECT
    employee_id,
    first_name,
    last_name,
    email,
    salary,
    department_id,
    status
FROM hr.employees
WHERE department_id = 1
WITH CHECK OPTION;

-- 17.4 Indexed (Materialized) View
CREATE OR ALTER VIEW sales.vw_monthly_sales
WITH SCHEMABINDING AS
SELECT
    YEAR(o.order_date)      AS sale_year,
    MONTH(o.order_date)     AS sale_month,
    COUNT_BIG(*)            AS order_count,
    SUM(o.total_amount)     AS total_revenue,
    SUM(o.tax_amount)       AS total_tax,
    SUM(o.discount_amount)  AS total_discounts
FROM sales.orders o
WHERE o.status = 'DELIVERED'
GROUP BY YEAR(o.order_date), MONTH(o.order_date);

CREATE UNIQUE CLUSTERED INDEX idx_monthly_sales
ON sales.vw_monthly_sales(sale_year, sale_month);

-- 17.5 Drop view
DROP VIEW IF EXISTS hr.vw_active_employees;

-- =============================================================================
-- SECTION 18: STORED PROCEDURES
-- =============================================================================

-- 18.1 Basic stored procedure
CREATE OR ALTER PROCEDURE hr.usp_get_department_employees
    @department_id  INT,
    @status         VARCHAR(20) = 'ACTIVE'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM hr.departments WHERE department_id = @department_id)
    BEGIN
        RAISERROR('Department ID %d does not exist.', 16, 1, @department_id);
        RETURN;
    END

    SELECT
        e.employee_id,
        e.first_name + ' ' + e.last_name   AS full_name,
        e.job_title,
        e.salary,
        e.hire_date,
        e.status,
        e.email,
        m.first_name + ' ' + m.last_name   AS manager_name
    FROM hr.employees e
    LEFT JOIN hr.employees m ON e.manager_id = m.employee_id
    WHERE e.department_id = @department_id
      AND (@status = 'ALL' OR e.status = @status)
    ORDER BY e.last_name, e.first_name;
END;

-- Execute
EXEC hr.usp_get_department_employees @department_id = 1;
EXEC hr.usp_get_department_employees @department_id = 1, @status = 'ALL';

-- 18.2 Procedure with OUTPUT parameters
CREATE OR ALTER PROCEDURE hr.usp_hire_employee
    @first_name     VARCHAR(50),
    @last_name      VARCHAR(50),
    @email          VARCHAR(100),
    @job_title      VARCHAR(100),
    @department_id  INT,
    @salary         DECIMAL(12,2),
    @manager_id     INT = NULL,
    @new_employee_id INT OUTPUT,
    @result_message  VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate email uniqueness
        IF EXISTS (SELECT 1 FROM hr.employees WHERE email = @email)
        BEGIN
            SET @result_message = 'Email address already exists: ' + @email;
            SET @new_employee_id = -1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate department
        IF NOT EXISTS (SELECT 1 FROM hr.departments WHERE department_id = @department_id AND is_active = 1)
        BEGIN
            SET @result_message = 'Invalid or inactive department ID: ' + CAST(@department_id AS VARCHAR);
            SET @new_employee_id = -1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insert employee
        INSERT INTO hr.employees (
            first_name, last_name, email, job_title,
            department_id, salary, manager_id, hire_date, status
        )
        VALUES (
            @first_name, @last_name, @email, @job_title,
            @department_id, @salary, @manager_id, GETDATE(), 'ACTIVE'
        );

        SET @new_employee_id = SCOPE_IDENTITY();
        SET @result_message = 'Employee hired successfully with ID: ' + CAST(@new_employee_id AS VARCHAR);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @new_employee_id = -1;
        SET @result_message = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

-- Execute with OUTPUT
DECLARE @new_id INT, @msg VARCHAR(200);
EXEC hr.usp_hire_employee
    @first_name    = 'Alex',
    @last_name     = 'Turner',
    @email         = 'alex.turner@company.com',
    @job_title     = 'Junior Engineer',
    @department_id = 1,
    @salary        = 65000.00,
    @new_employee_id = @new_id OUTPUT,
    @result_message  = @msg OUTPUT;
SELECT @new_id AS new_employee_id, @msg AS message;

-- 18.3 Procedure with dynamic SQL
CREATE OR ALTER PROCEDURE hr.usp_search_employees
    @search_term    VARCHAR(100) = NULL,
    @department_id  INT          = NULL,
    @min_salary     DECIMAL(12,2)= NULL,
    @max_salary     DECIMAL(12,2)= NULL,
    @status         VARCHAR(20)  = 'ACTIVE',
    @order_by       VARCHAR(50)  = 'last_name',
    @order_dir      VARCHAR(4)   = 'ASC',
    @page_number    INT          = 1,
    @page_size      INT          = 20
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate order_by to prevent SQL injection
    IF @order_by NOT IN ('last_name','first_name','salary','hire_date','department_id')
        SET @order_by = 'last_name';
    IF @order_dir NOT IN ('ASC','DESC')
        SET @order_dir = 'ASC';

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);
    DECLARE @offset INT = (@page_number - 1) * @page_size;

    SET @sql = N'
        SELECT
            e.employee_id,
            e.first_name + '' '' + e.last_name AS full_name,
            e.email,
            e.job_title,
            e.salary,
            e.hire_date,
            e.status,
            d.department_name
        FROM hr.employees e
        JOIN hr.departments d ON e.department_id = d.department_id
        WHERE 1=1';

    IF @search_term IS NOT NULL
        SET @sql += N' AND (e.first_name LIKE ''%'' + @search_term + ''%''
                        OR e.last_name  LIKE ''%'' + @search_term + ''%''
                        OR e.email      LIKE ''%'' + @search_term + ''%''
                        OR e.job_title  LIKE ''%'' + @search_term + ''%'')';

    IF @department_id IS NOT NULL
        SET @sql += N' AND e.department_id = @department_id';

    IF @min_salary IS NOT NULL
        SET @sql += N' AND e.salary >= @min_salary';

    IF @max_salary IS NOT NULL
        SET @sql += N' AND e.salary <= @max_salary';

    IF @status <> 'ALL'
        SET @sql += N' AND e.status = @status';

    SET @sql += N' ORDER BY e.' + @order_by + N' ' + @order_dir;
    SET @sql += N' OFFSET @offset ROWS FETCH NEXT @page_size ROWS ONLY';

    SET @params = N'@search_term VARCHAR(100), @department_id INT, @min_salary DECIMAL(12,2),
                    @max_salary DECIMAL(12,2), @status VARCHAR(20), @offset INT, @page_size INT';

    EXEC sp_executesql @sql, @params,
        @search_term   = @search_term,
        @department_id = @department_id,
        @min_salary    = @min_salary,
        @max_salary    = @max_salary,
        @status        = @status,
        @offset        = @offset,
        @page_size     = @page_size;
END;

-- =============================================================================
-- SECTION 19: USER-DEFINED FUNCTIONS
-- =============================================================================

-- 19.1 Scalar function
CREATE OR ALTER FUNCTION hr.fn_calculate_annual_compensation
(
    @salary         DECIMAL(12,2),
    @commission_pct DECIMAL(5,2),
    @bonus_pct      DECIMAL(5,2) = 10.0
)
RETURNS DECIMAL(15,2)
AS
BEGIN
    DECLARE @annual_comp DECIMAL(15,2);
    SET @annual_comp = @salary
                     + (@salary * COALESCE(@commission_pct, 0) / 100)
                     + (@salary * COALESCE(@bonus_pct, 0) / 100);
    RETURN @annual_comp;
END;

-- Use scalar function
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary,
    commission_pct,
    hr.fn_calculate_annual_compensation(salary, commission_pct, 10.0) AS total_annual_comp
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY total_annual_comp DESC;

-- 19.2 Inline Table-Valued Function
CREATE OR ALTER FUNCTION sales.fn_get_customer_orders
(
    @customer_id    INT,
    @start_date     DATE = NULL,
    @end_date       DATE = NULL
)
RETURNS TABLE
AS
RETURN (
    SELECT
        o.order_id,
        o.order_date,
        o.status,
        o.payment_status,
        o.total_amount,
        COUNT(oi.item_id)   AS item_count,
        SUM(oi.quantity)    AS total_quantity
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
      AND (@start_date IS NULL OR o.order_date >= @start_date)
      AND (@end_date   IS NULL OR o.order_date <= @end_date)
    GROUP BY o.order_id, o.order_date, o.status, o.payment_status, o.total_amount
);

-- Use inline TVF
SELECT * FROM sales.fn_get_customer_orders(1, '2024-01-01', '2024-12-31')
ORDER BY order_date DESC;

-- 19.3 Multi-statement Table-Valued Function
CREATE OR ALTER FUNCTION hr.fn_get_org_chart
(
    @root_employee_id INT,
    @max_levels       INT = 5
)
RETURNS @org_chart TABLE (
    employee_id     INT,
    full_name       VARCHAR(100),
    job_title       VARCHAR(100),
    level           INT,
    manager_id      INT,
    manager_name    VARCHAR(100),
    hierarchy_path  VARCHAR(1000)
)
AS
BEGIN
    WITH hierarchy AS (
        SELECT
            e.employee_id,
            e.first_name + ' ' + e.last_name AS full_name,
            e.job_title,
            0 AS level,
            e.manager_id,
            CAST(NULL AS VARCHAR(100)) AS manager_name,
            CAST(e.first_name + ' ' + e.last_name AS VARCHAR(1000)) AS hierarchy_path
        FROM hr.employees e
        WHERE e.employee_id = @root_employee_id

        UNION ALL

        SELECT
            e.employee_id,
            e.first_name + ' ' + e.last_name,
            e.job_title,
            h.level + 1,
            e.manager_id,
            h.full_name,
            CAST(h.hierarchy_path + ' > ' + e.first_name + ' ' + e.last_name AS VARCHAR(1000))
        FROM hr.employees e
        JOIN hierarchy h ON e.manager_id = h.employee_id
        WHERE h.level < @max_levels
    )
    INSERT INTO @org_chart
    SELECT * FROM hierarchy;

    RETURN;
END;

-- =============================================================================
-- SECTION 20: TRIGGERS
-- =============================================================================

-- 20.1 AFTER INSERT trigger
CREATE OR ALTER TRIGGER audit.trg_employees_insert
ON hr.employees
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO audit.change_log (table_name, record_id, action, new_values, changed_by)
    SELECT
        'hr.employees',
        i.employee_id,
        'INSERT',
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        SYSTEM_USER
    FROM inserted i;
END;

-- 20.2 AFTER UPDATE trigger
CREATE OR ALTER TRIGGER audit.trg_employees_update
ON hr.employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only log if salary or status changed
    IF UPDATE(salary) OR UPDATE(status)
    BEGIN
        INSERT INTO audit.change_log (table_name, record_id, action, old_values, new_values, changed_by)
        SELECT
            'hr.employees',
            i.employee_id,
            'UPDATE',
            (SELECT d.salary, d.status FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            (SELECT i.salary, i.status FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            SYSTEM_USER
        FROM inserted i
        JOIN deleted d ON i.employee_id = d.employee_id
        WHERE i.salary <> d.salary OR i.status <> d.status;
    END
END;

-- 20.3 AFTER DELETE trigger
CREATE OR ALTER TRIGGER audit.trg_employees_delete
ON hr.employees
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO audit.change_log (table_name, record_id, action, old_values, changed_by)
    SELECT
        'hr.employees',
        d.employee_id,
        'DELETE',
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        SYSTEM_USER
    FROM deleted d;
END;

-- 20.4 INSTEAD OF trigger (on view)
CREATE OR ALTER TRIGGER hr.trg_vw_employees_insert
ON hr.vw_active_employees
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO hr.employees (first_name, last_name, email, job_title, department_id, salary, hire_date, status)
    SELECT first_name, last_name, email, job_title, department_id, salary, GETDATE(), 'ACTIVE'
    FROM inserted;
END;

-- 20.5 DDL trigger
CREATE OR ALTER TRIGGER audit.trg_ddl_changes
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    DECLARE @event_data XML = EVENTDATA();
    INSERT INTO audit.change_log (table_name, record_id, action, new_values, changed_by)
    VALUES (
        @event_data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(100)'),
        0,
        @event_data.value('(/EVENT_INSTANCE/EventType)[1]', 'VARCHAR(50)'),
        CAST(@event_data AS NVARCHAR(MAX)),
        @event_data.value('(/EVENT_INSTANCE/LoginName)[1]', 'VARCHAR(100)')
    );
END;

-- =============================================================================
-- SECTION 21: TRANSACTIONS AND ACID PROPERTIES
-- =============================================================================

-- 21.1 Basic transaction
BEGIN TRANSACTION;
    UPDATE hr.employees SET salary = salary * 1.10 WHERE department_id = 1;
    UPDATE hr.departments SET budget = budget * 0.95 WHERE department_id = 1;
    -- Verify
    SELECT SUM(salary) FROM hr.employees WHERE department_id = 1;
COMMIT TRANSACTION;

-- 21.2 Transaction with error handling
BEGIN TRY
    BEGIN TRANSACTION;

    -- Transfer budget between departments
    DECLARE @transfer_amount DECIMAL(12,2) = 50000.00;
    DECLARE @from_dept INT = 2;
    DECLARE @to_dept   INT = 1;

    -- Deduct from source
    UPDATE hr.departments
    SET budget = budget - @transfer_amount
    WHERE department_id = @from_dept;

    -- Verify sufficient budget
    IF (SELECT budget FROM hr.departments WHERE department_id = @from_dept) < 0
        THROW 50001, 'Insufficient budget in source department.', 1;

    -- Add to destination
    UPDATE hr.departments
    SET budget = budget + @transfer_amount
    WHERE department_id = @to_dept;

    COMMIT TRANSACTION;
    PRINT 'Budget transfer completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;
END CATCH;

-- 21.3 Savepoints
BEGIN TRANSACTION;
    INSERT INTO hr.departments (department_name, location, budget)
    VALUES ('Temp Dept 1', 'NYC', 100000);

    SAVE TRANSACTION savepoint1;

    INSERT INTO hr.departments (department_name, location, budget)
    VALUES ('Temp Dept 2', 'LA', 200000);

    SAVE TRANSACTION savepoint2;

    INSERT INTO hr.departments (department_name, location, budget)
    VALUES ('Temp Dept 3', 'Chicago', 150000);

    -- Rollback to savepoint2 (keeps Temp Dept 1 and 2, removes Temp Dept 3)
    ROLLBACK TRANSACTION savepoint2;

COMMIT TRANSACTION;

-- 21.4 Isolation levels
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  -- Dirty reads allowed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;    -- Default: no dirty reads
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- No non-repeatable reads
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;      -- Strictest: no phantom reads
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;          -- Row versioning

-- 21.5 Lock hints
SELECT * FROM hr.employees WITH (NOLOCK);           -- Read uncommitted
SELECT * FROM hr.employees WITH (READPAST);         -- Skip locked rows
SELECT * FROM hr.employees WITH (UPDLOCK);          -- Update lock
SELECT * FROM hr.employees WITH (HOLDLOCK);         -- Hold shared lock
SELECT * FROM hr.employees WITH (ROWLOCK);          -- Row-level locking
SELECT * FROM hr.employees WITH (TABLOCK);          -- Table-level lock
SELECT * FROM hr.employees WITH (TABLOCKX);         -- Exclusive table lock

-- =============================================================================
-- SECTION 22: ERROR HANDLING
-- =============================================================================

-- 22.1 TRY/CATCH with full error info
BEGIN TRY
    -- Intentional error: divide by zero
    DECLARE @result INT = 10 / 0;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER()      AS error_number,
        ERROR_SEVERITY()    AS error_severity,
        ERROR_STATE()       AS error_state,
        ERROR_PROCEDURE()   AS error_procedure,
        ERROR_LINE()        AS error_line,
        ERROR_MESSAGE()     AS error_message;
END CATCH;

-- 22.2 Custom error with RAISERROR
CREATE OR ALTER PROCEDURE hr.usp_validate_salary
    @employee_id INT,
    @new_salary  DECIMAL(12,2)
AS
BEGIN
    DECLARE @current_salary DECIMAL(12,2);
    DECLARE @max_increase   DECIMAL(5,2) = 25.0;

    SELECT @current_salary = salary
    FROM hr.employees
    WHERE employee_id = @employee_id;

    IF @current_salary IS NULL
        RAISERROR('Employee ID %d not found.', 16, 1, @employee_id);

    DECLARE @increase_pct DECIMAL(5,2) = (@new_salary - @current_salary) / @current_salary * 100;

    IF @increase_pct > @max_increase
        RAISERROR('Salary increase of %.2f%% exceeds maximum allowed %.2f%%.', 16, 1, @increase_pct, @max_increase);

    IF @new_salary < @current_salary * 0.80
        RAISERROR('Salary decrease exceeds 20%% threshold. Current: %.2f, New: %.2f', 16, 1, @current_salary, @new_salary);

    PRINT 'Salary validation passed.';
END;

-- 22.3 THROW statement
CREATE OR ALTER PROCEDURE finance.usp_process_payment
    @order_id       INT,
    @payment_amount DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @order_total DECIMAL(12,2);
        SELECT @order_total = total_amount FROM sales.orders WHERE order_id = @order_id;

        IF @order_total IS NULL
            THROW 50001, 'Order not found.', 1;

        IF @payment_amount <= 0
            THROW 50002, 'Payment amount must be positive.', 1;

        IF @payment_amount > @order_total
            THROW 50003, 'Payment amount exceeds order total.', 1;

        UPDATE sales.orders
        SET payment_status = CASE
            WHEN @payment_amount >= @order_total THEN 'PAID'
            ELSE 'PARTIAL'
        END
        WHERE order_id = @order_id;

        INSERT INTO finance.invoices (order_id, invoice_date, due_date, amount, total_amount, status)
        VALUES (@order_id, GETDATE(), DATEADD(DAY, 30, GETDATE()), @payment_amount, @order_total,
                CASE WHEN @payment_amount >= @order_total THEN 'PAID' ELSE 'PARTIAL' END);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;  -- Re-throw the original error
    END CATCH
END;

-- =============================================================================
-- SECTION 23: CURSORS
-- =============================================================================

-- 23.1 Basic cursor
DECLARE @emp_id     INT;
DECLARE @emp_name   VARCHAR(100);
DECLARE @salary     DECIMAL(12,2);
DECLARE @new_salary DECIMAL(12,2);

DECLARE emp_cursor CURSOR
    LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR
    SELECT employee_id, first_name + ' ' + last_name, salary
    FROM hr.employees
    WHERE status = 'ACTIVE' AND department_id = 1
    ORDER BY salary DESC;

OPEN emp_cursor;
FETCH NEXT FROM emp_cursor INTO @emp_id, @emp_name, @salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @new_salary = @salary * 1.05;
    PRINT 'Employee: ' + @emp_name + ' | Old: $' + CAST(@salary AS VARCHAR) + ' | New: $' + CAST(@new_salary AS VARCHAR);
    FETCH NEXT FROM emp_cursor INTO @emp_id, @emp_name, @salary;
END

CLOSE emp_cursor;
DEALLOCATE emp_cursor;

-- 23.2 Updateable cursor
DECLARE update_cursor CURSOR
FOR
    SELECT employee_id, salary
    FROM hr.employees
    WHERE status = 'ACTIVE'
      AND hire_date < DATEADD(YEAR, -5, GETDATE())
      AND salary < 80000
FOR UPDATE OF salary;

OPEN update_cursor;
FETCH NEXT FROM update_cursor INTO @emp_id, @salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE hr.employees
    SET salary = @salary * 1.08
    WHERE CURRENT OF update_cursor;

    FETCH NEXT FROM update_cursor INTO @emp_id, @salary;
END

CLOSE update_cursor;
DEALLOCATE update_cursor;

-- NOTE: Prefer set-based operations over cursors for performance
-- Set-based equivalent of the above cursor:
UPDATE hr.employees
SET salary = salary * 1.08
WHERE status = 'ACTIVE'
  AND hire_date < DATEADD(YEAR, -5, GETDATE())
  AND salary < 80000;

-- =============================================================================
-- SECTION 24: DYNAMIC SQL
-- =============================================================================

-- 24.1 Basic dynamic SQL with sp_executesql
DECLARE @table_name VARCHAR(100) = 'hr.employees';
DECLARE @column_name VARCHAR(100) = 'salary';
DECLARE @min_value DECIMAL(12,2) = 80000;
DECLARE @sql_query NVARCHAR(MAX);
DECLARE @param_def NVARCHAR(MAX);

SET @sql_query = N'SELECT employee_id, first_name, last_name, ' + QUOTENAME(@column_name) +
                 N' FROM ' + @table_name +
                 N' WHERE ' + QUOTENAME(@column_name) + N' > @min_val ORDER BY ' + QUOTENAME(@column_name) + N' DESC';
SET @param_def = N'@min_val DECIMAL(12,2)';

EXEC sp_executesql @sql_query, @param_def, @min_val = @min_value;

-- 24.2 Dynamic pivot
DECLARE @pivot_cols NVARCHAR(MAX);
DECLARE @pivot_sql  NVARCHAR(MAX);

SELECT @pivot_cols = STRING_AGG(QUOTENAME(department_name), ',')
FROM hr.departments
WHERE is_active = 1;

SET @pivot_sql = N'
SELECT *
FROM (
    SELECT d.department_name, e.salary
    FROM hr.employees e
    JOIN hr.departments d ON e.department_id = d.department_id
    WHERE e.status = ''ACTIVE''
) AS source_data
PIVOT (
    AVG(salary)
    FOR department_name IN (' + @pivot_cols + N')
) AS pivot_result';

EXEC sp_executesql @pivot_sql;

-- 24.3 Dynamic table creation
DECLARE @new_table_name VARCHAR(100) = 'archive_employees_2023';
DECLARE @create_sql NVARCHAR(MAX);

SET @create_sql = N'
CREATE TABLE dbo.' + QUOTENAME(@new_table_name) + N' (
    archive_id      INT IDENTITY(1,1) PRIMARY KEY,
    employee_id     INT,
    full_name       VARCHAR(100),
    salary          DECIMAL(12,2),
    department_name VARCHAR(100),
    archived_date   DATETIME DEFAULT GETDATE()
)';

EXEC sp_executesql @create_sql;

-- =============================================================================
-- SECTION 25: PIVOT AND UNPIVOT
-- =============================================================================

-- 25.1 Static PIVOT
SELECT *
FROM (
    SELECT
        d.department_name,
        DATENAME(MONTH, e.hire_date) AS hire_month,
        e.employee_id
    FROM hr.employees e
    JOIN hr.departments d ON e.department_id = d.department_id
    WHERE YEAR(e.hire_date) = 2020
) AS source_data
PIVOT (
    COUNT(employee_id)
    FOR hire_month IN (
        [January],[February],[March],[April],[May],[June],
        [July],[August],[September],[October],[November],[December]
    )
) AS pivot_result
ORDER BY department_name;

-- 25.2 UNPIVOT
SELECT department_name, quarter, revenue
FROM (
    SELECT
        department_name,
        Q1_revenue, Q2_revenue, Q3_revenue, Q4_revenue
    FROM analytics.quarterly_revenue
) AS source_data
UNPIVOT (
    revenue FOR quarter IN (Q1_revenue, Q2_revenue, Q3_revenue, Q4_revenue)
) AS unpivot_result
ORDER BY department_name, quarter;

-- 25.3 Manual PIVOT using CASE
SELECT
    d.department_name,
    SUM(CASE WHEN MONTH(e.hire_date) = 1  THEN 1 ELSE 0 END) AS Jan,
    SUM(CASE WHEN MONTH(e.hire_date) = 2  THEN 1 ELSE 0 END) AS Feb,
    SUM(CASE WHEN MONTH(e.hire_date) = 3  THEN 1 ELSE 0 END) AS Mar,
    SUM(CASE WHEN MONTH(e.hire_date) = 4  THEN 1 ELSE 0 END) AS Apr,
    SUM(CASE WHEN MONTH(e.hire_date) = 5  THEN 1 ELSE 0 END) AS May,
    SUM(CASE WHEN MONTH(e.hire_date) = 6  THEN 1 ELSE 0 END) AS Jun,
    SUM(CASE WHEN MONTH(e.hire_date) = 7  THEN 1 ELSE 0 END) AS Jul,
    SUM(CASE WHEN MONTH(e.hire_date) = 8  THEN 1 ELSE 0 END) AS Aug,
    SUM(CASE WHEN MONTH(e.hire_date) = 9  THEN 1 ELSE 0 END) AS Sep,
    SUM(CASE WHEN MONTH(e.hire_date) = 10 THEN 1 ELSE 0 END) AS Oct,
    SUM(CASE WHEN MONTH(e.hire_date) = 11 THEN 1 ELSE 0 END) AS Nov,
    SUM(CASE WHEN MONTH(e.hire_date) = 12 THEN 1 ELSE 0 END) AS Dec,
    COUNT(*) AS total
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY d.department_name;

-- =============================================================================
-- SECTION 26: JSON IN SQL
-- =============================================================================

-- 26.1 Store JSON
CREATE TABLE sales.product_attributes (
    attribute_id    INT           NOT NULL IDENTITY(1,1),
    product_id      INT           NOT NULL,
    attributes      NVARCHAR(MAX) NOT NULL,
    CONSTRAINT pk_product_attrs PRIMARY KEY (attribute_id),
    CONSTRAINT fk_pa_product    FOREIGN KEY (product_id) REFERENCES inventory.products(product_id),
    CONSTRAINT chk_valid_json   CHECK (ISJSON(attributes) = 1)
);

INSERT INTO sales.product_attributes (product_id, attributes)
VALUES (1, N'{
    "color": "Silver",
    "weight_kg": 1.8,
    "dimensions": {"length": 35, "width": 24, "height": 2},
    "specs": {
        "processor": "Intel Core i7",
        "ram_gb": 16,
        "storage_gb": 512,
        "display_inch": 15.6
    },
    "tags": ["laptop", "portable", "business"],
    "warranty_years": 2,
    "in_stock": true
}');

-- 26.2 Extract JSON values
SELECT
    p.product_name,
    JSON_VALUE(pa.attributes, '$.color')                    AS color,
    JSON_VALUE(pa.attributes, '$.specs.processor')          AS processor,
    JSON_VALUE(pa.attributes, '$.specs.ram_gb')             AS ram_gb,
    JSON_VALUE(pa.attributes, '$.dimensions.length')        AS length_cm,
    JSON_QUERY(pa.attributes, '$.tags')                     AS tags_array,
    JSON_QUERY(pa.attributes, '$.specs')                    AS specs_object
FROM inventory.products p
JOIN sales.product_attributes pa ON p.product_id = pa.product_id;

-- 26.3 FOR JSON
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
FOR JSON PATH, ROOT('employees');

-- 26.4 OPENJSON
DECLARE @json_data NVARCHAR(MAX) = N'[
    {"id": 1, "name": "Alice", "salary": 75000, "dept": "Engineering"},
    {"id": 2, "name": "Bob",   "salary": 65000, "dept": "Marketing"},
    {"id": 3, "name": "Carol", "salary": 85000, "dept": "Finance"}
]';

SELECT *
FROM OPENJSON(@json_data)
WITH (
    id      INT           '$.id',
    name    VARCHAR(100)  '$.name',
    salary  DECIMAL(12,2) '$.salary',
    dept    VARCHAR(100)  '$.dept'
);

-- 26.5 JSON_MODIFY
UPDATE sales.product_attributes
SET attributes = JSON_MODIFY(attributes, '$.warranty_years', 3)
WHERE product_id = 1;

UPDATE sales.product_attributes
SET attributes = JSON_MODIFY(attributes, 'append $.tags', 'premium')
WHERE product_id = 1;

-- =============================================================================
-- SECTION 27: STRING FUNCTIONS
-- =============================================================================

SELECT
    -- Concatenation
    CONCAT('Hello', ' ', 'World')                           AS concat_result,
    CONCAT_WS(', ', 'Smith', 'John', 'Jr.')                 AS concat_ws_result,
    'Hello' + ' ' + 'World'                                 AS plus_concat,

    -- Case conversion
    UPPER('hello world')                                    AS upper_result,
    LOWER('HELLO WORLD')                                    AS lower_result,

    -- Trimming
    LTRIM('   hello   ')                                    AS ltrim_result,
    RTRIM('   hello   ')                                    AS rtrim_result,
    TRIM('   hello   ')                                     AS trim_result,
    TRIM('x' FROM 'xxxhelloxxx')                            AS trim_char_result,

    -- Substring operations
    SUBSTRING('Hello World', 7, 5)                          AS substring_result,
    LEFT('Hello World', 5)                                  AS left_result,
    RIGHT('Hello World', 5)                                 AS right_result,

    -- Length
    LEN('Hello World')                                      AS len_result,
    DATALENGTH('Hello World')                               AS datalength_result,
    DATALENGTH(N'Hello World')                              AS nvarchar_datalength,

    -- Search
    CHARINDEX('World', 'Hello World')                       AS charindex_result,
    CHARINDEX('o', 'Hello World', 6)                        AS charindex_from_pos,
    PATINDEX('%[0-9]%', 'abc123def')                        AS patindex_result,

    -- Replace
    REPLACE('Hello World', 'World', 'SQL')                  AS replace_result,
    STUFF('Hello World', 7, 5, 'SQL')                       AS stuff_result,

    -- Padding
    REPLICATE('*', 10)                                      AS replicate_result,
    SPACE(5)                                                AS space_result,
    FORMAT(1234567.89, 'N2')                                AS format_number,

    -- Reverse
    REVERSE('Hello')                                        AS reverse_result,

    -- ASCII / CHAR
    ASCII('A')                                              AS ascii_result,
    CHAR(65)                                                AS char_result,
    UNICODE(N'A')                                           AS unicode_result,
    NCHAR(65)                                               AS nchar_result,

    -- String split
    STRING_SPLIT('a,b,c,d', ',')                            AS -- use in FROM clause

    -- Soundex / Difference
    SOUNDEX('Smith')                                        AS soundex_result,
    DIFFERENCE('Smith', 'Smyth')                            AS difference_result;

-- STRING_SPLIT usage
SELECT value AS split_value
FROM STRING_SPLIT('Engineering,Marketing,Finance,HR', ',')
ORDER BY value;

-- 27.1 String manipulation examples
SELECT
    employee_id,
    first_name + ' ' + last_name                           AS full_name,
    UPPER(LEFT(first_name, 1)) + LOWER(SUBSTRING(first_name, 2, LEN(first_name))) AS proper_first,
    REVERSE(last_name)                                     AS reversed_last,
    LEN(first_name + last_name)                            AS name_length,
    CHARINDEX('@', email)                                  AS at_position,
    LEFT(email, CHARINDEX('@', email) - 1)                 AS email_username,
    RIGHT(email, LEN(email) - CHARINDEX('@', email))       AS email_domain,
    REPLICATE('*', LEN(email) - CHARINDEX('@', email) - 4) + RIGHT(email, 4) AS masked_domain
FROM hr.employees
WHERE status = 'ACTIVE';

-- =============================================================================
-- SECTION 28: DATE AND TIME FUNCTIONS
-- =============================================================================

SELECT
    -- Current date/time
    GETDATE()                                               AS current_datetime,
    GETUTCDATE()                                            AS utc_datetime,
    SYSDATETIME()                                           AS sys_datetime,
    SYSDATETIMEOFFSET()                                     AS sys_datetime_offset,
    CURRENT_TIMESTAMP                                       AS current_timestamp,

    -- Date parts
    YEAR(GETDATE())                                         AS current_year,
    MONTH(GETDATE())                                        AS current_month,
    DAY(GETDATE())                                          AS current_day,
    DATEPART(HOUR, GETDATE())                               AS current_hour,
    DATEPART(MINUTE, GETDATE())                             AS current_minute,
    DATEPART(SECOND, GETDATE())                             AS current_second,
    DATEPART(MILLISECOND, GETDATE())                        AS current_ms,
    DATEPART(WEEKDAY, GETDATE())                            AS weekday_number,
    DATEPART(WEEK, GETDATE())                               AS week_number,
    DATEPART(QUARTER, GETDATE())                            AS quarter_number,
    DATEPART(DAYOFYEAR, GETDATE())                          AS day_of_year,

    -- Date names
    DATENAME(WEEKDAY, GETDATE())                            AS weekday_name,
    DATENAME(MONTH, GETDATE())                              AS month_name,

    -- Date arithmetic
    DATEADD(DAY,    7,  GETDATE())                          AS plus_7_days,
    DATEADD(MONTH,  3,  GETDATE())                          AS plus_3_months,
    DATEADD(YEAR,   1,  GETDATE())                          AS plus_1_year,
    DATEADD(HOUR,  -8,  GETDATE())                          AS minus_8_hours,
    DATEADD(SECOND, 30, GETDATE())                          AS plus_30_seconds,

    -- Date differences
    DATEDIFF(DAY,   '2024-01-01', GETDATE())                AS days_since_jan1,
    DATEDIFF(MONTH, '2024-01-01', GETDATE())                AS months_since_jan1,
    DATEDIFF(YEAR,  '1990-05-15', GETDATE())                AS age_years,
    DATEDIFF(HOUR,  '2024-01-01 08:00', GETDATE())          AS hours_elapsed,

    -- Date construction
    DATEFROMPARTS(2024, 12, 31)                             AS constructed_date,
    TIMEFROMPARTS(14, 30, 0, 0, 0)                          AS constructed_time,
    DATETIMEFROMPARTS(2024, 12, 31, 23, 59, 59, 0)          AS constructed_datetime,

    -- Date truncation
    CAST(GETDATE() AS DATE)                                 AS date_only,
    CAST(GETDATE() AS TIME)                                 AS time_only,
    DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)        AS first_of_month,
    DATEADD(YEAR,  DATEDIFF(YEAR,  0, GETDATE()), 0)        AS first_of_year,
    EOMONTH(GETDATE())                                      AS end_of_month,
    EOMONTH(GETDATE(), 1)                                   AS end_of_next_month,

    -- Conversion
    FORMAT(GETDATE(), 'yyyy-MM-dd')                         AS iso_date,
    FORMAT(GETDATE(), 'dd/MM/yyyy')                         AS uk_date,
    FORMAT(GETDATE(), 'MMMM dd, yyyy')                      AS long_date,
    FORMAT(GETDATE(), 'HH:mm:ss')                           AS time_24h,
    CONVERT(VARCHAR, GETDATE(), 101)                        AS us_date,
    CONVERT(VARCHAR, GETDATE(), 103)                        AS uk_date_convert,
    CONVERT(VARCHAR, GETDATE(), 120)                        AS odbc_datetime;

-- 28.1 Business day calculations
WITH business_days AS (
    SELECT CAST('2024-01-01' AS DATE) AS biz_date
    UNION ALL
    SELECT DATEADD(DAY, 1, biz_date)
    FROM business_days
    WHERE biz_date < '2024-12-31'
)
SELECT
    COUNT(*) AS total_business_days_2024
FROM business_days
WHERE DATEPART(WEEKDAY, biz_date) NOT IN (1, 7)  -- Exclude Sunday (1) and Saturday (7)
OPTION (MAXRECURSION 400);

-- 28.2 Age calculation
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    birth_date,
    DATEDIFF(YEAR, birth_date, GETDATE()) -
        CASE WHEN MONTH(birth_date) > MONTH(GETDATE())
              OR (MONTH(birth_date) = MONTH(GETDATE()) AND DAY(birth_date) > DAY(GETDATE()))
             THEN 1 ELSE 0
        END AS exact_age
FROM hr.employees
WHERE birth_date IS NOT NULL
ORDER BY birth_date;

-- =============================================================================
-- SECTION 29: MATHEMATICAL FUNCTIONS
-- =============================================================================

SELECT
    -- Basic math
    ABS(-42)                                                AS absolute_value,
    SIGN(-42)                                               AS sign_negative,
    SIGN(42)                                                AS sign_positive,
    SIGN(0)                                                 AS sign_zero,

    -- Rounding
    ROUND(3.14159, 2)                                       AS round_2dp,
    ROUND(3.14159, 0)                                       AS round_0dp,
    ROUND(3.5, 0)                                           AS round_half_up,
    CEILING(3.2)                                            AS ceiling_result,
    FLOOR(3.9)                                              AS floor_result,

    -- Power and roots
    POWER(2, 10)                                            AS two_to_ten,
    SQRT(144)                                               AS square_root,
    SQUARE(12)                                              AS squared,
    EXP(1)                                                  AS e_value,
    LOG(2.71828)                                            AS natural_log,
    LOG(100, 10)                                            AS log_base_10,
    LOG10(1000)                                             AS log10_result,

    -- Trigonometry
    PI()                                                    AS pi_value,
    SIN(PI() / 2)                                           AS sin_90,
    COS(0)                                                  AS cos_0,
    TAN(PI() / 4)                                           AS tan_45,
    ASIN(1)                                                 AS arcsin_1,
    ACOS(1)                                                 AS arccos_1,
    ATAN(1)                                                 AS arctan_1,
    ATN2(1, 1)                                              AS atan2_result,
    DEGREES(PI())                                           AS radians_to_degrees,
    RADIANS(180.0)                                          AS degrees_to_radians,

    -- Modulo
    10 % 3                                                  AS modulo_result,

    -- Random
    RAND()                                                  AS random_0_to_1,
    FLOOR(RAND() * 100) + 1                                 AS random_1_to_100;

-- 29.1 Financial calculations
SELECT
    product_id,
    product_name,
    unit_price,
    cost_price,
    unit_price - cost_price                                 AS gross_profit,
    ROUND((unit_price - cost_price) / unit_price * 100, 2) AS gross_margin_pct,
    ROUND(unit_price * 1.08, 2)                             AS price_with_tax,
    ROUND(unit_price * 0.85, 2)                             AS discounted_price_15pct,
    -- Compound interest: P * (1 + r)^n
    ROUND(unit_price * POWER(1.05, 3), 2)                   AS price_after_3yr_5pct_inflation
FROM inventory.products
WHERE is_active = 1
ORDER BY gross_margin_pct DESC;

-- =============================================================================
-- SECTION 30: CONDITIONAL EXPRESSIONS
-- =============================================================================

-- 30.1 CASE expression - simple
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    status,
    CASE status
        WHEN 'ACTIVE'     THEN 'Currently Working'
        WHEN 'ON_LEAVE'   THEN 'On Leave'
        WHEN 'INACTIVE'   THEN 'Temporarily Inactive'
        WHEN 'TERMINATED' THEN 'No Longer Employed'
        ELSE 'Unknown Status'
    END AS status_description
FROM hr.employees;

-- 30.2 CASE expression - searched
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary,
    CASE
        WHEN salary >= 120000 THEN 'Executive'
        WHEN salary >= 100000 THEN 'Director'
        WHEN salary >= 80000  THEN 'Senior'
        WHEN salary >= 60000  THEN 'Mid-Level'
        WHEN salary >= 40000  THEN 'Junior'
        ELSE 'Entry Level'
    END AS salary_grade,
    CASE
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 10 THEN 0.15
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 7  THEN 0.12
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 5  THEN 0.10
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 3  THEN 0.07
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 1  THEN 0.05
        ELSE 0.03
    END AS bonus_rate,
    salary * CASE
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 10 THEN 0.15
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 7  THEN 0.12
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 5  THEN 0.10
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 3  THEN 0.07
        WHEN DATEDIFF(YEAR, hire_date, GETDATE()) >= 1  THEN 0.05
        ELSE 0.03
    END AS bonus_amount
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY salary DESC;

-- 30.3 COALESCE
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    COALESCE(phone, email, 'No contact info') AS primary_contact,
    COALESCE(commission_pct, 0)               AS commission_rate,
    COALESCE(manager_id, employee_id)         AS reports_to
FROM hr.employees;

-- 30.4 NULLIF
SELECT
    employee_id,
    salary,
    commission_pct,
    -- Avoid division by zero
    salary / NULLIF(commission_pct, 0)        AS salary_per_commission_point,
    NULLIF(status, 'ACTIVE')                  AS non_active_status
FROM hr.employees;

-- 30.5 IIF (SQL Server specific)
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary,
    IIF(salary > 80000, 'High Earner', 'Standard')  AS earner_category,
    IIF(manager_id IS NULL, 'Top Level', 'Has Manager') AS hierarchy_level
FROM hr.employees
WHERE status = 'ACTIVE';

-- 30.6 CHOOSE
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    DATEPART(QUARTER, hire_date) AS hire_quarter,
    CHOOSE(DATEPART(QUARTER, hire_date), 'Q1 (Jan-Mar)', 'Q2 (Apr-Jun)', 'Q3 (Jul-Sep)', 'Q4 (Oct-Dec)') AS quarter_label
FROM hr.employees;

-- =============================================================================
-- SECTION 31: NORMALIZATION
-- =============================================================================

-- 31.1 First Normal Form (1NF) - Atomic values, no repeating groups
-- VIOLATION: Multiple values in one column
CREATE TABLE normalization.bad_1nf (
    employee_id INT,
    employee_name VARCHAR(100),
    phone_numbers VARCHAR(200),  -- "555-0101, 555-0102, 555-0103" - VIOLATION
    skills VARCHAR(500)          -- "SQL, Python, Java" - VIOLATION
);

-- CORRECT 1NF: Separate tables for multi-valued attributes
CREATE TABLE normalization.employees_1nf (
    employee_id   INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL
);

CREATE TABLE normalization.employee_phones (
    phone_id    INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES normalization.employees_1nf(employee_id),
    phone_type  VARCHAR(20),
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE normalization.employee_skills (
    skill_id    INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES normalization.employees_1nf(employee_id),
    skill_name  VARCHAR(100) NOT NULL,
    proficiency VARCHAR(20)
);

-- 31.2 Second Normal Form (2NF) - 1NF + no partial dependencies
-- VIOLATION: Non-key attributes depend on part of composite key
CREATE TABLE normalization.bad_2nf (
    order_id     INT,
    product_id   INT,
    quantity     INT,
    product_name VARCHAR(200),  -- Depends only on product_id - VIOLATION
    unit_price   DECIMAL(12,2), -- Depends only on product_id - VIOLATION
    PRIMARY KEY (order_id, product_id)
);

-- CORRECT 2NF: Separate product info
CREATE TABLE normalization.products_2nf (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    unit_price   DECIMAL(12,2) NOT NULL
);

CREATE TABLE normalization.order_items_2nf (
    order_id   INT,
    product_id INT REFERENCES normalization.products_2nf(product_id),
    quantity   INT NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

-- 31.3 Third Normal Form (3NF) - 2NF + no transitive dependencies
-- VIOLATION: zip_code -> city, state (transitive dependency)
CREATE TABLE normalization.bad_3nf (
    employee_id INT PRIMARY KEY,
    name        VARCHAR(100),
    zip_code    VARCHAR(10),
    city        VARCHAR(100),  -- Depends on zip_code, not employee_id - VIOLATION
    state       VARCHAR(50)    -- Depends on zip_code, not employee_id - VIOLATION
);

-- CORRECT 3NF: Separate zip code table
CREATE TABLE normalization.zip_codes (
    zip_code VARCHAR(10) PRIMARY KEY,
    city     VARCHAR(100) NOT NULL,
    state    VARCHAR(50)  NOT NULL
);

CREATE TABLE normalization.employees_3nf (
    employee_id INT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    zip_code    VARCHAR(10) REFERENCES normalization.zip_codes(zip_code)
);

-- =============================================================================
-- SECTION 32: QUERY OPTIMIZATION
-- =============================================================================

-- 32.1 Use indexes effectively
-- BAD: Function on indexed column prevents index use
SELECT * FROM hr.employees WHERE YEAR(hire_date) = 2020;

-- GOOD: Range condition uses index
SELECT * FROM hr.employees
WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01';

-- BAD: Leading wildcard prevents index use
SELECT * FROM hr.employees WHERE last_name LIKE '%son';

-- GOOD: Trailing wildcard can use index
SELECT * FROM hr.employees WHERE last_name LIKE 'John%';

-- BAD: Implicit conversion
SELECT * FROM hr.employees WHERE employee_id = '5';  -- String vs INT

-- GOOD: Matching data types
SELECT * FROM hr.employees WHERE employee_id = 5;

-- 32.2 Avoid SELECT *
-- BAD
SELECT * FROM hr.employees;

-- GOOD: Select only needed columns
SELECT employee_id, first_name, last_name, salary FROM hr.employees;

-- 32.3 Use EXISTS instead of COUNT for existence checks
-- BAD
IF (SELECT COUNT(*) FROM hr.employees WHERE department_id = 1) > 0
    PRINT 'Has employees';

-- GOOD
IF EXISTS (SELECT 1 FROM hr.employees WHERE department_id = 1)
    PRINT 'Has employees';

-- 32.4 Execution plan hints
SELECT *
FROM hr.employees
WHERE department_id = 1
OPTION (OPTIMIZE FOR (@department_id = 1));

SELECT e.*, d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
OPTION (HASH JOIN);

SELECT e.*, d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
OPTION (LOOP JOIN);

SELECT e.*, d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
OPTION (MERGE JOIN);

-- 32.5 Statistics update
UPDATE STATISTICS hr.employees;
UPDATE STATISTICS hr.employees idx_emp_dept_salary;
EXEC sp_updatestats;

-- 32.6 Query hints
SELECT TOP 100 *
FROM hr.employees WITH (INDEX(idx_emp_dept_salary))
WHERE department_id = 1
ORDER BY salary DESC;

-- 32.7 Recompile hint
EXEC hr.usp_get_department_employees @department_id = 1
WITH RECOMPILE;

-- =============================================================================
-- SECTION 33: PARTITIONING
-- =============================================================================

-- 33.1 Partition function
CREATE PARTITION FUNCTION pf_order_date (DATE)
AS RANGE RIGHT FOR VALUES (
    '2022-01-01', '2023-01-01', '2024-01-01', '2025-01-01'
);

-- 33.2 Partition scheme
CREATE PARTITION SCHEME ps_order_date
AS PARTITION pf_order_date
TO (fg_2021, fg_2022, fg_2023, fg_2024, fg_2025);

-- 33.3 Partitioned table
CREATE TABLE sales.orders_partitioned (
    order_id        INT           NOT NULL,
    customer_id     INT           NOT NULL,
    order_date      DATE          NOT NULL,
    total_amount    DECIMAL(12,2),
    status          VARCHAR(20),
    CONSTRAINT pk_orders_part PRIMARY KEY (order_id, order_date)
) ON ps_order_date(order_date);

-- 33.4 Query specific partition
SELECT *
FROM sales.orders_partitioned
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'
  AND $PARTITION.pf_order_date(order_date) = 4;

-- 33.5 Partition metadata
SELECT
    p.partition_number,
    p.rows,
    rv.value AS boundary_value,
    fg.name  AS filegroup_name
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values rv ON pf.function_id = rv.function_id
    AND p.partition_number = rv.boundary_id + 1
JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id
    AND p.partition_number = dds.destination_id
JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'orders_partitioned'
ORDER BY p.partition_number;

-- =============================================================================
-- SECTION 34: SEQUENCES AND IDENTITY
-- =============================================================================

-- 34.1 IDENTITY column
CREATE TABLE hr.temp_ids (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        VARCHAR(100)
);

-- Get last inserted identity
INSERT INTO hr.temp_ids (name) VALUES ('Test');
SELECT SCOPE_IDENTITY() AS last_id;
SELECT @@IDENTITY AS last_identity;
SELECT IDENT_CURRENT('hr.temp_ids') AS current_identity;

-- Reseed identity
DBCC CHECKIDENT('hr.temp_ids', RESEED, 1000);

-- 34.2 SEQUENCE object
CREATE SEQUENCE dbo.seq_order_number
    START WITH 100000
    INCREMENT BY 1
    MINVALUE 100000
    MAXVALUE 999999
    CYCLE
    CACHE 50;

-- Use sequence
SELECT NEXT VALUE FOR dbo.seq_order_number AS next_order_number;

-- Use in INSERT
INSERT INTO sales.orders (order_id, customer_id, order_date, total_amount)
VALUES (NEXT VALUE FOR dbo.seq_order_number, 1, GETDATE(), 0);

-- Sequence info
SELECT * FROM sys.sequences WHERE name = 'seq_order_number';

-- Alter sequence
ALTER SEQUENCE dbo.seq_order_number RESTART WITH 200000;

-- =============================================================================
-- SECTION 35: SECURITY
-- =============================================================================

-- 35.1 Create login and user
CREATE LOGIN app_user WITH PASSWORD = 'SecureP@ssw0rd!';
CREATE USER app_user FOR LOGIN app_user;

-- 35.2 Grant permissions
GRANT SELECT ON hr.employees TO app_user;
GRANT SELECT, INSERT, UPDATE ON sales.orders TO app_user;
GRANT EXECUTE ON hr.usp_get_department_employees TO app_user;

-- 35.3 Revoke permissions
REVOKE INSERT ON sales.orders FROM app_user;

-- 35.4 Deny permissions
DENY DELETE ON hr.employees TO app_user;
DENY SELECT ON finance.invoices TO app_user;

-- 35.5 Roles
CREATE ROLE hr_read_role;
CREATE ROLE hr_write_role;
CREATE ROLE sales_manager_role;

GRANT SELECT ON SCHEMA::hr TO hr_read_role;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::hr TO hr_write_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sales TO sales_manager_role;

ALTER ROLE hr_read_role ADD MEMBER app_user;

-- 35.6 Row-Level Security (RLS)
CREATE SCHEMA security;

CREATE FUNCTION security.fn_dept_access_predicate(@department_id INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS access_result
WHERE @department_id = CAST(SESSION_CONTEXT(N'department_id') AS INT)
   OR IS_MEMBER('db_owner') = 1
   OR IS_MEMBER('hr_admin') = 1;

CREATE SECURITY POLICY security.dept_access_policy
ADD FILTER PREDICATE security.fn_dept_access_predicate(department_id)
ON hr.employees,
ADD BLOCK PREDICATE security.fn_dept_access_predicate(department_id)
ON hr.employees AFTER INSERT
WITH (STATE = ON);

-- Set session context
EXEC sp_set_session_context N'department_id', 1;

-- 35.7 Dynamic Data Masking
ALTER TABLE hr.employees
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE hr.employees
ALTER COLUMN phone ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XXXX",4)');

ALTER TABLE hr.employees
ALTER COLUMN salary ADD MASKED WITH (FUNCTION = 'default()');

-- Grant unmask permission
GRANT UNMASK TO hr_admin_user;

-- 35.8 Transparent Data Encryption (TDE)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKeyP@ss!';
CREATE CERTIFICATE tde_cert WITH SUBJECT = 'TDE Certificate';
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE tde_cert;
ALTER DATABASE CompanyDB SET ENCRYPTION ON;

-- =============================================================================
-- SECTION 36: FULL-TEXT SEARCH
-- =============================================================================

-- 36.1 Setup
CREATE FULLTEXT CATALOG ft_products_catalog AS DEFAULT;

CREATE FULLTEXT INDEX ON inventory.products (
    product_name LANGUAGE 1033,
    description  LANGUAGE 1033
)
KEY INDEX pk_products
ON ft_products_catalog
WITH CHANGE_TRACKING AUTO;

-- 36.2 CONTAINS
SELECT product_id, product_name, unit_price
FROM inventory.products
WHERE CONTAINS(product_name, 'laptop OR keyboard');

SELECT product_id, product_name
FROM inventory.products
WHERE CONTAINS(product_name, '"wireless mouse"');  -- Exact phrase

SELECT product_id, product_name
FROM inventory.products
WHERE CONTAINS(product_name, 'NEAR((laptop, keyboard), 5)');  -- Proximity

SELECT product_id, product_name
FROM inventory.products
WHERE CONTAINS(product_name, 'FORMSOF(INFLECTIONAL, compute)');  -- Inflectional

-- 36.3 FREETEXT
SELECT product_id, product_name, unit_price
FROM inventory.products
WHERE FREETEXT(product_name, 'portable computing device');

-- 36.4 CONTAINSTABLE (with ranking)
SELECT p.product_id, p.product_name, ft.RANK
FROM inventory.products p
JOIN CONTAINSTABLE(inventory.products, product_name, 'laptop') ft
    ON p.product_id = ft.[KEY]
ORDER BY ft.RANK DESC;

-- 36.5 FREETEXTTABLE
SELECT p.product_id, p.product_name, ft.RANK
FROM inventory.products p
JOIN FREETEXTTABLE(inventory.products, *, 'wireless office equipment') ft
    ON p.product_id = ft.[KEY]
ORDER BY ft.RANK DESC;

-- =============================================================================
-- SECTION 37: ADVANCED ANALYTICS
-- =============================================================================

-- 37.1 Year-over-Year comparison
WITH yearly_sales AS (
    SELECT
        YEAR(order_date)    AS sale_year,
        MONTH(order_date)   AS sale_month,
        SUM(total_amount)   AS monthly_revenue,
        COUNT(order_id)     AS order_count
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    curr.sale_year,
    curr.sale_month,
    DATENAME(MONTH, DATEFROMPARTS(curr.sale_year, curr.sale_month, 1)) AS month_name,
    curr.monthly_revenue,
    curr.order_count,
    prev.monthly_revenue                                AS prev_year_revenue,
    curr.monthly_revenue - prev.monthly_revenue         AS yoy_change,
    CASE WHEN prev.monthly_revenue > 0
         THEN ROUND((curr.monthly_revenue - prev.monthly_revenue) / prev.monthly_revenue * 100, 2)
         ELSE NULL
    END                                                 AS yoy_pct_change
FROM yearly_sales curr
LEFT JOIN yearly_sales prev ON curr.sale_month = prev.sale_month
                            AND curr.sale_year  = prev.sale_year + 1
ORDER BY curr.sale_year, curr.sale_month;

-- 37.2 Cohort Analysis
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(CAST(order_date AS DATE))                   AS first_order_date,
        DATEFROMPARTS(YEAR(MIN(order_date)), MONTH(MIN(order_date)), 1) AS cohort_month
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
),
order_activity AS (
    SELECT
        o.customer_id,
        fo.cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS order_month,
        DATEDIFF(MONTH, fo.cohort_month,
            DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)) AS months_since_first
    FROM sales.orders o
    JOIN first_orders fo ON o.customer_id = fo.customer_id
    WHERE o.status = 'DELIVERED'
)
SELECT
    cohort_month,
    COUNT(DISTINCT CASE WHEN months_since_first = 0 THEN customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN months_since_first = 1 THEN customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN months_since_first = 2 THEN customer_id END) AS month_2,
    COUNT(DISTINCT CASE WHEN months_since_first = 3 THEN customer_id END) AS month_3,
    COUNT(DISTINCT CASE WHEN months_since_first = 6 THEN customer_id END) AS month_6,
    COUNT(DISTINCT CASE WHEN months_since_first = 12 THEN customer_id END) AS month_12
FROM order_activity
GROUP BY cohort_month
ORDER BY cohort_month;

-- 37.3 RFM Analysis (Recency, Frequency, Monetary)
WITH rfm_base AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, MAX(order_date), GETDATE())   AS recency_days,
        COUNT(order_id)                             AS frequency,
        SUM(total_amount)                           AS monetary
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,  -- Lower days = higher score
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        r_score + f_score + m_score AS rfm_total,
        CAST(r_score AS VARCHAR) + CAST(f_score AS VARCHAR) + CAST(m_score AS VARCHAR) AS rfm_cell
    FROM rfm_scores
)
SELECT
    rs.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    rs.recency_days,
    rs.frequency,
    ROUND(rs.monetary, 2) AS monetary,
    rs.r_score,
    rs.f_score,
    rs.m_score,
    rs.rfm_total,
    rs.rfm_cell,
    CASE
        WHEN rs.r_score >= 4 AND rs.f_score >= 4 AND rs.m_score >= 4 THEN 'Champions'
        WHEN rs.r_score >= 3 AND rs.f_score >= 3                     THEN 'Loyal Customers'
        WHEN rs.r_score >= 4 AND rs.f_score <= 2                     THEN 'Recent Customers'
        WHEN rs.r_score >= 3 AND rs.m_score >= 3                     THEN 'Potential Loyalists'
        WHEN rs.r_score <= 2 AND rs.f_score >= 4 AND rs.m_score >= 4 THEN 'At Risk'
        WHEN rs.r_score <= 2 AND rs.f_score >= 2                     THEN 'Cant Lose Them'
        WHEN rs.r_score <= 2 AND rs.f_score <= 2                     THEN 'Lost'
        ELSE 'Needs Attention'
    END AS customer_segment
FROM rfm_segments rs
JOIN sales.customers c ON rs.customer_id = c.customer_id
ORDER BY rs.rfm_total DESC;

-- 37.4 Market Basket Analysis
WITH order_pairs AS (
    SELECT
        a.product_id AS product_a,
        b.product_id AS product_b,
        COUNT(DISTINCT a.order_id) AS co_occurrence_count
    FROM sales.order_items a
    JOIN sales.order_items b ON a.order_id = b.order_id
                             AND a.product_id < b.product_id
    GROUP BY a.product_id, b.product_id
    HAVING COUNT(DISTINCT a.order_id) >= 2
),
product_counts AS (
    SELECT product_id, COUNT(DISTINCT order_id) AS order_count
    FROM sales.order_items
    GROUP BY product_id
),
total_orders AS (
    SELECT COUNT(DISTINCT order_id) AS total FROM sales.orders
)
SELECT
    pa.product_name AS product_a_name,
    pb.product_name AS product_b_name,
    op.co_occurrence_count,
    ROUND(op.co_occurrence_count * 100.0 / t.total, 2) AS support_pct,
    ROUND(op.co_occurrence_count * 100.0 / pca.order_count, 2) AS confidence_a_to_b,
    ROUND(op.co_occurrence_count * 100.0 / pcb.order_count, 2) AS confidence_b_to_a,
    ROUND(
        (op.co_occurrence_count * 1.0 / t.total) /
        ((pca.order_count * 1.0 / t.total) * (pcb.order_count * 1.0 / t.total)),
        3
    ) AS lift
FROM order_pairs op
JOIN inventory.products pa ON op.product_a = pa.product_id
JOIN inventory.products pb ON op.product_b = pb.product_id
JOIN product_counts pca ON op.product_a = pca.product_id
JOIN product_counts pcb ON op.product_b = pcb.product_id
CROSS JOIN total_orders t
ORDER BY lift DESC, op.co_occurrence_count DESC;

-- 37.5 Percentile calculations
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    department_id,
    salary,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) AS p25_salary,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) AS median_salary,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) AS p75_salary,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) AS p90_salary,
    PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) AS median_disc,
    CUME_DIST() OVER (PARTITION BY department_id ORDER BY salary) AS cumulative_dist,
    PERCENT_RANK() OVER (PARTITION BY department_id ORDER BY salary) AS percent_rank
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY department_id, salary;

-- =============================================================================
-- SECTION 38: MATERIALIZED VIEWS (INDEXED VIEWS)
-- =============================================================================

-- 38.1 Create indexed view
CREATE OR ALTER VIEW sales.vw_product_sales_summary
WITH SCHEMABINDING AS
SELECT
    oi.product_id,
    YEAR(o.order_date)      AS sale_year,
    MONTH(o.order_date)     AS sale_month,
    COUNT_BIG(*)            AS order_line_count,
    SUM(oi.quantity)        AS total_quantity_sold,
    SUM(oi.line_total)      AS total_revenue,
    SUM(oi.quantity * p.cost_price) AS total_cost
FROM sales.order_items oi
JOIN sales.orders o ON oi.order_id = o.order_id
JOIN inventory.products p ON oi.product_id = p.product_id
WHERE o.status = 'DELIVERED'
GROUP BY oi.product_id, YEAR(o.order_date), MONTH(o.order_date);

-- Create clustered index to materialize the view
CREATE UNIQUE CLUSTERED INDEX idx_product_sales_summary
ON sales.vw_product_sales_summary(product_id, sale_year, sale_month);

-- Create additional non-clustered indexes
CREATE NONCLUSTERED INDEX idx_pss_year_month
ON sales.vw_product_sales_summary(sale_year, sale_month)
INCLUDE (total_revenue, total_quantity_sold);

-- 38.2 Query the indexed view
SELECT
    p.product_name,
    p.category,
    v.sale_year,
    v.sale_month,
    v.total_quantity_sold,
    ROUND(v.total_revenue, 2) AS total_revenue,
    ROUND(v.total_cost, 2) AS total_cost,
    ROUND(v.total_revenue - v.total_cost, 2) AS gross_profit,
    ROUND((v.total_revenue - v.total_cost) / NULLIF(v.total_revenue, 0) * 100, 2) AS margin_pct
FROM sales.vw_product_sales_summary v
JOIN inventory.products p ON v.product_id = p.product_id
WHERE v.sale_year = 2024
ORDER BY v.total_revenue DESC;

-- =============================================================================
-- SECTION 39: BACKUP AND RESTORE
-- =============================================================================

-- 39.1 Full backup
BACKUP DATABASE CompanyDB
TO DISK = 'D:\Backups\CompanyDB_Full_20240101.bak'
WITH
    COMPRESSION,
    CHECKSUM,
    STATS = 10,
    NAME = 'CompanyDB Full Backup 2024-01-01',
    DESCRIPTION = 'Full database backup before year-end processing';

-- 39.2 Differential backup
BACKUP DATABASE CompanyDB
TO DISK = 'D:\Backups\CompanyDB_Diff_20240115.bak'
WITH
    DIFFERENTIAL,
    COMPRESSION,
    CHECKSUM,
    STATS = 10;

-- 39.3 Transaction log backup
BACKUP LOG CompanyDB
TO DISK = 'D:\Backups\CompanyDB_Log_20240115_1400.trn'
WITH
    COMPRESSION,
    CHECKSUM,
    STATS = 10;

-- 39.4 Restore full backup
RESTORE DATABASE CompanyDB_Restored
FROM DISK = 'D:\Backups\CompanyDB_Full_20240101.bak'
WITH
    MOVE 'CompanyDB' TO 'D:\Data\CompanyDB_Restored.mdf',
    MOVE 'CompanyDB_log' TO 'D:\Logs\CompanyDB_Restored_log.ldf',
    NORECOVERY,
    STATS = 10;

-- 39.5 Restore differential
RESTORE DATABASE CompanyDB_Restored
FROM DISK = 'D:\Backups\CompanyDB_Diff_20240115.bak'
WITH NORECOVERY, STATS = 10;

-- 39.6 Restore log (point-in-time)
RESTORE LOG CompanyDB_Restored
FROM DISK = 'D:\Backups\CompanyDB_Log_20240115_1400.trn'
WITH
    RECOVERY,
    STOPAT = '2024-01-15 13:45:00';

-- 39.7 Verify backup
RESTORE VERIFYONLY
FROM DISK = 'D:\Backups\CompanyDB_Full_20240101.bak'
WITH CHECKSUM;

-- =============================================================================
-- SECTION 40: SYSTEM QUERIES AND DIAGNOSTICS
-- =============================================================================

-- 40.1 Table sizes
SELECT
    s.name                                          AS schema_name,
    t.name                                          AS table_name,
    p.rows                                          AS row_count,
    ROUND(SUM(a.total_pages) * 8 / 1024.0, 2)      AS total_size_mb,
    ROUND(SUM(a.used_pages) * 8 / 1024.0, 2)       AS used_size_mb,
    ROUND((SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024.0, 2) AS unused_size_mb
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
GROUP BY s.name, t.name, p.rows
ORDER BY total_size_mb DESC;

-- 40.2 Index usage statistics
SELECT
    OBJECT_NAME(i.object_id)    AS table_name,
    i.name                      AS index_name,
    i.type_desc                 AS index_type,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan,
    ius.last_user_update
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id
    AND i.index_id = ius.index_id
    AND ius.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY OBJECT_NAME(i.object_id), i.name;

-- 40.3 Missing indexes
SELECT TOP 20
    ROUND(migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans), 0) AS improvement_measure,
    mid.statement AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_total_user_cost,
    migs.avg_user_impact
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID()
ORDER BY improvement_measure DESC;

-- 40.4 Blocking queries
SELECT
    blocking.session_id         AS blocking_session_id,
    blocked.session_id          AS blocked_session_id,
    blocking_sql.text           AS blocking_sql,
    blocked_sql.text            AS blocked_sql,
    blocked.wait_type,
    blocked.wait_time / 1000.0  AS wait_seconds,
    blocked.status
FROM sys.dm_exec_sessions blocked
JOIN sys.dm_exec_sessions blocking ON blocked.blocking_session_id = blocking.session_id
CROSS APPLY sys.dm_exec_sql_text(blocked.most_recent_sql_handle)  AS blocked_sql
CROSS APPLY sys.dm_exec_sql_text(blocking.most_recent_sql_handle) AS blocking_sql
WHERE blocked.blocking_session_id > 0;

-- 40.5 Active connections
SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    s.status,
    s.cpu_time,
    s.memory_usage * 8          AS memory_kb,
    s.total_elapsed_time / 1000 AS elapsed_seconds,
    s.reads,
    s.writes,
    s.logical_reads,
    DB_NAME(r.database_id)      AS database_name,
    t.text                      AS current_sql
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE s.is_user_process = 1
ORDER BY s.cpu_time DESC;

-- 40.6 Long-running queries
SELECT TOP 20
    qs.total_elapsed_time / qs.execution_count / 1000.0 AS avg_elapsed_ms,
    qs.total_elapsed_time / 1000.0                      AS total_elapsed_ms,
    qs.execution_count,
    qs.total_logical_reads / qs.execution_count         AS avg_logical_reads,
    qs.total_physical_reads / qs.execution_count        AS avg_physical_reads,
    qs.total_worker_time / qs.execution_count / 1000.0  AS avg_cpu_ms,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.text)
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS query_text,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY avg_elapsed_ms DESC;

-- 40.7 Database file sizes
SELECT
    name                        AS file_name,
    physical_name               AS file_path,
    type_desc                   AS file_type,
    ROUND(size * 8 / 1024.0, 2) AS size_mb,
    ROUND(FILEPROPERTY(name, 'SpaceUsed') * 8 / 1024.0, 2) AS used_mb,
    ROUND((size - FILEPROPERTY(name, 'SpaceUsed')) * 8 / 1024.0, 2) AS free_mb,
    max_size,
    growth,
    is_percent_growth
FROM sys.database_files
ORDER BY type_desc, name;

-- 40.8 Wait statistics
SELECT TOP 20
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms,
    wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms,
    ROUND(wait_time_ms * 100.0 / SUM(wait_time_ms) OVER (), 2) AS pct_of_total
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'SLEEP_TASK','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_AUTO_EVENT',
    'DISPATCHER_QUEUE_SEMAPHORE','FT_IFTS_SCHEDULER_IDLE_WAIT',
    'HADR_FILESTREAM_IOMGR_IOCOMPLETION','HADR_WORK_QUEUE',
    'LAZYWRITER_SLEEP','LOGMGR_QUEUE','ONDEMAND_TASK_QUEUE',
    'REQUEST_FOR_DEADLOCK_MONITOR','RESOURCE_QUEUE','SERVER_IDLE_CHECK',
    'SLEEP_DBSTARTUP','SLEEP_DCOMSTARTUP','SLEEP_MASTERDBREADY',
    'SLEEP_MASTERMDREADY','SLEEP_MASTERUPGRADED','SLEEP_MSDBSTARTUP',
    'SLEEP_SYSTEMTASK','SLEEP_TEMPDBSTARTUP','SNI_HTTP_ACCEPT',
    'SP_SERVER_DIAGNOSTICS_SLEEP','SQLTRACE_BUFFER_FLUSH',
    'SQLTRACE_INCREMENTAL_FLUSH_SLEEP','WAITFOR','XE_DISPATCHER_WAIT',
    'XE_TIMER_EVENT','BROKER_EVENTHANDLER','CHECKPOINT_QUEUE',
    'DBMIRROR_EVENTS_QUEUE','SQLTRACE_WAIT_ENTRIES'
)
ORDER BY wait_time_ms DESC;

-- =============================================================================
-- SECTION 41: ADVANCED WINDOW FUNCTION PATTERNS
-- =============================================================================

-- 41.1 Gap and Island detection
WITH order_sequence AS (
    SELECT
        customer_id,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn,
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS grp
    FROM sales.orders
    WHERE status = 'DELIVERED'
),
consecutive_groups AS (
    SELECT
        customer_id,
        MIN(order_date) AS group_start,
        MAX(order_date) AS group_end,
        COUNT(*) AS consecutive_orders
    FROM order_sequence
    GROUP BY customer_id, grp
)
SELECT
    c.first_name + ' ' + c.last_name AS customer_name,
    cg.group_start,
    cg.group_end,
    cg.consecutive_orders,
    DATEDIFF(DAY, cg.group_start, cg.group_end) AS span_days
FROM consecutive_groups cg
JOIN sales.customers c ON cg.customer_id = c.customer_id
WHERE cg.consecutive_orders >= 2
ORDER BY cg.consecutive_orders DESC;

-- 41.2 Running totals with reset
SELECT
    customer_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id, YEAR(order_date), MONTH(order_date)
        ORDER BY order_date
        ROWS UNBOUNDED PRECEDING
    ) AS monthly_running_total,
    SUM(total_amount) OVER (
        PARTITION BY customer_id, YEAR(order_date)
        ORDER BY order_date
        ROWS UNBOUNDED PRECEDING
    ) AS yearly_running_total,
    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS UNBOUNDED PRECEDING
    ) AS lifetime_running_total
FROM sales.orders
WHERE status = 'DELIVERED'
ORDER BY customer_id, order_date;

-- 41.3 Median calculation
SELECT
    department_id,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) AS median_salary,
    AVG(salary) OVER (PARTITION BY department_id) AS mean_salary,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) -
    AVG(salary) OVER (PARTITION BY department_id) AS median_mean_diff
FROM hr.employees
WHERE status = 'ACTIVE';

-- 41.4 Top N per group
WITH ranked_employees AS (
    SELECT
        employee_id,
        first_name + ' ' + last_name AS full_name,
        department_id,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
    FROM hr.employees
    WHERE status = 'ACTIVE'
)
SELECT
    re.employee_id,
    re.full_name,
    d.department_name,
    re.salary,
    re.salary_rank
FROM ranked_employees re
JOIN hr.departments d ON re.department_id = d.department_id
WHERE re.salary_rank <= 3
ORDER BY d.department_name, re.salary_rank;

-- =============================================================================
-- SECTION 42: TEMPORAL TABLES (SYSTEM-VERSIONED)
-- =============================================================================

-- 42.1 Create temporal table
CREATE TABLE hr.employees_temporal (
    employee_id     INT           NOT NULL,
    first_name      VARCHAR(50)   NOT NULL,
    last_name       VARCHAR(50)   NOT NULL,
    salary          DECIMAL(12,2) NOT NULL,
    department_id   INT,
    job_title       VARCHAR(100),
    valid_from      DATETIME2     GENERATED ALWAYS AS ROW START NOT NULL,
    valid_to        DATETIME2     GENERATED ALWAYS AS ROW END   NOT NULL,
    PERIOD FOR SYSTEM_TIME (valid_from, valid_to),
    CONSTRAINT pk_emp_temporal PRIMARY KEY (employee_id)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = hr.employees_temporal_history));

-- 42.2 Query current data
SELECT * FROM hr.employees_temporal;

-- 42.3 Query historical data (AS OF)
SELECT *
FROM hr.employees_temporal
FOR SYSTEM_TIME AS OF '2023-06-01 00:00:00';

-- 42.4 Query data between two points
SELECT *
FROM hr.employees_temporal
FOR SYSTEM_TIME BETWEEN '2023-01-01' AND '2023-12-31';

-- 42.5 Query all versions
SELECT *
FROM hr.employees_temporal
FOR SYSTEM_TIME ALL
WHERE employee_id = 1
ORDER BY valid_from;

-- 42.6 Disable/Enable system versioning
ALTER TABLE hr.employees_temporal SET (SYSTEM_VERSIONING = OFF);
ALTER TABLE hr.employees_temporal SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = hr.employees_temporal_history));

-- =============================================================================
-- SECTION 43: GRAPH TABLES (SQL SERVER 2017+)
-- =============================================================================

-- 43.1 Node tables
CREATE TABLE hr.employee_node (
    employee_id INT PRIMARY KEY,
    name        VARCHAR(100),
    title       VARCHAR(100)
) AS NODE;

CREATE TABLE hr.department_node (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(100)
) AS NODE;

-- 43.2 Edge tables
CREATE TABLE hr.reports_to (
    start_date DATE,
    end_date   DATE
) AS EDGE;

CREATE TABLE hr.works_in AS EDGE;

-- 43.3 Insert graph data
INSERT INTO hr.employee_node VALUES (1, 'John Smith', 'CEO');
INSERT INTO hr.employee_node VALUES (2, 'Jane Doe', 'CTO');
INSERT INTO hr.employee_node VALUES (3, 'Bob Johnson', 'Engineer');

INSERT INTO hr.reports_to ($from_id, $to_id, start_date)
SELECT e1.$node_id, e2.$node_id, '2020-01-01'
FROM hr.employee_node e1, hr.employee_node e2
WHERE e1.employee_id = 3 AND e2.employee_id = 2;

-- 43.4 Graph query with MATCH
SELECT
    e1.name AS employee,
    e2.name AS manager
FROM hr.employee_node e1,
     hr.reports_to rt,
     hr.employee_node e2
WHERE MATCH(e1-(rt)->e2);

-- Shortest path
SELECT
    e1.name AS start_node,
    e2.name AS end_node,
    STRING_AGG(e.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS path
FROM hr.employee_node e1,
     hr.reports_to FOR PATH rt,
     hr.employee_node FOR PATH e,
     hr.employee_node e2
WHERE MATCH(SHORTEST_PATH(e1(-(rt)->e)+e2))
  AND e1.employee_id = 3;

-- =============================================================================
-- SECTION 44: COLUMNSTORE INDEXES
-- =============================================================================

-- 44.1 Clustered columnstore index (for analytics/DW tables)
CREATE TABLE analytics.fact_sales (
    sale_id         BIGINT        NOT NULL,
    sale_date       DATE          NOT NULL,
    customer_id     INT           NOT NULL,
    product_id      INT           NOT NULL,
    employee_id     INT,
    quantity        INT           NOT NULL,
    unit_price      DECIMAL(12,2) NOT NULL,
    discount_pct    DECIMAL(5,2)  DEFAULT 0,
    net_amount      DECIMAL(12,2) NOT NULL,
    cost_amount     DECIMAL(12,2),
    region          VARCHAR(100),
    channel         VARCHAR(50)
);

CREATE CLUSTERED COLUMNSTORE INDEX cci_fact_sales
ON analytics.fact_sales;

-- 44.2 Non-clustered columnstore index (on OLTP table)
CREATE NONCLUSTERED COLUMNSTORE INDEX ncci_orders_analytics
ON sales.orders (order_date, customer_id, total_amount, status, payment_status);

-- 44.3 Columnstore analytics query (benefits from batch mode)
SELECT
    YEAR(sale_date)     AS sale_year,
    MONTH(sale_date)    AS sale_month,
    region,
    channel,
    COUNT(*)            AS transaction_count,
    SUM(quantity)       AS total_units,
    SUM(net_amount)     AS total_revenue,
    SUM(cost_amount)    AS total_cost,
    SUM(net_amount - cost_amount) AS gross_profit,
    AVG(net_amount)     AS avg_transaction_value
FROM analytics.fact_sales
WHERE sale_date >= '2024-01-01'
GROUP BY YEAR(sale_date), MONTH(sale_date), region, channel
ORDER BY sale_year, sale_month, region;

-- =============================================================================
-- SECTION 45: IN-MEMORY OLTP (HEKATON)
-- =============================================================================

-- 45.1 Memory-optimized table
CREATE TABLE sales.orders_inmemory (
    order_id        INT           NOT NULL,
    customer_id     INT           NOT NULL,
    order_date      DATETIME2     NOT NULL,
    total_amount    DECIMAL(12,2) NOT NULL,
    status          VARCHAR(20)   NOT NULL,
    CONSTRAINT pk_orders_inmemory PRIMARY KEY NONCLUSTERED (order_id)
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);

-- 45.2 Natively compiled stored procedure
CREATE OR ALTER PROCEDURE sales.usp_insert_order_native
    @order_id       INT,
    @customer_id    INT,
    @total_amount   DECIMAL(12,2)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')
    INSERT INTO sales.orders_inmemory (order_id, customer_id, order_date, total_amount, status)
    VALUES (@order_id, @customer_id, SYSDATETIME(), @total_amount, 'PENDING');
END;

-- =============================================================================
-- SECTION 46: LINKED SERVERS AND DISTRIBUTED QUERIES
-- =============================================================================

-- 46.1 Create linked server
EXEC sp_addlinkedserver
    @server     = 'REMOTE_SERVER',
    @srvproduct = 'SQL Server';

EXEC sp_addlinkedsrvlogin
    @rmtsrvname  = 'REMOTE_SERVER',
    @useself     = 'FALSE',
    @locallogin  = NULL,
    @rmtuser     = 'remote_user',
    @rmtpassword = 'remote_password';

-- 46.2 Query linked server (four-part naming)
SELECT *
FROM REMOTE_SERVER.RemoteDB.hr.employees;

-- 46.3 OPENQUERY
SELECT *
FROM OPENQUERY(REMOTE_SERVER, 'SELECT employee_id, first_name, last_name FROM hr.employees WHERE status = ''ACTIVE''');

-- 46.4 OPENDATASOURCE
SELECT *
FROM OPENDATASOURCE(
    'SQLNCLI',
    'Data Source=REMOTE_SERVER;Integrated Security=SSPI'
).RemoteDB.hr.employees;

-- 46.5 Distributed transaction
BEGIN DISTRIBUTED TRANSACTION;
    UPDATE hr.employees SET salary = salary * 1.05 WHERE department_id = 1;
    UPDATE REMOTE_SERVER.RemoteDB.hr.employees SET salary = salary * 1.05 WHERE department_id = 1;
COMMIT TRANSACTION;

-- =============================================================================
-- SECTION 47: XML OPERATIONS
-- =============================================================================

-- 47.1 Store XML
CREATE TABLE hr.employee_documents (
    doc_id      INT           NOT NULL IDENTITY(1,1),
    employee_id INT           NOT NULL,
    doc_type    VARCHAR(50)   NOT NULL,
    doc_content XML           NOT NULL,
    created_at  DATETIME      DEFAULT GETDATE(),
    CONSTRAINT pk_emp_docs PRIMARY KEY (doc_id)
);

INSERT INTO hr.employee_documents (employee_id, doc_type, doc_content)
VALUES (1, 'PERFORMANCE_REVIEW', N'
<review year="2024" quarter="Q1">
    <employee id="1">
        <name>John Smith</name>
        <department>Engineering</department>
    </employee>
    <scores>
        <score category="technical" value="4.5" />
        <score category="communication" value="4.0" />
        <score category="leadership" value="3.8" />
        <score category="teamwork" value="4.2" />
    </scores>
    <comments>
        <comment type="strength">Excellent problem-solving skills</comment>
        <comment type="improvement">Could improve documentation</comment>
    </comments>
    <overall_rating>4.1</overall_rating>
    <recommended_raise>8</recommended_raise>
</review>');

-- 47.2 XQuery - value()
SELECT
    doc_id,
    employee_id,
    doc_content.value('(/review/@year)[1]', 'INT')          AS review_year,
    doc_content.value('(/review/@quarter)[1]', 'VARCHAR(5)') AS quarter,
    doc_content.value('(/review/overall_rating)[1]', 'DECIMAL(3,1)') AS overall_rating,
    doc_content.value('(/review/recommended_raise)[1]', 'INT') AS raise_pct
FROM hr.employee_documents
WHERE doc_type = 'PERFORMANCE_REVIEW';

-- 47.3 XQuery - query()
SELECT
    doc_id,
    doc_content.query('/review/scores') AS scores_xml,
    doc_content.query('/review/comments/comment[@type="strength"]') AS strengths
FROM hr.employee_documents;

-- 47.4 XQuery - nodes() for shredding
SELECT
    d.doc_id,
    d.employee_id,
    score.value('@category', 'VARCHAR(50)') AS category,
    score.value('@value', 'DECIMAL(3,1)')   AS score_value
FROM hr.employee_documents d
CROSS APPLY d.doc_content.nodes('/review/scores/score') AS scores(score)
ORDER BY d.doc_id, category;

-- 47.5 XML index
CREATE PRIMARY XML INDEX idx_xml_primary ON hr.employee_documents(doc_content);
CREATE XML INDEX idx_xml_path ON hr.employee_documents(doc_content) USING XML INDEX idx_xml_primary FOR PATH;
CREATE XML INDEX idx_xml_value ON hr.employee_documents(doc_content) USING XML INDEX idx_xml_primary FOR VALUE;

-- 47.6 FOR XML
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
FOR XML PATH('employee'), ROOT('employees'), ELEMENTS;

-- =============================================================================
-- SECTION 48: SPATIAL DATA
-- =============================================================================

-- 48.1 Geography data type
CREATE TABLE sales.store_locations (
    store_id    INT           NOT NULL IDENTITY(1,1),
    store_name  VARCHAR(100)  NOT NULL,
    address     VARCHAR(200),
    city        VARCHAR(100),
    state       VARCHAR(50),
    location    GEOGRAPHY,
    CONSTRAINT pk_stores PRIMARY KEY (store_id)
);

-- Insert with coordinates (longitude, latitude)
INSERT INTO sales.store_locations (store_name, city, state, location)
VALUES
    ('NYC Store',  'New York',    'NY', GEOGRAPHY::Point(40.7128, -74.0060, 4326)),
    ('LA Store',   'Los Angeles', 'CA', GEOGRAPHY::Point(34.0522, -118.2437, 4326)),
    ('Chicago',    'Chicago',     'IL', GEOGRAPHY::Point(41.8781, -87.6298, 4326)),
    ('Houston',    'Houston',     'TX', GEOGRAPHY::Point(29.7604, -95.3698, 4326)),
    ('Phoenix',    'Phoenix',     'AZ', GEOGRAPHY::Point(33.4484, -112.0740, 4326));

-- 48.2 Spatial queries
SELECT
    s1.store_name AS store_1,
    s2.store_name AS store_2,
    ROUND(s1.location.STDistance(s2.location) / 1000, 2) AS distance_km,
    ROUND(s1.location.STDistance(s2.location) / 1609.34, 2) AS distance_miles
FROM sales.store_locations s1
CROSS JOIN sales.store_locations s2
WHERE s1.store_id < s2.store_id
ORDER BY distance_km;

-- Find stores within 2000 km of NYC
DECLARE @nyc GEOGRAPHY = GEOGRAPHY::Point(40.7128, -74.0060, 4326);
SELECT
    store_name,
    city,
    ROUND(location.STDistance(@nyc) / 1000, 2) AS distance_km
FROM sales.store_locations
WHERE location.STDistance(@nyc) <= 2000000  -- meters
ORDER BY distance_km;

-- =============================================================================
-- SECTION 49: QUERY STORE
-- =============================================================================

-- 49.1 Enable Query Store
ALTER DATABASE CompanyDB SET QUERY_STORE = ON;
ALTER DATABASE CompanyDB SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);

-- 49.2 Top resource-consuming queries
SELECT TOP 20
    q.query_id,
    qt.query_sql_text,
    rs.count_executions,
    rs.avg_duration / 1000.0        AS avg_duration_ms,
    rs.avg_cpu_time / 1000.0        AS avg_cpu_ms,
    rs.avg_logical_io_reads,
    rs.avg_physical_io_reads,
    rs.avg_rowcount,
    p.plan_id,
    p.is_forced_plan
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
ORDER BY rs.avg_duration DESC;

-- 49.3 Force a query plan
EXEC sp_query_store_force_plan @query_id = 1, @plan_id = 1;

-- 49.4 Unforce a plan
EXEC sp_query_store_unforce_plan @query_id = 1, @plan_id = 1;

-- 49.5 Flush Query Store
EXEC sp_query_store_flush_db;

-- =============================================================================
-- SECTION 50: EXTENDED EVENTS
-- =============================================================================

-- 50.1 Create Extended Events session
CREATE EVENT SESSION [monitor_long_queries] ON SERVER
ADD EVENT sqlserver.sql_statement_completed (
    ACTION (
        sqlserver.sql_text,
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.client_hostname,
        sqlserver.plan_handle
    )
    WHERE (
        [duration] > 5000000  -- 5 seconds in microseconds
        AND [sqlserver].[database_name] = N'CompanyDB'
    )
),
ADD EVENT sqlserver.rpc_completed (
    WHERE ([duration] > 5000000)
)
ADD TARGET package0.event_file (
    SET filename = N'D:\XEvents\long_queries.xel',
        max_file_size = 50,
        max_rollover_files = 5
),
ADD TARGET package0.ring_buffer (
    SET max_memory = 51200
)
WITH (
    MAX_MEMORY = 4096 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    STARTUP_STATE = ON
);

-- 50.2 Start/Stop session
ALTER EVENT SESSION [monitor_long_queries] ON SERVER STATE = START;
ALTER EVENT SESSION [monitor_long_queries] ON SERVER STATE = STOP;

-- 50.3 Read ring buffer
SELECT
    event_data.value('(event/@name)[1]', 'VARCHAR(50)')         AS event_name,
    event_data.value('(event/@timestamp)[1]', 'DATETIME2')      AS event_time,
    event_data.value('(event/data[@name="duration"]/value)[1]', 'BIGINT') / 1000000.0 AS duration_sec,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'NVARCHAR(MAX)') AS sql_text,
    event_data.value('(event/action[@name="username"]/value)[1]', 'VARCHAR(100)') AS username
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_session_targets t
    JOIN sys.dm_xe_sessions s ON t.event_session_address = s.address
    WHERE s.name = 'monitor_long_queries'
      AND t.target_name = 'ring_buffer'
) AS ring_buffer_data
CROSS APPLY target_data.nodes('//RingBufferTarget/event') AS events(event_data)
ORDER BY event_time DESC;

-- =============================================================================
-- SECTION 51: ADDITIONAL PRACTICE QUERIES
-- =============================================================================

-- 51.1 Complex reporting query
WITH monthly_metrics AS (
    SELECT
        YEAR(o.order_date)                          AS year,
        MONTH(o.order_date)                         AS month,
        DATENAME(MONTH, o.order_date)               AS month_name,
        COUNT(DISTINCT o.order_id)                  AS total_orders,
        COUNT(DISTINCT o.customer_id)               AS unique_customers,
        COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' THEN o.order_id END) AS completed_orders,
        COUNT(DISTINCT CASE WHEN o.status = 'CANCELLED' THEN o.order_id END) AS cancelled_orders,
        SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total_amount ELSE 0 END) AS revenue,
        SUM(CASE WHEN o.status = 'DELIVERED' THEN o.discount_amount ELSE 0 END) AS discounts_given,
        AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total_amount END) AS avg_order_value,
        SUM(CASE WHEN o.status = 'DELIVERED' THEN oi.quantity ELSE 0 END) AS units_sold
    FROM sales.orders o
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date), DATENAME(MONTH, o.order_date)
),
metrics_with_growth AS (
    SELECT
        *,
        LAG(revenue, 1) OVER (ORDER BY year, month) AS prev_month_revenue,
        LAG(total_orders, 1) OVER (ORDER BY year, month) AS prev_month_orders,
        SUM(revenue) OVER (PARTITION BY year ORDER BY month ROWS UNBOUNDED PRECEDING) AS ytd_revenue,
        SUM(total_orders) OVER (PARTITION BY year ORDER BY month ROWS UNBOUNDED PRECEDING) AS ytd_orders
    FROM monthly_metrics
)
SELECT
    year,
    month,
    month_name,
    total_orders,
    unique_customers,
    completed_orders,
    cancelled_orders,
    ROUND(revenue, 2) AS revenue,
    ROUND(discounts_given, 2) AS discounts_given,
    ROUND(avg_order_value, 2) AS avg_order_value,
    units_sold,
    ROUND(prev_month_revenue, 2) AS prev_month_revenue,
    CASE WHEN prev_month_revenue > 0
         THEN ROUND((revenue - prev_month_revenue) / prev_month_revenue * 100, 2)
         ELSE NULL
    END AS mom_growth_pct,
    ROUND(ytd_revenue, 2) AS ytd_revenue,
    ytd_orders,
    ROUND(completed_orders * 100.0 / NULLIF(total_orders, 0), 2) AS completion_rate_pct,
    ROUND(cancelled_orders * 100.0 / NULLIF(total_orders, 0), 2) AS cancellation_rate_pct
FROM metrics_with_growth
ORDER BY year, month;

-- 51.2 Employee performance dashboard
WITH emp_metrics AS (
    SELECT
        e.employee_id,
        e.first_name + ' ' + e.last_name AS full_name,
        e.job_title,
        e.salary,
        e.hire_date,
        d.department_name,
        COUNT(DISTINCT o.order_id) AS orders_handled,
        SUM(o.total_amount) AS total_sales,
        AVG(o.total_amount) AS avg_order_value,
        COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' THEN o.order_id END) AS completed_orders,
        COUNT(DISTINCT CASE WHEN o.status = 'CANCELLED' THEN o.order_id END) AS cancelled_orders,
        DATEDIFF(YEAR, e.hire_date, GETDATE()) AS tenure_years
    FROM hr.employees e
    JOIN hr.departments d ON e.department_id = d.department_id
    LEFT JOIN sales.orders o ON e.employee_id = o.employee_id
    WHERE e.status = 'ACTIVE'
    GROUP BY e.employee_id, e.first_name, e.last_name, e.job_title, e.salary, e.hire_date, d.department_name
)
SELECT
    employee_id,
    full_name,
    job_title,
    department_name,
    salary,
    tenure_years,
    orders_handled,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(avg_order_value, 2) AS avg_order_value,
    completed_orders,
    cancelled_orders,
    ROUND(completed_orders * 100.0 / NULLIF(orders_handled, 0), 2) AS success_rate_pct,
    RANK() OVER (PARTITION BY department_name ORDER BY total_sales DESC) AS sales_rank_in_dept,
    RANK() OVER (ORDER BY total_sales DESC) AS overall_sales_rank,
    NTILE(4) OVER (ORDER BY total_sales DESC) AS performance_quartile
FROM emp_metrics
ORDER BY total_sales DESC;

-- 51.3 Inventory analysis
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_price,
    p.cost_price,
    p.stock_quantity,
    p.reorder_level,
    p.reorder_quantity,
    ROUND(p.unit_price - p.cost_price, 2) AS unit_margin,
    ROUND((p.unit_price - p.cost_price) / NULLIF(p.unit_price, 0) * 100, 2) AS margin_pct,
    ROUND(p.stock_quantity * p.cost_price, 2) AS inventory_value,
    COALESCE(sales.total_sold_30d, 0) AS units_sold_30d,
    COALESCE(sales.revenue_30d, 0) AS revenue_30d,
    CASE
        WHEN p.stock_quantity = 0 THEN 'OUT OF STOCK'
        WHEN p.stock_quantity <= p.reorder_level THEN 'REORDER NOW'
        WHEN p.stock_quantity <= p.reorder_level * 2 THEN 'LOW STOCK'
        WHEN p.stock_quantity > p.reorder_level * 10 THEN 'OVERSTOCKED'
        ELSE 'NORMAL'
    END AS stock_status,
    CASE WHEN COALESCE(sales.total_sold_30d, 0) > 0
         THEN ROUND(p.stock_quantity / (sales.total_sold_30d / 30.0), 0)
         ELSE NULL
    END AS days_of_stock_remaining
FROM inventory.products p
LEFT JOIN (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS total_sold_30d,
        SUM(oi.line_total) AS revenue_30d
    FROM sales.order_items oi
    JOIN sales.orders o ON oi.order_id = o.order_id
    WHERE o.status = 'DELIVERED'
      AND o.order_date >= DATEADD(DAY, -30, GETDATE())
    GROUP BY oi.product_id
) sales ON p.product_id = sales.product_id
WHERE p.is_active = 1
ORDER BY
    CASE
        WHEN p.stock_quantity = 0 THEN 1
        WHEN p.stock_quantity <= p.reorder_level THEN 2
        ELSE 3
    END,
    p.category,
    p.product_name;

-- =============================================================================
-- SECTION 52: COMMON INTERVIEW QUESTIONS AND SOLUTIONS
-- =============================================================================

-- Q1: Find the second highest salary
SELECT MAX(salary) AS second_highest_salary
FROM hr.employees
WHERE salary < (SELECT MAX(salary) FROM hr.employees);

-- Alternative using DENSE_RANK
SELECT salary AS second_highest_salary
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM hr.employees
) ranked
WHERE rnk = 2;

-- Q2: Find duplicate records
SELECT email, COUNT(*) AS duplicate_count
FROM hr.employees
GROUP BY email
HAVING COUNT(*) > 1;

-- Q3: Delete duplicate records (keep one)
WITH duplicates AS (
    SELECT
        employee_id,
        email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY employee_id) AS rn
    FROM hr.employees
)
DELETE FROM duplicates WHERE rn > 1;

-- Q4: Find employees who earn more than their manager
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name + ' ' + m.last_name AS manager_name,
    m.salary AS manager_salary,
    e.salary - m.salary AS salary_difference
FROM hr.employees e
JOIN hr.employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- Q5: Find departments with no employees
SELECT d.department_id, d.department_name
FROM hr.departments d
LEFT JOIN hr.employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- Q6: Nth highest salary (parameterized)
DECLARE @n INT = 3;
SELECT DISTINCT salary
FROM hr.employees
ORDER BY salary DESC
OFFSET @n - 1 ROWS
FETCH NEXT 1 ROW ONLY;

-- Q7: Running total
SELECT
    order_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY order_date ROWS UNBOUNDED PRECEDING) AS running_total
FROM sales.orders
WHERE status = 'DELIVERED'
ORDER BY order_date;

-- Q8: Employees hired in the last 30 days
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date >= DATEADD(DAY, -30, GETDATE())
ORDER BY hire_date DESC;

-- Q9: Department with highest average salary
SELECT TOP 1
    d.department_name,
    AVG(e.salary) AS avg_salary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name
ORDER BY avg_salary DESC;

-- Q10: Customers who placed orders in every month of 2024
SELECT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2024
GROUP BY customer_id
HAVING COUNT(DISTINCT MONTH(order_date)) = 12;

-- Q11: Products never ordered
SELECT p.product_id, p.product_name, p.category
FROM inventory.products p
WHERE NOT EXISTS (
    SELECT 1 FROM sales.order_items oi WHERE oi.product_id = p.product_id
);

-- Q12: Consecutive login days (streak)
WITH daily_orders AS (
    SELECT DISTINCT customer_id, CAST(order_date AS DATE) AS order_day
    FROM sales.orders
),
with_prev AS (
    SELECT
        customer_id,
        order_day,
        LAG(order_day) OVER (PARTITION BY customer_id ORDER BY order_day) AS prev_day
    FROM daily_orders
),
streak_groups AS (
    SELECT
        customer_id,
        order_day,
        SUM(CASE WHEN DATEDIFF(DAY, prev_day, order_day) = 1 THEN 0 ELSE 1 END)
            OVER (PARTITION BY customer_id ORDER BY order_day) AS streak_id
    FROM with_prev
)
SELECT
    customer_id,
    MIN(order_day) AS streak_start,
    MAX(order_day) AS streak_end,
    COUNT(*) AS streak_length
FROM streak_groups
GROUP BY customer_id, streak_id
HAVING COUNT(*) >= 3
ORDER BY streak_length DESC;

-- =============================================================================
-- SECTION 53: PERFORMANCE TUNING PATTERNS
-- =============================================================================

-- 53.1 SARGable vs Non-SARGable predicates
-- NON-SARGable (cannot use index efficiently)
SELECT * FROM hr.employees WHERE YEAR(hire_date) = 2020;
SELECT * FROM hr.employees WHERE UPPER(last_name) = 'SMITH';
SELECT * FROM hr.employees WHERE salary + 1000 > 80000;
SELECT * FROM hr.employees WHERE CONVERT(VARCHAR, employee_id) = '5';

-- SARGable equivalents
SELECT * FROM hr.employees WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01';
SELECT * FROM hr.employees WHERE last_name = 'Smith';  -- Case-insensitive collation
SELECT * FROM hr.employees WHERE salary > 79000;
SELECT * FROM hr.employees WHERE employee_id = 5;

-- 53.2 Covering index strategy
-- Query that benefits from covering index
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE department_id = 1 AND status = 'ACTIVE';

-- Create covering index
CREATE NONCLUSTERED INDEX idx_covering_dept_status
ON hr.employees(department_id, status)
INCLUDE (employee_id, first_name, last_name, salary);

-- 53.3 Avoid implicit conversions
-- BAD: Implicit conversion from INT to VARCHAR
SELECT * FROM hr.employees WHERE CAST(employee_id AS VARCHAR) = '5';

-- GOOD: Match data types
SELECT * FROM hr.employees WHERE employee_id = 5;

-- 53.4 Batch processing for large updates
DECLARE @batch_size INT = 1000;
DECLARE @rows_affected INT = 1;

WHILE @rows_affected > 0
BEGIN
    UPDATE TOP (@batch_size) hr.employees
    SET status = 'INACTIVE'
    WHERE last_review_date < DATEADD(YEAR, -3, GETDATE())
      AND status = 'ACTIVE';

    SET @rows_affected = @@ROWCOUNT;
    WAITFOR DELAY '00:00:01';  -- Brief pause between batches
END;

-- 53.5 Pagination with OFFSET/FETCH
DECLARE @page INT = 1;
DECLARE @page_size INT = 20;

SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary,
    department_id
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY last_name, first_name
OFFSET (@page - 1) * @page_size ROWS
FETCH NEXT @page_size ROWS ONLY;

-- =============================================================================
-- SECTION 54: DATA QUALITY CHECKS
-- =============================================================================

-- 54.1 Null checks
SELECT
    'hr.employees' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS null_first_name,
    SUM(CASE WHEN last_name IS NULL THEN 1 ELSE 0 END) AS null_last_name,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_email,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS null_phone,
    SUM(CASE WHEN department_id IS NULL THEN 1 ELSE 0 END) AS null_dept,
    SUM(CASE WHEN manager_id IS NULL THEN 1 ELSE 0 END) AS null_manager,
    SUM(CASE WHEN salary IS NULL THEN 1 ELSE 0 END) AS null_salary,
    SUM(CASE WHEN hire_date IS NULL THEN 1 ELSE 0 END) AS null_hire_date
FROM hr.employees;

-- 54.2 Referential integrity check
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name AS employee_name,
    e.department_id,
    'Orphaned department reference' AS issue
FROM hr.employees e
LEFT JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.department_id IS NOT NULL AND d.department_id IS NULL

UNION ALL

SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name,
    e.manager_id,
    'Orphaned manager reference'
FROM hr.employees e
LEFT JOIN hr.employees m ON e.manager_id = m.employee_id
WHERE e.manager_id IS NOT NULL AND m.employee_id IS NULL;

-- 54.3 Data range validation
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    salary,
    hire_date,
    birth_date,
    CASE
        WHEN salary <= 0 THEN 'Invalid salary (must be positive)'
        WHEN salary > 1000000 THEN 'Suspiciously high salary'
        WHEN hire_date > GETDATE() THEN 'Future hire date'
        WHEN hire_date < '1900-01-01' THEN 'Unreasonably old hire date'
        WHEN birth_date IS NOT NULL AND DATEDIFF(YEAR, birth_date, hire_date) < 16 THEN 'Hired too young'
        WHEN birth_date IS NOT NULL AND DATEDIFF(YEAR, birth_date, GETDATE()) > 100 THEN 'Unreasonable age'
        ELSE 'OK'
    END AS validation_result
FROM hr.employees
WHERE
    salary <= 0 OR salary > 1000000 OR
    hire_date > GETDATE() OR hire_date < '1900-01-01' OR
    (birth_date IS NOT NULL AND DATEDIFF(YEAR, birth_date, hire_date) < 16) OR
    (birth_date IS NOT NULL AND DATEDIFF(YEAR, birth_date, GETDATE()) > 100);

-- 54.4 Email format validation
SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    email,
    'Invalid email format' AS issue
FROM hr.employees
WHERE email NOT LIKE '%_@_%.__%'
   OR email LIKE '%@%@%'
   OR email LIKE ' %'
   OR email LIKE '% ';

-- =============================================================================
-- SECTION 55: MISCELLANEOUS USEFUL QUERIES
-- =============================================================================

-- 55.1 Generate a numbers table
WITH numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 1000
)
SELECT n FROM numbers
OPTION (MAXRECURSION 1000);

-- 55.2 Cross-tab report
SELECT
    d.department_name,
    SUM(CASE WHEN e.gender = 'M' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN e.gender = 'F' THEN 1 ELSE 0 END) AS female_count,
    SUM(CASE WHEN e.gender = 'O' THEN 1 ELSE 0 END) AS other_count,
    COUNT(*) AS total,
    ROUND(AVG(CASE WHEN e.gender = 'M' THEN e.salary END), 2) AS avg_male_salary,
    ROUND(AVG(CASE WHEN e.gender = 'F' THEN e.salary END), 2) AS avg_female_salary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name
ORDER BY d.department_name;

-- 55.3 Find overlapping date ranges
SELECT
    a.employee_id,
    a.leave_id AS leave_a,
    b.leave_id AS leave_b,
    a.start_date AS a_start,
    a.end_date AS a_end,
    b.start_date AS b_start,
    b.end_date AS b_end
FROM hr.leave_requests a
JOIN hr.leave_requests b ON a.employee_id = b.employee_id
                         AND a.leave_id < b.leave_id
                         AND a.start_date <= b.end_date
                         AND a.end_date >= b.start_date
WHERE a.status = 'APPROVED' AND b.status = 'APPROVED';

-- 55.4 Hierarchical data with path
WITH hierarchy AS (
    SELECT
        employee_id,
        first_name + ' ' + last_name AS name,
        manager_id,
        CAST(employee_id AS VARCHAR(MAX)) AS id_path,
        CAST(first_name + ' ' + last_name AS VARCHAR(MAX)) AS name_path,
        0 AS depth
    FROM hr.employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.first_name + ' ' + e.last_name,
        e.manager_id,
        h.id_path + '/' + CAST(e.employee_id AS VARCHAR),
        h.name_path + ' > ' + e.first_name + ' ' + e.last_name,
        h.depth + 1
    FROM hr.employees e
    JOIN hierarchy h ON e.manager_id = h.employee_id
)
SELECT
    REPLICATE('  ', depth) + name AS indented_name,
    depth AS org_level,
    id_path,
    name_path
FROM hierarchy
ORDER BY id_path;

-- 55.5 Salary histogram
SELECT
    salary_range,
    COUNT(*) AS employee_count,
    REPLICATE('|', COUNT(*)) AS bar_chart
FROM (
    SELECT
        CASE
            WHEN salary < 50000  THEN '< $50K'
            WHEN salary < 60000  THEN '$50K-$60K'
            WHEN salary < 70000  THEN '$60K-$70K'
            WHEN salary < 80000  THEN '$70K-$80K'
            WHEN salary < 90000  THEN '$80K-$90K'
            WHEN salary < 100000 THEN '$90K-$100K'
            WHEN salary < 120000 THEN '$100K-$120K'
            ELSE '$120K+'
        END AS salary_range,
        CASE
            WHEN salary < 50000  THEN 1
            WHEN salary < 60000  THEN 2
            WHEN salary < 70000  THEN 3
            WHEN salary < 80000  THEN 4
            WHEN salary < 90000  THEN 5
            WHEN salary < 100000 THEN 6
            WHEN salary < 120000 THEN 7
            ELSE 8
        END AS sort_order
    FROM hr.employees
    WHERE status = 'ACTIVE'
) salary_buckets
GROUP BY salary_range, sort_order
ORDER BY sort_order;

-- =============================================================================
-- END OF SQL COMPLETE REFERENCE GUIDE
-- Total Sections: 55
-- Coverage: DDL, DML, Queries, Functions, Procedures, Triggers, Transactions,
--           Error Handling, Cursors, Dynamic SQL, Pivot/Unpivot, JSON, XML,
--           Indexes, Views, CTEs, Window Functions, Set Operations, Partitioning,
--           Sequences, Security, Full-Text Search, Analytics, Temporal Tables,
--           Graph Tables, Columnstore, In-Memory OLTP, Spatial Data,
--           Query Store, Extended Events, Performance Tuning, Data Quality
-- =============================================================================
