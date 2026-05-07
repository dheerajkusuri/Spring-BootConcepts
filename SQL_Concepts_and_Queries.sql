-- =============================================================================
-- SQL CONCEPTS AND QUERIES - COMPREHENSIVE REFERENCE GUIDE
-- =============================================================================
-- Topics Covered:
--   1.  Database & Schema Management (DDL)
--   2.  Data Types
--   3.  Constraints
--   4.  DML - INSERT, UPDATE, DELETE, MERGE
--   5.  SELECT Queries - Basic to Advanced
--   6.  Filtering - WHERE, HAVING, BETWEEN, IN, LIKE, IS NULL
--   7.  Sorting - ORDER BY
--   8.  Aggregations - GROUP BY, COUNT, SUM, AVG, MIN, MAX
--   9.  JOINs - INNER, LEFT, RIGHT, FULL, CROSS, SELF
--  10.  Subqueries - Scalar, Correlated, Inline Views
--  11.  Common Table Expressions (CTEs)
--  12.  Window Functions - ROW_NUMBER, RANK, DENSE_RANK, NTILE, LAG, LEAD
--  13.  Set Operations - UNION, INTERSECT, EXCEPT
--  14.  Indexes
--  15.  Views
--  16.  Stored Procedures
--  17.  Functions (Scalar & Table-Valued)
--  18.  Triggers
--  19.  Transactions & ACID Properties
--  20.  Normalization (1NF, 2NF, 3NF, BCNF)
--  21.  Query Optimization & Execution Plans
--  22.  Partitioning
--  23.  Temporary Tables & Table Variables
--  24.  Pivot & Unpivot
--  25.  JSON in SQL
--  26.  String Functions
--  27.  Date & Time Functions
--  28.  Mathematical Functions
--  29.  Conditional Expressions - CASE, COALESCE, NULLIF, IIF
--  30.  Error Handling
--  31.  Cursors
--  32.  Dynamic SQL
--  33.  Sequences & Identity
--  34.  Synonyms & Linked Servers
--  35.  Security - Users, Roles, Permissions
--  36.  Backup & Restore Concepts
--  37.  Advanced Analytics Queries
--  38.  Recursive CTEs
--  39.  Full-Text Search
--  40.  Materialized Views
-- =============================================================================


-- =============================================================================
-- SECTION 1: DATABASE & SCHEMA MANAGEMENT (DDL)
-- =============================================================================

-- Create a new database
CREATE DATABASE CompanyDB;

-- Use the database
USE CompanyDB;

-- Create schemas for logical grouping
CREATE SCHEMA hr;
CREATE SCHEMA finance;
CREATE SCHEMA sales;
CREATE SCHEMA inventory;
CREATE SCHEMA audit;

-- Drop a schema (must be empty)
-- DROP SCHEMA hr;

-- Alter database settings
ALTER DATABASE CompanyDB SET RECOVERY FULL;

-- Create tables with full DDL
CREATE TABLE hr.departments (
    department_id   INT             NOT NULL,
    department_name VARCHAR(100)    NOT NULL,
    location        VARCHAR(100),
    manager_id      INT,
    budget          DECIMAL(15, 2),
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    is_active       BOOLEAN         DEFAULT TRUE,
    CONSTRAINT pk_departments PRIMARY KEY (department_id)
);

CREATE TABLE hr.employees (
    employee_id     INT             NOT NULL,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    phone           VARCHAR(20),
    hire_date       DATE            NOT NULL,
    job_title       VARCHAR(100),
    salary          DECIMAL(12, 2),
    department_id   INT,
    manager_id      INT,
    status          VARCHAR(20)     DEFAULT 'ACTIVE',
    birth_date      DATE,
    gender          CHAR(1),
    address         TEXT,
    city            VARCHAR(100),
    country         VARCHAR(100),
    postal_code     VARCHAR(20),
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_employees         PRIMARY KEY (employee_id),
    CONSTRAINT uq_employee_email    UNIQUE (email),
    CONSTRAINT fk_emp_department    FOREIGN KEY (department_id) REFERENCES hr.departments(department_id),
    CONSTRAINT fk_emp_manager       FOREIGN KEY (manager_id)    REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_salary           CHECK (salary >= 0),
    CONSTRAINT chk_gender           CHECK (gender IN ('M', 'F', 'O'))
);

CREATE TABLE sales.customers (
    customer_id     INT             NOT NULL,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    phone           VARCHAR(20),
    company_name    VARCHAR(200),
    address         TEXT,
    city            VARCHAR(100),
    state           VARCHAR(100),
    country         VARCHAR(100)    DEFAULT 'USA',
    postal_code     VARCHAR(20),
    credit_limit    DECIMAL(12, 2)  DEFAULT 5000.00,
    customer_type   VARCHAR(20)     DEFAULT 'RETAIL',
    registration_dt DATETIME        DEFAULT CURRENT_TIMESTAMP,
    last_order_dt   DATETIME,
    total_orders    INT             DEFAULT 0,
    is_active       BOOLEAN         DEFAULT TRUE,
    notes           TEXT,
    CONSTRAINT pk_customers         PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email    UNIQUE (email),
    CONSTRAINT chk_credit_limit     CHECK (credit_limit >= 0),
    CONSTRAINT chk_customer_type    CHECK (customer_type IN ('RETAIL', 'WHOLESALE', 'VIP', 'CORPORATE'))
);

CREATE TABLE inventory.products (
    product_id      INT             NOT NULL,
    product_name    VARCHAR(200)    NOT NULL,
    product_code    VARCHAR(50)     NOT NULL,
    category        VARCHAR(100),
    subcategory     VARCHAR(100),
    description     TEXT,
    unit_price      DECIMAL(12, 2)  NOT NULL,
    cost_price      DECIMAL(12, 2),
    stock_quantity  INT             DEFAULT 0,
    reorder_level   INT             DEFAULT 10,
    reorder_qty     INT             DEFAULT 50,
    supplier_id     INT,
    weight_kg       DECIMAL(8, 3),
    is_active       BOOLEAN         DEFAULT TRUE,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_products          PRIMARY KEY (product_id),
    CONSTRAINT uq_product_code      UNIQUE (product_code),
    CONSTRAINT chk_unit_price       CHECK (unit_price > 0),
    CONSTRAINT chk_stock            CHECK (stock_quantity >= 0)
);

CREATE TABLE sales.orders (
    order_id        INT             NOT NULL,
    customer_id     INT             NOT NULL,
    employee_id     INT,
    order_date      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    required_date   DATE,
    shipped_date    DATE,
    status          VARCHAR(30)     DEFAULT 'PENDING',
    payment_method  VARCHAR(50),
    payment_status  VARCHAR(30)     DEFAULT 'UNPAID',
    subtotal        DECIMAL(15, 2)  DEFAULT 0.00,
    tax_amount      DECIMAL(15, 2)  DEFAULT 0.00,
    discount_amount DECIMAL(15, 2)  DEFAULT 0.00,
    shipping_cost   DECIMAL(10, 2)  DEFAULT 0.00,
    total_amount    DECIMAL(15, 2)  DEFAULT 0.00,
    shipping_addr   TEXT,
    notes           TEXT,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_orders            PRIMARY KEY (order_id),
    CONSTRAINT fk_order_customer    FOREIGN KEY (customer_id)   REFERENCES sales.customers(customer_id),
    CONSTRAINT fk_order_employee    FOREIGN KEY (employee_id)   REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_order_status     CHECK (status IN ('PENDING','PROCESSING','SHIPPED','DELIVERED','CANCELLED','RETURNED')),
    CONSTRAINT chk_payment_status   CHECK (payment_status IN ('UNPAID','PAID','PARTIAL','REFUNDED'))
);

CREATE TABLE sales.order_items (
    order_item_id   INT             NOT NULL,
    order_id        INT             NOT NULL,
    product_id      INT             NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(12, 2)  NOT NULL,
    discount_pct    DECIMAL(5, 2)   DEFAULT 0.00,
    line_total      DECIMAL(15, 2)  NOT NULL,
    CONSTRAINT pk_order_items       PRIMARY KEY (order_item_id),
    CONSTRAINT fk_oi_order          FOREIGN KEY (order_id)      REFERENCES sales.orders(order_id),
    CONSTRAINT fk_oi_product        FOREIGN KEY (product_id)    REFERENCES inventory.products(product_id),
    CONSTRAINT chk_quantity         CHECK (quantity > 0),
    CONSTRAINT chk_discount         CHECK (discount_pct BETWEEN 0 AND 100)
);

CREATE TABLE finance.invoices (
    invoice_id      INT             NOT NULL,
    order_id        INT             NOT NULL,
    invoice_date    DATE            NOT NULL,
    due_date        DATE            NOT NULL,
    amount          DECIMAL(15, 2)  NOT NULL,
    paid_amount     DECIMAL(15, 2)  DEFAULT 0.00,
    status          VARCHAR(20)     DEFAULT 'OPEN',
    notes           TEXT,
    CONSTRAINT pk_invoices          PRIMARY KEY (invoice_id),
    CONSTRAINT fk_inv_order         FOREIGN KEY (order_id)      REFERENCES sales.orders(order_id),
    CONSTRAINT chk_invoice_status   CHECK (status IN ('OPEN','PAID','OVERDUE','CANCELLED'))
);

CREATE TABLE audit.change_log (
    log_id          BIGINT          NOT NULL,
    table_name      VARCHAR(100)    NOT NULL,
    record_id       INT             NOT NULL,
    action          VARCHAR(10)     NOT NULL,
    old_values      TEXT,
    new_values      TEXT,
    changed_by      VARCHAR(100),
    changed_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_change_log        PRIMARY KEY (log_id),
    CONSTRAINT chk_action           CHECK (action IN ('INSERT','UPDATE','DELETE'))
);

-- ALTER TABLE examples
ALTER TABLE hr.employees ADD COLUMN linkedin_url VARCHAR(300);
ALTER TABLE hr.employees DROP COLUMN linkedin_url;
ALTER TABLE hr.employees MODIFY COLUMN phone VARCHAR(30);
ALTER TABLE hr.employees ADD CONSTRAINT chk_hire_date CHECK (hire_date >= '1990-01-01');
ALTER TABLE hr.employees DROP CONSTRAINT chk_hire_date;
ALTER TABLE hr.departments RENAME COLUMN location TO office_location;

-- TRUNCATE vs DELETE
-- TRUNCATE removes all rows, resets identity, cannot be rolled back in some DBs
TRUNCATE TABLE audit.change_log;

-- DROP TABLE
-- DROP TABLE IF EXISTS audit.change_log;


-- =============================================================================
-- SECTION 2: DATA TYPES
-- =============================================================================

-- Numeric Types
-- TINYINT       : 0 to 255
-- SMALLINT      : -32,768 to 32,767
-- INT / INTEGER : -2,147,483,648 to 2,147,483,647
-- BIGINT        : -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
-- DECIMAL(p,s)  : Exact numeric with precision and scale
-- NUMERIC(p,s)  : Same as DECIMAL
-- FLOAT         : Approximate floating point
-- REAL          : Single precision floating point
-- DOUBLE        : Double precision floating point

-- String Types
-- CHAR(n)       : Fixed-length string
-- VARCHAR(n)    : Variable-length string
-- TEXT          : Large variable-length string
-- NCHAR(n)      : Fixed-length Unicode string
-- NVARCHAR(n)   : Variable-length Unicode string
-- NTEXT         : Large Unicode string

-- Date/Time Types
-- DATE          : YYYY-MM-DD
-- TIME          : HH:MM:SS
-- DATETIME      : YYYY-MM-DD HH:MM:SS
-- TIMESTAMP     : Auto-updated timestamp
-- YEAR          : Year value

-- Binary Types
-- BINARY(n)     : Fixed-length binary
-- VARBINARY(n)  : Variable-length binary
-- BLOB          : Binary Large Object
-- IMAGE         : Binary image data (deprecated in SQL Server)

-- Other Types
-- BOOLEAN / BIT : True/False or 1/0
-- JSON          : JSON document
-- XML           : XML document
-- UUID/GUID     : Universally unique identifier
-- ENUM          : Enumerated list of values
-- ARRAY         : Array of values (PostgreSQL)

CREATE TABLE data_type_examples (
    id              INT,
    tiny_val        TINYINT,
    small_val       SMALLINT,
    int_val         INT,
    big_val         BIGINT,
    decimal_val     DECIMAL(10, 4),
    float_val       FLOAT,
    char_val        CHAR(10),
    varchar_val     VARCHAR(255),
    text_val        TEXT,
    date_val        DATE,
    time_val        TIME,
    datetime_val    DATETIME,
    bool_val        BOOLEAN,
    json_val        JSON
);


-- =============================================================================
-- SECTION 3: CONSTRAINTS
-- =============================================================================

-- PRIMARY KEY: Uniquely identifies each row
-- FOREIGN KEY: Enforces referential integrity
-- UNIQUE: Ensures all values in a column are distinct
-- NOT NULL: Prevents null values
-- CHECK: Validates data against a condition
-- DEFAULT: Provides a default value

-- Adding constraints after table creation
ALTER TABLE sales.customers
    ADD CONSTRAINT chk_phone_format CHECK (phone REGEXP '^[0-9+\\-() ]+$');

-- Composite primary key
CREATE TABLE sales.product_promotions (
    product_id      INT     NOT NULL,
    promotion_id    INT     NOT NULL,
    discount_pct    DECIMAL(5,2),
    start_date      DATE,
    end_date        DATE,
    CONSTRAINT pk_product_promotions PRIMARY KEY (product_id, promotion_id)
);

-- Composite unique constraint
CREATE TABLE hr.employee_skills (
    employee_id     INT     NOT NULL,
    skill_name      VARCHAR(100) NOT NULL,
    proficiency     VARCHAR(20),
    CONSTRAINT uq_emp_skill UNIQUE (employee_id, skill_name)
);

-- Self-referencing foreign key (already shown in employees table)
-- Deferred constraints (PostgreSQL)
-- ALTER TABLE sales.orders ADD CONSTRAINT fk_order_customer
--     FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id)
--     DEFERRABLE INITIALLY DEFERRED;


-- =============================================================================
-- SECTION 4: DML - INSERT, UPDATE, DELETE, MERGE
-- =============================================================================

-- INSERT single row
INSERT INTO hr.departments (department_id, department_name, location, budget)
VALUES (1, 'Engineering', 'New York', 500000.00);

-- INSERT multiple rows
INSERT INTO hr.departments (department_id, department_name, location, budget)
VALUES
    (2, 'Marketing',   'Los Angeles', 300000.00),
    (3, 'Finance',     'Chicago',     400000.00),
    (4, 'HR',          'New York',    200000.00),
    (5, 'Sales',       'Dallas',      600000.00),
    (6, 'Operations',  'Houston',     350000.00),
    (7, 'IT Support',  'Seattle',     250000.00),
    (8, 'Legal',       'Washington',  180000.00),
    (9, 'R&D',         'Boston',      700000.00),
    (10,'Executive',   'New York',    1000000.00);

-- INSERT with SELECT
INSERT INTO audit.change_log (log_id, table_name, record_id, action, changed_by)
SELECT
    ROW_NUMBER() OVER (ORDER BY employee_id),
    'hr.employees',
    employee_id,
    'INSERT',
    'system_migration'
FROM hr.employees;

-- INSERT employees
INSERT INTO hr.employees
    (employee_id, first_name, last_name, email, hire_date, job_title, salary, department_id)
VALUES
    (1,  'Alice',   'Johnson',  'alice.johnson@company.com',  '2018-03-15', 'Senior Engineer',      95000.00, 1),
    (2,  'Bob',     'Smith',    'bob.smith@company.com',      '2019-07-01', 'Marketing Manager',    85000.00, 2),
    (3,  'Carol',   'Williams', 'carol.williams@company.com', '2017-01-10', 'Financial Analyst',    78000.00, 3),
    (4,  'David',   'Brown',    'david.brown@company.com',    '2020-05-20', 'HR Specialist',        65000.00, 4),
    (5,  'Eve',     'Davis',    'eve.davis@company.com',      '2016-11-30', 'Sales Director',      110000.00, 5),
    (6,  'Frank',   'Miller',   'frank.miller@company.com',   '2021-02-14', 'Operations Manager',   80000.00, 6),
    (7,  'Grace',   'Wilson',   'grace.wilson@company.com',   '2015-08-22', 'IT Manager',           90000.00, 7),
    (8,  'Henry',   'Moore',    'henry.moore@company.com',    '2022-09-01', 'Legal Counsel',        95000.00, 8),
    (9,  'Iris',    'Taylor',   'iris.taylor@company.com',    '2014-04-17', 'Research Scientist',  105000.00, 9),
    (10, 'Jack',    'Anderson', 'jack.anderson@company.com',  '2013-12-05', 'CEO',                 200000.00, 10),
    (11, 'Karen',   'Thomas',   'karen.thomas@company.com',   '2019-06-15', 'Software Engineer',    88000.00, 1),
    (12, 'Leo',     'Jackson',  'leo.jackson@company.com',    '2020-03-10', 'Data Analyst',         75000.00, 1),
    (13, 'Mia',     'White',    'mia.white@company.com',      '2018-11-20', 'Marketing Analyst',    70000.00, 2),
    (14, 'Nathan',  'Harris',   'nathan.harris@company.com',  '2021-07-08', 'Accountant',           72000.00, 3),
    (15, 'Olivia',  'Martin',   'olivia.martin@company.com',  '2017-09-25', 'Sales Representative', 60000.00, 5);

-- INSERT customers
INSERT INTO sales.customers
    (customer_id, first_name, last_name, email, phone, company_name, city, country, credit_limit, customer_type)
VALUES
    (1,  'John',    'Doe',      'john.doe@email.com',       '555-0101', 'Doe Enterprises',    'New York',    'USA', 10000.00, 'CORPORATE'),
    (2,  'Jane',    'Smith',    'jane.smith@email.com',     '555-0102', NULL,                 'Los Angeles', 'USA',  5000.00, 'RETAIL'),
    (3,  'Mike',    'Johnson',  'mike.j@email.com',         '555-0103', 'Johnson LLC',        'Chicago',     'USA', 15000.00, 'WHOLESALE'),
    (4,  'Sarah',   'Williams', 'sarah.w@email.com',        '555-0104', NULL,                 'Houston',     'USA',  5000.00, 'RETAIL'),
    (5,  'Chris',   'Brown',    'chris.b@email.com',        '555-0105', 'Brown & Co',         'Phoenix',     'USA', 20000.00, 'VIP'),
    (6,  'Amanda',  'Davis',    'amanda.d@email.com',       '555-0106', NULL,                 'Philadelphia','USA',  5000.00, 'RETAIL'),
    (7,  'Robert',  'Miller',   'robert.m@email.com',       '555-0107', 'Miller Industries',  'San Antonio', 'USA', 12000.00, 'CORPORATE'),
    (8,  'Lisa',    'Wilson',   'lisa.w@email.com',         '555-0108', NULL,                 'San Diego',   'USA',  5000.00, 'RETAIL'),
    (9,  'James',   'Moore',    'james.m@email.com',        '555-0109', 'Moore Global',       'Dallas',      'USA', 25000.00, 'VIP'),
    (10, 'Emily',   'Taylor',   'emily.t@email.com',        '555-0110', NULL,                 'San Jose',    'USA',  5000.00, 'RETAIL');

-- INSERT products
INSERT INTO inventory.products
    (product_id, product_name, product_code, category, unit_price, cost_price, stock_quantity)
VALUES
    (1,  'Laptop Pro 15',       'TECH-001', 'Electronics',  1299.99,  800.00, 150),
    (2,  'Wireless Mouse',      'TECH-002', 'Electronics',    29.99,   10.00, 500),
    (3,  'USB-C Hub',           'TECH-003', 'Electronics',    49.99,   20.00, 300),
    (4,  'Office Chair',        'FURN-001', 'Furniture',     299.99,  150.00,  80),
    (5,  'Standing Desk',       'FURN-002', 'Furniture',     599.99,  300.00,  40),
    (6,  'Notebook A4',         'STAT-001', 'Stationery',      4.99,    1.50, 2000),
    (7,  'Ballpoint Pen Set',   'STAT-002', 'Stationery',      9.99,    3.00, 1500),
    (8,  'Monitor 27"',         'TECH-004', 'Electronics',   399.99,  220.00, 100),
    (9,  'Keyboard Mechanical', 'TECH-005', 'Electronics',   129.99,   60.00, 200),
    (10, 'Webcam HD',           'TECH-006', 'Electronics',    79.99,   35.00, 250),
    (11, 'Desk Lamp LED',       'FURN-003', 'Furniture',      39.99,   15.00, 400),
    (12, 'Filing Cabinet',      'FURN-004', 'Furniture',     199.99,  100.00,  60),
    (13, 'Printer Laser',       'TECH-007', 'Electronics',   349.99,  180.00,  75),
    (14, 'Paper Ream A4',       'STAT-003', 'Stationery',      8.99,    3.50, 3000),
    (15, 'Stapler Heavy Duty',  'STAT-004', 'Stationery',     14.99,    5.00, 800);

-- INSERT orders
INSERT INTO sales.orders
    (order_id, customer_id, employee_id, order_date, status, payment_method, subtotal, tax_amount, total_amount)
VALUES
    (1,  1,  5,  '2024-01-05', 'DELIVERED', 'CREDIT_CARD', 1329.98, 106.40, 1436.38),
    (2,  2,  15, '2024-01-10', 'DELIVERED', 'PAYPAL',        59.98,   4.80,   64.78),
    (3,  3,  5,  '2024-01-15', 'SHIPPED',   'BANK_TRANSFER',599.99,  48.00,  647.99),
    (4,  4,  15, '2024-01-20', 'PROCESSING','CREDIT_CARD',   49.99,   4.00,   53.99),
    (5,  5,  5,  '2024-02-01', 'DELIVERED', 'CREDIT_CARD', 1699.97, 136.00, 1835.97),
    (6,  6,  15, '2024-02-05', 'PENDING',   'PAYPAL',        14.98,   1.20,   16.18),
    (7,  7,  5,  '2024-02-10', 'DELIVERED', 'CREDIT_CARD',  429.98,  34.40,  464.38),
    (8,  8,  15, '2024-02-15', 'CANCELLED', 'CREDIT_CARD',  299.99,  24.00,  323.99),
    (9,  9,  5,  '2024-03-01', 'DELIVERED', 'BANK_TRANSFER',2099.97,168.00, 2267.97),
    (10, 10, 15, '2024-03-05', 'SHIPPED',   'PAYPAL',        39.98,   3.20,   43.18),
    (11, 1,  5,  '2024-03-10', 'DELIVERED', 'CREDIT_CARD',  399.99,  32.00,  431.99),
    (12, 3,  15, '2024-03-15', 'PROCESSING','CREDIT_CARD',  129.99,  10.40,  140.39),
    (13, 5,  5,  '2024-04-01', 'DELIVERED', 'CREDIT_CARD',  799.98,  64.00,  863.98),
    (14, 7,  15, '2024-04-05', 'PENDING',   'PAYPAL',        79.99,   6.40,   86.39),
    (15, 9,  5,  '2024-04-10', 'DELIVERED', 'BANK_TRANSFER',1299.99,104.00, 1403.99);

-- INSERT order items
INSERT INTO sales.order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_pct, line_total)
VALUES
    (1,  1,  1, 1, 1299.99, 0.00, 1299.99),
    (2,  1,  2, 1,   29.99, 0.00,   29.99),
    (3,  2,  2, 2,   29.99, 0.00,   59.98),
    (4,  3,  5, 1,  599.99, 0.00,  599.99),
    (5,  4,  3, 1,   49.99, 0.00,   49.99),
    (6,  5,  1, 1, 1299.99, 0.00, 1299.99),
    (7,  5,  9, 1,  129.99, 0.00,  129.99),
    (8,  5,  2, 1,   29.99, 5.00,   28.49),
    (9,  6,  7, 1,    9.99, 0.00,    9.99),
    (10, 6,  6, 1,    4.99, 0.00,    4.99),
    (11, 7,  8, 1,  399.99, 0.00,  399.99),
    (12, 7,  2, 1,   29.99, 0.00,   29.99),
    (13, 8,  4, 1,  299.99, 0.00,  299.99),
    (14, 9,  1, 1, 1299.99,10.00, 1169.99),
    (15, 9,  8, 1,  399.99, 5.00,  379.99),
    (16, 9,  9, 1,  129.99, 0.00,  129.99),
    (17,10,  6, 2,    4.99, 0.00,    9.98),
    (18,10,  7, 3,    9.99, 0.00,   29.97),
    (19,11,  8, 1,  399.99, 0.00,  399.99),
    (20,12,  9, 1,  129.99, 0.00,  129.99),
    (21,13,  8, 2,  399.99, 0.00,  799.98),
    (22,14, 10, 1,   79.99, 0.00,   79.99),
    (23,15,  1, 1, 1299.99, 0.00, 1299.99);

-- UPDATE single column
UPDATE hr.employees
SET salary = salary * 1.10
WHERE department_id = 1;

-- UPDATE multiple columns
UPDATE sales.customers
SET
    credit_limit    = credit_limit * 1.20,
    customer_type   = 'VIP',
    updated_at      = CURRENT_TIMESTAMP
WHERE total_orders > 5;

-- UPDATE with JOIN (SQL Server syntax)
UPDATE o
SET o.payment_status = 'PAID',
    o.updated_at     = CURRENT_TIMESTAMP
FROM sales.orders o
INNER JOIN finance.invoices i ON o.order_id = i.order_id
WHERE i.status = 'PAID';

-- UPDATE with subquery
UPDATE inventory.products
SET stock_quantity = stock_quantity - oi.total_qty
FROM (
    SELECT product_id, SUM(quantity) AS total_qty
    FROM sales.order_items
    GROUP BY product_id
) oi
WHERE inventory.products.product_id = oi.product_id;

-- DELETE with condition
DELETE FROM sales.order_items
WHERE order_id IN (
    SELECT order_id FROM sales.orders WHERE status = 'CANCELLED'
);

DELETE FROM sales.orders
WHERE status = 'CANCELLED'
  AND order_date < DATEADD(YEAR, -2, CURRENT_DATE);

-- MERGE (UPSERT) statement
MERGE INTO inventory.products AS target
USING (
    SELECT 1 AS product_id, 'Laptop Pro 15 Updated' AS product_name, 1199.99 AS unit_price, 200 AS stock_quantity
    UNION ALL
    SELECT 16, 'New Product XYZ', 99.99, 100
) AS source
ON target.product_id = source.product_id
WHEN MATCHED THEN
    UPDATE SET
        target.product_name    = source.product_name,
        target.unit_price      = source.unit_price,
        target.stock_quantity  = source.stock_quantity,
        target.updated_at      = CURRENT_TIMESTAMP
WHEN NOT MATCHED BY TARGET THEN
    INSERT (product_id, product_name, product_code, unit_price, stock_quantity)
    VALUES (source.product_id, source.product_name, 'NEW-001', source.unit_price, source.stock_quantity)
WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET target.is_active = FALSE;


-- =============================================================================
-- SECTION 5: SELECT QUERIES - BASIC TO ADVANCED
-- =============================================================================

-- Basic SELECT
SELECT * FROM hr.employees;

-- SELECT specific columns
SELECT employee_id, first_name, last_name, salary
FROM hr.employees;

-- SELECT with alias
SELECT
    e.employee_id                           AS id,
    CONCAT(e.first_name, ' ', e.last_name)  AS full_name,
    e.salary                                AS annual_salary,
    e.salary / 12                           AS monthly_salary,
    d.department_name                       AS department
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- SELECT DISTINCT
SELECT DISTINCT department_id FROM hr.employees;
SELECT DISTINCT city, country FROM sales.customers;

-- SELECT with computed columns
SELECT
    product_id,
    product_name,
    unit_price,
    cost_price,
    unit_price - cost_price                         AS gross_profit,
    ROUND((unit_price - cost_price) / unit_price * 100, 2) AS profit_margin_pct
FROM inventory.products
WHERE cost_price IS NOT NULL;

-- SELECT TOP / LIMIT
SELECT TOP 10 * FROM sales.orders ORDER BY order_date DESC;       -- SQL Server
SELECT * FROM sales.orders ORDER BY order_date DESC LIMIT 10;     -- MySQL/PostgreSQL
SELECT * FROM sales.orders ORDER BY order_date DESC FETCH FIRST 10 ROWS ONLY; -- Standard SQL

-- SELECT with OFFSET (pagination)
SELECT * FROM hr.employees
ORDER BY employee_id
LIMIT 10 OFFSET 20;   -- Page 3 (rows 21-30)

-- SELECT INTO (create table from query)
SELECT *
INTO hr.employees_backup
FROM hr.employees
WHERE hire_date < '2020-01-01';

-- SELECT with CASE expression
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'Executive'
        WHEN salary >= 80000  THEN 'Senior'
        WHEN salary >= 60000  THEN 'Mid-Level'
        ELSE                       'Junior'
    END AS salary_band
FROM hr.employees;


-- =============================================================================
-- SECTION 6: FILTERING - WHERE, HAVING, BETWEEN, IN, LIKE, IS NULL
-- =============================================================================

-- Basic WHERE
SELECT * FROM hr.employees WHERE department_id = 1;

-- Multiple conditions with AND / OR
SELECT * FROM hr.employees
WHERE department_id IN (1, 3, 5)
  AND salary > 70000
  AND status = 'ACTIVE';

-- BETWEEN (inclusive)
SELECT * FROM hr.employees
WHERE salary BETWEEN 70000 AND 100000;

SELECT * FROM sales.orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31';

-- IN operator
SELECT * FROM inventory.products
WHERE category IN ('Electronics', 'Furniture');

-- NOT IN
SELECT * FROM hr.employees
WHERE department_id NOT IN (4, 8, 10);

-- LIKE patterns
SELECT * FROM sales.customers WHERE email LIKE '%@gmail.com';
SELECT * FROM hr.employees WHERE first_name LIKE 'A%';
SELECT * FROM hr.employees WHERE last_name LIKE '%son';
SELECT * FROM inventory.products WHERE product_code LIKE 'TECH-%';
SELECT * FROM hr.employees WHERE phone LIKE '555-0[1-5]__';

-- IS NULL / IS NOT NULL
SELECT * FROM hr.employees WHERE manager_id IS NULL;
SELECT * FROM sales.customers WHERE company_name IS NOT NULL;

-- EXISTS
SELECT * FROM sales.customers c
WHERE EXISTS (
    SELECT 1 FROM sales.orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'DELIVERED'
);

-- NOT EXISTS
SELECT * FROM sales.customers c
WHERE NOT EXISTS (
    SELECT 1 FROM sales.orders o
    WHERE o.customer_id = c.customer_id
);

-- HAVING (filter on aggregated results)
SELECT
    department_id,
    COUNT(*)        AS employee_count,
    AVG(salary)     AS avg_salary,
    SUM(salary)     AS total_salary
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 2
   AND AVG(salary) > 70000;

-- WHERE vs HAVING
-- WHERE filters rows BEFORE aggregation
-- HAVING filters groups AFTER aggregation
SELECT
    category,
    COUNT(*)            AS product_count,
    AVG(unit_price)     AS avg_price
FROM inventory.products
WHERE is_active = TRUE          -- filters rows before grouping
GROUP BY category
HAVING AVG(unit_price) > 50;   -- filters groups after aggregation


-- =============================================================================
-- SECTION 7: SORTING - ORDER BY
-- =============================================================================

-- Basic ORDER BY
SELECT * FROM hr.employees ORDER BY last_name ASC;
SELECT * FROM hr.employees ORDER BY salary DESC;

-- Multiple sort columns
SELECT * FROM hr.employees
ORDER BY department_id ASC, salary DESC, last_name ASC;

-- ORDER BY column position (not recommended but valid)
SELECT employee_id, first_name, salary FROM hr.employees
ORDER BY 3 DESC;

-- ORDER BY with NULLS
SELECT * FROM hr.employees ORDER BY manager_id ASC NULLS LAST;   -- PostgreSQL
SELECT * FROM hr.employees ORDER BY manager_id ASC NULLS FIRST;

-- ORDER BY with expression
SELECT
    first_name,
    last_name,
    salary
FROM hr.employees
ORDER BY salary * 1.10 DESC;

-- ORDER BY with CASE
SELECT * FROM sales.orders
ORDER BY
    CASE status
        WHEN 'PENDING'    THEN 1
        WHEN 'PROCESSING' THEN 2
        WHEN 'SHIPPED'    THEN 3
        WHEN 'DELIVERED'  THEN 4
        ELSE                   5
    END;


-- =============================================================================
-- SECTION 8: AGGREGATIONS
-- =============================================================================

-- COUNT
SELECT COUNT(*)                 AS total_employees      FROM hr.employees;
SELECT COUNT(manager_id)        AS employees_with_mgr   FROM hr.employees;
SELECT COUNT(DISTINCT department_id) AS dept_count      FROM hr.employees;

-- SUM
SELECT SUM(salary)              AS total_payroll        FROM hr.employees;
SELECT SUM(total_amount)        AS total_revenue        FROM sales.orders WHERE status = 'DELIVERED';

-- AVG
SELECT AVG(salary)              AS avg_salary           FROM hr.employees;
SELECT AVG(unit_price)          AS avg_product_price    FROM inventory.products;

-- MIN / MAX
SELECT MIN(salary), MAX(salary) FROM hr.employees;
SELECT MIN(order_date), MAX(order_date) FROM sales.orders;

-- GROUP BY with multiple aggregations
SELECT
    d.department_name,
    COUNT(e.employee_id)    AS headcount,
    MIN(e.salary)           AS min_salary,
    MAX(e.salary)           AS max_salary,
    AVG(e.salary)           AS avg_salary,
    SUM(e.salary)           AS total_salary,
    ROUND(AVG(e.salary), 2) AS avg_salary_rounded
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_salary DESC;

-- GROUP BY with ROLLUP (subtotals)
SELECT
    category,
    subcategory,
    COUNT(*)            AS product_count,
    SUM(stock_quantity) AS total_stock
FROM inventory.products
GROUP BY ROLLUP(category, subcategory);

-- GROUP BY with CUBE (all combinations)
SELECT
    category,
    subcategory,
    SUM(unit_price * stock_quantity) AS inventory_value
FROM inventory.products
GROUP BY CUBE(category, subcategory);

-- GROUPING SETS
SELECT
    category,
    subcategory,
    COUNT(*) AS cnt
FROM inventory.products
GROUP BY GROUPING SETS (
    (category, subcategory),
    (category),
    ()
);

-- STRING_AGG (aggregate strings)
SELECT
    department_id,
    STRING_AGG(first_name, ', ') AS employee_names
FROM hr.employees
GROUP BY department_id;


-- =============================================================================
-- SECTION 9: JOINS
-- =============================================================================

-- INNER JOIN - only matching rows
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- LEFT JOIN - all rows from left, matching from right
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id)   AS order_count,
    SUM(o.total_amount) AS total_spent
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- RIGHT JOIN - all rows from right, matching from left
SELECT
    d.department_name,
    e.first_name,
    e.last_name
FROM hr.employees e
RIGHT JOIN hr.departments d ON e.department_id = d.department_id;

-- FULL OUTER JOIN - all rows from both tables
SELECT
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
FULL OUTER JOIN hr.departments d ON e.department_id = d.department_id;

-- CROSS JOIN - cartesian product
SELECT
    e.first_name,
    d.department_name
FROM hr.employees e
CROSS JOIN hr.departments d;

-- SELF JOIN - join table to itself
SELECT
    e.first_name        AS employee,
    m.first_name        AS manager
FROM hr.employees e
LEFT JOIN hr.employees m ON e.manager_id = m.employee_id;

-- Multi-table JOIN
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    CONCAT(e.first_name, ' ', e.last_name)  AS sales_rep,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM sales.orders o
INNER JOIN sales.customers c    ON o.customer_id    = c.customer_id
INNER JOIN hr.employees e       ON o.employee_id    = e.employee_id
INNER JOIN sales.order_items oi ON o.order_id       = oi.order_id
INNER JOIN inventory.products p ON oi.product_id    = p.product_id
WHERE o.status = 'DELIVERED'
ORDER BY o.order_date DESC;

-- JOIN with multiple conditions
SELECT *
FROM sales.orders o
INNER JOIN sales.customers c
    ON o.customer_id = c.customer_id
    AND c.customer_type = 'VIP'
    AND o.total_amount > 1000;

-- JOIN with USING (when column names match)
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d USING (department_id);

-- Non-equi JOIN
SELECT
    e1.first_name   AS employee,
    e1.salary,
    e2.first_name   AS higher_paid_colleague,
    e2.salary       AS higher_salary
FROM hr.employees e1
INNER JOIN hr.employees e2
    ON e1.department_id = e2.department_id
    AND e1.salary < e2.salary;


-- =============================================================================
-- SECTION 10: SUBQUERIES
-- =============================================================================

-- Scalar subquery (returns single value)
SELECT
    employee_id,
    first_name,
    salary,
    (SELECT AVG(salary) FROM hr.employees) AS company_avg_salary,
    salary - (SELECT AVG(salary) FROM hr.employees) AS diff_from_avg
FROM hr.employees;

-- Subquery in WHERE
SELECT * FROM hr.employees
WHERE salary > (SELECT AVG(salary) FROM hr.employees);

-- Subquery with IN
SELECT * FROM sales.customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE total_amount > 1000
);

-- Correlated subquery (references outer query)
SELECT
    e.employee_id,
    e.first_name,
    e.salary,
    (
        SELECT AVG(e2.salary)
        FROM hr.employees e2
        WHERE e2.department_id = e.department_id
    ) AS dept_avg_salary
FROM hr.employees e;

-- Correlated subquery in WHERE
SELECT * FROM hr.employees e
WHERE salary > (
    SELECT AVG(salary)
    FROM hr.employees
    WHERE department_id = e.department_id
);

-- Inline view (subquery in FROM)
SELECT
    dept_stats.department_id,
    dept_stats.avg_salary,
    dept_stats.headcount
FROM (
    SELECT
        department_id,
        AVG(salary)     AS avg_salary,
        COUNT(*)        AS headcount
    FROM hr.employees
    GROUP BY department_id
) AS dept_stats
WHERE dept_stats.headcount > 2;

-- Subquery with EXISTS
SELECT p.product_name
FROM inventory.products p
WHERE EXISTS (
    SELECT 1
    FROM sales.order_items oi
    WHERE oi.product_id = p.product_id
);

-- Subquery with ANY / ALL
SELECT * FROM hr.employees
WHERE salary > ANY (
    SELECT salary FROM hr.employees WHERE department_id = 5
);

SELECT * FROM hr.employees
WHERE salary > ALL (
    SELECT salary FROM hr.employees WHERE department_id = 4
);


-- =============================================================================
-- SECTION 11: COMMON TABLE EXPRESSIONS (CTEs)
-- =============================================================================

-- Basic CTE
WITH department_summary AS (
    SELECT
        department_id,
        COUNT(*)    AS headcount,
        AVG(salary) AS avg_salary,
        SUM(salary) AS total_salary
    FROM hr.employees
    GROUP BY department_id
)
SELECT
    d.department_name,
    ds.headcount,
    ds.avg_salary,
    ds.total_salary
FROM department_summary ds
INNER JOIN hr.departments d ON ds.department_id = d.department_id
ORDER BY ds.total_salary DESC;

-- Multiple CTEs
WITH
high_value_customers AS (
    SELECT customer_id
    FROM sales.orders
    GROUP BY customer_id
    HAVING SUM(total_amount) > 2000
),
customer_details AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        c.email,
        c.customer_type
    FROM sales.customers c
    INNER JOIN high_value_customers hvc ON c.customer_id = hvc.customer_id
),
order_summary AS (
    SELECT
        customer_id,
        COUNT(*)            AS order_count,
        SUM(total_amount)   AS lifetime_value,
        MAX(order_date)     AS last_order_date
    FROM sales.orders
    GROUP BY customer_id
)
SELECT
    cd.full_name,
    cd.email,
    cd.customer_type,
    os.order_count,
    os.lifetime_value,
    os.last_order_date
FROM customer_details cd
INNER JOIN order_summary os ON cd.customer_id = os.customer_id
ORDER BY os.lifetime_value DESC;

-- CTE for UPDATE
WITH employees_to_promote AS (
    SELECT employee_id
    FROM hr.employees
    WHERE salary < 80000
      AND hire_date < DATEADD(YEAR, -3, CURRENT_DATE)
)
UPDATE hr.employees
SET salary = salary * 1.15
WHERE employee_id IN (SELECT employee_id FROM employees_to_promote);

-- CTE for DELETE
WITH old_cancelled_orders AS (
    SELECT order_id
    FROM sales.orders
    WHERE status = 'CANCELLED'
      AND order_date < DATEADD(YEAR, -3, CURRENT_DATE)
)
DELETE FROM sales.orders
WHERE order_id IN (SELECT order_id FROM old_cancelled_orders);


-- =============================================================================
-- SECTION 12: WINDOW FUNCTIONS
-- =============================================================================

-- ROW_NUMBER - unique sequential number per partition
SELECT
    employee_id,
    first_name,
    department_id,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank_in_dept
FROM hr.employees;

-- RANK - same rank for ties, gaps after ties
SELECT
    employee_id,
    first_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM hr.employees;

-- DENSE_RANK - same rank for ties, no gaps
SELECT
    employee_id,
    first_name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_dense_rank
FROM hr.employees;

-- NTILE - divide rows into N buckets
SELECT
    employee_id,
    first_name,
    salary,
    NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM hr.employees;

-- LAG - access previous row value
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    LAG(total_amount, 1, 0) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_amount,
    total_amount - LAG(total_amount, 1, 0) OVER (PARTITION BY customer_id ORDER BY order_date) AS amount_change
FROM sales.orders;

-- LEAD - access next row value
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date,
    DATEDIFF(
        LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date),
        order_date
    ) AS days_to_next_order
FROM sales.orders;

-- FIRST_VALUE / LAST_VALUE
SELECT
    employee_id,
    first_name,
    department_id,
    salary,
    FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY salary DESC) AS highest_in_dept,
    LAST_VALUE(salary)  OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_in_dept
FROM hr.employees;

-- Running totals with SUM OVER
SELECT
    order_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(total_amount) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM sales.orders
ORDER BY order_date;

-- Cumulative distribution
SELECT
    employee_id,
    first_name,
    salary,
    CUME_DIST()     OVER (ORDER BY salary) AS cumulative_dist,
    PERCENT_RANK()  OVER (ORDER BY salary) AS percent_rank
FROM hr.employees;

-- Top N per group using window function
SELECT *
FROM (
    SELECT
        employee_id,
        first_name,
        department_id,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rn
    FROM hr.employees
) ranked
WHERE rn <= 2;  -- Top 2 earners per department


-- =============================================================================
-- SECTION 13: SET OPERATIONS
-- =============================================================================

-- UNION (removes duplicates)
SELECT first_name, last_name, email FROM hr.employees
UNION
SELECT first_name, last_name, email FROM sales.customers;

-- UNION ALL (keeps duplicates, faster)
SELECT 'Employee' AS type, first_name, last_name FROM hr.employees
UNION ALL
SELECT 'Customer' AS type, first_name, last_name FROM sales.customers;

-- INTERSECT (rows in both)
SELECT city FROM hr.employees
INTERSECT
SELECT city FROM sales.customers;

-- EXCEPT / MINUS (rows in first but not second)
SELECT customer_id FROM sales.customers
EXCEPT
SELECT DISTINCT customer_id FROM sales.orders;  -- Customers who never ordered

-- Complex set operation
(
    SELECT product_id, product_name, 'Electronics' AS filter_category
    FROM inventory.products
    WHERE category = 'Electronics'
)
UNION ALL
(
    SELECT product_id, product_name, 'Furniture' AS filter_category
    FROM inventory.products
    WHERE category = 'Furniture'
)
ORDER BY filter_category, product_name;


-- =============================================================================
-- SECTION 14: INDEXES
-- =============================================================================

-- Single column index
CREATE INDEX idx_employees_department ON hr.employees(department_id);
CREATE INDEX idx_employees_salary     ON hr.employees(salary);
CREATE INDEX idx_orders_customer      ON sales.orders(customer_id);
CREATE INDEX idx_orders_date          ON sales.orders(order_date);

-- Unique index
CREATE UNIQUE INDEX idx_employees_email ON hr.employees(email);

-- Composite index
CREATE INDEX idx_orders_customer_date ON sales.orders(customer_id, order_date);
CREATE INDEX idx_emp_dept_salary      ON hr.employees(department_id, salary DESC);

-- Covering index (includes non-key columns)
CREATE INDEX idx_orders_covering
ON sales.orders(customer_id, order_date)
INCLUDE (total_amount, status);

-- Filtered index (partial index)
CREATE INDEX idx_active_employees
ON hr.employees(department_id, salary)
WHERE status = 'ACTIVE';

-- Full-text index
CREATE FULLTEXT INDEX ON inventory.products(product_name, description);

-- Drop index
DROP INDEX idx_employees_salary ON hr.employees;

-- Rebuild index (SQL Server)
ALTER INDEX idx_employees_department ON hr.employees REBUILD;

-- Reorganize index
ALTER INDEX idx_orders_customer ON sales.orders REORGANIZE;

-- Index usage analysis (SQL Server)
SELECT
    i.name                  AS index_name,
    i.type_desc             AS index_type,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id
    AND i.index_id = ius.index_id
WHERE OBJECT_NAME(i.object_id) = 'employees';


-- =============================================================================
-- SECTION 15: VIEWS
-- =============================================================================

-- Simple view
CREATE VIEW sales.vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    o.status,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.email                                  AS customer_email,
    o.total_amount,
    o.payment_status
FROM sales.orders o
INNER JOIN sales.customers c ON o.customer_id = c.customer_id;

-- Complex view with aggregations
CREATE VIEW sales.vw_customer_lifetime_value AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.email,
    c.customer_type,
    COUNT(o.order_id)                        AS total_orders,
    COALESCE(SUM(o.total_amount), 0)         AS lifetime_value,
    COALESCE(AVG(o.total_amount), 0)         AS avg_order_value,
    MIN(o.order_date)                        AS first_order_date,
    MAX(o.order_date)                        AS last_order_date,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_tenure_days
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.customer_type;

-- View with security (column masking)
CREATE VIEW hr.vw_employee_public AS
SELECT
    employee_id,
    first_name,
    last_name,
    job_title,
    department_id,
    hire_date
    -- salary and personal info excluded
FROM hr.employees
WHERE status = 'ACTIVE';

-- Updatable view
CREATE VIEW hr.vw_active_employees AS
SELECT *
FROM hr.employees
WHERE status = 'ACTIVE'
WITH CHECK OPTION;  -- prevents updates that would remove row from view

-- Indexed/Materialized view (SQL Server)
CREATE VIEW sales.vw_product_sales_summary
WITH SCHEMABINDING AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT_BIG(*)            AS order_count,
    SUM(oi.quantity)        AS total_qty_sold,
    SUM(oi.line_total)      AS total_revenue
FROM inventory.products p
INNER JOIN sales.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category;

CREATE UNIQUE CLUSTERED INDEX idx_vw_product_sales
ON sales.vw_product_sales_summary(product_id);

-- Alter view
ALTER VIEW sales.vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    o.status,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.email,
    c.customer_type,
    o.total_amount,
    o.payment_status,
    o.shipping_cost
FROM sales.orders o
INNER JOIN sales.customers c ON o.customer_id = c.customer_id;

-- Drop view
DROP VIEW IF EXISTS sales.vw_order_summary;


-- =============================================================================
-- SECTION 16: STORED PROCEDURES
-- =============================================================================

-- Basic stored procedure
CREATE PROCEDURE hr.usp_get_employees_by_department
    @department_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        employee_id,
        first_name,
        last_name,
        job_title,
        salary
    FROM hr.employees
    WHERE department_id = @department_id
      AND status = 'ACTIVE'
    ORDER BY last_name;
END;

-- Execute stored procedure
EXEC hr.usp_get_employees_by_department @department_id = 1;

-- Stored procedure with output parameter
CREATE PROCEDURE hr.usp_get_department_stats
    @department_id  INT,
    @headcount      INT         OUTPUT,
    @avg_salary     DECIMAL(12,2) OUTPUT,
    @total_salary   DECIMAL(15,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        @headcount    = COUNT(*),
        @avg_salary   = AVG(salary),
        @total_salary = SUM(salary)
    FROM hr.employees
    WHERE department_id = @department_id
      AND status = 'ACTIVE';
END;

-- Execute with output
DECLARE @cnt INT, @avg DECIMAL(12,2), @tot DECIMAL(15,2);
EXEC hr.usp_get_department_stats
    @department_id  = 1,
    @headcount      = @cnt OUTPUT,
    @avg_salary     = @avg OUTPUT,
    @total_salary   = @tot OUTPUT;
SELECT @cnt AS headcount, @avg AS avg_salary, @tot AS total_salary;

-- Stored procedure with error handling
CREATE PROCEDURE sales.usp_create_order
    @customer_id    INT,
    @employee_id    INT,
    @order_id       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate customer exists
        IF NOT EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @customer_id AND is_active = 1)
        BEGIN
            RAISERROR('Customer not found or inactive.', 16, 1);
            RETURN;
        END

        -- Generate new order ID
        SELECT @order_id = ISNULL(MAX(order_id), 0) + 1 FROM sales.orders;

        -- Insert order
        INSERT INTO sales.orders (order_id, customer_id, employee_id, status)
        VALUES (@order_id, @customer_id, @employee_id, 'PENDING');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @err_msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@err_msg, 16, 1);
    END CATCH
END;

-- Stored procedure with dynamic SQL
CREATE PROCEDURE hr.usp_search_employees
    @search_term    VARCHAR(100),
    @department_id  INT = NULL,
    @min_salary     DECIMAL(12,2) = NULL,
    @max_salary     DECIMAL(12,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);

    SET @sql = N'
        SELECT employee_id, first_name, last_name, salary, department_id
        FROM hr.employees
        WHERE (first_name LIKE @search OR last_name LIKE @search OR email LIKE @search)
    ';

    IF @department_id IS NOT NULL
        SET @sql = @sql + N' AND department_id = @dept_id';

    IF @min_salary IS NOT NULL
        SET @sql = @sql + N' AND salary >= @min_sal';

    IF @max_salary IS NOT NULL
        SET @sql = @sql + N' AND salary <= @max_sal';

    SET @params = N'@search VARCHAR(100), @dept_id INT, @min_sal DECIMAL(12,2), @max_sal DECIMAL(12,2)';

    EXEC sp_executesql @sql, @params,
        @search     = @search_term,
        @dept_id    = @department_id,
        @min_sal    = @min_salary,
        @max_sal    = @max_salary;
END;


-- =============================================================================
-- SECTION 17: FUNCTIONS
-- =============================================================================

-- Scalar function
CREATE FUNCTION hr.fn_calculate_annual_bonus
(
    @salary         DECIMAL(12,2),
    @performance    VARCHAR(20)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @bonus_pct DECIMAL(5,2);
    SET @bonus_pct = CASE @performance
        WHEN 'EXCELLENT'    THEN 0.20
        WHEN 'GOOD'         THEN 0.15
        WHEN 'SATISFACTORY' THEN 0.10
        WHEN 'NEEDS_IMPROVEMENT' THEN 0.05
        ELSE 0.00
    END;
    RETURN @salary * @bonus_pct;
END;

-- Use scalar function
SELECT
    employee_id,
    first_name,
    salary,
    hr.fn_calculate_annual_bonus(salary, 'GOOD') AS estimated_bonus
FROM hr.employees;

-- Table-valued function (inline)
CREATE FUNCTION sales.fn_get_customer_orders
(
    @customer_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.order_id,
        o.order_date,
        o.status,
        o.total_amount,
        COUNT(oi.order_item_id) AS item_count
    FROM sales.orders o
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
    GROUP BY o.order_id, o.order_date, o.status, o.total_amount
);

-- Use table-valued function
SELECT * FROM sales.fn_get_customer_orders(1);

-- Multi-statement table-valued function
CREATE FUNCTION hr.fn_get_org_chart
(
    @manager_id INT
)
RETURNS @result TABLE
(
    employee_id     INT,
    full_name       VARCHAR(101),
    job_title       VARCHAR(100),
    level           INT
)
AS
BEGIN
    WITH org_cte AS (
        SELECT employee_id, CONCAT(first_name, ' ', last_name) AS full_name, job_title, 1 AS level
        FROM hr.employees
        WHERE manager_id = @manager_id

        UNION ALL

        SELECT e.employee_id, CONCAT(e.first_name, ' ', e.last_name), e.job_title, oc.level + 1
        FROM hr.employees e
        INNER JOIN org_cte oc ON e.manager_id = oc.employee_id
    )
    INSERT INTO @result
    SELECT * FROM org_cte;

    RETURN;
END;


-- =============================================================================
-- SECTION 18: TRIGGERS
-- =============================================================================

-- AFTER INSERT trigger
CREATE TRIGGER trg_orders_after_insert
ON sales.orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO audit.change_log (table_name, record_id, action, new_values, changed_by)
    SELECT
        'sales.orders',
        order_id,
        'INSERT',
        CONCAT('customer_id=', customer_id, ', total=', total_amount),
        SYSTEM_USER
    FROM inserted;
END;

-- AFTER UPDATE trigger
CREATE TRIGGER trg_employees_after_update
ON hr.employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(salary)
    BEGIN
        INSERT INTO audit.change_log (table_name, record_id, action, old_values, new_values, changed_by)
        SELECT
            'hr.employees',
            i.employee_id,
            'UPDATE',
            CONCAT('salary=', d.salary),
            CONCAT('salary=', i.salary),
            SYSTEM_USER
        FROM inserted i
        INNER JOIN deleted d ON i.employee_id = d.employee_id;
    END
END;

-- INSTEAD OF trigger (on views)
CREATE TRIGGER trg_vw_active_employees_update
ON hr.vw_active_employees
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE hr.employees
    SET
        first_name  = i.first_name,
        last_name   = i.last_name,
        salary      = i.salary,
        updated_at  = CURRENT_TIMESTAMP
    FROM hr.employees e
    INNER JOIN inserted i ON e.employee_id = i.employee_id;
END;

-- DDL trigger (database-level)
CREATE TRIGGER trg_prevent_table_drop
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    PRINT 'Table drop is not allowed in production!';
    ROLLBACK;
END;

-- Disable / Enable trigger
DISABLE TRIGGER trg_orders_after_insert ON sales.orders;
ENABLE  TRIGGER trg_orders_after_insert ON sales.orders;

-- Drop trigger
DROP TRIGGER IF EXISTS trg_orders_after_insert;


-- =============================================================================
-- SECTION 19: TRANSACTIONS & ACID PROPERTIES
-- =============================================================================

-- ACID Properties:
-- A - Atomicity:   All operations succeed or all fail
-- C - Consistency: Database remains in valid state
-- I - Isolation:   Concurrent transactions don't interfere
-- D - Durability:  Committed changes persist

-- Basic transaction
BEGIN TRANSACTION;
    UPDATE inventory.products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
    INSERT INTO sales.order_items (order_item_id, order_id, product_id, quantity, unit_price, line_total)
    VALUES (100, 1, 1, 1, 1299.99, 1299.99);
COMMIT TRANSACTION;

-- Transaction with rollback
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE sales.orders SET status = 'SHIPPED' WHERE order_id = 1;
    UPDATE inventory.products SET stock_quantity = stock_quantity - 5 WHERE product_id = 1;

    IF (SELECT stock_quantity FROM inventory.products WHERE product_id = 1) < 0
    BEGIN
        RAISERROR('Insufficient stock', 16, 1);
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    SELECT ERROR_MESSAGE() AS error_message;
END CATCH;

-- Savepoints
BEGIN TRANSACTION;
    INSERT INTO hr.departments VALUES (11, 'New Dept', 'Miami', NULL, 100000);
    SAVE TRANSACTION sp1;

    INSERT INTO hr.employees (employee_id, first_name, last_name, email, hire_date, department_id)
    VALUES (16, 'Test', 'User', 'test@company.com', CURRENT_DATE, 11);

    -- If employee insert fails, rollback to savepoint (keep department)
    ROLLBACK TRANSACTION sp1;

COMMIT TRANSACTION;

-- Isolation levels
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  -- Dirty reads allowed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;    -- Default - no dirty reads
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- No non-repeatable reads
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;      -- Strictest - no phantom reads
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;          -- Row versioning (SQL Server)

-- Deadlock prevention - always access tables in same order
-- Lock hints
SELECT * FROM sales.orders WITH (NOLOCK);           -- Dirty read
SELECT * FROM sales.orders WITH (UPDLOCK);          -- Update lock
SELECT * FROM sales.orders WITH (HOLDLOCK);         -- Hold shared lock
SELECT * FROM sales.orders WITH (ROWLOCK);          -- Row-level lock
SELECT * FROM sales.orders WITH (TABLOCK);          -- Table-level lock


-- =============================================================================
-- SECTION 20: NORMALIZATION
-- =============================================================================

-- 1NF (First Normal Form):
-- - Each column contains atomic (indivisible) values
-- - Each column contains values of a single type
-- - Each row is unique (has a primary key)
-- - No repeating groups

-- VIOLATION of 1NF:
CREATE TABLE orders_unnormalized (
    order_id    INT,
    customer    VARCHAR(200),   -- should be split into first/last name
    products    TEXT,           -- multiple products in one field (not atomic)
    phones      VARCHAR(500)    -- multiple phone numbers (repeating group)
);

-- 1NF COMPLIANT:
-- Separate tables for orders, customers, order_items (as already defined above)

-- 2NF (Second Normal Form):
-- - Must be in 1NF
-- - No partial dependencies (non-key columns depend on WHOLE primary key)

-- VIOLATION of 2NF (composite key: order_id + product_id):
CREATE TABLE order_items_bad (
    order_id        INT,
    product_id      INT,
    quantity        INT,
    product_name    VARCHAR(200),   -- depends only on product_id, not full key
    customer_name   VARCHAR(200),   -- depends only on order_id, not full key
    PRIMARY KEY (order_id, product_id)
);

-- 2NF COMPLIANT: Separate products table, separate orders table

-- 3NF (Third Normal Form):
-- - Must be in 2NF
-- - No transitive dependencies (non-key columns depend only on primary key)

-- VIOLATION of 3NF:
CREATE TABLE employees_bad (
    employee_id     INT PRIMARY KEY,
    department_id   INT,
    department_name VARCHAR(100),   -- depends on department_id, not employee_id
    manager_name    VARCHAR(100)    -- depends on department_id transitively
);

-- 3NF COMPLIANT: Separate departments table (as already defined)

-- BCNF (Boyce-Codd Normal Form):
-- - Must be in 3NF
-- - Every determinant must be a candidate key

-- 4NF: No multi-valued dependencies
-- 5NF: No join dependencies


-- =============================================================================
-- SECTION 21: QUERY OPTIMIZATION
-- =============================================================================

-- EXPLAIN / EXECUTION PLAN
EXPLAIN SELECT * FROM hr.employees WHERE department_id = 1;
EXPLAIN ANALYZE SELECT * FROM hr.employees WHERE department_id = 1;

-- Query hints (SQL Server)
SELECT * FROM hr.employees WITH (INDEX(idx_employees_department))
WHERE department_id = 1;

-- Avoid SELECT *
-- BAD:
SELECT * FROM hr.employees;
-- GOOD:
SELECT employee_id, first_name, last_name, salary FROM hr.employees;

-- Use EXISTS instead of COUNT for existence check
-- BAD:
SELECT * FROM sales.customers WHERE (SELECT COUNT(*) FROM sales.orders WHERE customer_id = customers.customer_id) > 0;
-- GOOD:
SELECT * FROM sales.customers c WHERE EXISTS (SELECT 1 FROM sales.orders o WHERE o.customer_id = c.customer_id);

-- Avoid functions on indexed columns in WHERE
-- BAD (index not used):
SELECT * FROM hr.employees WHERE YEAR(hire_date) = 2020;
-- GOOD (index used):
SELECT * FROM hr.employees WHERE hire_date BETWEEN '2020-01-01' AND '2020-12-31';

-- Avoid implicit type conversion
-- BAD:
SELECT * FROM hr.employees WHERE employee_id = '1';  -- string vs int
-- GOOD:
SELECT * FROM hr.employees WHERE employee_id = 1;

-- Use covering indexes for frequently queried columns
-- Use query store to identify slow queries (SQL Server 2016+)
-- Use statistics to help optimizer

-- Partition elimination
SELECT * FROM sales.orders
WHERE order_date >= '2024-01-01'  -- if table is partitioned by order_date, only relevant partitions scanned
  AND order_date <  '2024-04-01';

-- Batch processing for large updates
DECLARE @batch_size INT = 1000;
DECLARE @rows_affected INT = 1;

WHILE @rows_affected > 0
BEGIN
    UPDATE TOP (@batch_size) hr.employees
    SET updated_at = CURRENT_TIMESTAMP
    WHERE updated_at IS NULL;

    SET @rows_affected = @@ROWCOUNT;
END;


-- =============================================================================
-- SECTION 22: PARTITIONING
-- =============================================================================

-- Range partitioning (PostgreSQL)
CREATE TABLE sales.orders_partitioned (
    order_id        INT             NOT NULL,
    customer_id     INT             NOT NULL,
    order_date      DATE            NOT NULL,
    total_amount    DECIMAL(15,2),
    status          VARCHAR(30)
) PARTITION BY RANGE (order_date);

CREATE TABLE sales.orders_2023 PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE sales.orders_2024 PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE sales.orders_2025 PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- List partitioning
CREATE TABLE sales.orders_by_status (
    order_id    INT,
    status      VARCHAR(30),
    order_date  DATE
) PARTITION BY LIST (status);

CREATE TABLE sales.orders_active PARTITION OF sales.orders_by_status
    FOR VALUES IN ('PENDING', 'PROCESSING', 'SHIPPED');

CREATE TABLE sales.orders_closed PARTITION OF sales.orders_by_status
    FOR VALUES IN ('DELIVERED', 'CANCELLED', 'RETURNED');

-- Hash partitioning
CREATE TABLE sales.orders_hashed (
    order_id    INT,
    customer_id INT,
    order_date  DATE
) PARTITION BY HASH (customer_id);

CREATE TABLE sales.orders_hash_0 PARTITION OF sales.orders_hashed
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE sales.orders_hash_1 PARTITION OF sales.orders_hashed
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE sales.orders_hash_2 PARTITION OF sales.orders_hashed
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE sales.orders_hash_3 PARTITION OF sales.orders_hashed
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- SQL Server partitioning
CREATE PARTITION FUNCTION pf_order_date (DATE)
AS RANGE RIGHT FOR VALUES ('2022-01-01', '2023-01-01', '2024-01-01', '2025-01-01');

CREATE PARTITION SCHEME ps_order_date
AS PARTITION pf_order_date
TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]);


-- =============================================================================
-- SECTION 23: TEMPORARY TABLES & TABLE VARIABLES
-- =============================================================================

-- Local temporary table (session-scoped)
CREATE TABLE #temp_high_value_orders (
    order_id        INT,
    customer_id     INT,
    total_amount    DECIMAL(15,2),
    order_date      DATETIME
);

INSERT INTO #temp_high_value_orders
SELECT order_id, customer_id, total_amount, order_date
FROM sales.orders
WHERE total_amount > 1000;

SELECT * FROM #temp_high_value_orders ORDER BY total_amount DESC;

DROP TABLE IF EXISTS #temp_high_value_orders;

-- Global temporary table (all sessions)
CREATE TABLE ##global_temp_products (
    product_id      INT,
    product_name    VARCHAR(200),
    unit_price      DECIMAL(12,2)
);

-- Table variable (scope: batch/procedure)
DECLARE @top_customers TABLE (
    customer_id     INT,
    full_name       VARCHAR(101),
    total_spent     DECIMAL(15,2)
);

INSERT INTO @top_customers
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name),
    SUM(o.total_amount)
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY SUM(o.total_amount) DESC;

SELECT * FROM @top_customers;

-- CTE vs Temp Table vs Table Variable comparison:
-- CTE:          Best for readability, single-use, no statistics
-- Temp Table:   Best for large datasets, reuse, has statistics, can be indexed
-- Table Var:    Best for small datasets, no transaction log, no statistics


-- =============================================================================
-- SECTION 24: PIVOT & UNPIVOT
-- =============================================================================

-- PIVOT - rows to columns
SELECT *
FROM (
    SELECT
        YEAR(order_date)    AS order_year,
        DATENAME(MONTH, order_date) AS order_month,
        total_amount
    FROM sales.orders
    WHERE status = 'DELIVERED'
) AS source_data
PIVOT (
    SUM(total_amount)
    FOR order_month IN ([January],[February],[March],[April],[May],[June],
                        [July],[August],[September],[October],[November],[December])
) AS pivot_table;

-- Dynamic PIVOT
DECLARE @columns NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);

SELECT @columns = STRING_AGG(QUOTENAME(category), ',')
FROM (SELECT DISTINCT category FROM inventory.products) AS cats;

SET @sql = N'
SELECT *
FROM (
    SELECT category, product_name, unit_price
    FROM inventory.products
) AS src
PIVOT (
    AVG(unit_price)
    FOR category IN (' + @columns + N')
) AS pvt';

EXEC sp_executesql @sql;

-- UNPIVOT - columns to rows
SELECT product_id, price_type, price_value
FROM inventory.products
UNPIVOT (
    price_value FOR price_type IN (unit_price, cost_price)
) AS unpvt;

-- Manual UNPIVOT using UNION ALL
SELECT product_id, 'unit_price' AS price_type, unit_price AS price_value FROM inventory.products
UNION ALL
SELECT product_id, 'cost_price' AS price_type, cost_price AS price_value FROM inventory.products
ORDER BY product_id, price_type;


-- =============================================================================
-- SECTION 25: JSON IN SQL
-- =============================================================================

-- JSON data type and functions (MySQL 5.7+ / PostgreSQL / SQL Server 2016+)

-- Store JSON
CREATE TABLE api_logs (
    log_id      INT PRIMARY KEY,
    endpoint    VARCHAR(200),
    request     JSON,
    response    JSON,
    logged_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO api_logs (log_id, endpoint, request, response)
VALUES (
    1,
    '/api/orders',
    '{"customer_id": 1, "items": [{"product_id": 1, "qty": 2}]}',
    '{"order_id": 100, "status": "created", "total": 2599.98}'
);

-- Extract JSON values (MySQL)
SELECT
    log_id,
    JSON_EXTRACT(request, '$.customer_id')      AS customer_id,
    JSON_EXTRACT(response, '$.order_id')        AS order_id,
    JSON_EXTRACT(response, '$.status')          AS status
FROM api_logs;

-- JSON_VALUE (SQL Server / PostgreSQL)
SELECT
    log_id,
    JSON_VALUE(request, '$.customer_id')        AS customer_id,
    JSON_VALUE(response, '$.status')            AS status
FROM api_logs;

-- JSON_QUERY - extract object/array
SELECT
    log_id,
    JSON_QUERY(request, '$.items')              AS items_array
FROM api_logs;

-- FOR JSON (SQL Server - convert result to JSON)
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM hr.employees
FOR JSON PATH;

-- FOR JSON AUTO
SELECT
    e.employee_id,
    e.first_name,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
FOR JSON AUTO;

-- OPENJSON (SQL Server - parse JSON)
SELECT *
FROM OPENJSON('{"employees": [{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]}', '$.employees')
WITH (
    id      INT             '$.id',
    name    VARCHAR(100)    '$.name'
);

-- JSON_ARRAYAGG (MySQL 5.7.22+)
SELECT
    department_id,
    JSON_ARRAYAGG(
        JSON_OBJECT('id', employee_id, 'name', CONCAT(first_name, ' ', last_name))
    ) AS employees_json
FROM hr.employees
GROUP BY department_id;


-- =============================================================================
-- SECTION 26: STRING FUNCTIONS
-- =============================================================================

-- Concatenation
SELECT CONCAT(first_name, ' ', last_name)           AS full_name FROM hr.employees;
SELECT first_name || ' ' || last_name               AS full_name FROM hr.employees;  -- PostgreSQL
SELECT first_name + ' ' + last_name                 AS full_name FROM hr.employees;  -- SQL Server

-- CONCAT_WS (with separator)
SELECT CONCAT_WS(', ', last_name, first_name)        AS name_formal FROM hr.employees;

-- Length
SELECT LENGTH(first_name)                            AS name_length FROM hr.employees;
SELECT LEN(first_name)                               AS name_length FROM hr.employees;  -- SQL Server

-- Case conversion
SELECT UPPER(first_name), LOWER(last_name)           FROM hr.employees;
SELECT INITCAP(first_name)                           FROM hr.employees;  -- PostgreSQL

-- Trimming
SELECT TRIM('  hello world  ')                       AS trimmed;
SELECT LTRIM('  hello')                              AS left_trimmed;
SELECT RTRIM('hello  ')                              AS right_trimmed;
SELECT TRIM(BOTH 'x' FROM 'xxxhelloxxx')             AS custom_trim;

-- Substring
SELECT SUBSTRING(email, 1, CHARINDEX('@', email)-1)  AS username FROM hr.employees;
SELECT SUBSTR(email, 1, INSTR(email, '@')-1)         AS username FROM hr.employees;  -- MySQL
SELECT LEFT(email, CHARINDEX('@', email)-1)          AS username FROM hr.employees;  -- SQL Server
SELECT RIGHT(email, LEN(email) - CHARINDEX('@', email)) AS domain FROM hr.employees;

-- Position / Find
SELECT CHARINDEX('@', email)                         AS at_position FROM hr.employees;
SELECT INSTR(email, '@')                             AS at_position FROM hr.employees;  -- MySQL
SELECT POSITION('@' IN email)                        AS at_position FROM hr.employees;  -- Standard

-- Replace
SELECT REPLACE(email, '@company.com', '@newdomain.com') AS new_email FROM hr.employees;

-- Padding
SELECT LPAD(CAST(employee_id AS VARCHAR), 6, '0')    AS padded_id FROM hr.employees;  -- MySQL/PostgreSQL
SELECT RIGHT('000000' + CAST(employee_id AS VARCHAR), 6) AS padded_id FROM hr.employees;  -- SQL Server

-- Repeat
SELECT REPEAT('*', 10)                               AS stars;
SELECT REPLICATE('*', 10)                            AS stars;  -- SQL Server

-- Reverse
SELECT REVERSE(first_name)                           AS reversed FROM hr.employees;

-- String splitting
SELECT value FROM STRING_SPLIT('apple,banana,cherry', ',');  -- SQL Server 2016+

-- SOUNDEX / DIFFERENCE (phonetic matching)
SELECT SOUNDEX('Smith'), SOUNDEX('Smyth');
SELECT DIFFERENCE('Smith', 'Smyth');  -- 0-4, 4 = most similar

-- FORMAT
SELECT FORMAT(salary, 'C', 'en-US')                  AS formatted_salary FROM hr.employees;  -- SQL Server
SELECT FORMAT(1234567.89, '$#,##0.00')               AS formatted;

-- STUFF (SQL Server) / INSERT (MySQL)
SELECT STUFF('Hello World', 7, 5, 'SQL')             AS result;  -- 'Hello SQL'

-- TRANSLATE (replace multiple chars)
SELECT TRANSLATE('Hello World!', 'aeiou', '*****')   AS result;  -- PostgreSQL 9.4+

-- REGEXP operations
SELECT * FROM hr.employees WHERE email REGEXP '^[a-z]+\\.[a-z]+@company\\.com$';  -- MySQL
SELECT * FROM hr.employees WHERE email ~ '^[a-z]+\.[a-z]+@company\.com$';          -- PostgreSQL


-- =============================================================================
-- SECTION 27: DATE & TIME FUNCTIONS
-- =============================================================================

-- Current date/time
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
SELECT CURRENT_TIMESTAMP;
SELECT NOW();               -- MySQL/PostgreSQL
SELECT GETDATE();           -- SQL Server
SELECT SYSDATE;             -- Oracle

-- Date parts
SELECT
    YEAR(order_date)        AS order_year,
    MONTH(order_date)       AS order_month,
    DAY(order_date)         AS order_day,
    HOUR(order_date)        AS order_hour,
    MINUTE(order_date)      AS order_minute,
    SECOND(order_date)      AS order_second
FROM sales.orders;

-- EXTRACT (standard SQL)
SELECT
    EXTRACT(YEAR  FROM order_date) AS yr,
    EXTRACT(MONTH FROM order_date) AS mo,
    EXTRACT(DOW   FROM order_date) AS day_of_week
FROM sales.orders;

-- DATEPART (SQL Server)
SELECT
    DATEPART(YEAR,    order_date) AS yr,
    DATEPART(QUARTER, order_date) AS qtr,
    DATEPART(WEEK,    order_date) AS wk,
    DATEPART(WEEKDAY, order_date) AS wd
FROM sales.orders;

-- Date arithmetic
SELECT
    order_date,
    DATEADD(DAY,   30, order_date)  AS plus_30_days,
    DATEADD(MONTH,  3, order_date)  AS plus_3_months,
    DATEADD(YEAR,   1, order_date)  AS plus_1_year
FROM sales.orders;

-- Date difference
SELECT
    order_id,
    order_date,
    shipped_date,
    DATEDIFF(DAY, order_date, shipped_date) AS days_to_ship
FROM sales.orders
WHERE shipped_date IS NOT NULL;

-- Date formatting
SELECT
    FORMAT(order_date, 'yyyy-MM-dd')        AS iso_date,
    FORMAT(order_date, 'MMMM dd, yyyy')     AS long_date,
    FORMAT(order_date, 'MM/dd/yyyy')        AS us_date
FROM sales.orders;

-- Date truncation
SELECT DATE_TRUNC('month', order_date)      AS month_start FROM sales.orders;  -- PostgreSQL
SELECT DATETRUNC('month', order_date)       AS month_start FROM sales.orders;  -- SQL Server 2022+
SELECT DATE_FORMAT(order_date, '%Y-%m-01') AS month_start FROM sales.orders;  -- MySQL

-- Convert string to date
SELECT STR_TO_DATE('2024-01-15', '%Y-%m-%d');   -- MySQL
SELECT CAST('2024-01-15' AS DATE);               -- Standard
SELECT CONVERT(DATE, '2024-01-15', 23);          -- SQL Server

-- Age calculation
SELECT
    employee_id,
    first_name,
    birth_date,
    DATEDIFF(YEAR, birth_date, CURRENT_DATE) AS age_years
FROM hr.employees
WHERE birth_date IS NOT NULL;

-- Business days calculation (approximate)
SELECT
    order_id,
    order_date,
    shipped_date,
    DATEDIFF(DAY, order_date, shipped_date)
    - (DATEDIFF(WEEK, order_date, shipped_date) * 2)
    - CASE WHEN DATEPART(WEEKDAY, order_date) = 1 THEN 1 ELSE 0 END
    - CASE WHEN DATEPART(WEEKDAY, shipped_date) = 7 THEN 1 ELSE 0 END
    AS business_days_to_ship
FROM sales.orders
WHERE shipped_date IS NOT NULL;

-- Last day of month
SELECT EOMONTH(order_date) AS last_day_of_month FROM sales.orders;  -- SQL Server
SELECT LAST_DAY(order_date) AS last_day_of_month FROM sales.orders; -- MySQL


-- =============================================================================
-- SECTION 28: MATHEMATICAL FUNCTIONS
-- =============================================================================

SELECT
    ABS(-42)                AS absolute_value,
    CEILING(4.2)            AS ceiling_val,
    FLOOR(4.9)              AS floor_val,
    ROUND(4.567, 2)         AS rounded,
    ROUND(4.567, 0)         AS rounded_int,
    TRUNCATE(4.567, 2)      AS truncated,
    POWER(2, 10)            AS two_to_ten,
    SQRT(144)               AS square_root,
    EXP(1)                  AS euler_number,
    LOG(100)                AS natural_log,
    LOG10(1000)             AS log_base_10,
    LOG(8, 2)               AS log_base_2,
    MOD(17, 5)              AS modulo,
    17 % 5                  AS modulo_operator,
    PI()                    AS pi_value,
    SIN(PI()/2)             AS sine_90,
    COS(0)                  AS cosine_0,
    TAN(PI()/4)             AS tangent_45,
    SIGN(-5)                AS sign_neg,
    SIGN(0)                 AS sign_zero,
    SIGN(5)                 AS sign_pos,
    GREATEST(10, 20, 5, 15) AS greatest_val,
    LEAST(10, 20, 5, 15)    AS least_val,
    RAND()                  AS random_val,
    RAND(42)                AS seeded_random;

-- Financial calculations
SELECT
    product_id,
    unit_price,
    cost_price,
    ROUND(unit_price * 0.08, 2)                             AS tax_amount,
    ROUND(unit_price * 1.08, 2)                             AS price_with_tax,
    ROUND((unit_price - cost_price) / unit_price * 100, 2)  AS margin_pct,
    ROUND(cost_price * POWER(1.05, 3), 2)                   AS cost_in_3_years
FROM inventory.products
WHERE cost_price IS NOT NULL;


-- =============================================================================
-- SECTION 29: CONDITIONAL EXPRESSIONS
-- =============================================================================

-- CASE - simple form
SELECT
    order_id,
    status,
    CASE status
        WHEN 'PENDING'    THEN 'Awaiting Processing'
        WHEN 'PROCESSING' THEN 'Being Prepared'
        WHEN 'SHIPPED'    THEN 'On the Way'
        WHEN 'DELIVERED'  THEN 'Completed'
        WHEN 'CANCELLED'  THEN 'Cancelled'
        ELSE                   'Unknown Status'
    END AS status_description
FROM sales.orders;

-- CASE - searched form
SELECT
    employee_id,
    first_name,
    salary,
    CASE
        WHEN salary >= 150000 THEN 'C-Suite'
        WHEN salary >= 100000 THEN 'Director'
        WHEN salary >= 80000  THEN 'Manager'
        WHEN salary >= 60000  THEN 'Senior'
        WHEN salary >= 40000  THEN 'Mid-Level'
        ELSE                       'Junior'
    END AS level
FROM hr.employees;

-- CASE in ORDER BY
SELECT * FROM sales.orders
ORDER BY
    CASE payment_status
        WHEN 'UNPAID'   THEN 1
        WHEN 'PARTIAL'  THEN 2
        WHEN 'PAID'     THEN 3
        ELSE                 4
    END;

-- CASE in aggregation
SELECT
    COUNT(*)                                                    AS total_orders,
    COUNT(CASE WHEN status = 'DELIVERED' THEN 1 END)            AS delivered,
    COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END)            AS cancelled,
    SUM(CASE WHEN status = 'DELIVERED' THEN total_amount END)   AS delivered_revenue,
    AVG(CASE WHEN status = 'DELIVERED' THEN total_amount END)   AS avg_delivered_value
FROM sales.orders;

-- COALESCE - return first non-null value
SELECT
    employee_id,
    COALESCE(phone, email, 'No contact info')   AS contact,
    COALESCE(manager_id, 0)                     AS manager_id_safe
FROM hr.employees;

-- NULLIF - return null if two values are equal
SELECT
    product_id,
    unit_price,
    cost_price,
    unit_price / NULLIF(cost_price, 0)          AS price_to_cost_ratio
FROM inventory.products;

-- IIF (SQL Server shorthand for CASE)
SELECT
    order_id,
    total_amount,
    IIF(total_amount > 1000, 'High Value', 'Standard') AS order_category
FROM sales.orders;

-- NVL (Oracle) / IFNULL (MySQL) / ISNULL (SQL Server)
SELECT IFNULL(manager_id, 0)    AS manager_id FROM hr.employees;  -- MySQL
SELECT ISNULL(manager_id, 0)    AS manager_id FROM hr.employees;  -- SQL Server
SELECT NVL(manager_id, 0)       AS manager_id FROM hr.employees;  -- Oracle


-- =============================================================================
-- SECTION 30: ERROR HANDLING
-- =============================================================================

-- TRY...CATCH (SQL Server / PostgreSQL)
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO hr.departments (department_id, department_name)
    VALUES (1, 'Duplicate Department');  -- Will fail - duplicate PK

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER()      AS error_number,
        ERROR_SEVERITY()    AS error_severity,
        ERROR_STATE()       AS error_state,
        ERROR_PROCEDURE()   AS error_procedure,
        ERROR_LINE()        AS error_line,
        ERROR_MESSAGE()     AS error_message;
END CATCH;

-- RAISERROR (SQL Server)
CREATE PROCEDURE validate_salary
    @salary DECIMAL(12,2)
AS
BEGIN
    IF @salary < 0
        RAISERROR('Salary cannot be negative. Provided: %f', 16, 1, @salary);

    IF @salary > 1000000
        RAISERROR('Salary exceeds maximum allowed value.', 16, 1);
END;

-- THROW (SQL Server 2012+)
CREATE PROCEDURE safe_delete_employee
    @employee_id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM hr.employees WHERE employee_id = @employee_id)
        THROW 50001, 'Employee not found.', 1;

    DELETE FROM hr.employees WHERE employee_id = @employee_id;
END;

-- Custom error messages
EXEC sp_addmessage
    @msgnum   = 60001,
    @severity = 16,
    @msgtext  = 'The %s with ID %d was not found in the database.',
    @lang     = 'us_english';

RAISERROR(60001, 16, 1, 'Employee', 999);

-- EXCEPTION handling (PostgreSQL)
DO $$
BEGIN
    INSERT INTO hr.departments VALUES (1, 'Test', NULL, NULL, NULL);
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Department already exists.';
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint violated.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END;
$$;


-- =============================================================================
-- SECTION 31: CURSORS
-- =============================================================================

-- Basic cursor
DECLARE @emp_id     INT;
DECLARE @emp_name   VARCHAR(101);
DECLARE @salary     DECIMAL(12,2);

DECLARE emp_cursor CURSOR FOR
    SELECT employee_id, CONCAT(first_name, ' ', last_name), salary
    FROM hr.employees
    WHERE department_id = 1
    ORDER BY salary DESC;

OPEN emp_cursor;

FETCH NEXT FROM emp_cursor INTO @emp_id, @emp_name, @salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT('Employee: ', @emp_name, ' | Salary: $', FORMAT(@salary, 'N2'));
    FETCH NEXT FROM emp_cursor INTO @emp_id, @emp_name, @salary;
END;

CLOSE emp_cursor;
DEALLOCATE emp_cursor;

-- NOTE: Cursors are slow. Prefer set-based operations when possible.
-- The above UPDATE cursor is better written as:
UPDATE hr.employees
SET salary = salary * 1.05
WHERE hire_date < DATEADD(YEAR, -5, CURRENT_DATE)
  AND salary < 80000;


-- =============================================================================
-- SECTION 32: DYNAMIC SQL
-- =============================================================================

-- Basic dynamic SQL
DECLARE @table_name VARCHAR(100) = 'hr.employees';
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'SELECT COUNT(*) AS row_count FROM ' + @table_name;
EXEC sp_executesql @sql;

-- Dynamic SQL with parameters (safe - prevents SQL injection)
DECLARE @dept_id INT = 1;
DECLARE @min_sal DECIMAL(12,2) = 70000;

SET @sql = N'
    SELECT employee_id, first_name, salary
    FROM hr.employees
    WHERE department_id = @dept
      AND salary >= @min_salary
    ORDER BY salary DESC
';

EXEC sp_executesql @sql,
    N'@dept INT, @min_salary DECIMAL(12,2)',
    @dept = @dept_id,
    @min_salary = @min_sal;

-- Dynamic ORDER BY (safe approach)
DECLARE @sort_col VARCHAR(50) = 'salary';
DECLARE @sort_dir VARCHAR(4)  = 'DESC';

-- Whitelist approach to prevent injection
IF @sort_col NOT IN ('employee_id', 'first_name', 'last_name', 'salary', 'hire_date')
    SET @sort_col = 'employee_id';

IF @sort_dir NOT IN ('ASC', 'DESC')
    SET @sort_dir = 'ASC';

SET @sql = N'SELECT * FROM hr.employees ORDER BY ' + QUOTENAME(@sort_col) + N' ' + @sort_dir;
EXEC sp_executesql @sql;


-- =============================================================================
-- SECTION 33: SEQUENCES & IDENTITY
-- =============================================================================

-- IDENTITY column (SQL Server / MySQL AUTO_INCREMENT)
CREATE TABLE test_identity (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        VARCHAR(100)
);

-- AUTO_INCREMENT (MySQL)
CREATE TABLE test_autoincrement (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)
);

-- SERIAL (PostgreSQL)
CREATE TABLE test_serial (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100)
);

-- SEQUENCE object (SQL Server 2012+ / PostgreSQL / Oracle)
CREATE SEQUENCE seq_order_id
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1000
    MAXVALUE 9999999
    CYCLE
    CACHE 20;

-- Use sequence
SELECT NEXT VALUE FOR seq_order_id;  -- SQL Server
SELECT nextval('seq_order_id');       -- PostgreSQL

-- Get current identity value
SELECT SCOPE_IDENTITY();    -- SQL Server - last identity in current scope
SELECT @@IDENTITY;          -- SQL Server - last identity in current session
SELECT IDENT_CURRENT('sales.orders');  -- SQL Server - last identity for table

-- Reset identity
DBCC CHECKIDENT ('sales.orders', RESEED, 100);  -- SQL Server


-- =============================================================================
-- SECTION 34: SYNONYMS & LINKED SERVERS
-- =============================================================================

-- Synonym (alias for database object)
CREATE SYNONYM emp FOR hr.employees;
CREATE SYNONYM orders FOR sales.orders;

SELECT * FROM emp;  -- same as SELECT * FROM hr.employees

DROP SYNONYM emp;

-- Linked server (SQL Server - access remote databases)
EXEC sp_addlinkedserver
    @server     = 'REMOTE_SERVER',
    @srvproduct = 'SQL Server';

-- Query linked server (four-part naming)
SELECT * FROM REMOTE_SERVER.CompanyDB.hr.employees;

-- Drop linked server
EXEC sp_dropserver 'REMOTE_SERVER', 'droplogins';


-- =============================================================================
-- SECTION 35: SECURITY - USERS, ROLES, PERMISSIONS
-- =============================================================================

-- Create login (SQL Server)
CREATE LOGIN app_user WITH PASSWORD = 'SecureP@ssw0rd!';
CREATE LOGIN readonly_user WITH PASSWORD = 'ReadOnly@123';

-- Create database user
CREATE USER app_user FOR LOGIN app_user;
CREATE USER readonly_user FOR LOGIN readonly_user;

-- Create role
CREATE ROLE db_sales_reader;
CREATE ROLE db_hr_manager;
CREATE ROLE db_report_user;

-- Grant permissions to role
GRANT SELECT ON SCHEMA::sales TO db_sales_reader;
GRANT SELECT ON SCHEMA::hr   TO db_hr_manager;
GRANT INSERT, UPDATE ON hr.employees TO db_hr_manager;
GRANT EXECUTE ON hr.usp_get_employees_by_department TO db_hr_manager;

-- Grant SELECT on specific view
GRANT SELECT ON sales.vw_order_summary TO db_report_user;
GRANT SELECT ON hr.vw_employee_public  TO db_report_user;

-- Add user to role
ALTER ROLE db_sales_reader ADD MEMBER readonly_user;
ALTER ROLE db_hr_manager   ADD MEMBER app_user;

-- Revoke permissions
REVOKE INSERT ON hr.employees FROM db_hr_manager;

-- Deny permissions (overrides GRANT)
DENY SELECT ON hr.employees TO readonly_user;

-- Dynamic data masking (SQL Server 2016+)
ALTER TABLE hr.employees
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE hr.employees
ALTER COLUMN salary ADD MASKED WITH (FUNCTION = 'random(1000, 200000)');

ALTER TABLE sales.customers
ALTER COLUMN phone ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XXXX",4)');

-- Grant unmask permission
GRANT UNMASK TO app_user;


-- =============================================================================
-- SECTION 36: BACKUP & RESTORE CONCEPTS
-- =============================================================================

-- Full backup (SQL Server)
BACKUP DATABASE CompanyDB
TO DISK = 'C:\Backups\CompanyDB_Full.bak'
WITH FORMAT, COMPRESSION, STATS = 10;

-- Differential backup
BACKUP DATABASE CompanyDB
TO DISK = 'C:\Backups\CompanyDB_Diff.bak'
WITH DIFFERENTIAL, COMPRESSION, STATS = 10;

-- Transaction log backup
BACKUP LOG CompanyDB
TO DISK = 'C:\Backups\CompanyDB_Log.bak'
WITH COMPRESSION, STATS = 10;

-- Restore full backup
RESTORE DATABASE CompanyDB
FROM DISK = 'C:\Backups\CompanyDB_Full.bak'
WITH NORECOVERY, STATS = 10;

-- Point-in-time restore
RESTORE LOG CompanyDB
FROM DISK = 'C:\Backups\CompanyDB_Log.bak'
WITH RECOVERY, STOPAT = '2024-03-15 14:30:00';

-- Verify backup
RESTORE VERIFYONLY
FROM DISK = 'C:\Backups\CompanyDB_Full.bak';

-- Check database integrity
DBCC CHECKDB ('CompanyDB') WITH NO_INFOMSGS;


-- =============================================================================
-- SECTION 37: ADVANCED ANALYTICS QUERIES
-- =============================================================================

-- Year-over-year comparison
WITH monthly_revenue AS (
    SELECT
        YEAR(order_date)    AS yr,
        MONTH(order_date)   AS mo,
        SUM(total_amount)   AS revenue
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    curr.yr,
    curr.mo,
    curr.revenue                                AS current_revenue,
    prev.revenue                                AS prev_year_revenue,
    curr.revenue - COALESCE(prev.revenue, 0)    AS yoy_change,
    CASE
        WHEN prev.revenue IS NULL OR prev.revenue = 0 THEN NULL
        ELSE ROUND((curr.revenue - prev.revenue) / prev.revenue * 100, 2)
    END AS yoy_pct_change
FROM monthly_revenue curr
LEFT JOIN monthly_revenue prev
    ON curr.mo = prev.mo
    AND curr.yr = prev.yr + 1
ORDER BY curr.yr, curr.mo;

-- RFM Analysis (Recency, Frequency, Monetary)
WITH rfm_base AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, MAX(order_date), CURRENT_DATE)    AS recency,
        COUNT(order_id)                                  AS frequency,
        SUM(total_amount)                                AS monetary
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency ASC)    AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)  AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost Customers'
        ELSE                                                      'Potential Loyalists'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_total DESC;

-- Market basket analysis (product affinity)
SELECT
    a.product_id    AS product_a,
    b.product_id    AS product_b,
    COUNT(*)        AS times_bought_together
FROM sales.order_items a
INNER JOIN sales.order_items b
    ON a.order_id = b.order_id
    AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
HAVING COUNT(*) >= 2
ORDER BY times_bought_together DESC;

-- Running totals and moving averages
SELECT
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue,
    AVG(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7_days
FROM sales.orders
WHERE status = 'DELIVERED'
ORDER BY order_date;

-- Percentile calculations
SELECT
    department_id,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) AS p25_salary,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY salary) AS median_salary,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS p75_salary,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY salary) AS p90_salary
FROM hr.employees
GROUP BY department_id;


-- =============================================================================
-- SECTION 38: RECURSIVE CTEs
-- =============================================================================

-- Organizational hierarchy
WITH RECURSIVE org_hierarchy AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        manager_id,
        job_title,
        0 AS level,
        CAST(CONCAT(first_name, ' ', last_name) AS VARCHAR(1000)) AS hierarchy_path
    FROM hr.employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        e.job_title,
        oh.level + 1,
        CAST(CONCAT(oh.hierarchy_path, ' > ', e.first_name, ' ', e.last_name) AS VARCHAR(1000))
    FROM hr.employees e
    INNER JOIN org_hierarchy oh ON e.manager_id = oh.employee_id
)
SELECT
    REPLICATE('  ', level) + first_name + ' ' + last_name AS indented_name,
    job_title,
    level,
    hierarchy_path
FROM org_hierarchy
ORDER BY hierarchy_path;

-- Number series generation
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 100
)
SELECT n FROM numbers;

-- Date series generation
WITH RECURSIVE date_series AS (
    SELECT CAST('2024-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt) FROM date_series WHERE dt < '2024-12-31'
)
SELECT
    ds.dt AS date,
    DATENAME(WEEKDAY, ds.dt) AS day_name,
    COALESCE(SUM(o.total_amount), 0) AS daily_revenue
FROM date_series ds
LEFT JOIN sales.orders o
    ON CAST(o.order_date AS DATE) = ds.dt
    AND o.status = 'DELIVERED'
GROUP BY ds.dt
ORDER BY ds.dt;

-- Fibonacci sequence
WITH RECURSIVE fibonacci AS (
    SELECT 0 AS n, 0 AS fib_val, 1 AS next_val
    UNION ALL
    SELECT n + 1, next_val, fib_val + next_val
    FROM fibonacci
    WHERE n < 20
)
SELECT n, fib_val FROM fibonacci;


-- =============================================================================
-- SECTION 39: FULL-TEXT SEARCH
-- =============================================================================

-- Create full-text catalog (SQL Server)
CREATE FULLTEXT CATALOG ft_catalog AS DEFAULT;

-- Create full-text index
CREATE FULLTEXT INDEX ON inventory.products
(
    product_name    LANGUAGE 1033,
    description     LANGUAGE 1033
)
KEY INDEX pk_products
ON ft_catalog
WITH CHANGE_TRACKING AUTO;

-- CONTAINS - precise word search
SELECT product_id, product_name
FROM inventory.products
WHERE CONTAINS(product_name, 'Laptop');

-- CONTAINS with AND/OR/NOT
SELECT product_id, product_name
FROM inventory.products
WHERE CONTAINS(product_name, '"Laptop" OR "Monitor"');

-- FREETEXT - natural language search
SELECT product_id, product_name
FROM inventory.products
WHERE FREETEXT(product_name, 'computer accessories');

-- CONTAINSTABLE - returns relevance rank
SELECT
    p.product_id,
    p.product_name,
    ct.RANK AS relevance_rank
FROM inventory.products p
INNER JOIN CONTAINSTABLE(inventory.products, product_name, 'Laptop') ct
    ON p.product_id = ct.[KEY]
ORDER BY ct.RANK DESC;

-- Full-text search (PostgreSQL using tsvector/tsquery)
ALTER TABLE inventory.products
ADD COLUMN search_vector TSVECTOR;

UPDATE inventory.products
SET search_vector = to_tsvector('english', COALESCE(product_name, '') || ' ' || COALESCE(description, ''));

CREATE INDEX idx_products_fts ON inventory.products USING GIN(search_vector);

-- Search using tsquery
SELECT product_id, product_name
FROM inventory.products
WHERE search_vector @@ to_tsquery('english', 'laptop & wireless');

-- Ranked search
SELECT
    product_id,
    product_name,
    ts_rank(search_vector, query) AS rank
FROM inventory.products,
     to_tsquery('english', 'laptop | monitor') query
WHERE search_vector @@ query
ORDER BY rank DESC;


-- =============================================================================
-- SECTION 40: MATERIALIZED VIEWS
-- =============================================================================

-- Materialized view (PostgreSQL)
CREATE MATERIALIZED VIEW sales.mv_monthly_revenue AS
SELECT
    DATE_TRUNC('month', order_date)     AS month,
    COUNT(order_id)                     AS order_count,
    SUM(total_amount)                   AS total_revenue,
    AVG(total_amount)                   AS avg_order_value,
    COUNT(DISTINCT customer_id)         AS unique_customers
FROM sales.orders
WHERE status = 'DELIVERED'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Create index on materialized view
CREATE INDEX idx_mv_monthly_revenue_month
ON sales.mv_monthly_revenue(month);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW sales.mv_monthly_revenue;

-- Refresh without locking (PostgreSQL 9.4+)
REFRESH MATERIALIZED VIEW CONCURRENTLY sales.mv_monthly_revenue;

-- Drop materialized view
DROP MATERIALIZED VIEW IF EXISTS sales.mv_monthly_revenue;

-- Materialized view for product performance
CREATE MATERIALIZED VIEW sales.mv_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    p.cost_price,
    COUNT(oi.order_item_id)                                     AS times_ordered,
    SUM(oi.quantity)                                            AS total_units_sold,
    SUM(oi.line_total)                                          AS total_revenue,
    AVG(oi.discount_pct)                                        AS avg_discount,
    SUM(oi.line_total) - (SUM(oi.quantity) * p.cost_price)      AS total_profit,
    ROUND(
        (SUM(oi.line_total) - SUM(oi.quantity) * p.cost_price)
        / NULLIF(SUM(oi.line_total), 0) * 100, 2
    )                                                           AS profit_margin_pct
FROM inventory.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
LEFT JOIN sales.orders o ON oi.order_id = o.order_id AND o.status = 'DELIVERED'
GROUP BY p.product_id, p.product_name, p.category, p.unit_price, p.cost_price;

-- Indexed view (SQL Server equivalent of materialized view)
CREATE VIEW sales.mv_customer_stats
WITH SCHEMABINDING AS
SELECT
    customer_id,
    COUNT_BIG(*)            AS order_count,
    SUM(total_amount)       AS total_spent,
    COUNT_BIG(DISTINCT CAST(order_date AS DATE)) AS active_days
FROM sales.orders
WHERE status = 'DELIVERED'
GROUP BY customer_id;

CREATE UNIQUE CLUSTERED INDEX idx_mv_customer_stats
ON sales.mv_customer_stats(customer_id);


-- =============================================================================
-- BONUS: USEFUL SYSTEM QUERIES
-- =============================================================================

-- List all tables in database
SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- List all columns with data types
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION;

-- List all indexes
SELECT
    t.name          AS table_name,
    i.name          AS index_name,
    i.type_desc     AS index_type,
    i.is_unique,
    i.is_primary_key,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS columns
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
GROUP BY t.name, i.name, i.type_desc, i.is_unique, i.is_primary_key;

-- List all foreign keys
SELECT
    fk.name                 AS fk_name,
    tp.name                 AS parent_table,
    cp.name                 AS parent_column,
    tr.name                 AS referenced_table,
    cr.name                 AS referenced_column,
    fk.delete_referential_action_desc AS on_delete,
    fk.update_referential_action_desc AS on_update
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id;

-- Find missing indexes (SQL Server)
SELECT TOP 20
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    mid.statement AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.user_seeks,
    migs.user_scans
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY improvement_measure DESC;

-- Table sizes
SELECT
    t.name                                          AS table_name,
    s.name                                          AS schema_name,
    p.rows                                          AS row_count,
    SUM(a.total_pages) * 8                          AS total_space_kb,
    SUM(a.used_pages) * 8                           AS used_space_kb,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8   AS unused_space_kb
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
GROUP BY t.name, s.name, p.rows
ORDER BY total_space_kb DESC;

-- Active connections
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    cpu_time,
    memory_usage,
    total_elapsed_time,
    last_request_start_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
ORDER BY cpu_time DESC;

-- =============================================================================
-- END OF SQL CONCEPTS AND QUERIES REFERENCE GUIDE
-- Total Sections: 40 + Bonus
-- Topics: DDL, DML, Queries, Joins, Subqueries, CTEs, Window Functions,
--         Set Operations, Indexes, Views, Stored Procedures, Functions,
--         Triggers, Transactions, Normalization, Optimization, Partitioning,
--         Temp Tables, Pivot/Unpivot, JSON, String/Date/Math Functions,
--         Conditional Expressions, Error Handling, Cursors, Dynamic SQL,
--         Sequences, Synonyms, Security, Backup, Analytics, Recursive CTEs,
--         Full-Text Search, Materialized Views, System Queries
-- =============================================================================
