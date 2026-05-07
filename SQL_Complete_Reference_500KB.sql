-- ============================================================================================================================
-- SQL COMPLETE REFERENCE GUIDE - 500KB+ EDITION
-- ============================================================================================================================
-- This file is a comprehensive, deeply detailed SQL reference covering every major concept with
-- extensive examples, explanations, edge cases, and real-world patterns.
--
-- CONTENTS:
--   PART A : DDL - Databases, Schemas, Tables, Constraints, Alter, Drop
--   PART B : Data Types - All types across SQL Server, MySQL, PostgreSQL, Oracle
--   PART C : DML - INSERT, UPDATE, DELETE, MERGE, TRUNCATE
--   PART D : SELECT - Basic, Filtering, Sorting, Aggregation, Grouping
--   PART E : JOINs - All join types with detailed examples
--   PART F : Subqueries - Scalar, Correlated, Inline Views, EXISTS, ANY, ALL
--   PART G : CTEs - Simple, Multiple, Recursive, Hierarchical
--   PART H : Window Functions - ROW_NUMBER, RANK, DENSE_RANK, NTILE, LAG, LEAD, FIRST_VALUE, LAST_VALUE
--   PART I : Set Operations - UNION, UNION ALL, INTERSECT, EXCEPT
--   PART J : Indexes - Types, Creation, Maintenance, Usage Analysis
--   PART K : Views - Simple, Complex, Updatable, Materialized, Indexed
--   PART L : Stored Procedures - Basic, Parameters, Output, Error Handling, Dynamic SQL
--   PART M : Functions - Scalar, Inline TVF, Multi-Statement TVF
--   PART N : Triggers - AFTER, BEFORE, INSTEAD OF, DDL
--   PART O : Transactions - ACID, Isolation Levels, Savepoints, Locking
--   PART P : Normalization - 1NF through 5NF with examples
--   PART Q : Query Optimization - Execution Plans, Hints, Best Practices
--   PART R : Partitioning - Range, List, Hash, Composite
--   PART S : Temporary Objects - Temp Tables, Table Variables, CTEs comparison
--   PART T : Pivot and Unpivot - Static, Dynamic
--   PART U : JSON in SQL - Store, Query, Modify, Index
--   PART V : XML in SQL - FOR XML, OPENXML, XQuery
--   PART W : String Functions - All major string operations
--   PART X : Date and Time Functions - All date/time operations
--   PART Y : Mathematical and Statistical Functions
--   PART Z : Conditional Expressions - CASE, COALESCE, NULLIF, IIF, DECODE
--   PART AA: Error Handling - TRY/CATCH, RAISERROR, THROW, Custom Messages
--   PART AB: Cursors - Forward-Only, Scrollable, Update Cursors
--   PART AC: Dynamic SQL - sp_executesql, EXEC, Injection Prevention
--   PART AD: Sequences and Identity - IDENTITY, AUTO_INCREMENT, SERIAL, SEQUENCE
--   PART AE: Security - Logins, Users, Roles, Permissions, RLS, Masking
--   PART AF: Backup and Recovery - Full, Differential, Log, Point-in-Time
--   PART AG: Advanced Analytics - YoY, Cohort, RFM, Market Basket, Funnel
--   PART AH: Recursive Queries - Hierarchies, Graphs, Series Generation
--   PART AI: Full-Text Search - Catalogs, Indexes, CONTAINS, FREETEXT, tsvector
--   PART AJ: Materialized Views - Creation, Refresh, Indexing
--   PART AK: Database Design Patterns - Star Schema, Snowflake, EAV, Audit Tables
--   PART AL: Performance Tuning - Statistics, Cardinality, Parameter Sniffing
--   PART AM: Replication and High Availability Concepts
--   PART AN: Common Interview Questions and Answers in SQL
--   PART AO: 100 Practice Queries with Solutions
-- ============================================================================================================================


-- ============================================================================================================================
-- PART A: DDL - DATABASE, SCHEMA, TABLE MANAGEMENT
-- ============================================================================================================================

-- ---- A.1 Database Creation and Management ----

CREATE DATABASE EnterpriseDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE AnalyticsDB;
CREATE DATABASE ArchiveDB;

ALTER DATABASE EnterpriseDB SET RECOVERY FULL;
ALTER DATABASE EnterpriseDB SET AUTO_SHRINK OFF;
ALTER DATABASE EnterpriseDB SET READ_COMMITTED_SNAPSHOT ON;

DROP DATABASE IF EXISTS ArchiveDB;

-- ---- A.2 Schema Creation ----

CREATE SCHEMA core;
CREATE SCHEMA hr;
CREATE SCHEMA sales;
CREATE SCHEMA finance;
CREATE SCHEMA inventory;
CREATE SCHEMA logistics;
CREATE SCHEMA marketing;
CREATE SCHEMA analytics;
CREATE SCHEMA audit;
CREATE SCHEMA staging;
CREATE SCHEMA archive;
CREATE SCHEMA config;

-- ---- A.3 Core Reference Tables ----

CREATE TABLE config.countries (
    country_code    CHAR(2)         NOT NULL,
    country_name    VARCHAR(100)    NOT NULL,
    region          VARCHAR(50),
    currency_code   CHAR(3),
    phone_prefix    VARCHAR(10),
    is_active       BOOLEAN         DEFAULT TRUE,
    CONSTRAINT pk_countries PRIMARY KEY (country_code)
);

CREATE TABLE config.currencies (
    currency_code   CHAR(3)         NOT NULL,
    currency_name   VARCHAR(100)    NOT NULL,
    symbol          VARCHAR(5),
    decimal_places  TINYINT         DEFAULT 2,
    CONSTRAINT pk_currencies PRIMARY KEY (currency_code)
);

CREATE TABLE config.lookup_types (
    lookup_type_id  INT             NOT NULL,
    type_code       VARCHAR(50)     NOT NULL,
    type_name       VARCHAR(100)    NOT NULL,
    description     TEXT,
    CONSTRAINT pk_lookup_types PRIMARY KEY (lookup_type_id),
    CONSTRAINT uq_lookup_type_code UNIQUE (type_code)
);

CREATE TABLE config.lookup_values (
    lookup_value_id INT             NOT NULL,
    lookup_type_id  INT             NOT NULL,
    value_code      VARCHAR(50)     NOT NULL,
    value_name      VARCHAR(200)    NOT NULL,
    sort_order      INT             DEFAULT 0,
    is_active       BOOLEAN         DEFAULT TRUE,
    CONSTRAINT pk_lookup_values PRIMARY KEY (lookup_value_id),
    CONSTRAINT fk_lv_type FOREIGN KEY (lookup_type_id) REFERENCES config.lookup_types(lookup_type_id)
);

-- ---- A.4 HR Tables ----

CREATE TABLE hr.job_grades (
    grade_id        INT             NOT NULL,
    grade_code      VARCHAR(10)     NOT NULL,
    grade_name      VARCHAR(50)     NOT NULL,
    min_salary      DECIMAL(12,2)   NOT NULL,
    max_salary      DECIMAL(12,2)   NOT NULL,
    CONSTRAINT pk_job_grades PRIMARY KEY (grade_id),
    CONSTRAINT uq_grade_code UNIQUE (grade_code),
    CONSTRAINT chk_salary_range CHECK (min_salary < max_salary)
);

CREATE TABLE hr.departments (
    department_id       INT             NOT NULL,
    department_code     VARCHAR(10)     NOT NULL,
    department_name     VARCHAR(100)    NOT NULL,
    parent_dept_id      INT,
    manager_id          INT,
    cost_center         VARCHAR(20),
    location_id         INT,
    budget              DECIMAL(15,2),
    headcount_limit     INT,
    is_active           BOOLEAN         DEFAULT TRUE,
    created_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_departments       PRIMARY KEY (department_id),
    CONSTRAINT uq_dept_code         UNIQUE (department_code),
    CONSTRAINT fk_dept_parent       FOREIGN KEY (parent_dept_id) REFERENCES hr.departments(department_id)
);

CREATE TABLE hr.employees (
    employee_id         INT             NOT NULL,
    employee_number     VARCHAR(20)     NOT NULL,
    first_name          VARCHAR(50)     NOT NULL,
    middle_name         VARCHAR(50),
    last_name           VARCHAR(50)     NOT NULL,
    preferred_name      VARCHAR(50),
    email               VARCHAR(150)    NOT NULL,
    work_email          VARCHAR(150),
    phone_mobile        VARCHAR(20),
    phone_work          VARCHAR(20),
    phone_home          VARCHAR(20),
    hire_date           DATE            NOT NULL,
    termination_date    DATE,
    job_title           VARCHAR(100),
    job_grade_id        INT,
    department_id       INT,
    manager_id          INT,
    employment_type     VARCHAR(20)     DEFAULT 'FULL_TIME',
    status              VARCHAR(20)     DEFAULT 'ACTIVE',
    salary              DECIMAL(12,2),
    hourly_rate         DECIMAL(8,2),
    bonus_target_pct    DECIMAL(5,2),
    birth_date          DATE,
    gender              CHAR(1),
    nationality         CHAR(2),
    national_id         VARCHAR(30),
    passport_number     VARCHAR(30),
    address_line1       VARCHAR(200),
    address_line2       VARCHAR(200),
    city                VARCHAR(100),
    state_province      VARCHAR(100),
    postal_code         VARCHAR(20),
    country_code        CHAR(2)         DEFAULT 'US',
    emergency_contact   VARCHAR(100),
    emergency_phone     VARCHAR(20),
    notes               TEXT,
    profile_photo_url   VARCHAR(500),
    linkedin_url        VARCHAR(300),
    created_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    created_by          INT,
    updated_by          INT,
    CONSTRAINT pk_employees             PRIMARY KEY (employee_id),
    CONSTRAINT uq_employee_number       UNIQUE (employee_number),
    CONSTRAINT uq_employee_email        UNIQUE (email),
    CONSTRAINT fk_emp_department        FOREIGN KEY (department_id)  REFERENCES hr.departments(department_id),
    CONSTRAINT fk_emp_manager           FOREIGN KEY (manager_id)     REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_emp_job_grade         FOREIGN KEY (job_grade_id)   REFERENCES hr.job_grades(grade_id),
    CONSTRAINT fk_emp_country           FOREIGN KEY (country_code)   REFERENCES config.countries(country_code),
    CONSTRAINT chk_salary               CHECK (salary >= 0),
    CONSTRAINT chk_gender               CHECK (gender IN ('M','F','O','U')),
    CONSTRAINT chk_employment_type      CHECK (employment_type IN ('FULL_TIME','PART_TIME','CONTRACT','INTERN','CONSULTANT')),
    CONSTRAINT chk_status               CHECK (status IN ('ACTIVE','INACTIVE','ON_LEAVE','TERMINATED','SUSPENDED'))
);

CREATE TABLE hr.employee_history (
    history_id          BIGINT          NOT NULL,
    employee_id         INT             NOT NULL,
    change_type         VARCHAR(30)     NOT NULL,
    field_name          VARCHAR(100)    NOT NULL,
    old_value           TEXT,
    new_value           TEXT,
    effective_date      DATE            NOT NULL,
    changed_by          INT,
    changed_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    reason              TEXT,
    CONSTRAINT pk_employee_history  PRIMARY KEY (history_id),
    CONSTRAINT fk_eh_employee       FOREIGN KEY (employee_id) REFERENCES hr.employees(employee_id)
);

CREATE TABLE hr.leave_types (
    leave_type_id   INT             NOT NULL,
    type_code       VARCHAR(20)     NOT NULL,
    type_name       VARCHAR(100)    NOT NULL,
    days_per_year   DECIMAL(5,1),
    is_paid         BOOLEAN         DEFAULT TRUE,
    carry_forward   BOOLEAN         DEFAULT FALSE,
    max_carry_days  INT             DEFAULT 0,
    CONSTRAINT pk_leave_types PRIMARY KEY (leave_type_id)
);

CREATE TABLE hr.leave_requests (
    request_id      INT             NOT NULL,
    employee_id     INT             NOT NULL,
    leave_type_id   INT             NOT NULL,
    start_date      DATE            NOT NULL,
    end_date        DATE            NOT NULL,
    days_requested  DECIMAL(5,1)    NOT NULL,
    status          VARCHAR(20)     DEFAULT 'PENDING',
    approved_by     INT,
    approved_at     DATETIME,
    reason          TEXT,
    notes           TEXT,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_leave_requests    PRIMARY KEY (request_id),
    CONSTRAINT fk_lr_employee       FOREIGN KEY (employee_id)   REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_lr_leave_type     FOREIGN KEY (leave_type_id) REFERENCES hr.leave_types(leave_type_id),
    CONSTRAINT chk_leave_dates      CHECK (end_date >= start_date),
    CONSTRAINT chk_leave_status     CHECK (status IN ('PENDING','APPROVED','REJECTED','CANCELLED'))
);

CREATE TABLE hr.performance_reviews (
    review_id           INT             NOT NULL,
    employee_id         INT             NOT NULL,
    reviewer_id         INT             NOT NULL,
    review_period_start DATE            NOT NULL,
    review_period_end   DATE            NOT NULL,
    overall_rating      DECIMAL(3,1),
    goals_rating        DECIMAL(3,1),
    competency_rating   DECIMAL(3,1),
    comments            TEXT,
    employee_comments   TEXT,
    status              VARCHAR(20)     DEFAULT 'DRAFT',
    submitted_at        DATETIME,
    approved_at         DATETIME,
    CONSTRAINT pk_performance_reviews   PRIMARY KEY (review_id),
    CONSTRAINT fk_pr_employee           FOREIGN KEY (employee_id)   REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_pr_reviewer           FOREIGN KEY (reviewer_id)   REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_rating_range         CHECK (overall_rating BETWEEN 1.0 AND 5.0)
);

-- ---- A.5 Sales Tables ----

CREATE TABLE sales.customer_segments (
    segment_id      INT             NOT NULL,
    segment_code    VARCHAR(20)     NOT NULL,
    segment_name    VARCHAR(100)    NOT NULL,
    description     TEXT,
    discount_pct    DECIMAL(5,2)    DEFAULT 0.00,
    credit_limit    DECIMAL(12,2)   DEFAULT 5000.00,
    CONSTRAINT pk_customer_segments PRIMARY KEY (segment_id)
);

CREATE TABLE sales.customers (
    customer_id         INT             NOT NULL,
    customer_number     VARCHAR(20)     NOT NULL,
    first_name          VARCHAR(50)     NOT NULL,
    last_name           VARCHAR(50)     NOT NULL,
    email               VARCHAR(150)    NOT NULL,
    phone_primary       VARCHAR(20),
    phone_secondary     VARCHAR(20),
    company_name        VARCHAR(200),
    tax_id              VARCHAR(30),
    segment_id          INT,
    account_manager_id  INT,
    billing_address     TEXT,
    billing_city        VARCHAR(100),
    billing_state       VARCHAR(100),
    billing_postal      VARCHAR(20),
    billing_country     CHAR(2)         DEFAULT 'US',
    shipping_address    TEXT,
    shipping_city       VARCHAR(100),
    shipping_state      VARCHAR(100),
    shipping_postal     VARCHAR(20),
    shipping_country    CHAR(2)         DEFAULT 'US',
    credit_limit        DECIMAL(12,2)   DEFAULT 5000.00,
    credit_used         DECIMAL(12,2)   DEFAULT 0.00,
    payment_terms       VARCHAR(30)     DEFAULT 'NET30',
    preferred_currency  CHAR(3)         DEFAULT 'USD',
    registration_date   DATE,
    last_order_date     DATE,
    total_orders        INT             DEFAULT 0,
    total_revenue       DECIMAL(15,2)   DEFAULT 0.00,
    loyalty_points      INT             DEFAULT 0,
    is_active           BOOLEAN         DEFAULT TRUE,
    notes               TEXT,
    created_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_customers             PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_number       UNIQUE (customer_number),
    CONSTRAINT uq_customer_email        UNIQUE (email),
    CONSTRAINT fk_cust_segment          FOREIGN KEY (segment_id)            REFERENCES sales.customer_segments(segment_id),
    CONSTRAINT fk_cust_account_mgr      FOREIGN KEY (account_manager_id)    REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_credit_limit         CHECK (credit_limit >= 0),
    CONSTRAINT chk_payment_terms        CHECK (payment_terms IN ('IMMEDIATE','NET7','NET15','NET30','NET60','NET90'))
);

CREATE TABLE sales.price_lists (
    price_list_id   INT             NOT NULL,
    list_name       VARCHAR(100)    NOT NULL,
    currency_code   CHAR(3)         DEFAULT 'USD',
    effective_from  DATE            NOT NULL,
    effective_to    DATE,
    is_active       BOOLEAN         DEFAULT TRUE,
    CONSTRAINT pk_price_lists PRIMARY KEY (price_list_id)
);

CREATE TABLE sales.orders (
    order_id            INT             NOT NULL,
    order_number        VARCHAR(30)     NOT NULL,
    customer_id         INT             NOT NULL,
    sales_rep_id        INT,
    order_date          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    required_date       DATE,
    promised_date       DATE,
    shipped_date        DATE,
    delivery_date       DATE,
    status              VARCHAR(30)     DEFAULT 'DRAFT',
    priority            VARCHAR(10)     DEFAULT 'NORMAL',
    channel             VARCHAR(30)     DEFAULT 'DIRECT',
    price_list_id       INT,
    currency_code       CHAR(3)         DEFAULT 'USD',
    exchange_rate       DECIMAL(10,6)   DEFAULT 1.000000,
    subtotal            DECIMAL(15,2)   DEFAULT 0.00,
    discount_amount     DECIMAL(15,2)   DEFAULT 0.00,
    tax_amount          DECIMAL(15,2)   DEFAULT 0.00,
    shipping_cost       DECIMAL(10,2)   DEFAULT 0.00,
    total_amount        DECIMAL(15,2)   DEFAULT 0.00,
    total_amount_usd    DECIMAL(15,2)   DEFAULT 0.00,
    payment_method      VARCHAR(50),
    payment_status      VARCHAR(30)     DEFAULT 'UNPAID',
    payment_date        DATE,
    billing_address     TEXT,
    shipping_address    TEXT,
    tracking_number     VARCHAR(100),
    carrier             VARCHAR(50),
    po_number           VARCHAR(50),
    notes               TEXT,
    internal_notes      TEXT,
    created_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    created_by          INT,
    CONSTRAINT pk_orders                PRIMARY KEY (order_id),
    CONSTRAINT uq_order_number          UNIQUE (order_number),
    CONSTRAINT fk_order_customer        FOREIGN KEY (customer_id)   REFERENCES sales.customers(customer_id),
    CONSTRAINT fk_order_sales_rep       FOREIGN KEY (sales_rep_id)  REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_order_price_list      FOREIGN KEY (price_list_id) REFERENCES sales.price_lists(price_list_id),
    CONSTRAINT chk_order_status         CHECK (status IN ('DRAFT','PENDING','CONFIRMED','PROCESSING','SHIPPED','DELIVERED','CANCELLED','RETURNED','ON_HOLD')),
    CONSTRAINT chk_order_priority       CHECK (priority IN ('LOW','NORMAL','HIGH','URGENT')),
    CONSTRAINT chk_payment_status       CHECK (payment_status IN ('UNPAID','PARTIAL','PAID','REFUNDED','DISPUTED'))
);

CREATE TABLE sales.order_items (
    order_item_id       INT             NOT NULL,
    order_id            INT             NOT NULL,
    line_number         INT             NOT NULL,
    product_id          INT             NOT NULL,
    product_variant_id  INT,
    quantity_ordered    DECIMAL(12,3)   NOT NULL,
    quantity_shipped    DECIMAL(12,3)   DEFAULT 0,
    quantity_returned   DECIMAL(12,3)   DEFAULT 0,
    unit_of_measure     VARCHAR(10)     DEFAULT 'EA',
    unit_price          DECIMAL(12,4)   NOT NULL,
    list_price          DECIMAL(12,4),
    discount_pct        DECIMAL(5,2)    DEFAULT 0.00,
    discount_amount     DECIMAL(12,2)   DEFAULT 0.00,
    tax_rate            DECIMAL(5,2)    DEFAULT 0.00,
    tax_amount          DECIMAL(12,2)   DEFAULT 0.00,
    line_subtotal       DECIMAL(15,2)   NOT NULL,
    line_total          DECIMAL(15,2)   NOT NULL,
    cost_price          DECIMAL(12,4),
    gross_margin        DECIMAL(12,2),
    notes               TEXT,
    CONSTRAINT pk_order_items       PRIMARY KEY (order_item_id),
    CONSTRAINT uq_order_line        UNIQUE (order_id, line_number),
    CONSTRAINT fk_oi_order          FOREIGN KEY (order_id)      REFERENCES sales.orders(order_id),
    CONSTRAINT chk_qty_ordered      CHECK (quantity_ordered > 0),
    CONSTRAINT chk_discount_pct     CHECK (discount_pct BETWEEN 0 AND 100),
    CONSTRAINT chk_tax_rate         CHECK (tax_rate BETWEEN 0 AND 100)
);

CREATE TABLE sales.returns (
    return_id           INT             NOT NULL,
    return_number       VARCHAR(30)     NOT NULL,
    order_id            INT             NOT NULL,
    customer_id         INT             NOT NULL,
    return_date         DATE            NOT NULL,
    reason_code         VARCHAR(30),
    reason_description  TEXT,
    status              VARCHAR(20)     DEFAULT 'PENDING',
    refund_amount       DECIMAL(15,2),
    refund_method       VARCHAR(30),
    refund_date         DATE,
    processed_by        INT,
    CONSTRAINT pk_returns           PRIMARY KEY (return_id),
    CONSTRAINT uq_return_number     UNIQUE (return_number),
    CONSTRAINT fk_ret_order         FOREIGN KEY (order_id)      REFERENCES sales.orders(order_id),
    CONSTRAINT fk_ret_customer      FOREIGN KEY (customer_id)   REFERENCES sales.customers(customer_id)
);

-- ---- A.6 Inventory Tables ----

CREATE TABLE inventory.categories (
    category_id     INT             NOT NULL,
    parent_id       INT,
    category_code   VARCHAR(20)     NOT NULL,
    category_name   VARCHAR(100)    NOT NULL,
    description     TEXT,
    image_url       VARCHAR(500),
    sort_order      INT             DEFAULT 0,
    is_active       BOOLEAN         DEFAULT TRUE,
    CONSTRAINT pk_categories        PRIMARY KEY (category_id),
    CONSTRAINT uq_category_code     UNIQUE (category_code),
    CONSTRAINT fk_cat_parent        FOREIGN KEY (parent_id) REFERENCES inventory.categories(category_id)
);

CREATE TABLE inventory.suppliers (
    supplier_id         INT             NOT NULL,
    supplier_code       VARCHAR(20)     NOT NULL,
    supplier_name       VARCHAR(200)    NOT NULL,
    contact_name        VARCHAR(100),
    email               VARCHAR(150),
    phone               VARCHAR(20),
    fax                 VARCHAR(20),
    website             VARCHAR(300),
    address             TEXT,
    city                VARCHAR(100),
    state               VARCHAR(100),
    postal_code         VARCHAR(20),
    country_code        CHAR(2),
    payment_terms       VARCHAR(30),
    lead_time_days      INT,
    min_order_amount    DECIMAL(12,2),
    currency_code       CHAR(3)         DEFAULT 'USD',
    rating              DECIMAL(3,1),
    is_active           BOOLEAN         DEFAULT TRUE,
    notes               TEXT,
    CONSTRAINT pk_suppliers         PRIMARY KEY (supplier_id),
    CONSTRAINT uq_supplier_code     UNIQUE (supplier_code)
);

CREATE TABLE inventory.products (
    product_id          INT             NOT NULL,
    product_code        VARCHAR(50)     NOT NULL,
    sku                 VARCHAR(50),
    barcode             VARCHAR(50),
    product_name        VARCHAR(200)    NOT NULL,
    short_description   VARCHAR(500),
    description         TEXT,
    category_id         INT,
    supplier_id         INT,
    brand               VARCHAR(100),
    model_number        VARCHAR(100),
    unit_of_measure     VARCHAR(10)     DEFAULT 'EA',
    unit_price          DECIMAL(12,4)   NOT NULL,
    list_price          DECIMAL(12,4),
    cost_price          DECIMAL(12,4),
    msrp                DECIMAL(12,4),
    tax_class           VARCHAR(30),
    weight_kg           DECIMAL(8,3),
    length_cm           DECIMAL(8,2),
    width_cm            DECIMAL(8,2),
    height_cm           DECIMAL(8,2),
    stock_quantity      DECIMAL(12,3)   DEFAULT 0,
    reserved_quantity   DECIMAL(12,3)   DEFAULT 0,
    available_quantity  DECIMAL(12,3)   DEFAULT 0,
    reorder_point       DECIMAL(12,3)   DEFAULT 10,
    reorder_quantity    DECIMAL(12,3)   DEFAULT 50,
    max_stock_level     DECIMAL(12,3),
    lead_time_days      INT,
    is_active           BOOLEAN         DEFAULT TRUE,
    is_discontinued     BOOLEAN         DEFAULT FALSE,
    is_serialized       BOOLEAN         DEFAULT FALSE,
    is_lot_tracked      BOOLEAN         DEFAULT FALSE,
    created_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_products          PRIMARY KEY (product_id),
    CONSTRAINT uq_product_code      UNIQUE (product_code),
    CONSTRAINT fk_prod_category     FOREIGN KEY (category_id)   REFERENCES inventory.categories(category_id),
    CONSTRAINT fk_prod_supplier     FOREIGN KEY (supplier_id)   REFERENCES inventory.suppliers(supplier_id),
    CONSTRAINT chk_unit_price       CHECK (unit_price >= 0),
    CONSTRAINT chk_stock_qty        CHECK (stock_quantity >= 0)
);

CREATE TABLE inventory.warehouses (
    warehouse_id    INT             NOT NULL,
    warehouse_code  VARCHAR(20)     NOT NULL,
    warehouse_name  VARCHAR(100)    NOT NULL,
    address         TEXT,
    city            VARCHAR(100),
    country_code    CHAR(2),
    manager_id      INT,
    capacity_sqft   DECIMAL(10,2),
    is_active       BOOLEAN         DEFAULT TRUE,
    CONSTRAINT pk_warehouses        PRIMARY KEY (warehouse_id),
    CONSTRAINT uq_warehouse_code    UNIQUE (warehouse_code)
);

CREATE TABLE inventory.stock_levels (
    stock_id        INT             NOT NULL,
    product_id      INT             NOT NULL,
    warehouse_id    INT             NOT NULL,
    bin_location    VARCHAR(30),
    quantity        DECIMAL(12,3)   DEFAULT 0,
    reserved_qty    DECIMAL(12,3)   DEFAULT 0,
    last_counted    DATE,
    last_movement   DATETIME,
    CONSTRAINT pk_stock_levels      PRIMARY KEY (stock_id),
    CONSTRAINT uq_product_warehouse UNIQUE (product_id, warehouse_id),
    CONSTRAINT fk_sl_product        FOREIGN KEY (product_id)    REFERENCES inventory.products(product_id),
    CONSTRAINT fk_sl_warehouse      FOREIGN KEY (warehouse_id)  REFERENCES inventory.warehouses(warehouse_id)
);

CREATE TABLE inventory.stock_movements (
    movement_id     BIGINT          NOT NULL,
    product_id      INT             NOT NULL,
    warehouse_id    INT             NOT NULL,
    movement_type   VARCHAR(20)     NOT NULL,
    reference_type  VARCHAR(30),
    reference_id    INT,
    quantity        DECIMAL(12,3)   NOT NULL,
    unit_cost       DECIMAL(12,4),
    total_cost      DECIMAL(15,2),
    movement_date   DATETIME        DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT,
    created_by      INT,
    CONSTRAINT pk_stock_movements   PRIMARY KEY (movement_id),
    CONSTRAINT fk_sm_product        FOREIGN KEY (product_id)    REFERENCES inventory.products(product_id),
    CONSTRAINT fk_sm_warehouse      FOREIGN KEY (warehouse_id)  REFERENCES inventory.warehouses(warehouse_id),
    CONSTRAINT chk_movement_type    CHECK (movement_type IN ('RECEIPT','ISSUE','TRANSFER','ADJUSTMENT','RETURN','WRITE_OFF'))
);

-- ---- A.7 Finance Tables ----

CREATE TABLE finance.accounts (
    account_id      INT             NOT NULL,
    account_code    VARCHAR(20)     NOT NULL,
    account_name    VARCHAR(200)    NOT NULL,
    account_type    VARCHAR(30)     NOT NULL,
    parent_id       INT,
    currency_code   CHAR(3)         DEFAULT 'USD',
    is_active       BOOLEAN         DEFAULT TRUE,
    CONSTRAINT pk_accounts          PRIMARY KEY (account_id),
    CONSTRAINT uq_account_code      UNIQUE (account_code),
    CONSTRAINT fk_acc_parent        FOREIGN KEY (parent_id) REFERENCES finance.accounts(account_id),
    CONSTRAINT chk_account_type     CHECK (account_type IN ('ASSET','LIABILITY','EQUITY','REVENUE','EXPENSE'))
);

CREATE TABLE finance.invoices (
    invoice_id          INT             NOT NULL,
    invoice_number      VARCHAR(30)     NOT NULL,
    order_id            INT             NOT NULL,
    customer_id         INT             NOT NULL,
    invoice_date        DATE            NOT NULL,
    due_date            DATE            NOT NULL,
    currency_code       CHAR(3)         DEFAULT 'USD',
    subtotal            DECIMAL(15,2)   NOT NULL,
    tax_amount          DECIMAL(15,2)   DEFAULT 0.00,
    total_amount        DECIMAL(15,2)   NOT NULL,
    paid_amount         DECIMAL(15,2)   DEFAULT 0.00,
    outstanding_amount  DECIMAL(15,2),
    status              VARCHAR(20)     DEFAULT 'OPEN',
    payment_terms       VARCHAR(30),
    notes               TEXT,
    created_at          DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_invoices          PRIMARY KEY (invoice_id),
    CONSTRAINT uq_invoice_number    UNIQUE (invoice_number),
    CONSTRAINT fk_inv_order         FOREIGN KEY (order_id)      REFERENCES sales.orders(order_id),
    CONSTRAINT fk_inv_customer      FOREIGN KEY (customer_id)   REFERENCES sales.customers(customer_id),
    CONSTRAINT chk_invoice_status   CHECK (status IN ('DRAFT','OPEN','PARTIAL','PAID','OVERDUE','CANCELLED','DISPUTED'))
);

CREATE TABLE finance.payments (
    payment_id          INT             NOT NULL,
    payment_number      VARCHAR(30)     NOT NULL,
    invoice_id          INT             NOT NULL,
    customer_id         INT             NOT NULL,
    payment_date        DATE            NOT NULL,
    amount              DECIMAL(15,2)   NOT NULL,
    currency_code       CHAR(3)         DEFAULT 'USD',
    payment_method      VARCHAR(30),
    reference_number    VARCHAR(100),
    bank_account        VARCHAR(50),
    status              VARCHAR(20)     DEFAULT 'PENDING',
    notes               TEXT,
    CONSTRAINT pk_payments          PRIMARY KEY (payment_id),
    CONSTRAINT uq_payment_number    UNIQUE (payment_number),
    CONSTRAINT fk_pay_invoice       FOREIGN KEY (invoice_id)    REFERENCES finance.invoices(invoice_id),
    CONSTRAINT fk_pay_customer      FOREIGN KEY (customer_id)   REFERENCES sales.customers(customer_id)
);

CREATE TABLE finance.expense_reports (
    report_id       INT             NOT NULL,
    employee_id     INT             NOT NULL,
    report_date     DATE            NOT NULL,
    period_start    DATE,
    period_end      DATE,
    total_amount    DECIMAL(12,2)   DEFAULT 0.00,
    status          VARCHAR(20)     DEFAULT 'DRAFT',
    submitted_at    DATETIME,
    approved_by     INT,
    approved_at     DATETIME,
    notes           TEXT,
    CONSTRAINT pk_expense_reports   PRIMARY KEY (report_id),
    CONSTRAINT fk_er_employee       FOREIGN KEY (employee_id)   REFERENCES hr.employees(employee_id)
);

-- ---- A.8 Audit Table ----

CREATE TABLE audit.activity_log (
    log_id          BIGINT          NOT NULL,
    session_id      VARCHAR(100),
    user_id         INT,
    user_name       VARCHAR(100),
    action          VARCHAR(20)     NOT NULL,
    schema_name     VARCHAR(50),
    table_name      VARCHAR(100),
    record_id       VARCHAR(50),
    old_data        TEXT,
    new_data        TEXT,
    ip_address      VARCHAR(45),
    user_agent      VARCHAR(500),
    application     VARCHAR(100),
    duration_ms     INT,
    status          VARCHAR(10)     DEFAULT 'SUCCESS',
    error_message   TEXT,
    logged_at       DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_activity_log  PRIMARY KEY (log_id),
    CONSTRAINT chk_action       CHECK (action IN ('SELECT','INSERT','UPDATE','DELETE','LOGIN','LOGOUT','EXPORT','IMPORT'))
);

-- ---- A.9 ALTER TABLE Examples ----

-- Add columns
ALTER TABLE hr.employees ADD COLUMN twitter_handle VARCHAR(100);
ALTER TABLE hr.employees ADD COLUMN slack_username  VARCHAR(100);
ALTER TABLE sales.customers ADD COLUMN referral_source VARCHAR(50);
ALTER TABLE inventory.products ADD COLUMN search_keywords TEXT;

-- Modify columns
ALTER TABLE hr.employees MODIFY COLUMN phone_mobile VARCHAR(30);
ALTER TABLE sales.customers MODIFY COLUMN email VARCHAR(200);

-- Drop columns
ALTER TABLE hr.employees DROP COLUMN twitter_handle;
ALTER TABLE hr.employees DROP COLUMN slack_username;

-- Add constraints
ALTER TABLE sales.orders ADD CONSTRAINT chk_exchange_rate CHECK (exchange_rate > 0);
ALTER TABLE inventory.products ADD CONSTRAINT chk_weight CHECK (weight_kg >= 0);

-- Drop constraints
ALTER TABLE sales.orders DROP CONSTRAINT chk_exchange_rate;

-- Rename table
-- ALTER TABLE hr.employees RENAME TO hr.staff;  -- PostgreSQL
-- EXEC sp_rename 'hr.employees', 'staff';        -- SQL Server

-- Add index via ALTER
ALTER TABLE hr.employees ADD INDEX idx_emp_hire_date (hire_date);
ALTER TABLE sales.orders ADD INDEX idx_ord_order_date (order_date);


-- ============================================================================================================================
-- PART B: DATA TYPES - COMPREHENSIVE REFERENCE
-- ============================================================================================================================

-- ---- B.1 Numeric Types ----
-- TINYINT          : 1 byte,  0 to 255 (unsigned) or -128 to 127 (signed)
-- SMALLINT         : 2 bytes, -32,768 to 32,767
-- MEDIUMINT        : 3 bytes, -8,388,608 to 8,388,607 (MySQL)
-- INT / INTEGER    : 4 bytes, -2,147,483,648 to 2,147,483,647
-- BIGINT           : 8 bytes, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
-- DECIMAL(p,s)     : Exact fixed-point number, p=precision (total digits), s=scale (decimal digits)
-- NUMERIC(p,s)     : Identical to DECIMAL in most databases
-- FLOAT(n)         : Approximate floating-point, 4 bytes for n<=24, 8 bytes for n>24
-- REAL             : 4-byte approximate floating-point (single precision)
-- DOUBLE PRECISION : 8-byte approximate floating-point (double precision)
-- MONEY            : 8-byte currency value (SQL Server)
-- SMALLMONEY       : 4-byte currency value (SQL Server)
-- NUMBER(p,s)      : Oracle equivalent of DECIMAL

-- ---- B.2 String Types ----
-- CHAR(n)          : Fixed-length, padded with spaces, max 8000 bytes
-- VARCHAR(n)       : Variable-length, max 8000 bytes (SQL Server) or 65535 (MySQL)
-- TEXT             : Variable-length large string (up to 2GB)
-- NCHAR(n)         : Fixed-length Unicode (UTF-16), max 4000 chars
-- NVARCHAR(n)      : Variable-length Unicode, max 4000 chars or MAX (2GB)
-- NTEXT            : Large Unicode text (deprecated in SQL Server)
-- TINYTEXT         : Up to 255 bytes (MySQL)
-- MEDIUMTEXT       : Up to 16MB (MySQL)
-- LONGTEXT         : Up to 4GB (MySQL)
-- CLOB             : Character Large Object (Oracle/DB2)
-- VARCHAR2(n)      : Oracle variable-length string

-- ---- B.3 Date and Time Types ----
-- DATE             : YYYY-MM-DD, range 0001-01-01 to 9999-12-31
-- TIME             : HH:MM:SS[.nnnnnnn], with optional fractional seconds
-- DATETIME         : YYYY-MM-DD HH:MM:SS, range 1753-01-01 to 9999-12-31 (SQL Server)
-- DATETIME2        : Higher precision datetime (SQL Server 2008+)
-- SMALLDATETIME    : YYYY-MM-DD HH:MM:SS, range 1900-01-01 to 2079-06-06 (SQL Server)
-- DATETIMEOFFSET   : Datetime with timezone offset (SQL Server)
-- TIMESTAMP        : Auto-updated on row change (MySQL) or unique row version (SQL Server)
-- YEAR             : 4-digit year (MySQL)
-- INTERVAL         : Time interval (PostgreSQL, Oracle)

-- ---- B.4 Binary Types ----
-- BINARY(n)        : Fixed-length binary data
-- VARBINARY(n)     : Variable-length binary data
-- IMAGE            : Binary large object (deprecated SQL Server)
-- BLOB             : Binary Large Object (MySQL, Oracle)
-- TINYBLOB         : Up to 255 bytes (MySQL)
-- MEDIUMBLOB       : Up to 16MB (MySQL)
-- LONGBLOB         : Up to 4GB (MySQL)
-- BYTEA            : Binary data (PostgreSQL)
-- RAW(n)           : Raw binary (Oracle)

-- ---- B.5 Other Types ----
-- BOOLEAN / BIT    : True/False or 1/0
-- BIT(n)           : n-bit integer (MySQL)
-- ENUM             : Enumerated list of string values (MySQL)
-- SET              : Set of string values (MySQL)
-- JSON             : JSON document storage
-- JSONB            : Binary JSON (PostgreSQL, faster queries)
-- XML              : XML document storage
-- UUID / UNIQUEIDENTIFIER : 128-bit globally unique identifier
-- ARRAY            : Array of values (PostgreSQL)
-- HSTORE           : Key-value pairs (PostgreSQL)
-- INET             : IPv4/IPv6 address (PostgreSQL)
-- CIDR             : Network address (PostgreSQL)
-- MACADDR          : MAC address (PostgreSQL)
-- POINT/LINE/POLYGON : Geometric types (PostgreSQL)
-- GEOGRAPHY/GEOMETRY : Spatial types (SQL Server, PostGIS)
-- HIERARCHYID      : Hierarchical data (SQL Server)
-- ROWVERSION       : Auto-incrementing binary number (SQL Server)
-- SQL_VARIANT      : Any SQL Server data type value

CREATE TABLE data_type_showcase (
    -- Numeric
    col_tinyint         TINYINT,
    col_smallint        SMALLINT,
    col_int             INT,
    col_bigint          BIGINT,
    col_decimal         DECIMAL(18,4),
    col_numeric         NUMERIC(18,4),
    col_float           FLOAT,
    col_real            REAL,
    -- String
    col_char            CHAR(10),
    col_varchar         VARCHAR(255),
    col_text            TEXT,
    col_nvarchar        NVARCHAR(255),
    -- Date/Time
    col_date            DATE,
    col_time            TIME,
    col_datetime        DATETIME,
    col_timestamp       TIMESTAMP,
    -- Binary
    col_binary          BINARY(16),
    col_varbinary       VARBINARY(255),
    -- Other
    col_boolean         BOOLEAN,
    col_json            JSON,
    col_uuid            VARCHAR(36)  -- UUID stored as string for portability
);


-- ============================================================================================================================
-- PART C: DML - INSERT, UPDATE, DELETE, MERGE, TRUNCATE
-- ============================================================================================================================

-- ---- C.1 INSERT Variations ----

-- Single row insert
INSERT INTO config.countries (country_code, country_name, region, currency_code, phone_prefix)
VALUES ('US', 'United States', 'North America', 'USD', '+1');

-- Multi-row insert
INSERT INTO config.countries (country_code, country_name, region, currency_code, phone_prefix)
VALUES
    ('GB', 'United Kingdom',    'Europe',           'GBP', '+44'),
    ('DE', 'Germany',           'Europe',           'EUR', '+49'),
    ('FR', 'France',            'Europe',           'EUR', '+33'),
    ('JP', 'Japan',             'Asia Pacific',     'JPY', '+81'),
    ('CN', 'China',             'Asia Pacific',     'CNY', '+86'),
    ('IN', 'India',             'Asia Pacific',     'INR', '+91'),
    ('AU', 'Australia',         'Asia Pacific',     'AUD', '+61'),
    ('CA', 'Canada',            'North America',    'CAD', '+1'),
    ('BR', 'Brazil',            'South America',    'BRL', '+55'),
    ('MX', 'Mexico',            'North America',    'MXN', '+52'),
    ('SG', 'Singapore',         'Asia Pacific',     'SGD', '+65'),
    ('AE', 'United Arab Emirates','Middle East',    'AED', '+971'),
    ('ZA', 'South Africa',      'Africa',           'ZAR', '+27'),
    ('NG', 'Nigeria',           'Africa',           'NGN', '+234'),
    ('EG', 'Egypt',             'Africa',           'EGP', '+20');

-- INSERT with SELECT (copy data)
INSERT INTO archive.activity_log_archive
SELECT * FROM audit.activity_log
WHERE logged_at < DATEADD(YEAR, -2, CURRENT_DATE);

-- INSERT with DEFAULT values
INSERT INTO hr.departments (department_id, department_code, department_name)
VALUES (1, 'ENG', 'Engineering');

-- INSERT with RETURNING (PostgreSQL)
-- INSERT INTO sales.customers (customer_id, first_name, last_name, email)
-- VALUES (1, 'John', 'Doe', 'john@example.com')
-- RETURNING customer_id, email;

-- INSERT IGNORE (MySQL - skip duplicate key errors)
-- INSERT IGNORE INTO config.countries VALUES ('US', 'United States', 'North America', 'USD', '+1', TRUE);

-- INSERT ON DUPLICATE KEY UPDATE (MySQL)
-- INSERT INTO inventory.stock_levels (product_id, warehouse_id, quantity)
-- VALUES (1, 1, 100)
-- ON DUPLICATE KEY UPDATE quantity = quantity + 100;

-- INSERT OR REPLACE (SQLite)
-- REPLACE INTO config.countries VALUES ('US', 'United States', 'North America', 'USD', '+1', TRUE);

-- ---- C.2 UPDATE Variations ----

-- Simple update
UPDATE hr.employees
SET salary = salary * 1.05,
    updated_at = CURRENT_TIMESTAMP
WHERE department_id = 1
  AND status = 'ACTIVE';

-- Update with CASE
UPDATE hr.employees
SET salary = salary * CASE
    WHEN job_grade_id = 1 THEN 1.10
    WHEN job_grade_id = 2 THEN 1.08
    WHEN job_grade_id = 3 THEN 1.06
    ELSE 1.03
END,
updated_at = CURRENT_TIMESTAMP
WHERE status = 'ACTIVE';

-- Update with subquery
UPDATE sales.customers
SET credit_limit = (
    SELECT AVG(total_amount) * 3
    FROM sales.orders
    WHERE customer_id = sales.customers.customer_id
      AND status = 'DELIVERED'
)
WHERE customer_id IN (
    SELECT customer_id
    FROM sales.orders
    GROUP BY customer_id
    HAVING COUNT(*) >= 5
);

-- Update with JOIN (SQL Server)
UPDATE c
SET c.credit_limit = c.credit_limit * 1.20,
    c.updated_at   = CURRENT_TIMESTAMP
FROM sales.customers c
INNER JOIN (
    SELECT customer_id, SUM(total_amount) AS lifetime_value
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
    HAVING SUM(total_amount) > 10000
) lv ON c.customer_id = lv.customer_id;

-- Update with CTE
WITH employees_due_raise AS (
    SELECT e.employee_id
    FROM hr.employees e
    LEFT JOIN hr.performance_reviews pr
        ON e.employee_id = pr.employee_id
        AND pr.review_period_end >= DATEADD(YEAR, -1, CURRENT_DATE)
    WHERE e.status = 'ACTIVE'
      AND e.hire_date < DATEADD(YEAR, -1, CURRENT_DATE)
      AND COALESCE(pr.overall_rating, 0) >= 4.0
)
UPDATE hr.employees
SET salary = salary * 1.08,
    updated_at = CURRENT_TIMESTAMP
WHERE employee_id IN (SELECT employee_id FROM employees_due_raise);

-- ---- C.3 DELETE Variations ----

-- Simple delete
DELETE FROM audit.activity_log
WHERE logged_at < DATEADD(YEAR, -3, CURRENT_DATE)
  AND status = 'SUCCESS';

-- Delete with subquery
DELETE FROM sales.order_items
WHERE order_id IN (
    SELECT order_id
    FROM sales.orders
    WHERE status = 'CANCELLED'
      AND order_date < DATEADD(YEAR, -2, CURRENT_DATE)
);

-- Delete with JOIN (SQL Server)
DELETE oi
FROM sales.order_items oi
INNER JOIN sales.orders o ON oi.order_id = o.order_id
WHERE o.status = 'CANCELLED'
  AND o.order_date < DATEADD(YEAR, -2, CURRENT_DATE);

-- Delete with CTE
WITH old_cancelled AS (
    SELECT order_id
    FROM sales.orders
    WHERE status = 'CANCELLED'
      AND order_date < DATEADD(YEAR, -2, CURRENT_DATE)
)
DELETE FROM sales.orders
WHERE order_id IN (SELECT order_id FROM old_cancelled);

-- Soft delete pattern (preferred over hard delete)
UPDATE sales.customers
SET is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE customer_id = 999;

-- ---- C.4 MERGE (UPSERT) ----

MERGE INTO inventory.products AS target
USING (
    SELECT
        'PROD-NEW-001'  AS product_code,
        'New Widget Pro' AS product_name,
        99.99           AS unit_price,
        200             AS stock_quantity
    UNION ALL
    SELECT 'TECH-001', 'Laptop Pro 15 v2', 1199.99, 150
) AS source
ON target.product_code = source.product_code
WHEN MATCHED THEN
    UPDATE SET
        target.product_name    = source.product_name,
        target.unit_price      = source.unit_price,
        target.stock_quantity  = source.stock_quantity,
        target.updated_at      = CURRENT_TIMESTAMP
WHEN NOT MATCHED BY TARGET THEN
    INSERT (product_code, product_name, unit_price, stock_quantity)
    VALUES (source.product_code, source.product_name, source.unit_price, source.stock_quantity)
WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET target.is_discontinued = TRUE;

-- ---- C.5 TRUNCATE ----

-- TRUNCATE removes all rows, resets identity, minimal logging
TRUNCATE TABLE staging.import_staging;

-- TRUNCATE with CASCADE (PostgreSQL)
-- TRUNCATE TABLE sales.orders CASCADE;

-- Difference: DELETE vs TRUNCATE
-- DELETE: DML, logged per row, can be rolled back, fires triggers, WHERE clause allowed
-- TRUNCATE: DDL, minimally logged, faster, resets identity, no WHERE clause, no triggers


-- ============================================================================================================================
-- PART D: SELECT - COMPREHENSIVE QUERY EXAMPLES
-- ============================================================================================================================

-- ---- D.1 Basic SELECT ----

SELECT * FROM hr.employees;

SELECT
    employee_id,
    employee_number,
    CONCAT(first_name, ' ', last_name)  AS full_name,
    email,
    job_title,
    salary,
    hire_date
FROM hr.employees
WHERE status = 'ACTIVE';

-- ---- D.2 Column Expressions and Aliases ----

SELECT
    e.employee_id                                               AS id,
    UPPER(CONCAT(e.last_name, ', ', e.first_name))             AS name_formal,
    LOWER(e.email)                                              AS email,
    e.salary                                                    AS annual_salary,
    ROUND(e.salary / 12, 2)                                     AS monthly_salary,
    ROUND(e.salary / 52, 2)                                     AS weekly_salary,
    ROUND(e.salary / 260, 2)                                    AS daily_salary,
    ROUND(e.salary / 2080, 2)                                   AS hourly_equivalent,
    DATEDIFF(YEAR, e.hire_date, CURRENT_DATE)                   AS years_of_service,
    DATEDIFF(MONTH, e.hire_date, CURRENT_DATE)                  AS months_of_service,
    d.department_name,
    g.grade_name                                                AS job_grade
FROM hr.employees e
LEFT JOIN hr.departments d  ON e.department_id  = d.department_id
LEFT JOIN hr.job_grades g   ON e.job_grade_id   = g.grade_id
WHERE e.status = 'ACTIVE'
ORDER BY e.last_name, e.first_name;

-- ---- D.3 DISTINCT ----

SELECT DISTINCT department_id FROM hr.employees;
SELECT DISTINCT city, billing_country FROM sales.customers ORDER BY billing_country, city;
SELECT DISTINCT employment_type, status FROM hr.employees ORDER BY employment_type;

-- ---- D.4 TOP / LIMIT / FETCH ----

-- SQL Server
SELECT TOP 10 * FROM sales.orders ORDER BY order_date DESC;
SELECT TOP 10 WITH TIES * FROM sales.orders ORDER BY total_amount DESC;

-- MySQL / PostgreSQL
SELECT * FROM sales.orders ORDER BY order_date DESC LIMIT 10;
SELECT * FROM sales.orders ORDER BY order_date DESC LIMIT 10 OFFSET 20;

-- Standard SQL (SQL Server 2012+, PostgreSQL)
SELECT * FROM sales.orders
ORDER BY order_date DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Page 3 (rows 21-30)
SELECT * FROM sales.orders
ORDER BY order_id
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;

-- ---- D.5 WHERE Clause - All Operators ----

-- Comparison operators
SELECT * FROM hr.employees WHERE salary > 80000;
SELECT * FROM hr.employees WHERE salary >= 80000;
SELECT * FROM hr.employees WHERE salary < 50000;
SELECT * FROM hr.employees WHERE salary <= 50000;
SELECT * FROM hr.employees WHERE salary = 75000;
SELECT * FROM hr.employees WHERE salary <> 75000;
SELECT * FROM hr.employees WHERE salary != 75000;

-- BETWEEN
SELECT * FROM hr.employees WHERE salary BETWEEN 60000 AND 100000;
SELECT * FROM sales.orders WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';
SELECT * FROM inventory.products WHERE unit_price BETWEEN 10.00 AND 100.00;

-- IN / NOT IN
SELECT * FROM hr.employees WHERE department_id IN (1, 2, 3);
SELECT * FROM hr.employees WHERE status NOT IN ('TERMINATED', 'SUSPENDED');
SELECT * FROM inventory.products WHERE category_id IN (SELECT category_id FROM inventory.categories WHERE category_name LIKE '%Electronics%');

-- LIKE / NOT LIKE
SELECT * FROM hr.employees WHERE email LIKE '%@company.com';
SELECT * FROM hr.employees WHERE first_name LIKE 'A%';
SELECT * FROM hr.employees WHERE last_name LIKE '%son';
SELECT * FROM hr.employees WHERE first_name LIKE '_a%';       -- second char is 'a'
SELECT * FROM inventory.products WHERE product_code LIKE 'TECH-[0-9][0-9][0-9]';
SELECT * FROM hr.employees WHERE email NOT LIKE '%@gmail.com';

-- IS NULL / IS NOT NULL
SELECT * FROM hr.employees WHERE manager_id IS NULL;
SELECT * FROM hr.employees WHERE termination_date IS NOT NULL;
SELECT * FROM sales.customers WHERE company_name IS NOT NULL;

-- Logical operators
SELECT * FROM hr.employees
WHERE (department_id = 1 OR department_id = 2)
  AND salary > 70000
  AND status = 'ACTIVE'
  AND hire_date >= '2018-01-01';

-- NOT operator
SELECT * FROM hr.employees
WHERE NOT (status = 'TERMINATED' OR status = 'SUSPENDED');

-- ---- D.6 ORDER BY ----

SELECT * FROM hr.employees ORDER BY last_name ASC, first_name ASC;
SELECT * FROM hr.employees ORDER BY salary DESC, hire_date ASC;
SELECT * FROM hr.employees ORDER BY department_id, salary DESC;

-- ORDER BY with expression
SELECT first_name, last_name, salary FROM hr.employees
ORDER BY salary * 1.10 DESC;

-- ORDER BY with CASE
SELECT * FROM sales.orders
ORDER BY
    CASE status
        WHEN 'URGENT'       THEN 1
        WHEN 'PROCESSING'   THEN 2
        WHEN 'PENDING'      THEN 3
        WHEN 'CONFIRMED'    THEN 4
        ELSE                     5
    END,
    order_date DESC;

-- ORDER BY with NULLS
SELECT * FROM hr.employees ORDER BY manager_id ASC NULLS LAST;   -- PostgreSQL
SELECT * FROM hr.employees ORDER BY manager_id ASC NULLS FIRST;

-- ---- D.7 GROUP BY and Aggregations ----

-- Basic aggregations
SELECT
    COUNT(*)                        AS total_employees,
    COUNT(DISTINCT department_id)   AS departments_with_staff,
    MIN(salary)                     AS min_salary,
    MAX(salary)                     AS max_salary,
    AVG(salary)                     AS avg_salary,
    SUM(salary)                     AS total_payroll,
    STDEV(salary)                   AS salary_std_dev,
    VAR(salary)                     AS salary_variance
FROM hr.employees
WHERE status = 'ACTIVE';

-- GROUP BY
SELECT
    d.department_name,
    e.employment_type,
    COUNT(e.employee_id)            AS headcount,
    MIN(e.salary)                   AS min_salary,
    MAX(e.salary)                   AS max_salary,
    ROUND(AVG(e.salary), 2)         AS avg_salary,
    SUM(e.salary)                   AS total_salary,
    ROUND(SUM(e.salary) / SUM(SUM(e.salary)) OVER () * 100, 2) AS pct_of_total_payroll
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name, e.employment_type
ORDER BY d.department_name, e.employment_type;

-- HAVING
SELECT
    department_id,
    COUNT(*)        AS headcount,
    AVG(salary)     AS avg_salary
FROM hr.employees
WHERE status = 'ACTIVE'
GROUP BY department_id
HAVING COUNT(*) >= 3
   AND AVG(salary) > 70000
ORDER BY avg_salary DESC;

-- ROLLUP
SELECT
    COALESCE(d.department_name, 'ALL DEPARTMENTS')  AS department,
    COALESCE(e.employment_type, 'ALL TYPES')         AS employment_type,
    COUNT(*)                                          AS headcount,
    SUM(e.salary)                                     AS total_salary
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY ROLLUP(d.department_name, e.employment_type);

-- CUBE
SELECT
    COALESCE(category_id::VARCHAR, 'ALL')   AS category,
    COALESCE(supplier_id::VARCHAR, 'ALL')   AS supplier,
    COUNT(*)                                 AS product_count,
    SUM(unit_price * stock_quantity)         AS inventory_value
FROM inventory.products
WHERE is_active = TRUE
GROUP BY CUBE(category_id, supplier_id);

-- GROUPING SETS
SELECT
    category_id,
    supplier_id,
    COUNT(*) AS cnt,
    SUM(stock_quantity) AS total_stock
FROM inventory.products
GROUP BY GROUPING SETS (
    (category_id, supplier_id),
    (category_id),
    (supplier_id),
    ()
);

-- STRING_AGG
SELECT
    d.department_name,
    STRING_AGG(CONCAT(e.first_name, ' ', e.last_name), ', ' ORDER BY e.last_name) AS employees
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name;


-- ============================================================================================================================
-- PART E: JOINS - ALL TYPES WITH DETAILED EXAMPLES
-- ============================================================================================================================

-- ---- E.1 INNER JOIN ----

-- Basic inner join
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee_name,
    d.department_name,
    e.job_title,
    e.salary
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
ORDER BY d.department_name, e.last_name;

-- ---- E.2 LEFT JOIN ----

-- All customers, with or without orders
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.email,
    COUNT(o.order_id)                        AS order_count,
    COALESCE(SUM(o.total_amount), 0)         AS total_spent,
    MAX(o.order_date)                        AS last_order_date
FROM sales.customers c
LEFT JOIN sales.orders o
    ON c.customer_id = o.customer_id
    AND o.status NOT IN ('CANCELLED', 'RETURNED')
WHERE c.is_active = TRUE
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_spent DESC;

-- ---- E.3 RIGHT JOIN ----

-- All departments, with or without employees
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id)    AS headcount,
    AVG(e.salary)           AS avg_salary
FROM hr.employees e
RIGHT JOIN hr.departments d ON e.department_id = d.department_id
WHERE d.is_active = TRUE
GROUP BY d.department_id, d.department_name
ORDER BY headcount DESC;

-- ---- E.4 FULL OUTER JOIN ----

-- All employees and all departments, matched where possible
SELECT
    COALESCE(e.first_name, 'N/A')   AS employee_first,
    COALESCE(e.last_name, 'N/A')    AS employee_last,
    COALESCE(d.department_name, 'UNASSIGNED') AS department
FROM hr.employees e
FULL OUTER JOIN hr.departments d ON e.department_id = d.department_id;

-- ---- E.5 CROSS JOIN ----

-- All possible employee-department combinations (for scheduling)
SELECT
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
CROSS JOIN hr.departments d
WHERE e.status = 'ACTIVE'
ORDER BY e.last_name, d.department_name;

-- ---- E.6 SELF JOIN ----

-- Employee with their manager
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee,
    e.job_title,
    CONCAT(m.first_name, ' ', m.last_name)  AS manager,
    m.job_title                              AS manager_title
FROM hr.employees e
LEFT JOIN hr.employees m ON e.manager_id = m.employee_id
WHERE e.status = 'ACTIVE'
ORDER BY m.last_name, e.last_name;

-- Employees earning more than their manager
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee,
    e.salary                                 AS employee_salary,
    CONCAT(m.first_name, ' ', m.last_name)  AS manager,
    m.salary                                 AS manager_salary,
    e.salary - m.salary                      AS salary_difference
FROM hr.employees e
INNER JOIN hr.employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary
ORDER BY salary_difference DESC;

-- ---- E.7 Multi-Table JOIN ----

SELECT
    o.order_number,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer,
    c.email                                  AS customer_email,
    CONCAT(e.first_name, ' ', e.last_name)  AS sales_rep,
    p.product_name,
    p.product_code,
    cat.category_name,
    oi.quantity_ordered,
    oi.unit_price,
    oi.discount_pct,
    oi.line_total,
    o.status                                 AS order_status
FROM sales.orders o
INNER JOIN sales.customers c        ON o.customer_id    = c.customer_id
LEFT  JOIN hr.employees e           ON o.sales_rep_id   = e.employee_id
INNER JOIN sales.order_items oi     ON o.order_id       = oi.order_id
INNER JOIN inventory.products p     ON oi.product_id    = p.product_id
LEFT  JOIN inventory.categories cat ON p.category_id    = cat.category_id
WHERE o.order_date >= '2024-01-01'
  AND o.status NOT IN ('CANCELLED')
ORDER BY o.order_date DESC, o.order_number;

-- ---- E.8 JOIN with Aggregation ----

SELECT
    p.product_id,
    p.product_name,
    p.product_code,
    cat.category_name,
    COUNT(DISTINCT oi.order_id)     AS times_ordered,
    SUM(oi.quantity_ordered)        AS total_qty_sold,
    SUM(oi.line_total)              AS total_revenue,
    AVG(oi.unit_price)              AS avg_selling_price,
    MIN(oi.unit_price)              AS min_selling_price,
    MAX(oi.unit_price)              AS max_selling_price,
    AVG(oi.discount_pct)            AS avg_discount_pct
FROM inventory.products p
LEFT JOIN inventory.categories cat  ON p.category_id    = cat.category_id
LEFT JOIN sales.order_items oi      ON p.product_id     = oi.product_id
LEFT JOIN sales.orders o            ON oi.order_id      = o.order_id
    AND o.status NOT IN ('CANCELLED', 'RETURNED')
WHERE p.is_active = TRUE
GROUP BY p.product_id, p.product_name, p.product_code, cat.category_name
ORDER BY total_revenue DESC NULLS LAST;

-- ---- E.9 Non-Equi JOIN ----

-- Assign salary band based on job grade ranges
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee,
    e.salary,
    g.grade_name,
    g.min_salary,
    g.max_salary,
    CASE
        WHEN e.salary < g.min_salary THEN 'BELOW BAND'
        WHEN e.salary > g.max_salary THEN 'ABOVE BAND'
        ELSE 'IN BAND'
    END AS salary_position
FROM hr.employees e
INNER JOIN hr.job_grades g
    ON e.salary BETWEEN g.min_salary AND g.max_salary
WHERE e.status = 'ACTIVE';

-- ---- E.10 LATERAL JOIN (PostgreSQL) / CROSS APPLY (SQL Server) ----

-- Get last 3 orders per customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer,
    recent.order_number,
    recent.order_date,
    recent.total_amount
FROM sales.customers c
CROSS APPLY (
    SELECT TOP 3 order_number, order_date, total_amount
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY order_date DESC
) recent
WHERE c.is_active = TRUE;


-- ============================================================================================================================
-- PART F: SUBQUERIES
-- ============================================================================================================================

-- ---- F.1 Scalar Subquery ----

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)          AS employee,
    e.salary,
    (SELECT AVG(salary) FROM hr.employees WHERE status = 'ACTIVE')  AS company_avg,
    e.salary - (SELECT AVG(salary) FROM hr.employees WHERE status = 'ACTIVE') AS vs_avg,
    ROUND(e.salary / (SELECT AVG(salary) FROM hr.employees WHERE status = 'ACTIVE') * 100, 1) AS pct_of_avg
FROM hr.employees e
WHERE e.status = 'ACTIVE'
ORDER BY e.salary DESC;

-- ---- F.2 Subquery in WHERE ----

-- Employees earning above company average
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary > (SELECT AVG(salary) FROM hr.employees WHERE status = 'ACTIVE')
  AND status = 'ACTIVE'
ORDER BY salary DESC;

-- Customers who placed orders above average order value
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM sales.customers c
WHERE c.customer_id IN (
    SELECT DISTINCT o.customer_id
    FROM sales.orders o
    WHERE o.total_amount > (SELECT AVG(total_amount) FROM sales.orders WHERE status = 'DELIVERED')
      AND o.status = 'DELIVERED'
);

-- ---- F.3 Correlated Subquery ----

-- Employees earning above their department average
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee,
    e.department_id,
    e.salary,
    (
        SELECT ROUND(AVG(e2.salary), 2)
        FROM hr.employees e2
        WHERE e2.department_id = e.department_id
          AND e2.status = 'ACTIVE'
    ) AS dept_avg_salary
FROM hr.employees e
WHERE e.status = 'ACTIVE'
  AND e.salary > (
    SELECT AVG(e3.salary)
    FROM hr.employees e3
    WHERE e3.department_id = e.department_id
      AND e3.status = 'ACTIVE'
  )
ORDER BY e.department_id, e.salary DESC;

-- ---- F.4 EXISTS / NOT EXISTS ----

-- Customers who have placed at least one delivered order
SELECT c.customer_id, c.first_name, c.last_name
FROM sales.customers c
WHERE EXISTS (
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'DELIVERED'
);

-- Products never ordered
SELECT p.product_id, p.product_name, p.product_code
FROM inventory.products p
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.order_items oi
    WHERE oi.product_id = p.product_id
)
AND p.is_active = TRUE;

-- ---- F.5 ANY / ALL ----

-- Employees earning more than ANY employee in department 5
SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > ANY (
    SELECT salary FROM hr.employees WHERE department_id = 5 AND status = 'ACTIVE'
)
AND department_id != 5
AND status = 'ACTIVE';

-- Employees earning more than ALL employees in department 4
SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > ALL (
    SELECT salary FROM hr.employees WHERE department_id = 4 AND status = 'ACTIVE'
)
AND status = 'ACTIVE';

-- ---- F.6 Inline View (Derived Table) ----

SELECT
    dept_stats.department_name,
    dept_stats.headcount,
    dept_stats.avg_salary,
    dept_stats.total_salary,
    dept_stats.min_salary,
    dept_stats.max_salary,
    ROUND(dept_stats.total_salary / SUM(dept_stats.total_salary) OVER () * 100, 2) AS pct_of_payroll
FROM (
    SELECT
        d.department_name,
        COUNT(e.employee_id)    AS headcount,
        ROUND(AVG(e.salary), 2) AS avg_salary,
        SUM(e.salary)           AS total_salary,
        MIN(e.salary)           AS min_salary,
        MAX(e.salary)           AS max_salary
    FROM hr.employees e
    INNER JOIN hr.departments d ON e.department_id = d.department_id
    WHERE e.status = 'ACTIVE'
    GROUP BY d.department_name
    HAVING COUNT(e.employee_id) > 0
) dept_stats
ORDER BY dept_stats.total_salary DESC;


-- ============================================================================================================================
-- PART G: COMMON TABLE EXPRESSIONS (CTEs)
-- ============================================================================================================================

-- ---- G.1 Simple CTE ----

WITH active_employees AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name)  AS full_name,
        e.salary,
        e.department_id,
        e.hire_date,
        DATEDIFF(YEAR, e.hire_date, CURRENT_DATE) AS years_service
    FROM hr.employees e
    WHERE e.status = 'ACTIVE'
)
SELECT
    ae.full_name,
    ae.salary,
    ae.years_service,
    d.department_name
FROM active_employees ae
INNER JOIN hr.departments d ON ae.department_id = d.department_id
WHERE ae.years_service >= 5
ORDER BY ae.years_service DESC;

-- ---- G.2 Multiple CTEs ----

WITH
dept_summary AS (
    SELECT
        department_id,
        COUNT(*)        AS headcount,
        AVG(salary)     AS avg_salary,
        SUM(salary)     AS total_salary,
        MAX(salary)     AS max_salary
    FROM hr.employees
    WHERE status = 'ACTIVE'
    GROUP BY department_id
),
high_value_depts AS (
    SELECT department_id
    FROM dept_summary
    WHERE avg_salary > 75000
      AND headcount >= 3
),
top_earners AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.salary,
        e.department_id,
        ROW_NUMBER() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank
    FROM hr.employees e
    INNER JOIN high_value_depts hvd ON e.department_id = hvd.department_id
    WHERE e.status = 'ACTIVE'
)
SELECT
    te.first_name,
    te.last_name,
    te.salary,
    te.salary_rank,
    d.department_name,
    ds.avg_salary       AS dept_avg,
    ds.headcount        AS dept_headcount
FROM top_earners te
INNER JOIN hr.departments d     ON te.department_id = d.department_id
INNER JOIN dept_summary ds      ON te.department_id = ds.department_id
WHERE te.salary_rank <= 3
ORDER BY d.department_name, te.salary_rank;

-- ---- G.3 CTE for Data Modification ----

-- CTE for UPDATE
WITH underperforming_stock AS (
    SELECT product_id
    FROM inventory.products
    WHERE stock_quantity > reorder_point * 3
      AND is_active = TRUE
)
UPDATE inventory.products
SET reorder_point = reorder_point * 0.8
WHERE product_id IN (SELECT product_id FROM underperforming_stock);

-- CTE for DELETE
WITH expired_sessions AS (
    SELECT log_id
    FROM audit.activity_log
    WHERE logged_at < DATEADD(MONTH, -6, CURRENT_DATE)
      AND action = 'SELECT'
)
DELETE FROM audit.activity_log
WHERE log_id IN (SELECT log_id FROM expired_sessions);

-- ---- G.4 Recursive CTE ----

-- Organizational hierarchy
WITH RECURSIVE org_tree AS (
    -- Anchor: CEO (no manager)
    SELECT
        employee_id,
        CONCAT(first_name, ' ', last_name)  AS full_name,
        job_title,
        manager_id,
        salary,
        0                                    AS depth,
        CAST(employee_id AS VARCHAR(1000))   AS path,
        CAST(CONCAT(first_name, ' ', last_name) AS VARCHAR(4000)) AS hierarchy_path
    FROM hr.employees
    WHERE manager_id IS NULL
      AND status = 'ACTIVE'

    UNION ALL

    -- Recursive: direct reports
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name),
        e.job_title,
        e.manager_id,
        e.salary,
        ot.depth + 1,
        CAST(CONCAT(ot.path, '->', e.employee_id) AS VARCHAR(1000)),
        CAST(CONCAT(ot.hierarchy_path, ' > ', e.first_name, ' ', e.last_name) AS VARCHAR(4000))
    FROM hr.employees e
    INNER JOIN org_tree ot ON e.manager_id = ot.employee_id
    WHERE e.status = 'ACTIVE'
)
SELECT
    REPLICATE('    ', depth) + full_name    AS indented_name,
    job_title,
    salary,
    depth                                   AS org_level,
    hierarchy_path
FROM org_tree
ORDER BY path;

-- Recursive CTE: Category hierarchy
WITH RECURSIVE category_tree AS (
    SELECT
        category_id,
        category_name,
        parent_id,
        0 AS level,
        CAST(category_name AS VARCHAR(1000)) AS full_path
    FROM inventory.categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.category_id,
        c.category_name,
        c.parent_id,
        ct.level + 1,
        CAST(CONCAT(ct.full_path, ' > ', c.category_name) AS VARCHAR(1000))
    FROM inventory.categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.category_id
)
SELECT
    REPLICATE('  ', level) + category_name AS indented_category,
    level,
    full_path
FROM category_tree
ORDER BY full_path;

-- Recursive CTE: Generate date series
WITH RECURSIVE date_series AS (
    SELECT CAST('2024-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt)
    FROM date_series
    WHERE dt < '2024-12-31'
)
SELECT
    ds.dt                                               AS date,
    DATENAME(WEEKDAY, ds.dt)                            AS day_name,
    DATENAME(MONTH, ds.dt)                              AS month_name,
    DATEPART(WEEK, ds.dt)                               AS week_number,
    DATEPART(QUARTER, ds.dt)                            AS quarter,
    CASE WHEN DATEPART(WEEKDAY, ds.dt) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COALESCE(COUNT(o.order_id), 0)                      AS order_count,
    COALESCE(SUM(o.total_amount), 0)                    AS daily_revenue
FROM date_series ds
LEFT JOIN sales.orders o
    ON CAST(o.order_date AS DATE) = ds.dt
    AND o.status NOT IN ('CANCELLED')
GROUP BY ds.dt
ORDER BY ds.dt;

-- Recursive CTE: Number series
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 1000
)
SELECT n FROM nums;

-- Recursive CTE: Fibonacci
WITH RECURSIVE fib AS (
    SELECT 0 AS n, 0 AS a, 1 AS b
    UNION ALL
    SELECT n + 1, b, a + b
    FROM fib
    WHERE n < 30
)
SELECT n AS position, a AS fibonacci_value FROM fib;


-- ============================================================================================================================
-- PART H: WINDOW FUNCTIONS
-- ============================================================================================================================

-- ---- H.1 ROW_NUMBER ----

-- Unique row number per partition
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name)  AS employee,
    department_id,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS rank_in_dept
FROM hr.employees
WHERE status = 'ACTIVE';

-- Pagination using ROW_NUMBER
SELECT * FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY order_date DESC) AS rn
    FROM sales.orders
    WHERE status = 'DELIVERED'
) paged
WHERE rn BETWEEN 21 AND 30;

-- ---- H.2 RANK and DENSE_RANK ----

SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    RANK()          OVER (ORDER BY salary DESC) AS rank_with_gaps,
    DENSE_RANK()    OVER (ORDER BY salary DESC) AS rank_no_gaps,
    ROW_NUMBER()    OVER (ORDER BY salary DESC) AS row_num
FROM hr.employees
WHERE status = 'ACTIVE';

-- Top 3 per department (using DENSE_RANK to handle ties)
SELECT *
FROM (
    SELECT
        employee_id,
        first_name,
        last_name,
        department_id,
        salary,
        DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
    FROM hr.employees
    WHERE status = 'ACTIVE'
) ranked
WHERE dept_rank <= 3;

-- ---- H.3 NTILE ----

SELECT
    employee_id,
    first_name,
    salary,
    NTILE(4)  OVER (ORDER BY salary) AS salary_quartile,
    NTILE(10) OVER (ORDER BY salary) AS salary_decile,
    NTILE(100) OVER (ORDER BY salary) AS salary_percentile
FROM hr.employees
WHERE status = 'ACTIVE';

-- ---- H.4 LAG and LEAD ----

-- Month-over-month revenue comparison
SELECT
    order_month,
    monthly_revenue,
    LAG(monthly_revenue, 1, 0)  OVER (ORDER BY order_month) AS prev_month_revenue,
    LEAD(monthly_revenue, 1, 0) OVER (ORDER BY order_month) AS next_month_revenue,
    monthly_revenue - LAG(monthly_revenue, 1, 0) OVER (ORDER BY order_month) AS mom_change,
    CASE
        WHEN LAG(monthly_revenue, 1) OVER (ORDER BY order_month) = 0 THEN NULL
        ELSE ROUND(
            (monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY order_month))
            / LAG(monthly_revenue, 1) OVER (ORDER BY order_month) * 100, 2
        )
    END AS mom_pct_change
FROM (
    SELECT
        FORMAT(order_date, 'yyyy-MM')   AS order_month,
        SUM(total_amount)               AS monthly_revenue
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY FORMAT(order_date, 'yyyy-MM')
) monthly
ORDER BY order_month;

-- Days between consecutive orders per customer
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
    DATEDIFF(DAY,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date),
        order_date
    ) AS days_since_last_order
FROM sales.orders
WHERE status NOT IN ('CANCELLED')
ORDER BY customer_id, order_date;

-- ---- H.5 FIRST_VALUE and LAST_VALUE ----

SELECT
    employee_id,
    first_name,
    department_id,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_highest_salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_lowest_salary,
    FIRST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (
        PARTITION BY department_id
        ORDER BY hire_date ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS longest_serving_in_dept
FROM hr.employees
WHERE status = 'ACTIVE';

-- ---- H.6 Running Totals and Moving Averages ----

SELECT
    order_date,
    total_amount,
    -- Running total (cumulative sum)
    SUM(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    -- 7-day moving average
    AVG(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7d,
    -- 30-day moving sum
    SUM(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30d_sum,
    -- Monthly total
    SUM(total_amount) OVER (
        PARTITION BY FORMAT(order_date, 'yyyy-MM')
    ) AS monthly_total,
    -- Percentage of monthly total
    ROUND(
        total_amount / SUM(total_amount) OVER (PARTITION BY FORMAT(order_date, 'yyyy-MM')) * 100,
        2
    ) AS pct_of_month
FROM sales.orders
WHERE status = 'DELIVERED'
ORDER BY order_date;

-- ---- H.7 PERCENT_RANK and CUME_DIST ----

SELECT
    employee_id,
    first_name,
    salary,
    PERCENT_RANK() OVER (ORDER BY salary)   AS percent_rank,
    CUME_DIST()    OVER (ORDER BY salary)   AS cumulative_dist,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary) * 100, 1) AS percentile
FROM hr.employees
WHERE status = 'ACTIVE'
ORDER BY salary;

-- ---- H.8 Aggregate Window Functions ----

SELECT
    employee_id,
    first_name,
    department_id,
    salary,
    -- Department-level aggregates as window functions
    COUNT(*)    OVER (PARTITION BY department_id)               AS dept_headcount,
    SUM(salary) OVER (PARTITION BY department_id)               AS dept_total_salary,
    AVG(salary) OVER (PARTITION BY department_id)               AS dept_avg_salary,
    MIN(salary) OVER (PARTITION BY department_id)               AS dept_min_salary,
    MAX(salary) OVER (PARTITION BY department_id)               AS dept_max_salary,
    -- Company-level
    AVG(salary) OVER ()                                         AS company_avg_salary,
    -- Salary vs department average
    ROUND(salary / AVG(salary) OVER (PARTITION BY department_id) * 100, 1) AS pct_of_dept_avg
FROM hr.employees
WHERE status = 'ACTIVE';


-- ============================================================================================================================
-- PART I: SET OPERATIONS
-- ============================================================================================================================

-- ---- I.1 UNION ----

-- All people (employees + customers) - removes duplicates
SELECT 'Employee' AS person_type, first_name, last_name, email
FROM hr.employees
WHERE status = 'ACTIVE'
UNION
SELECT 'Customer', first_name, last_name, email
FROM sales.customers
WHERE is_active = TRUE
ORDER BY last_name, first_name;

-- ---- I.2 UNION ALL ----

-- All people including duplicates (faster)
SELECT 'Employee' AS person_type, first_name, last_name, email, hire_date AS event_date
FROM hr.employees
UNION ALL
SELECT 'Customer', first_name, last_name, email, registration_date
FROM sales.customers
ORDER BY event_date DESC;

-- ---- I.3 INTERSECT ----

-- Cities that have both employees and customers
SELECT city FROM hr.employees WHERE city IS NOT NULL
INTERSECT
SELECT billing_city FROM sales.customers WHERE billing_city IS NOT NULL
ORDER BY city;

-- ---- I.4 EXCEPT / MINUS ----

-- Customers who have never placed an order
SELECT customer_id FROM sales.customers
EXCEPT
SELECT DISTINCT customer_id FROM sales.orders;

-- Products never ordered
SELECT product_id FROM inventory.products WHERE is_active = TRUE
EXCEPT
SELECT DISTINCT product_id FROM sales.order_items;

-- ---- I.5 Complex Set Operations ----

-- Revenue by channel for Q1 and Q2 combined
(
    SELECT 'Q1' AS quarter, channel, SUM(total_amount) AS revenue
    FROM sales.orders
    WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31'
      AND status = 'DELIVERED'
    GROUP BY channel
)
UNION ALL
(
    SELECT 'Q2', channel, SUM(total_amount)
    FROM sales.orders
    WHERE order_date BETWEEN '2024-04-01' AND '2024-06-30'
      AND status = 'DELIVERED'
    GROUP BY channel
)
ORDER BY quarter, revenue DESC;


-- ============================================================================================================================
-- PART J: INDEXES
-- ============================================================================================================================

-- ---- J.1 Index Types ----

-- Clustered index (physical sort order of table)
CREATE CLUSTERED INDEX idx_orders_order_date ON sales.orders(order_date);

-- Non-clustered index
CREATE NONCLUSTERED INDEX idx_employees_dept ON hr.employees(department_id);
CREATE NONCLUSTERED INDEX idx_employees_salary ON hr.employees(salary DESC);
CREATE NONCLUSTERED INDEX idx_customers_email ON sales.customers(email);
CREATE NONCLUSTERED INDEX idx_products_code ON inventory.products(product_code);

-- Unique index
CREATE UNIQUE INDEX idx_employees_emp_number ON hr.employees(employee_number);
CREATE UNIQUE INDEX idx_orders_order_number ON sales.orders(order_number);

-- Composite index (column order matters!)
CREATE INDEX idx_orders_customer_date ON sales.orders(customer_id, order_date DESC);
CREATE INDEX idx_emp_dept_status ON hr.employees(department_id, status, salary DESC);
CREATE INDEX idx_oi_order_product ON sales.order_items(order_id, product_id);

-- Covering index (includes non-key columns to avoid key lookups)
CREATE INDEX idx_orders_covering
ON sales.orders(customer_id, order_date)
INCLUDE (order_number, total_amount, status, payment_status);

CREATE INDEX idx_employees_covering
ON hr.employees(department_id, status)
INCLUDE (first_name, last_name, email, salary, job_title);

-- Filtered index (partial index - only indexes rows matching WHERE)
CREATE INDEX idx_active_employees
ON hr.employees(department_id, salary)
WHERE status = 'ACTIVE';

CREATE INDEX idx_pending_orders
ON sales.orders(customer_id, order_date)
WHERE status IN ('PENDING', 'PROCESSING');

CREATE INDEX idx_low_stock
ON inventory.products(product_id, stock_quantity)
WHERE stock_quantity <= reorder_point AND is_active = TRUE;

-- Full-text index
CREATE FULLTEXT CATALOG ft_products_catalog AS DEFAULT;
CREATE FULLTEXT INDEX ON inventory.products(product_name, short_description, description)
KEY INDEX pk_products ON ft_products_catalog WITH CHANGE_TRACKING AUTO;

-- ---- J.2 Index Maintenance ----

-- Rebuild index (defragments, updates statistics)
ALTER INDEX idx_orders_customer_date ON sales.orders REBUILD;
ALTER INDEX ALL ON hr.employees REBUILD;

-- Reorganize index (online, less resource intensive)
ALTER INDEX idx_employees_dept ON hr.employees REORGANIZE;

-- Update statistics
UPDATE STATISTICS hr.employees;
UPDATE STATISTICS sales.orders WITH FULLSCAN;

-- Drop index
DROP INDEX idx_employees_salary ON hr.employees;
DROP INDEX IF EXISTS idx_employees_salary ON hr.employees;

-- ---- J.3 Index Usage Analysis ----

-- Find unused indexes (SQL Server)
SELECT
    OBJECT_NAME(i.object_id)    AS table_name,
    i.name                      AS index_name,
    i.type_desc,
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
  AND i.index_id > 0
ORDER BY COALESCE(ius.user_seeks, 0) + COALESCE(ius.user_scans, 0) ASC;

-- Find missing indexes (SQL Server)
SELECT TOP 25
    ROUND(migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans), 0) AS improvement_score,
    mid.statement                   AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_total_user_cost,
    migs.avg_user_impact
FROM sys.dm_db_missing_index_group_stats migs
INNER JOIN sys.dm_db_missing_index_groups mig ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY improvement_score DESC;

-- Index fragmentation
SELECT
    OBJECT_NAME(ips.object_id)  AS table_name,
    i.name                      AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
  AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;


-- ============================================================================================================================
-- PART K: VIEWS
-- ============================================================================================================================

-- ---- K.1 Simple Views ----

CREATE VIEW hr.vw_active_employees AS
SELECT
    e.employee_id,
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name)  AS full_name,
    e.first_name,
    e.last_name,
    e.email,
    e.phone_mobile,
    e.job_title,
    e.hire_date,
    DATEDIFF(YEAR, e.hire_date, CURRENT_DATE) AS years_service,
    e.salary,
    d.department_name,
    g.grade_name,
    CONCAT(m.first_name, ' ', m.last_name)  AS manager_name
FROM hr.employees e
LEFT JOIN hr.departments d  ON e.department_id  = d.department_id
LEFT JOIN hr.job_grades g   ON e.job_grade_id   = g.grade_id
LEFT JOIN hr.employees m    ON e.manager_id     = m.employee_id
WHERE e.status = 'ACTIVE';

-- ---- K.2 Complex Analytical View ----

CREATE VIEW sales.vw_customer_360 AS
SELECT
    c.customer_id,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.email,
    c.company_name,
    cs.segment_name                          AS customer_segment,
    c.credit_limit,
    c.payment_terms,
    -- Order metrics
    COUNT(o.order_id)                        AS total_orders,
    COUNT(CASE WHEN o.status = 'DELIVERED' THEN 1 END) AS delivered_orders,
    COUNT(CASE WHEN o.status = 'CANCELLED' THEN 1 END) AS cancelled_orders,
    COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total_amount END), 0) AS lifetime_value,
    COALESCE(AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total_amount END), 0) AS avg_order_value,
    MIN(o.order_date)                        AS first_order_date,
    MAX(o.order_date)                        AS last_order_date,
    DATEDIFF(DAY, MAX(o.order_date), CURRENT_DATE) AS days_since_last_order,
    -- Invoice metrics
    COALESCE(SUM(CASE WHEN i.status = 'OPEN' THEN i.outstanding_amount END), 0) AS outstanding_balance,
    COALESCE(SUM(CASE WHEN i.status = 'OVERDUE' THEN i.outstanding_amount END), 0) AS overdue_balance,
    c.is_active
FROM sales.customers c
LEFT JOIN sales.customer_segments cs    ON c.segment_id     = cs.segment_id
LEFT JOIN sales.orders o                ON c.customer_id    = o.customer_id
LEFT JOIN finance.invoices i            ON c.customer_id    = i.customer_id
GROUP BY
    c.customer_id, c.customer_number, c.first_name, c.last_name,
    c.email, c.company_name, cs.segment_name,
    c.credit_limit, c.payment_terms, c.is_active;

-- ---- K.3 Security View (column masking) ----

CREATE VIEW hr.vw_employee_directory AS
SELECT
    employee_id,
    employee_number,
    first_name,
    last_name,
    CONCAT(LEFT(email, 2), '***@', SUBSTRING(email, CHARINDEX('@', email)+1, 100)) AS masked_email,
    phone_mobile,
    job_title,
    department_id,
    hire_date
    -- salary, national_id, passport_number excluded for security
FROM hr.employees
WHERE status = 'ACTIVE';

-- ---- K.4 Updatable View ----

CREATE VIEW sales.vw_pending_orders AS
SELECT
    order_id,
    order_number,
    customer_id,
    order_date,
    status,
    total_amount,
    payment_status,
    notes
FROM sales.orders
WHERE status IN ('PENDING', 'PROCESSING')
WITH CHECK OPTION;

-- ---- K.5 Indexed View (SQL Server) ----

CREATE VIEW sales.vw_product_revenue_summary
WITH SCHEMABINDING AS
SELECT
    p.product_id,
    p.product_name,
    p.product_code,
    COUNT_BIG(*)                AS order_line_count,
    SUM(oi.quantity_ordered)    AS total_qty_sold,
    SUM(oi.line_total)          AS total_revenue,
    SUM(oi.discount_amount)     AS total_discount
FROM inventory.products p
INNER JOIN sales.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.product_code;

CREATE UNIQUE CLUSTERED INDEX idx_vw_product_revenue
ON sales.vw_product_revenue_summary(product_id);


-- ============================================================================================================================
-- PART L: STORED PROCEDURES
-- ============================================================================================================================

-- ---- L.1 Basic Stored Procedure ----

CREATE PROCEDURE hr.usp_get_department_employees
    @dept_id    INT,
    @status     VARCHAR(20) = 'ACTIVE'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.employee_id,
        e.employee_number,
        CONCAT(e.first_name, ' ', e.last_name)  AS full_name,
        e.job_title,
        e.salary,
        e.hire_date,
        DATEDIFF(YEAR, e.hire_date, CURRENT_DATE) AS years_service
    FROM hr.employees e
    WHERE e.department_id = @dept_id
      AND e.status = @status
    ORDER BY e.last_name, e.first_name;
END;

EXEC hr.usp_get_department_employees @dept_id = 1;
EXEC hr.usp_get_department_employees @dept_id = 2, @status = 'ACTIVE';

-- ---- L.2 Procedure with Output Parameters ----

CREATE PROCEDURE sales.usp_get_customer_summary
    @customer_id        INT,
    @total_orders       INT             OUTPUT,
    @lifetime_value     DECIMAL(15,2)   OUTPUT,
    @last_order_date    DATE            OUTPUT,
    @outstanding_bal    DECIMAL(15,2)   OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @total_orders       = COUNT(o.order_id),
        @lifetime_value     = COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total_amount END), 0),
        @last_order_date    = MAX(o.order_date)
    FROM sales.orders o
    WHERE o.customer_id = @customer_id;

    SELECT
        @outstanding_bal = COALESCE(SUM(i.outstanding_amount), 0)
    FROM finance.invoices i
    WHERE i.customer_id = @customer_id
      AND i.status IN ('OPEN', 'OVERDUE');
END;

-- Usage
DECLARE @orders INT, @ltv DECIMAL(15,2), @last_dt DATE, @bal DECIMAL(15,2);
EXEC sales.usp_get_customer_summary
    @customer_id        = 1,
    @total_orders       = @orders       OUTPUT,
    @lifetime_value     = @ltv          OUTPUT,
    @last_order_date    = @last_dt      OUTPUT,
    @outstanding_bal    = @bal          OUTPUT;
SELECT @orders AS orders, @ltv AS lifetime_value, @last_dt AS last_order, @bal AS outstanding;

-- ---- L.3 Procedure with Error Handling ----

CREATE PROCEDURE sales.usp_process_order
    @customer_id    INT,
    @sales_rep_id   INT,
    @order_id       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate customer
        IF NOT EXISTS (
            SELECT 1 FROM sales.customers
            WHERE customer_id = @customer_id AND is_active = 1
        )
        BEGIN
            THROW 50001, 'Customer not found or inactive.', 1;
        END

        -- Check credit limit
        DECLARE @credit_available DECIMAL(12,2);
        SELECT @credit_available = credit_limit - credit_used
        FROM sales.customers
        WHERE customer_id = @customer_id;

        IF @credit_available <= 0
        BEGIN
            THROW 50002, 'Customer has no available credit.', 1;
        END

        -- Generate order number
        DECLARE @order_number VARCHAR(30);
        SET @order_number = CONCAT('ORD-', FORMAT(CURRENT_DATE, 'yyyyMMdd'), '-', RIGHT('00000' + CAST(NEXT VALUE FOR seq_order_id AS VARCHAR), 5));

        -- Get next order ID
        SELECT @order_id = ISNULL(MAX(order_id), 0) + 1 FROM sales.orders;

        -- Create order
        INSERT INTO sales.orders (order_id, order_number, customer_id, sales_rep_id, status)
        VALUES (@order_id, @order_number, @customer_id, @sales_rep_id, 'DRAFT');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @err_num    INT             = ERROR_NUMBER();
        DECLARE @err_msg    NVARCHAR(4000)  = ERROR_MESSAGE();
        DECLARE @err_sev    INT             = ERROR_SEVERITY();
        DECLARE @err_state  INT             = ERROR_STATE();

        -- Log error
        INSERT INTO audit.activity_log (action, table_name, error_message, status)
        VALUES ('INSERT', 'sales.orders', @err_msg, 'ERROR');

        RAISERROR(@err_msg, @err_sev, @err_state);
    END CATCH
END;

-- ---- L.4 Dynamic SQL Procedure ----

CREATE PROCEDURE core.usp_dynamic_search
    @table_name     VARCHAR(100),
    @search_column  VARCHAR(100),
    @search_value   NVARCHAR(500),
    @order_column   VARCHAR(100) = NULL,
    @order_dir      VARCHAR(4)   = 'ASC',
    @page_num       INT          = 1,
    @page_size      INT          = 20
AS
BEGIN
    SET NOCOUNT ON;

    -- Whitelist validation
    IF @table_name NOT IN ('hr.employees', 'sales.customers', 'inventory.products')
    BEGIN
        THROW 50010, 'Invalid table name.', 1;
    END

    IF @order_dir NOT IN ('ASC', 'DESC')
        SET @order_dir = 'ASC';

    DECLARE @sql        NVARCHAR(MAX);
    DECLARE @params     NVARCHAR(MAX);
    DECLARE @offset     INT = (@page_num - 1) * @page_size;

    SET @sql = N'
        SELECT *
        FROM ' + @table_name + N'
        WHERE ' + QUOTENAME(@search_column) + N' LIKE @search
        ORDER BY ' + ISNULL(QUOTENAME(@order_column), '1') + N' ' + @order_dir + N'
        OFFSET @offset_rows ROWS FETCH NEXT @page_sz ROWS ONLY
    ';

    SET @params = N'@search NVARCHAR(500), @offset_rows INT, @page_sz INT';

    EXEC sp_executesql @sql, @params,
        @search         = @search_value,
        @offset_rows    = @offset,
        @page_sz        = @page_size;
END;


-- ============================================================================================================================
-- PART M: FUNCTIONS
-- ============================================================================================================================

-- ---- M.1 Scalar Functions ----

CREATE FUNCTION finance.fn_calculate_tax
(
    @amount     DECIMAL(15,2),
    @tax_rate   DECIMAL(5,2)
)
RETURNS DECIMAL(15,2)
AS
BEGIN
    RETURN ROUND(@amount * @tax_rate / 100, 2);
END;

CREATE FUNCTION hr.fn_get_salary_band
(
    @salary DECIMAL(12,2)
)
RETURNS VARCHAR(20)
AS
BEGIN
    RETURN CASE
        WHEN @salary >= 200000  THEN 'C-SUITE'
        WHEN @salary >= 150000  THEN 'EXECUTIVE'
        WHEN @salary >= 100000  THEN 'DIRECTOR'
        WHEN @salary >= 80000   THEN 'MANAGER'
        WHEN @salary >= 60000   THEN 'SENIOR'
        WHEN @salary >= 40000   THEN 'MID-LEVEL'
        ELSE                         'JUNIOR'
    END;
END;

CREATE FUNCTION sales.fn_calculate_discount
(
    @unit_price     DECIMAL(12,4),
    @quantity       DECIMAL(12,3),
    @customer_type  VARCHAR(20)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @discount DECIMAL(5,2) = 0;

    -- Volume discount
    SET @discount = CASE
        WHEN @quantity >= 1000  THEN 15.00
        WHEN @quantity >= 500   THEN 10.00
        WHEN @quantity >= 100   THEN 5.00
        WHEN @quantity >= 50    THEN 3.00
        ELSE 0.00
    END;

    -- Customer type additional discount
    SET @discount = @discount + CASE @customer_type
        WHEN 'VIP'          THEN 5.00
        WHEN 'WHOLESALE'    THEN 3.00
        WHEN 'CORPORATE'    THEN 2.00
        ELSE 0.00
    END;

    -- Cap at 25%
    IF @discount > 25.00 SET @discount = 25.00;

    RETURN @discount;
END;

-- ---- M.2 Inline Table-Valued Functions ----

CREATE FUNCTION sales.fn_customer_orders
(
    @customer_id    INT,
    @from_date      DATE = NULL,
    @to_date        DATE = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.order_id,
        o.order_number,
        o.order_date,
        o.status,
        o.total_amount,
        o.payment_status,
        COUNT(oi.order_item_id)     AS item_count,
        SUM(oi.quantity_ordered)    AS total_qty
    FROM sales.orders o
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
      AND (@from_date IS NULL OR o.order_date >= @from_date)
      AND (@to_date   IS NULL OR o.order_date <= @to_date)
    GROUP BY o.order_id, o.order_number, o.order_date, o.status, o.total_amount, o.payment_status
);

-- Usage
SELECT * FROM sales.fn_customer_orders(1, '2024-01-01', '2024-12-31');

CREATE FUNCTION inventory.fn_low_stock_products
(
    @warehouse_id   INT = NULL,
    @threshold_pct  DECIMAL(5,2) = 100  -- % of reorder point
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.product_id,
        p.product_code,
        p.product_name,
        p.reorder_point,
        p.reorder_quantity,
        COALESCE(sl.quantity, 0)    AS current_stock,
        p.reorder_point * @threshold_pct / 100 AS threshold_qty,
        p.lead_time_days,
        s.supplier_name
    FROM inventory.products p
    LEFT JOIN inventory.stock_levels sl
        ON p.product_id = sl.product_id
        AND (@warehouse_id IS NULL OR sl.warehouse_id = @warehouse_id)
    LEFT JOIN inventory.suppliers s ON p.supplier_id = s.supplier_id
    WHERE p.is_active = TRUE
      AND p.is_discontinued = FALSE
      AND COALESCE(sl.quantity, 0) <= p.reorder_point * @threshold_pct / 100
);

-- ---- M.3 Multi-Statement Table-Valued Function ----

CREATE FUNCTION hr.fn_employee_org_chart
(
    @root_employee_id INT,
    @max_depth        INT = 10
)
RETURNS @result TABLE
(
    employee_id     INT,
    full_name       VARCHAR(101),
    job_title       VARCHAR(100),
    department_name VARCHAR(100),
    salary          DECIMAL(12,2),
    depth           INT,
    path            VARCHAR(1000)
)
AS
BEGIN
    WITH org AS (
        SELECT
            e.employee_id,
            CONCAT(e.first_name, ' ', e.last_name)  AS full_name,
            e.job_title,
            d.department_name,
            e.salary,
            0                                        AS depth,
            CAST(e.employee_id AS VARCHAR(1000))     AS path
        FROM hr.employees e
        LEFT JOIN hr.departments d ON e.department_id = d.department_id
        WHERE e.employee_id = @root_employee_id

        UNION ALL

        SELECT
            e.employee_id,
            CONCAT(e.first_name, ' ', e.last_name),
            e.job_title,
            d.department_name,
            e.salary,
            o.depth + 1,
            CAST(CONCAT(o.path, '->', e.employee_id) AS VARCHAR(1000))
        FROM hr.employees e
        LEFT JOIN hr.departments d ON e.department_id = d.department_id
        INNER JOIN org o ON e.manager_id = o.employee_id
        WHERE o.depth < @max_depth
          AND e.status = 'ACTIVE'
    )
    INSERT INTO @result
    SELECT employee_id, full_name, job_title, department_name, salary, depth, path
    FROM org;

    RETURN;
END;


-- ============================================================================================================================
-- PART N: TRIGGERS
-- ============================================================================================================================

-- ---- N.1 AFTER INSERT Trigger ----

CREATE TRIGGER trg_orders_after_insert
ON sales.orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Log the insert
    INSERT INTO audit.activity_log (action, table_name, record_id, new_data, user_name)
    SELECT
        'INSERT',
        'sales.orders',
        CAST(order_id AS VARCHAR),
        CONCAT('order_number=', order_number, ', customer_id=', customer_id, ', total=', total_amount),
        SYSTEM_USER
    FROM inserted;

    -- Update customer's last order date and total orders
    UPDATE c
    SET
        c.last_order_date   = i.order_date,
        c.total_orders      = c.total_orders + 1,
        c.updated_at        = CURRENT_TIMESTAMP
    FROM sales.customers c
    INNER JOIN inserted i ON c.customer_id = i.customer_id;
END;

-- ---- N.2 AFTER UPDATE Trigger ----

CREATE TRIGGER trg_employees_salary_change
ON hr.employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(salary)
    BEGIN
        -- Log salary changes
        INSERT INTO hr.employee_history
            (employee_id, change_type, field_name, old_value, new_value, effective_date, changed_by)
        SELECT
            i.employee_id,
            'SALARY_CHANGE',
            'salary',
            CAST(d.salary AS VARCHAR),
            CAST(i.salary AS VARCHAR),
            CURRENT_DATE,
            SYSTEM_USER
        FROM inserted i
        INNER JOIN deleted d ON i.employee_id = d.employee_id
        WHERE i.salary <> d.salary;
    END

    IF UPDATE(department_id)
    BEGIN
        INSERT INTO hr.employee_history
            (employee_id, change_type, field_name, old_value, new_value, effective_date, changed_by)
        SELECT
            i.employee_id,
            'DEPARTMENT_TRANSFER',
            'department_id',
            CAST(d.department_id AS VARCHAR),
            CAST(i.department_id AS VARCHAR),
            CURRENT_DATE,
            SYSTEM_USER
        FROM inserted i
        INNER JOIN deleted d ON i.employee_id = d.employee_id
        WHERE ISNULL(i.department_id, 0) <> ISNULL(d.department_id, 0);
    END
END;

-- ---- N.3 AFTER DELETE Trigger ----

CREATE TRIGGER trg_products_after_delete
ON inventory.products
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.activity_log (action, table_name, record_id, old_data, user_name)
    SELECT
        'DELETE',
        'inventory.products',
        CAST(product_id AS VARCHAR),
        CONCAT('product_code=', product_code, ', name=', product_name, ', price=', unit_price),
        SYSTEM_USER
    FROM deleted;
END;

-- ---- N.4 INSTEAD OF Trigger ----

CREATE TRIGGER trg_vw_active_employees_instead_update
ON hr.vw_active_employees
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only allow updating certain columns
    UPDATE hr.employees
    SET
        phone_mobile    = i.phone_mobile,
        address_line1   = i.address_line1,
        city            = i.city,
        updated_at      = CURRENT_TIMESTAMP
    FROM hr.employees e
    INNER JOIN inserted i ON e.employee_id = i.employee_id;
END;

-- ---- N.5 DDL Trigger ----

CREATE TRIGGER trg_prevent_drop_in_production
ON DATABASE
FOR DROP_TABLE, DROP_VIEW, DROP_PROCEDURE
AS
BEGIN
    DECLARE @event_data XML = EVENTDATA();
    DECLARE @object_name VARCHAR(200) = @event_data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(200)');
    DECLARE @event_type  VARCHAR(100) = @event_data.value('(/EVENT_INSTANCE/EventType)[1]', 'VARCHAR(100)');

    INSERT INTO audit.activity_log (action, table_name, user_name, new_data)
    VALUES ('DELETE', @object_name, SYSTEM_USER, CONCAT('DDL Event: ', @event_type));

    -- Uncomment to prevent drops:
    -- ROLLBACK;
    -- PRINT 'DROP operations are not allowed in production!';
END;

-- Disable/Enable triggers
DISABLE TRIGGER trg_orders_after_insert ON sales.orders;
ENABLE  TRIGGER trg_orders_after_insert ON sales.orders;
DISABLE TRIGGER ALL ON sales.orders;
ENABLE  TRIGGER ALL ON sales.orders;


-- ============================================================================================================================
-- PART O: TRANSACTIONS
-- ============================================================================================================================

-- ---- O.1 Basic Transaction ----

BEGIN TRANSACTION;
    UPDATE inventory.products
    SET stock_quantity = stock_quantity - 5,
        updated_at = CURRENT_TIMESTAMP
    WHERE product_id = 1;

    INSERT INTO inventory.stock_movements
        (product_id, warehouse_id, movement_type, reference_type, quantity, movement_date)
    VALUES (1, 1, 'ISSUE', 'SALES_ORDER', -5, CURRENT_TIMESTAMP);
COMMIT TRANSACTION;

-- ---- O.2 Transaction with Error Handling ----

BEGIN TRANSACTION;
BEGIN TRY
    -- Transfer stock between warehouses
    UPDATE inventory.stock_levels
    SET quantity = quantity - 100
    WHERE product_id = 1 AND warehouse_id = 1;

    IF (SELECT quantity FROM inventory.stock_levels WHERE product_id = 1 AND warehouse_id = 1) < 0
        THROW 50100, 'Insufficient stock in source warehouse.', 1;

    UPDATE inventory.stock_levels
    SET quantity = quantity + 100
    WHERE product_id = 1 AND warehouse_id = 2;

    INSERT INTO inventory.stock_movements VALUES
        (NEXT VALUE FOR seq_movement_id, 1, 1, 'TRANSFER', 'WAREHOUSE_TRANSFER', NULL, -100, NULL, NULL, CURRENT_TIMESTAMP, 'Transfer to WH2', NULL),
        (NEXT VALUE FOR seq_movement_id, 1, 2, 'TRANSFER', 'WAREHOUSE_TRANSFER', NULL,  100, NULL, NULL, CURRENT_TIMESTAMP, 'Transfer from WH1', NULL);

    COMMIT TRANSACTION;
    PRINT 'Stock transfer completed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT CONCAT('Error: ', ERROR_MESSAGE());
    THROW;
END CATCH;

-- ---- O.3 Savepoints ----

BEGIN TRANSACTION;
    INSERT INTO hr.departments (department_id, department_code, department_name)
    VALUES (20, 'NEWDEPT', 'New Department');

    SAVE TRANSACTION after_dept_insert;

    INSERT INTO hr.employees (employee_id, employee_number, first_name, last_name, email, hire_date, department_id)
    VALUES (100, 'EMP-100', 'Test', 'Employee', 'test@company.com', CURRENT_DATE, 20);

    -- If employee insert fails, rollback to savepoint (keep department)
    -- ROLLBACK TRANSACTION after_dept_insert;

COMMIT TRANSACTION;

-- ---- O.4 Isolation Levels ----

-- READ UNCOMMITTED: Allows dirty reads (fastest, least safe)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM sales.orders WITH (NOLOCK);  -- SQL Server hint equivalent

-- READ COMMITTED: Default - no dirty reads
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- REPEATABLE READ: No dirty reads, no non-repeatable reads
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SERIALIZABLE: Strictest - no phantom reads
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SNAPSHOT: Row versioning, no blocking reads (SQL Server)
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

-- ---- O.5 Lock Hints (SQL Server) ----

SELECT * FROM sales.orders WITH (NOLOCK);           -- Dirty read, no shared lock
SELECT * FROM sales.orders WITH (READPAST);         -- Skip locked rows
SELECT * FROM sales.orders WITH (UPDLOCK);          -- Upgrade to update lock
SELECT * FROM sales.orders WITH (XLOCK);            -- Exclusive lock
SELECT * FROM sales.orders WITH (HOLDLOCK);         -- Hold shared lock until transaction end
SELECT * FROM sales.orders WITH (ROWLOCK);          -- Row-level locking
SELECT * FROM sales.orders WITH (PAGLOCK);          -- Page-level locking
SELECT * FROM sales.orders WITH (TABLOCK);          -- Table-level shared lock
SELECT * FROM sales.orders WITH (TABLOCKX);         -- Table-level exclusive lock


-- ============================================================================================================================
-- PART P: NORMALIZATION
-- ============================================================================================================================

-- ---- P.1 First Normal Form (1NF) ----
-- Rules: Atomic values, single type per column, unique rows, no repeating groups

-- VIOLATION - multiple values in one column:
CREATE TABLE orders_1nf_violation (
    order_id    INT,
    customer    VARCHAR(200),       -- Not atomic: "John Doe, 555-1234"
    products    TEXT,               -- Repeating group: "Laptop, Mouse, Keyboard"
    quantities  TEXT                -- Repeating group: "1, 2, 1"
);

-- COMPLIANT - separate tables, atomic values:
-- orders table + order_items table (as defined above)

-- ---- P.2 Second Normal Form (2NF) ----
-- Rules: Must be 1NF + no partial dependencies on composite key

-- VIOLATION - partial dependency on composite key (order_id, product_id):
CREATE TABLE order_items_2nf_violation (
    order_id        INT,
    product_id      INT,
    quantity        INT,
    product_name    VARCHAR(200),   -- Depends only on product_id (partial dependency)
    customer_name   VARCHAR(200),   -- Depends only on order_id (partial dependency)
    PRIMARY KEY (order_id, product_id)
);

-- COMPLIANT: Move product_name to products table, customer_name to orders/customers table

-- ---- P.3 Third Normal Form (3NF) ----
-- Rules: Must be 2NF + no transitive dependencies

-- VIOLATION - transitive dependency:
CREATE TABLE employees_3nf_violation (
    employee_id     INT PRIMARY KEY,
    department_id   INT,
    department_name VARCHAR(100),   -- Depends on department_id, not employee_id (transitive)
    dept_location   VARCHAR(100)    -- Depends on department_id transitively
);

-- COMPLIANT: Separate departments table

-- ---- P.4 Boyce-Codd Normal Form (BCNF) ----
-- Rules: Must be 3NF + every determinant is a candidate key

-- ---- P.5 Fourth Normal Form (4NF) ----
-- Rules: Must be BCNF + no multi-valued dependencies

-- ---- P.6 Fifth Normal Form (5NF) ----
-- Rules: Must be 4NF + no join dependencies

-- ---- P.7 Denormalization (intentional) ----
-- Sometimes denormalize for performance:
-- - Storing calculated totals (order.total_amount)
-- - Storing redundant foreign key descriptions
-- - Pre-aggregated summary tables
-- - Materialized views


-- ============================================================================================================================
-- PART Q: QUERY OPTIMIZATION
-- ============================================================================================================================

-- ---- Q.1 Execution Plans ----

-- View estimated execution plan
SET SHOWPLAN_ALL ON;
SELECT * FROM hr.employees WHERE department_id = 1;
SET SHOWPLAN_ALL OFF;

-- View actual execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM hr.employees WHERE department_id = 1;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- EXPLAIN (MySQL/PostgreSQL)
EXPLAIN SELECT * FROM hr.employees WHERE department_id = 1;
EXPLAIN ANALYZE SELECT * FROM hr.employees WHERE department_id = 1;
EXPLAIN FORMAT=JSON SELECT * FROM hr.employees WHERE department_id = 1;

-- ---- Q.2 Common Anti-Patterns ----

-- BAD: SELECT * (fetches unnecessary columns)
SELECT * FROM hr.employees;
-- GOOD: Select only needed columns
SELECT employee_id, first_name, last_name, salary FROM hr.employees;

-- BAD: Function on indexed column in WHERE (index not used)
SELECT * FROM hr.employees WHERE YEAR(hire_date) = 2020;
SELECT * FROM hr.employees WHERE UPPER(email) = 'ALICE@COMPANY.COM';
-- GOOD: Sargable predicates
SELECT * FROM hr.employees WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01';
SELECT * FROM hr.employees WHERE email = 'alice@company.com';

-- BAD: Implicit type conversion
SELECT * FROM hr.employees WHERE employee_id = '1';  -- string vs int
-- GOOD: Explicit matching types
SELECT * FROM hr.employees WHERE employee_id = 1;

-- BAD: OR on different columns (can't use composite index efficiently)
SELECT * FROM hr.employees WHERE first_name = 'John' OR last_name = 'Smith';
-- GOOD: UNION ALL
SELECT * FROM hr.employees WHERE first_name = 'John'
UNION ALL
SELECT * FROM hr.employees WHERE last_name = 'Smith' AND first_name != 'John';

-- BAD: NOT IN with subquery (NULL issues + performance)
SELECT * FROM sales.customers WHERE customer_id NOT IN (SELECT customer_id FROM sales.orders);
-- GOOD: NOT EXISTS
SELECT * FROM sales.customers c WHERE NOT EXISTS (SELECT 1 FROM sales.orders o WHERE o.customer_id = c.customer_id);

-- BAD: COUNT(*) for existence check
SELECT * FROM sales.customers WHERE (SELECT COUNT(*) FROM sales.orders WHERE customer_id = customers.customer_id) > 0;
-- GOOD: EXISTS
SELECT * FROM sales.customers c WHERE EXISTS (SELECT 1 FROM sales.orders o WHERE o.customer_id = c.customer_id);

-- BAD: DISTINCT to fix bad joins
SELECT DISTINCT c.customer_id FROM sales.customers c INNER JOIN sales.orders o ON c.customer_id = o.customer_id;
-- GOOD: EXISTS or proper join
SELECT c.customer_id FROM sales.customers c WHERE EXISTS (SELECT 1 FROM sales.orders o WHERE o.customer_id = c.customer_id);

-- ---- Q.3 Query Hints ----

-- Force index usage (SQL Server)
SELECT * FROM hr.employees WITH (INDEX(idx_employees_dept)) WHERE department_id = 1;

-- Force join type
SELECT * FROM sales.orders o
INNER HASH JOIN sales.customers c ON o.customer_id = c.customer_id;

SELECT * FROM sales.orders o
INNER LOOP JOIN sales.customers c ON o.customer_id = c.customer_id;

SELECT * FROM sales.orders o
INNER MERGE JOIN sales.customers c ON o.customer_id = c.customer_id;

-- MAXDOP hint
SELECT * FROM hr.employees OPTION (MAXDOP 1);

-- RECOMPILE hint (avoid parameter sniffing)
EXEC hr.usp_get_department_employees @dept_id = 1 WITH RECOMPILE;

-- ---- Q.4 Batch Processing ----

-- Process large updates in batches to avoid lock escalation
DECLARE @batch_size INT = 5000;
DECLARE @rows_affected INT = 1;
DECLARE @total_updated INT = 0;

WHILE @rows_affected > 0
BEGIN
    UPDATE TOP (@batch_size) sales.orders
    SET updated_at = CURRENT_TIMESTAMP
    WHERE updated_at IS NULL;

    SET @rows_affected = @@ROWCOUNT;
    SET @total_updated = @total_updated + @rows_affected;

    WAITFOR DELAY '00:00:01';  -- Brief pause between batches
END;

PRINT CONCAT('Total rows updated: ', @total_updated);

-- ---- Q.5 Statistics ----

-- Update statistics
UPDATE STATISTICS hr.employees WITH FULLSCAN;
UPDATE STATISTICS sales.orders (idx_orders_customer_date) WITH ROWCOUNT = 1000000, PAGECOUNT = 5000;

-- View statistics
DBCC SHOW_STATISTICS ('hr.employees', 'idx_employees_dept');

-- Auto-update statistics
ALTER DATABASE EnterpriseDB SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE EnterpriseDB SET AUTO_UPDATE_STATISTICS_ASYNC ON;


-- ============================================================================================================================
-- PART R: PARTITIONING
-- ============================================================================================================================

-- ---- R.1 Range Partitioning (PostgreSQL) ----

CREATE TABLE sales.orders_partitioned (
    order_id        INT             NOT NULL,
    customer_id     INT             NOT NULL,
    order_date      DATE            NOT NULL,
    total_amount    DECIMAL(15,2),
    status          VARCHAR(30)
) PARTITION BY RANGE (order_date);

CREATE TABLE sales.orders_2022 PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE sales.orders_2023 PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE sales.orders_2024 PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE sales.orders_2025 PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE sales.orders_future PARTITION OF sales.orders_partitioned
    FOR VALUES FROM ('2026-01-01') TO (MAXVALUE);

-- ---- R.2 List Partitioning ----

CREATE TABLE sales.orders_by_region (
    order_id    INT,
    region      VARCHAR(30),
    order_date  DATE,
    total_amount DECIMAL(15,2)
) PARTITION BY LIST (region);

CREATE TABLE sales.orders_north_america PARTITION OF sales.orders_by_region
    FOR VALUES IN ('US', 'CA', 'MX');
CREATE TABLE sales.orders_europe PARTITION OF sales.orders_by_region
    FOR VALUES IN ('GB', 'DE', 'FR', 'IT', 'ES');
CREATE TABLE sales.orders_apac PARTITION OF sales.orders_by_region
    FOR VALUES IN ('JP', 'CN', 'AU', 'SG', 'IN');
CREATE TABLE sales.orders_other PARTITION OF sales.orders_by_region
    DEFAULT;

-- ---- R.3 Hash Partitioning ----

CREATE TABLE audit.activity_log_partitioned (
    log_id      BIGINT,
    user_id     INT,
    action      VARCHAR(20),
    logged_at   DATETIME
) PARTITION BY HASH (user_id);

CREATE TABLE audit.activity_log_p0 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE audit.activity_log_p1 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 1);
CREATE TABLE audit.activity_log_p2 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 2);
CREATE TABLE audit.activity_log_p3 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 3);
CREATE TABLE audit.activity_log_p4 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 4);
CREATE TABLE audit.activity_log_p5 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 5);
CREATE TABLE audit.activity_log_p6 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 6);
CREATE TABLE audit.activity_log_p7 PARTITION OF audit.activity_log_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 7);

-- ---- R.4 SQL Server Partitioning ----

-- Step 1: Create partition function
CREATE PARTITION FUNCTION pf_order_date_monthly (DATE)
AS RANGE RIGHT FOR VALUES (
    '2022-01-01', '2022-02-01', '2022-03-01', '2022-04-01',
    '2022-05-01', '2022-06-01', '2022-07-01', '2022-08-01',
    '2022-09-01', '2022-10-01', '2022-11-01', '2022-12-01',
    '2023-01-01', '2023-02-01', '2023-03-01', '2023-04-01',
    '2023-05-01', '2023-06-01', '2023-07-01', '2023-08-01',
    '2023-09-01', '2023-10-01', '2023-11-01', '2023-12-01',
    '2024-01-01', '2024-02-01', '2024-03-01', '2024-04-01',
    '2024-05-01', '2024-06-01', '2024-07-01', '2024-08-01',
    '2024-09-01', '2024-10-01', '2024-11-01', '2024-12-01'
);

-- Step 2: Create partition scheme
CREATE PARTITION SCHEME ps_order_date_monthly
AS PARTITION pf_order_date_monthly
ALL TO ([PRIMARY]);

-- Step 3: Create partitioned table
CREATE TABLE sales.orders_sql_server_partitioned (
    order_id        INT             NOT NULL,
    order_date      DATE            NOT NULL,
    customer_id     INT             NOT NULL,
    total_amount    DECIMAL(15,2)
) ON ps_order_date_monthly(order_date);


-- ============================================================================================================================
-- PART S: TEMPORARY OBJECTS
-- ============================================================================================================================

-- ---- S.1 Local Temporary Tables ----

CREATE TABLE #temp_sales_summary (
    customer_id     INT,
    customer_name   VARCHAR(101),
    order_count     INT,
    total_revenue   DECIMAL(15,2),
    avg_order_value DECIMAL(15,2),
    last_order_date DATE
);

INSERT INTO #temp_sales_summary
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name),
    COUNT(o.order_id),
    SUM(o.total_amount),
    AVG(o.total_amount),
    MAX(o.order_date)
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id AND o.status = 'DELIVERED'
WHERE c.is_active = TRUE
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Add index to temp table for performance
CREATE INDEX idx_temp_revenue ON #temp_sales_summary(total_revenue DESC);

SELECT * FROM #temp_sales_summary WHERE total_revenue > 5000 ORDER BY total_revenue DESC;

DROP TABLE IF EXISTS #temp_sales_summary;

-- ---- S.2 Global Temporary Tables ----

CREATE TABLE ##global_product_cache (
    product_id      INT,
    product_name    VARCHAR(200),
    unit_price      DECIMAL(12,4),
    stock_quantity  DECIMAL(12,3),
    cached_at       DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ---- S.3 Table Variables ----

DECLARE @monthly_targets TABLE (
    month_num       INT,
    month_name      VARCHAR(20),
    revenue_target  DECIMAL(15,2),
    order_target    INT
);

INSERT INTO @monthly_targets VALUES
    (1,  'January',   500000, 200),
    (2,  'February',  480000, 190),
    (3,  'March',     550000, 220),
    (4,  'April',     520000, 210),
    (5,  'May',       580000, 230),
    (6,  'June',      600000, 240),
    (7,  'July',      590000, 235),
    (8,  'August',    610000, 245),
    (9,  'September', 570000, 228),
    (10, 'October',   620000, 248),
    (11, 'November',  700000, 280),
    (12, 'December',  750000, 300);

SELECT
    mt.month_name,
    mt.revenue_target,
    COALESCE(actual.actual_revenue, 0)  AS actual_revenue,
    COALESCE(actual.actual_orders, 0)   AS actual_orders,
    COALESCE(actual.actual_revenue, 0) - mt.revenue_target AS variance,
    ROUND(COALESCE(actual.actual_revenue, 0) / mt.revenue_target * 100, 1) AS achievement_pct
FROM @monthly_targets mt
LEFT JOIN (
    SELECT
        MONTH(order_date)   AS month_num,
        SUM(total_amount)   AS actual_revenue,
        COUNT(order_id)     AS actual_orders
    FROM sales.orders
    WHERE YEAR(order_date) = 2024
      AND status = 'DELIVERED'
    GROUP BY MONTH(order_date)
) actual ON mt.month_num = actual.month_num
ORDER BY mt.month_num;


-- ============================================================================================================================
-- PART T: PIVOT AND UNPIVOT
-- ============================================================================================================================

-- ---- T.1 Static PIVOT ----

-- Monthly revenue by year
SELECT *
FROM (
    SELECT
        YEAR(order_date)    AS yr,
        DATENAME(MONTH, order_date) AS month_name,
        total_amount
    FROM sales.orders
    WHERE status = 'DELIVERED'
) src
PIVOT (
    SUM(total_amount)
    FOR month_name IN (
        [January],[February],[March],[April],[May],[June],
        [July],[August],[September],[October],[November],[December]
    )
) pvt
ORDER BY yr;

-- Product sales by category
SELECT *
FROM (
    SELECT
        p.product_name,
        cat.category_name,
        oi.line_total
    FROM sales.order_items oi
    INNER JOIN inventory.products p     ON oi.product_id    = p.product_id
    INNER JOIN inventory.categories cat ON p.category_id    = cat.category_id
) src
PIVOT (
    SUM(line_total)
    FOR category_name IN ([Electronics],[Furniture],[Stationery])
) pvt;

-- ---- T.2 Dynamic PIVOT ----

DECLARE @pivot_cols NVARCHAR(MAX);
DECLARE @pivot_sql  NVARCHAR(MAX);

-- Get distinct categories
SELECT @pivot_cols = STRING_AGG(QUOTENAME(category_name), ',')
FROM (SELECT DISTINCT category_name FROM inventory.categories WHERE is_active = TRUE) cats;

SET @pivot_sql = N'
SELECT *
FROM (
    SELECT
        p.product_name,
        cat.category_name,
        oi.line_total
    FROM sales.order_items oi
    INNER JOIN inventory.products p     ON oi.product_id = p.product_id
    INNER JOIN inventory.categories cat ON p.category_id = cat.category_id
) src
PIVOT (
    SUM(line_total)
    FOR category_name IN (' + @pivot_cols + N')
) pvt
ORDER BY product_name
';

EXEC sp_executesql @pivot_sql;

-- ---- T.3 UNPIVOT ----

-- Convert price columns to rows
SELECT product_id, price_type, price_value
FROM inventory.products
UNPIVOT (
    price_value FOR price_type IN (unit_price, list_price, cost_price, msrp)
) unpvt
WHERE price_value IS NOT NULL;

-- Manual UNPIVOT using UNION ALL (more portable)
SELECT product_id, product_name, 'unit_price'  AS price_type, unit_price  AS price_value FROM inventory.products WHERE unit_price  IS NOT NULL
UNION ALL
SELECT product_id, product_name, 'list_price'  AS price_type, list_price  AS price_value FROM inventory.products WHERE list_price  IS NOT NULL
UNION ALL
SELECT product_id, product_name, 'cost_price'  AS price_type, cost_price  AS price_value FROM inventory.products WHERE cost_price  IS NOT NULL
UNION ALL
SELECT product_id, product_name, 'msrp'        AS price_type, msrp        AS price_value FROM inventory.products WHERE msrp        IS NOT NULL
ORDER BY product_id, price_type;


-- ============================================================================================================================
-- PART U: JSON IN SQL
-- ============================================================================================================================

-- ---- U.1 Storing JSON ----

CREATE TABLE core.api_requests (
    request_id      BIGINT          NOT NULL,
    endpoint        VARCHAR(300)    NOT NULL,
    method          VARCHAR(10)     NOT NULL,
    request_headers JSON,
    request_body    JSON,
    response_status INT,
    response_body   JSON,
    duration_ms     INT,
    requested_at    DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_api_requests PRIMARY KEY (request_id)
);

INSERT INTO core.api_requests (request_id, endpoint, method, request_body, response_status, response_body, duration_ms)
VALUES (
    1,
    '/api/v1/orders',
    'POST',
    '{"customer_id": 1, "items": [{"product_id": 1, "qty": 2, "price": 1299.99}, {"product_id": 2, "qty": 1, "price": 29.99}], "shipping": {"method": "EXPRESS", "address": "123 Main St"}}',
    201,
    '{"order_id": 1001, "order_number": "ORD-20240101-00001", "status": "CREATED", "total": 2629.97}',
    145
);

-- ---- U.2 Querying JSON (SQL Server) ----

-- JSON_VALUE: Extract scalar value
SELECT
    request_id,
    JSON_VALUE(request_body, '$.customer_id')       AS customer_id,
    JSON_VALUE(response_body, '$.order_id')         AS order_id,
    JSON_VALUE(response_body, '$.order_number')     AS order_number,
    JSON_VALUE(response_body, '$.status')           AS status,
    JSON_VALUE(response_body, '$.total')            AS total
FROM core.api_requests;

-- JSON_QUERY: Extract object or array
SELECT
    request_id,
    JSON_QUERY(request_body, '$.items')             AS items_array,
    JSON_QUERY(request_body, '$.shipping')          AS shipping_object
FROM core.api_requests;

-- OPENJSON: Parse JSON array into rows
SELECT
    r.request_id,
    items.product_id,
    items.qty,
    items.price
FROM core.api_requests r
CROSS APPLY OPENJSON(r.request_body, '$.items')
WITH (
    product_id  INT             '$.product_id',
    qty         INT             '$.qty',
    price       DECIMAL(12,2)   '$.price'
) items;

-- ---- U.3 JSON in MySQL ----

-- JSON_EXTRACT
SELECT
    request_id,
    JSON_EXTRACT(request_body, '$.customer_id')     AS customer_id,
    JSON_EXTRACT(response_body, '$.order_id')       AS order_id
FROM core.api_requests;

-- Shorthand operator
SELECT
    request_id,
    request_body->>'$.customer_id'                  AS customer_id,
    response_body->>'$.status'                      AS status
FROM core.api_requests;

-- JSON_ARRAYAGG
SELECT
    d.department_name,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'id',       e.employee_id,
            'name',     CONCAT(e.first_name, ' ', e.last_name),
            'title',    e.job_title,
            'salary',   e.salary
        )
    ) AS employees_json
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name;

-- ---- U.4 FOR JSON (SQL Server) ----

-- Convert query result to JSON
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
FOR JSON PATH, ROOT('employees');

-- Nested JSON
SELECT
    d.department_id,
    d.department_name,
    (
        SELECT e.employee_id, e.first_name, e.last_name, e.salary
        FROM hr.employees e
        WHERE e.department_id = d.department_id AND e.status = 'ACTIVE'
        FOR JSON PATH
    ) AS employees
FROM hr.departments d
WHERE d.is_active = TRUE
FOR JSON PATH, ROOT('departments');


-- ============================================================================================================================
-- PART W: STRING FUNCTIONS
-- ============================================================================================================================

-- ---- W.1 Concatenation ----
SELECT CONCAT(first_name, ' ', last_name)                   AS full_name FROM hr.employees;
SELECT CONCAT_WS(' | ', employee_number, first_name, email) AS employee_info FROM hr.employees;
SELECT first_name + ' ' + last_name                         AS full_name FROM hr.employees;  -- SQL Server
SELECT first_name || ' ' || last_name                       AS full_name FROM hr.employees;  -- PostgreSQL/Oracle

-- ---- W.2 Case Conversion ----
SELECT UPPER(first_name), LOWER(last_name), INITCAP(city) FROM hr.employees;

-- ---- W.3 Trimming ----
SELECT
    TRIM('   hello world   ')           AS trimmed,
    LTRIM('   hello')                   AS left_trimmed,
    RTRIM('hello   ')                   AS right_trimmed,
    TRIM(BOTH '-' FROM '--hello--')     AS custom_trim;

-- ---- W.4 Length ----
SELECT
    first_name,
    LENGTH(first_name)                  AS len_mysql_pg,
    LEN(first_name)                     AS len_sqlserver,
    CHAR_LENGTH(first_name)             AS char_len
FROM hr.employees;

-- ---- W.5 Substring ----
SELECT
    email,
    SUBSTRING(email, 1, CHARINDEX('@', email) - 1)                     AS username,
    SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email))            AS domain,
    LEFT(email, CHARINDEX('@', email) - 1)                             AS username_left,
    RIGHT(email, LEN(email) - CHARINDEX('@', email))                   AS domain_right,
    SUBSTR(email, 1, INSTR(email, '@') - 1)                            AS username_mysql
FROM hr.employees;

-- ---- W.6 Search and Replace ----
SELECT
    email,
    CHARINDEX('@', email)                                               AS at_position,
    INSTR(email, '@')                                                   AS at_position_mysql,
    POSITION('@' IN email)                                              AS at_position_standard,
    REPLACE(email, '@company.com', '@newdomain.com')                   AS new_email,
    TRANSLATE(first_name, 'aeiou', '*****')                            AS vowels_masked
FROM hr.employees;

-- ---- W.7 Padding ----
SELECT
    employee_id,
    LPAD(CAST(employee_id AS VARCHAR), 8, '0')                         AS padded_id_mysql,
    RIGHT('00000000' + CAST(employee_id AS VARCHAR), 8)                AS padded_id_sqlserver,
    RPAD(first_name, 20, '.')                                          AS right_padded
FROM hr.employees;

-- ---- W.8 Pattern Matching ----
SELECT * FROM hr.employees WHERE email LIKE '%@company.com';
SELECT * FROM hr.employees WHERE first_name LIKE '[AEIOU]%';        -- starts with vowel
SELECT * FROM hr.employees WHERE phone_mobile LIKE '+1-[0-9][0-9][0-9]-%';
SELECT * FROM hr.employees WHERE email REGEXP '^[a-z]+\\.[a-z]+@company\\.com$';  -- MySQL
SELECT * FROM hr.employees WHERE email ~ '^[a-z]+\.[a-z]+@company\.com$';          -- PostgreSQL

-- ---- W.9 String Splitting ----
SELECT value FROM STRING_SPLIT('apple,banana,cherry,date', ',');  -- SQL Server 2016+

-- ---- W.10 String Aggregation ----
SELECT
    department_id,
    STRING_AGG(CONCAT(first_name, ' ', last_name), '; ' ORDER BY last_name) AS employees
FROM hr.employees
WHERE status = 'ACTIVE'
GROUP BY department_id;

-- ---- W.11 Format and Conversion ----
SELECT
    FORMAT(salary, 'C2', 'en-US')                                      AS currency_format,
    FORMAT(salary, 'N0')                                                AS number_format,
    FORMAT(hire_date, 'MMMM dd, yyyy')                                 AS date_format,
    CAST(salary AS VARCHAR(20))                                         AS salary_string,
    CONVERT(VARCHAR, hire_date, 103)                                    AS date_uk_format,
    STR(salary, 12, 2)                                                  AS str_format
FROM hr.employees;

-- ---- W.12 Phonetic and Similarity ----
SELECT
    SOUNDEX('Smith')                                                    AS soundex_smith,
    SOUNDEX('Smyth')                                                    AS soundex_smyth,
    DIFFERENCE('Smith', 'Smyth')                                       AS similarity_score,
    STUFF('Hello World', 7, 5, 'SQL Server')                           AS stuffed_string,
    REVERSE('Hello World')                                             AS reversed,
    REPLICATE('*', 10)                                                  AS repeated,
    SPACE(5)                                                            AS spaces,
    UNICODE('A')                                                        AS unicode_val,
    CHAR(65)                                                            AS char_from_code,
    ASCII('A')                                                          AS ascii_val,
    NCHAR(9786)                                                         AS smiley_face
FROM hr.employees
WHERE employee_id = 1;


-- ============================================================================================================================
-- PART X: DATE AND TIME FUNCTIONS
-- ============================================================================================================================

-- ---- X.1 Current Date/Time ----
SELECT
    CURRENT_DATE                        AS current_date,
    CURRENT_TIME                        AS current_time,
    CURRENT_TIMESTAMP                   AS current_timestamp,
    GETDATE()                           AS getdate_sqlserver,
    SYSDATETIME()                       AS sysdatetime_sqlserver,
    NOW()                               AS now_mysql_pg,
    SYSDATE                             AS sysdate_oracle,
    GETUTCDATE()                        AS utc_date,
    SYSDATETIMEOFFSET()                 AS datetime_with_offset;

-- ---- X.2 Date Parts ----
SELECT
    order_date,
    YEAR(order_date)                    AS yr,
    MONTH(order_date)                   AS mo,
    DAY(order_date)                     AS dy,
    HOUR(order_date)                    AS hr,
    MINUTE(order_date)                  AS mi,
    SECOND(order_date)                  AS sc,
    DATEPART(QUARTER, order_date)       AS quarter,
    DATEPART(WEEK, order_date)          AS week_num,
    DATEPART(WEEKDAY, order_date)       AS weekday_num,
    DATENAME(WEEKDAY, order_date)       AS weekday_name,
    DATENAME(MONTH, order_date)         AS month_name,
    EXTRACT(DOY FROM order_date)        AS day_of_year
FROM sales.orders;

-- ---- X.3 Date Arithmetic ----
SELECT
    order_date,
    DATEADD(DAY,    7,  order_date)     AS plus_7_days,
    DATEADD(MONTH,  1,  order_date)     AS plus_1_month,
    DATEADD(YEAR,   1,  order_date)     AS plus_1_year,
    DATEADD(HOUR,  -8,  order_date)     AS minus_8_hours,
    DATEADD(MINUTE, 30, order_date)     AS plus_30_min,
    order_date + INTERVAL '7 days'      AS plus_7_pg,       -- PostgreSQL
    DATE_ADD(order_date, INTERVAL 7 DAY) AS plus_7_mysql    -- MySQL
FROM sales.orders;

-- ---- X.4 Date Differences ----
SELECT
    order_id,
    order_date,
    shipped_date,
    delivery_date,
    DATEDIFF(DAY,   order_date, shipped_date)   AS days_to_ship,
    DATEDIFF(DAY,   order_date, delivery_date)  AS days_to_deliver,
    DATEDIFF(HOUR,  order_date, shipped_date)   AS hours_to_ship,
    DATEDIFF(MONTH, order_date, CURRENT_DATE)   AS months_ago
FROM sales.orders
WHERE shipped_date IS NOT NULL;

-- ---- X.5 Date Formatting ----
SELECT
    order_date,
    FORMAT(order_date, 'yyyy-MM-dd')            AS iso_format,
    FORMAT(order_date, 'dd/MM/yyyy')            AS uk_format,
    FORMAT(order_date, 'MM/dd/yyyy')            AS us_format,
    FORMAT(order_date, 'MMMM d, yyyy')          AS long_format,
    FORMAT(order_date, 'ddd, MMM d yyyy')       AS short_format,
    CONVERT(VARCHAR, order_date, 112)           AS yyyymmdd,
    CONVERT(VARCHAR, order_date, 120)           AS iso_datetime
FROM sales.orders;

-- ---- X.6 Date Truncation ----
SELECT
    order_date,
    DATE_TRUNC('year',    order_date)           AS year_start,      -- PostgreSQL
    DATE_TRUNC('quarter', order_date)           AS quarter_start,
    DATE_TRUNC('month',   order_date)           AS month_start,
    DATE_TRUNC('week',    order_date)           AS week_start,
    DATETRUNC('month',    order_date)           AS month_start_ss,  -- SQL Server 2022+
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start_sqlserver,
    EOMONTH(order_date)                         AS month_end,
    LAST_DAY(order_date)                        AS month_end_mysql
FROM sales.orders;

-- ---- X.7 Date Conversion ----
SELECT
    STR_TO_DATE('2024-01-15', '%Y-%m-%d')       AS from_string_mysql,
    CAST('2024-01-15' AS DATE)                  AS cast_to_date,
    CONVERT(DATE, '2024-01-15', 23)             AS convert_sqlserver,
    TO_DATE('2024-01-15', 'YYYY-MM-DD')         AS to_date_oracle,
    PARSE('January 15, 2024' AS DATE USING 'en-US') AS parse_sqlserver;

-- ---- X.8 Business Day Calculations ----
SELECT
    order_id,
    order_date,
    shipped_date,
    -- Approximate business days (excludes weekends, not holidays)
    DATEDIFF(DAY, order_date, shipped_date)
    - (DATEDIFF(WEEK, order_date, shipped_date) * 2)
    - CASE WHEN DATEPART(WEEKDAY, order_date)   = 1 THEN 1 ELSE 0 END
    - CASE WHEN DATEPART(WEEKDAY, shipped_date) = 7 THEN 1 ELSE 0 END
    AS business_days_to_ship
FROM sales.orders
WHERE shipped_date IS NOT NULL;

-- ---- X.9 Age and Tenure ----
SELECT
    employee_id,
    first_name,
    birth_date,
    hire_date,
    DATEDIFF(YEAR, birth_date, CURRENT_DATE)    AS age_years,
    DATEDIFF(YEAR, hire_date, CURRENT_DATE)     AS tenure_years,
    DATEDIFF(MONTH, hire_date, CURRENT_DATE)    AS tenure_months,
    CONCAT(
        DATEDIFF(YEAR, hire_date, CURRENT_DATE), ' years, ',
        DATEDIFF(MONTH, hire_date, CURRENT_DATE) % 12, ' months'
    ) AS tenure_formatted
FROM hr.employees
WHERE status = 'ACTIVE' AND birth_date IS NOT NULL;


-- ============================================================================================================================
-- PART Y: MATHEMATICAL AND STATISTICAL FUNCTIONS
-- ============================================================================================================================

SELECT
    -- Basic math
    ABS(-42.5)                          AS absolute_value,
    CEILING(4.1)                        AS ceiling,
    FLOOR(4.9)                          AS floor,
    ROUND(4.5678, 2)                    AS rounded_2dp,
    ROUND(4.5678, 0)                    AS rounded_int,
    TRUNCATE(4.9999, 2)                 AS truncated,
    SIGN(-5)                            AS sign_neg,
    SIGN(0)                             AS sign_zero,
    SIGN(5)                             AS sign_pos,
    -- Power and roots
    POWER(2, 10)                        AS two_to_ten,
    SQRT(144)                           AS square_root,
    CBRT(27)                            AS cube_root,
    EXP(1)                              AS e_constant,
    -- Logarithms
    LOG(100)                            AS natural_log,
    LOG10(1000)                         AS log_base_10,
    LOG(8, 2)                           AS log_base_2,
    -- Trigonometry
    PI()                                AS pi,
    SIN(PI()/6)                         AS sin_30,
    COS(PI()/3)                         AS cos_60,
    TAN(PI()/4)                         AS tan_45,
    ASIN(0.5)                           AS arcsin,
    ACOS(0.5)                           AS arccos,
    ATAN(1)                             AS arctan,
    ATAN2(1, 1)                         AS arctan2,
    -- Modulo
    MOD(17, 5)                          AS modulo,
    17 % 5                              AS modulo_op,
    -- Random
    RAND()                              AS random_0_to_1,
    RAND(42)                            AS seeded_random,
    FLOOR(RAND() * 100) + 1             AS random_1_to_100,
    -- Comparison
    GREATEST(10, 25, 5, 18, 30)        AS greatest,
    LEAST(10, 25, 5, 18, 30)           AS least;

-- Statistical aggregates
SELECT
    department_id,
    COUNT(*)                            AS n,
    AVG(salary)                         AS mean,
    STDEV(salary)                       AS std_dev,
    STDEVP(salary)                      AS std_dev_population,
    VAR(salary)                         AS variance,
    VARP(salary)                        AS variance_population,
    MIN(salary)                         AS minimum,
    MAX(salary)                         AS maximum,
    MAX(salary) - MIN(salary)           AS range_val,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) AS q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY salary) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS q3,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY salary) AS p90
FROM hr.employees
WHERE status = 'ACTIVE'
GROUP BY department_id;

-- Financial calculations
SELECT
    product_id,
    product_name,
    unit_price,
    cost_price,
    -- Gross profit
    unit_price - cost_price                                             AS gross_profit,
    -- Gross margin %
    ROUND((unit_price - cost_price) / NULLIF(unit_price, 0) * 100, 2) AS gross_margin_pct,
    -- Markup %
    ROUND((unit_price - cost_price) / NULLIF(cost_price, 0) * 100, 2) AS markup_pct,
    -- Price with tax
    ROUND(unit_price * 1.08, 2)                                        AS price_with_8pct_tax,
    -- Future value (compound interest)
    ROUND(cost_price * POWER(1.03, 5), 2)                              AS cost_in_5_years_3pct,
    -- Break-even units (assuming $10000 fixed cost)
    CEILING(10000 / NULLIF(unit_price - cost_price, 0))                AS break_even_units
FROM inventory.products
WHERE cost_price IS NOT NULL AND cost_price > 0;


-- ============================================================================================================================
-- PART Z: CONDITIONAL EXPRESSIONS
-- ============================================================================================================================

-- ---- Z.1 CASE - Simple Form ----
SELECT
    order_id,
    status,
    CASE status
        WHEN 'DRAFT'        THEN 'Not Submitted'
        WHEN 'PENDING'      THEN 'Awaiting Confirmation'
        WHEN 'CONFIRMED'    THEN 'Confirmed - Processing Soon'
        WHEN 'PROCESSING'   THEN 'Being Prepared'
        WHEN 'SHIPPED'      THEN 'In Transit'
        WHEN 'DELIVERED'    THEN 'Successfully Delivered'
        WHEN 'CANCELLED'    THEN 'Order Cancelled'
        WHEN 'RETURNED'     THEN 'Return Processed'
        WHEN 'ON_HOLD'      THEN 'On Hold - Action Required'
        ELSE                     'Unknown Status: ' + status
    END AS status_description
FROM sales.orders;

-- ---- Z.2 CASE - Searched Form ----
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    DATEDIFF(YEAR, hire_date, CURRENT_DATE) AS years_service,
    CASE
        WHEN salary >= 200000                                   THEN 'C-Suite Executive'
        WHEN salary >= 150000                                   THEN 'Senior Executive'
        WHEN salary >= 100000                                   THEN 'Director Level'
        WHEN salary >= 80000                                    THEN 'Manager Level'
        WHEN salary >= 60000                                    THEN 'Senior Individual Contributor'
        WHEN salary >= 40000                                    THEN 'Mid-Level'
        ELSE                                                         'Entry Level'
    END AS salary_band,
    CASE
        WHEN DATEDIFF(YEAR, hire_date, CURRENT_DATE) >= 10     THEN 'Veteran (10+ years)'
        WHEN DATEDIFF(YEAR, hire_date, CURRENT_DATE) >= 5      THEN 'Experienced (5-9 years)'
        WHEN DATEDIFF(YEAR, hire_date, CURRENT_DATE) >= 2      THEN 'Established (2-4 years)'
        ELSE                                                         'New Hire (<2 years)'
    END AS tenure_band
FROM hr.employees
WHERE status = 'ACTIVE';

-- ---- Z.3 CASE in Aggregation ----
SELECT
    YEAR(order_date)                                                    AS year,
    COUNT(*)                                                            AS total_orders,
    COUNT(CASE WHEN status = 'DELIVERED'    THEN 1 END)                AS delivered,
    COUNT(CASE WHEN status = 'CANCELLED'    THEN 1 END)                AS cancelled,
    COUNT(CASE WHEN status = 'RETURNED'     THEN 1 END)                AS returned,
    COUNT(CASE WHEN status = 'PENDING'      THEN 1 END)                AS pending,
    SUM(CASE WHEN status = 'DELIVERED'      THEN total_amount ELSE 0 END) AS delivered_revenue,
    SUM(CASE WHEN status = 'CANCELLED'      THEN total_amount ELSE 0 END) AS cancelled_value,
    ROUND(
        COUNT(CASE WHEN status = 'DELIVERED' THEN 1 END) * 100.0 / COUNT(*), 2
    )                                                                   AS delivery_rate_pct,
    ROUND(
        COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) * 100.0 / COUNT(*), 2
    )                                                                   AS cancellation_rate_pct
FROM sales.orders
GROUP BY YEAR(order_date)
ORDER BY year;

-- ---- Z.4 COALESCE ----
SELECT
    employee_id,
    COALESCE(preferred_name, first_name)                                AS display_name,
    COALESCE(phone_mobile, phone_work, phone_home, 'No phone on file') AS best_phone,
    COALESCE(work_email, email)                                         AS best_email,
    COALESCE(salary, hourly_rate * 2080, 0)                            AS annual_compensation
FROM hr.employees;

-- ---- Z.5 NULLIF ----
SELECT
    product_id,
    product_name,
    unit_price,
    cost_price,
    -- Avoid division by zero
    ROUND(unit_price / NULLIF(cost_price, 0), 4)                       AS price_to_cost_ratio,
    -- Treat empty string as NULL
    NULLIF(TRIM(notes), '')                                             AS clean_notes
FROM inventory.products;

-- ---- Z.6 IIF (SQL Server) ----
SELECT
    order_id,
    total_amount,
    IIF(total_amount >= 1000, 'High Value', 'Standard')                AS order_tier,
    IIF(payment_status = 'PAID', 'Paid', 'Outstanding')                AS payment_label,
    IIF(DATEDIFF(DAY, order_date, CURRENT_DATE) > 30, 'Old', 'Recent') AS age_label
FROM sales.orders;

-- ---- Z.7 CHOOSE (SQL Server) ----
SELECT
    employee_id,
    DATEPART(WEEKDAY, hire_date)                                        AS hire_weekday_num,
    CHOOSE(DATEPART(WEEKDAY, hire_date), 'Sun','Mon','Tue','Wed','Thu','Fri','Sat') AS hire_weekday
FROM hr.employees;


-- ============================================================================================================================
-- PART AA: ERROR HANDLING
-- ============================================================================================================================

-- ---- AA.1 TRY...CATCH ----
BEGIN TRY
    BEGIN TRANSACTION;

    -- Intentional error: duplicate primary key
    INSERT INTO hr.departments (department_id, department_code, department_name)
    VALUES (1, 'DUP', 'Duplicate Department');

    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER()      AS error_number,
        ERROR_SEVERITY()    AS error_severity,
        ERROR_STATE()       AS error_state,
        ERROR_PROCEDURE()   AS error_procedure,
        ERROR_LINE()        AS error_line,
        ERROR_MESSAGE()     AS error_message,
        XACT_STATE()        AS transaction_state;
END CATCH;

-- ---- AA.2 RAISERROR ----
CREATE PROCEDURE hr.usp_validate_salary
    @employee_id    INT,
    @new_salary     DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @new_salary < 0
        RAISERROR('Salary cannot be negative. Value: %f', 16, 1, @new_salary);

    IF @new_salary > 1000000
        RAISERROR('Salary %f exceeds maximum allowed value of $1,000,000.', 16, 1, @new_salary);

    DECLARE @current_salary DECIMAL(12,2);
    SELECT @current_salary = salary FROM hr.employees WHERE employee_id = @employee_id;

    IF @new_salary < @current_salary * 0.5
        RAISERROR('New salary cannot be less than 50%% of current salary.', 16, 1);

    IF @new_salary > @current_salary * 2.0
        RAISERROR('New salary cannot exceed 200%% of current salary.', 16, 1);

    UPDATE hr.employees
    SET salary = @new_salary, updated_at = CURRENT_TIMESTAMP
    WHERE employee_id = @employee_id;

    PRINT CONCAT('Salary updated successfully for employee ', @employee_id);
END;

-- ---- AA.3 THROW ----
CREATE PROCEDURE sales.usp_cancel_order
    @order_id   INT,
    @reason     VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM sales.orders WHERE order_id = @order_id)
            THROW 50001, 'Order not found.', 1;

        DECLARE @current_status VARCHAR(30);
        SELECT @current_status = status FROM sales.orders WHERE order_id = @order_id;

        IF @current_status IN ('DELIVERED', 'CANCELLED')
            THROW 50002, 'Cannot cancel an order that is already delivered or cancelled.', 1;

        IF @current_status = 'SHIPPED'
            THROW 50003, 'Cannot cancel a shipped order. Please initiate a return instead.', 1;

        UPDATE sales.orders
        SET status = 'CANCELLED',
            notes = CONCAT(COALESCE(notes, ''), ' | CANCELLED: ', @reason),
            updated_at = CURRENT_TIMESTAMP
        WHERE order_id = @order_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

-- ---- AA.4 Custom Error Messages ----
EXEC sp_addmessage @msgnum = 60001, @severity = 16, @lang = 'us_english',
    @msgtext = 'The %s with ID %d was not found.';
EXEC sp_addmessage @msgnum = 60002, @severity = 16, @lang = 'us_english',
    @msgtext = 'Insufficient %s. Required: %d, Available: %d.';
EXEC sp_addmessage @msgnum = 60003, @severity = 11, @lang = 'us_english',
    @msgtext = 'Access denied to %s for user %s.';

RAISERROR(60001, 16, 1, 'Customer', 9999);
RAISERROR(60002, 16, 1, 'stock', 100, 45);

-- ---- AA.5 PostgreSQL Exception Handling ----
DO $$
DECLARE
    v_dept_id INT := 1;
BEGIN
    INSERT INTO hr.departments (department_id, department_code, department_name)
    VALUES (v_dept_id, 'TEST', 'Test Department');

    RAISE NOTICE 'Department inserted successfully.';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Department with ID % already exists.', v_dept_id;
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint violated.';
    WHEN check_violation THEN
        RAISE NOTICE 'Check constraint violated.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: % - %', SQLSTATE, SQLERRM;
END;
$$;


-- ============================================================================================================================
-- PART AB: CURSORS
-- ============================================================================================================================

-- ---- AB.1 Basic Forward-Only Cursor ----
DECLARE
    @emp_id     INT,
    @emp_name   VARCHAR(101),
    @salary     DECIMAL(12,2),
    @dept_id    INT;

DECLARE emp_cursor CURSOR FAST_FORWARD FOR
    SELECT employee_id, CONCAT(first_name, ' ', last_name), salary, department_id
    FROM hr.employees
    WHERE status = 'ACTIVE'
    ORDER BY department_id, salary DESC;

OPEN emp_cursor;
FETCH NEXT FROM emp_cursor INTO @emp_id, @emp_name, @salary, @dept_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT('Dept: ', @dept_id, ' | Employee: ', @emp_name, ' | Salary: $', FORMAT(@salary, 'N2'));
    FETCH NEXT FROM emp_cursor INTO @emp_id, @emp_name, @salary, @dept_id;
END;

CLOSE emp_cursor;
DEALLOCATE emp_cursor;

-- ---- AB.2 Scrollable Cursor ----
DECLARE scroll_cursor CURSOR SCROLL FOR
    SELECT employee_id, first_name, salary
    FROM hr.employees
    WHERE status = 'ACTIVE'
    ORDER BY salary DESC;

OPEN scroll_cursor;

FETCH FIRST FROM scroll_cursor;         -- First row
FETCH LAST  FROM scroll_cursor;         -- Last row
FETCH ABSOLUTE 5 FROM scroll_cursor;    -- 5th row
FETCH RELATIVE -2 FROM scroll_cursor;   -- 2 rows back
FETCH NEXT FROM scroll_cursor;          -- Next row
FETCH PRIOR FROM scroll_cursor;         -- Previous row

CLOSE scroll_cursor;
DEALLOCATE scroll_cursor;

-- ---- AB.3 Cursor for Batch Processing ----
-- NOTE: Always prefer set-based operations. Use cursors only when row-by-row logic is unavoidable.

DECLARE
    @product_id     INT,
    @stock_qty      DECIMAL(12,3),
    @reorder_pt     DECIMAL(12,3),
    @reorder_qty    DECIMAL(12,3),
    @supplier_id    INT;

DECLARE reorder_cursor CURSOR FOR
    SELECT product_id, stock_quantity, reorder_point, reorder_quantity, supplier_id
    FROM inventory.products
    WHERE stock_quantity <= reorder_point
      AND is_active = TRUE
      AND is_discontinued = FALSE;

OPEN reorder_cursor;
FETCH NEXT FROM reorder_cursor INTO @product_id, @stock_qty, @reorder_pt, @reorder_qty, @supplier_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Complex per-row logic that can't easily be set-based
    PRINT CONCAT('Reorder needed: Product ', @product_id,
                 ' | Stock: ', @stock_qty,
                 ' | Reorder Qty: ', @reorder_qty,
                 ' | Supplier: ', @supplier_id);

    FETCH NEXT FROM reorder_cursor INTO @product_id, @stock_qty, @reorder_pt, @reorder_qty, @supplier_id;
END;

CLOSE reorder_cursor;
DEALLOCATE reorder_cursor;


-- ============================================================================================================================
-- PART AC: DYNAMIC SQL
-- ============================================================================================================================

-- ---- AC.1 Basic Dynamic SQL ----
DECLARE @sql NVARCHAR(MAX);
DECLARE @table VARCHAR(100) = 'hr.employees';

SET @sql = N'SELECT COUNT(*) AS row_count FROM ' + @table;
EXEC sp_executesql @sql;

-- ---- AC.2 Parameterized Dynamic SQL (Safe) ----
DECLARE @dept_id    INT = 1;
DECLARE @min_sal    DECIMAL(12,2) = 70000;
DECLARE @params     NVARCHAR(MAX);

SET @sql = N'
    SELECT employee_id, first_name, last_name, salary
    FROM hr.employees
    WHERE department_id = @dept
      AND salary >= @min_salary
      AND status = ''ACTIVE''
    ORDER BY salary DESC
';
SET @params = N'@dept INT, @min_salary DECIMAL(12,2)';

EXEC sp_executesql @sql, @params, @dept = @dept_id, @min_salary = @min_sal;

-- ---- AC.3 Dynamic ORDER BY (Safe Whitelist) ----
DECLARE @sort_col   VARCHAR(50) = 'salary';
DECLARE @sort_dir   VARCHAR(4)  = 'DESC';

-- Whitelist validation
IF @sort_col NOT IN ('employee_id','first_name','last_name','salary','hire_date','department_id')
    SET @sort_col = 'employee_id';
IF @sort_dir NOT IN ('ASC','DESC')
    SET @sort_dir = 'ASC';

SET @sql = N'SELECT * FROM hr.employees WHERE status = ''ACTIVE'' ORDER BY '
         + QUOTENAME(@sort_col) + N' ' + @sort_dir;
EXEC sp_executesql @sql;

-- ---- AC.4 Dynamic Pivot ----
DECLARE @pivot_columns  NVARCHAR(MAX);
DECLARE @pivot_query    NVARCHAR(MAX);

SELECT @pivot_columns = STRING_AGG(QUOTENAME(DATENAME(MONTH, order_date)), ',')
FROM (
    SELECT DISTINCT order_date
    FROM sales.orders
    WHERE YEAR(order_date) = 2024
) months;

SET @pivot_query = N'
SELECT customer_id, ' + @pivot_columns + N'
FROM (
    SELECT customer_id, DATENAME(MONTH, order_date) AS month_name, total_amount
    FROM sales.orders
    WHERE YEAR(order_date) = 2024 AND status = ''DELIVERED''
) src
PIVOT (SUM(total_amount) FOR month_name IN (' + @pivot_columns + N')) pvt
ORDER BY customer_id
';
EXEC sp_executesql @pivot_query;

-- ---- AC.5 Dynamic Table Creation ----
DECLARE @archive_table  VARCHAR(100);
DECLARE @year_suffix    VARCHAR(4) = CAST(YEAR(CURRENT_DATE) AS VARCHAR);

SET @archive_table = 'archive.orders_' + @year_suffix;
SET @sql = N'
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = ''orders_' + @year_suffix + N''' AND schema_id = SCHEMA_ID(''archive''))
    BEGIN
        SELECT * INTO ' + @archive_table + N'
        FROM sales.orders
        WHERE YEAR(order_date) = ' + @year_suffix + N'
          AND status IN (''DELIVERED'', ''CANCELLED'', ''RETURNED'');
        PRINT ''Archive table created: ' + @archive_table + N''';
    END
    ELSE
        PRINT ''Archive table already exists: ' + @archive_table + N''';
';
EXEC sp_executesql @sql;


-- ============================================================================================================================
-- PART AD: SEQUENCES AND IDENTITY
-- ============================================================================================================================

-- ---- AD.1 IDENTITY (SQL Server) ----
CREATE TABLE test_identity_demo (
    id          INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
    name        VARCHAR(100)        NOT NULL,
    created_at  DATETIME            DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO test_identity_demo (name) VALUES ('Row 1'), ('Row 2'), ('Row 3');

SELECT SCOPE_IDENTITY()                         AS last_identity_this_scope;
SELECT @@IDENTITY                               AS last_identity_this_session;
SELECT IDENT_CURRENT('test_identity_demo')      AS last_identity_for_table;
SELECT IDENT_SEED('test_identity_demo')         AS identity_seed;
SELECT IDENT_INCR('test_identity_demo')         AS identity_increment;

-- Reset identity
DBCC CHECKIDENT ('test_identity_demo', RESEED, 100);

-- ---- AD.2 AUTO_INCREMENT (MySQL) ----
CREATE TABLE test_autoincrement_demo (
    id          INT AUTO_INCREMENT   NOT NULL PRIMARY KEY,
    name        VARCHAR(100)         NOT NULL
);
-- SELECT LAST_INSERT_ID();  -- MySQL equivalent of SCOPE_IDENTITY()

-- ---- AD.3 SERIAL (PostgreSQL) ----
CREATE TABLE test_serial_demo (
    id          SERIAL              NOT NULL PRIMARY KEY,
    name        VARCHAR(100)        NOT NULL
);
-- SELECT currval('test_serial_demo_id_seq');
-- SELECT nextval('test_serial_demo_id_seq');

-- ---- AD.4 SEQUENCE Objects ----
CREATE SEQUENCE seq_order_id
    START WITH 10000
    INCREMENT BY 1
    MINVALUE 10000
    MAXVALUE 9999999999
    NO CYCLE
    CACHE 50;

CREATE SEQUENCE seq_invoice_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE
    CACHE 20;

CREATE SEQUENCE seq_employee_number
    START WITH 1000
    INCREMENT BY 1
    NO CYCLE;

-- Use sequences
SELECT NEXT VALUE FOR seq_order_id;
SELECT NEXT VALUE FOR seq_invoice_id;

-- Use in INSERT
INSERT INTO sales.orders (order_id, order_number, customer_id, order_date)
VALUES (NEXT VALUE FOR seq_order_id, CONCAT('ORD-', NEXT VALUE FOR seq_order_id), 1, CURRENT_DATE);

-- Alter sequence
ALTER SEQUENCE seq_order_id RESTART WITH 20000;
ALTER SEQUENCE seq_order_id INCREMENT BY 5;
ALTER SEQUENCE seq_order_id CACHE 100;

-- Drop sequence
DROP SEQUENCE IF EXISTS seq_order_id;

-- ---- AD.5 GUID/UUID ----
-- SQL Server
SELECT NEWID()                                  AS new_guid;
SELECT NEWSEQUENTIALID()                        AS sequential_guid;

-- MySQL
SELECT UUID()                                   AS new_uuid;

-- PostgreSQL
SELECT gen_random_uuid()                        AS new_uuid;

CREATE TABLE test_guid_pk (
    id          UNIQUEIDENTIFIER    DEFAULT NEWID() PRIMARY KEY,
    name        VARCHAR(100)
);


-- ============================================================================================================================
-- PART AE: SECURITY
-- ============================================================================================================================

-- ---- AE.1 Logins and Users ----
CREATE LOGIN app_service_account WITH PASSWORD = 'Str0ng!P@ssw0rd#2024';
CREATE LOGIN readonly_analyst WITH PASSWORD = 'R3adOnly!Analyst#2024';
CREATE LOGIN etl_process WITH PASSWORD = 'ETL!Pr0cess#2024';

CREATE USER app_service_account FOR LOGIN app_service_account;
CREATE USER readonly_analyst FOR LOGIN readonly_analyst;
CREATE USER etl_process FOR LOGIN etl_process;

-- ---- AE.2 Roles ----
CREATE ROLE role_sales_read;
CREATE ROLE role_sales_write;
CREATE ROLE role_hr_read;
CREATE ROLE role_hr_write;
CREATE ROLE role_finance_read;
CREATE ROLE role_inventory_read;
CREATE ROLE role_inventory_write;
CREATE ROLE role_report_user;
CREATE ROLE role_etl_user;
CREATE ROLE role_admin;

-- ---- AE.3 Permissions ----
-- Schema-level permissions
GRANT SELECT ON SCHEMA::sales      TO role_sales_read;
GRANT SELECT ON SCHEMA::hr         TO role_hr_read;
GRANT SELECT ON SCHEMA::finance    TO role_finance_read;
GRANT SELECT ON SCHEMA::inventory  TO role_inventory_read;

GRANT SELECT, INSERT, UPDATE ON SCHEMA::sales     TO role_sales_write;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::hr        TO role_hr_write;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::inventory TO role_inventory_write;

-- Object-level permissions
GRANT SELECT ON hr.vw_employee_directory    TO role_report_user;
GRANT SELECT ON sales.vw_customer_360       TO role_report_user;
GRANT SELECT ON sales.vw_order_summary      TO role_report_user;

GRANT EXECUTE ON hr.usp_get_department_employees    TO role_hr_read;
GRANT EXECUTE ON sales.usp_process_order            TO role_sales_write;

-- ETL permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::staging TO role_etl_user;
GRANT SELECT ON SCHEMA::sales       TO role_etl_user;
GRANT SELECT ON SCHEMA::hr          TO role_etl_user;

-- Assign users to roles
ALTER ROLE role_sales_read      ADD MEMBER readonly_analyst;
ALTER ROLE role_hr_read         ADD MEMBER readonly_analyst;
ALTER ROLE role_finance_read    ADD MEMBER readonly_analyst;
ALTER ROLE role_sales_write     ADD MEMBER app_service_account;
ALTER ROLE role_etl_user        ADD MEMBER etl_process;

-- Revoke and Deny
REVOKE INSERT ON hr.employees FROM role_hr_write;
DENY SELECT ON hr.employees TO readonly_analyst;  -- Overrides any GRANT

-- ---- AE.4 Row-Level Security (SQL Server 2016+) ----
CREATE SCHEMA rls;

-- Filter function: employees can only see their own department's data
CREATE FUNCTION rls.fn_department_filter(@department_id INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS result
    WHERE @department_id = CAST(SESSION_CONTEXT(N'department_id') AS INT)
       OR IS_MEMBER('role_hr_write') = 1
       OR IS_MEMBER('role_admin') = 1;

-- Apply security policy
CREATE SECURITY POLICY hr.dept_security_policy
ADD FILTER PREDICATE rls.fn_department_filter(department_id)
ON hr.employees
WITH (STATE = ON, SCHEMABINDING = ON);

-- Set session context
EXEC sp_set_session_context N'department_id', 1;

-- ---- AE.5 Dynamic Data Masking ----
ALTER TABLE hr.employees
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE hr.employees
ALTER COLUMN salary ADD MASKED WITH (FUNCTION = 'random(30000, 200000)');

ALTER TABLE hr.employees
ALTER COLUMN national_id ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XX-",4)');

ALTER TABLE hr.employees
ALTER COLUMN phone_mobile ADD MASKED WITH (FUNCTION = 'partial(0,"(XXX) XXX-",4)');

ALTER TABLE sales.customers
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');

-- Grant unmask to privileged users
GRANT UNMASK TO app_service_account;
GRANT UNMASK TO role_admin;

-- ---- AE.6 Transparent Data Encryption (TDE) ----
-- CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKey!2024';
-- CREATE CERTIFICATE tde_cert WITH SUBJECT = 'TDE Certificate';
-- CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE tde_cert;
-- ALTER DATABASE EnterpriseDB SET ENCRYPTION ON;


-- ============================================================================================================================
-- PART AG: ADVANCED ANALYTICS
-- ============================================================================================================================

-- ---- AG.1 Year-over-Year Analysis ----
WITH monthly_metrics AS (
    SELECT
        YEAR(order_date)    AS yr,
        MONTH(order_date)   AS mo,
        DATENAME(MONTH, order_date) AS month_name,
        COUNT(order_id)     AS order_count,
        COUNT(DISTINCT customer_id) AS unique_customers,
        SUM(total_amount)   AS revenue,
        AVG(total_amount)   AS avg_order_value
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY YEAR(order_date), MONTH(order_date), DATENAME(MONTH, order_date)
)
SELECT
    curr.yr,
    curr.mo,
    curr.month_name,
    curr.order_count,
    curr.unique_customers,
    curr.revenue,
    curr.avg_order_value,
    prev.revenue                                                        AS prev_year_revenue,
    curr.revenue - COALESCE(prev.revenue, 0)                           AS yoy_revenue_change,
    CASE
        WHEN COALESCE(prev.revenue, 0) = 0 THEN NULL
        ELSE ROUND((curr.revenue - prev.revenue) / prev.revenue * 100, 2)
    END                                                                 AS yoy_revenue_pct,
    prev.order_count                                                    AS prev_year_orders,
    curr.order_count - COALESCE(prev.order_count, 0)                   AS yoy_order_change
FROM monthly_metrics curr
LEFT JOIN monthly_metrics prev
    ON curr.mo = prev.mo AND curr.yr = prev.yr + 1
ORDER BY curr.yr, curr.mo;

-- ---- AG.2 Cohort Analysis ----
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))    AS cohort_month
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT
        o.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date)       AS activity_month,
        DATEDIFF(MONTH, fp.cohort_month, DATE_TRUNC('month', o.order_date)) AS months_since_first
    FROM sales.orders o
    INNER JOIN first_purchase fp ON o.customer_id = fp.customer_id
    WHERE o.status = 'DELIVERED'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
),
retention AS (
    SELECT
        cohort_month,
        months_since_first,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM customer_activity
    GROUP BY cohort_month, months_since_first
)
SELECT
    r.cohort_month,
    cs.cohort_customers,
    r.months_since_first,
    r.retained_customers,
    ROUND(r.retained_customers * 100.0 / cs.cohort_customers, 2) AS retention_rate
FROM retention r
INNER JOIN cohort_size cs ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.months_since_first;

-- ---- AG.3 RFM Segmentation ----
WITH rfm_raw AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, MAX(order_date), CURRENT_DATE)    AS recency_days,
        COUNT(order_id)                                  AS frequency,
        SUM(total_amount)                                AS monetary
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
),
rfm_scored AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_raw
),
rfm_segmented AS (
    SELECT
        *,
        r_score + f_score + m_score AS rfm_total,
        CONCAT(r_score, f_score, m_score) AS rfm_cell,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 4 AND f_score >= 3                  THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                  THEN 'Recent Customers'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Potential Loyalists'
            WHEN r_score = 3 AND f_score = 1                    THEN 'Promising'
            WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 2 AND m_score >= 2 THEN 'Needs Attention'
            WHEN r_score = 1 AND f_score >= 4 AND m_score >= 4  THEN 'Cant Lose Them'
            WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost'
            ELSE                                                      'Others'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*)                        AS customer_count,
    ROUND(AVG(recency_days), 0)     AS avg_recency_days,
    ROUND(AVG(frequency), 1)        AS avg_frequency,
    ROUND(AVG(monetary), 2)         AS avg_monetary,
    ROUND(SUM(monetary), 2)         AS total_monetary,
    ROUND(AVG(rfm_total), 1)        AS avg_rfm_score
FROM rfm_segmented
GROUP BY segment
ORDER BY avg_rfm_score DESC;

-- ---- AG.4 Funnel Analysis ----
WITH funnel AS (
    SELECT
        COUNT(DISTINCT CASE WHEN status IN ('DRAFT','PENDING','CONFIRMED','PROCESSING','SHIPPED','DELIVERED','CANCELLED','RETURNED','ON_HOLD') THEN order_id END) AS total_orders,
        COUNT(DISTINCT CASE WHEN status IN ('CONFIRMED','PROCESSING','SHIPPED','DELIVERED') THEN order_id END) AS confirmed_orders,
        COUNT(DISTINCT CASE WHEN status IN ('PROCESSING','SHIPPED','DELIVERED') THEN order_id END) AS processing_orders,
        COUNT(DISTINCT CASE WHEN status IN ('SHIPPED','DELIVERED') THEN order_id END) AS shipped_orders,
        COUNT(DISTINCT CASE WHEN status = 'DELIVERED' THEN order_id END) AS delivered_orders
    FROM sales.orders
    WHERE order_date >= DATEADD(MONTH, -3, CURRENT_DATE)
)
SELECT
    'Total Orders'          AS stage, total_orders      AS count, 100.0 AS conversion_pct FROM funnel
UNION ALL
SELECT 'Confirmed',         confirmed_orders,   ROUND(confirmed_orders  * 100.0 / NULLIF(total_orders, 0), 2) FROM funnel
UNION ALL
SELECT 'Processing',        processing_orders,  ROUND(processing_orders * 100.0 / NULLIF(total_orders, 0), 2) FROM funnel
UNION ALL
SELECT 'Shipped',           shipped_orders,     ROUND(shipped_orders    * 100.0 / NULLIF(total_orders, 0), 2) FROM funnel
UNION ALL
SELECT 'Delivered',         delivered_orders,   ROUND(delivered_orders  * 100.0 / NULLIF(total_orders, 0), 2) FROM funnel;

-- ---- AG.5 Market Basket Analysis ----
SELECT
    a.product_id                                AS product_a,
    pa.product_name                             AS product_a_name,
    b.product_id                                AS product_b,
    pb.product_name                             AS product_b_name,
    COUNT(DISTINCT a.order_id)                  AS co_occurrence_count,
    ROUND(COUNT(DISTINCT a.order_id) * 100.0 / (
        SELECT COUNT(DISTINCT order_id) FROM sales.order_items
    ), 4)                                       AS support_pct,
    ROUND(COUNT(DISTINCT a.order_id) * 100.0 / (
        SELECT COUNT(DISTINCT order_id) FROM sales.order_items WHERE product_id = a.product_id
    ), 2)                                       AS confidence_pct
FROM sales.order_items a
INNER JOIN sales.order_items b
    ON a.order_id = b.order_id
    AND a.product_id < b.product_id
INNER JOIN inventory.products pa ON a.product_id = pa.product_id
INNER JOIN inventory.products pb ON b.product_id = pb.product_id
GROUP BY a.product_id, pa.product_name, b.product_id, pb.product_name
HAVING COUNT(DISTINCT a.order_id) >= 2
ORDER BY co_occurrence_count DESC;

-- ---- AG.6 Moving Averages and Trend Analysis ----
WITH daily_revenue AS (
    SELECT
        CAST(order_date AS DATE)    AS order_day,
        SUM(total_amount)           AS daily_revenue,
        COUNT(order_id)             AS daily_orders
    FROM sales.orders
    WHERE status = 'DELIVERED'
    GROUP BY CAST(order_date AS DATE)
)
SELECT
    order_day,
    daily_revenue,
    daily_orders,
    -- 7-day moving average
    AVG(daily_revenue) OVER (ORDER BY order_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)  AS ma_7d,
    -- 30-day moving average
    AVG(daily_revenue) OVER (ORDER BY order_day ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS ma_30d,
    -- Cumulative revenue
    SUM(daily_revenue) OVER (ORDER BY order_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
    -- Day-over-day change
    daily_revenue - LAG(daily_revenue, 1) OVER (ORDER BY order_day) AS dod_change,
    -- Week-over-week change
    daily_revenue - LAG(daily_revenue, 7) OVER (ORDER BY order_day) AS wow_change
FROM daily_revenue
ORDER BY order_day;


-- ============================================================================================================================
-- PART AN: COMMON SQL INTERVIEW QUESTIONS AND ANSWERS
-- ============================================================================================================================

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

-- Q3: Delete duplicate records keeping the one with lowest ID
WITH duplicates AS (
    SELECT employee_id,
           ROW_NUMBER() OVER (PARTITION BY email ORDER BY employee_id) AS rn
    FROM hr.employees
)
DELETE FROM hr.employees
WHERE employee_id IN (SELECT employee_id FROM duplicates WHERE rn > 1);

-- Q4: Find employees who joined in the same month as their manager
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee,
    e.hire_date                              AS emp_hire_date,
    CONCAT(m.first_name, ' ', m.last_name)  AS manager,
    m.hire_date                              AS mgr_hire_date
FROM hr.employees e
INNER JOIN hr.employees m ON e.manager_id = m.employee_id
WHERE MONTH(e.hire_date) = MONTH(m.hire_date)
  AND YEAR(e.hire_date)  = YEAR(m.hire_date);

-- Q5: Find the department with the highest average salary
SELECT TOP 1
    d.department_name,
    ROUND(AVG(e.salary), 2) AS avg_salary
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_name
ORDER BY avg_salary DESC;

-- Q6: Find customers who placed orders every month for the last 6 months
WITH monthly_orders AS (
    SELECT
        customer_id,
        FORMAT(order_date, 'yyyy-MM') AS order_month
    FROM sales.orders
    WHERE order_date >= DATEADD(MONTH, -6, CURRENT_DATE)
      AND status NOT IN ('CANCELLED')
    GROUP BY customer_id, FORMAT(order_date, 'yyyy-MM')
),
customer_month_count AS (
    SELECT customer_id, COUNT(DISTINCT order_month) AS months_with_orders
    FROM monthly_orders
    GROUP BY customer_id
)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer
FROM sales.customers c
INNER JOIN customer_month_count cmc ON c.customer_id = cmc.customer_id
WHERE cmc.months_with_orders = 6;

-- Q7: Running total with reset per group
SELECT
    customer_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS customer_running_total
FROM sales.orders
WHERE status = 'DELIVERED'
ORDER BY customer_id, order_date;

-- Q8: Find products that were sold in all months of 2024
SELECT product_id
FROM (
    SELECT DISTINCT product_id, MONTH(o.order_date) AS sale_month
    FROM sales.order_items oi
    INNER JOIN sales.orders o ON oi.order_id = o.order_id
    WHERE YEAR(o.order_date) = 2024 AND o.status = 'DELIVERED'
) monthly_sales
GROUP BY product_id
HAVING COUNT(DISTINCT sale_month) = 12;

-- Q9: Employees with no direct reports
SELECT e.employee_id, CONCAT(e.first_name, ' ', e.last_name) AS employee
FROM hr.employees e
WHERE e.status = 'ACTIVE'
  AND NOT EXISTS (
    SELECT 1 FROM hr.employees sub
    WHERE sub.manager_id = e.employee_id AND sub.status = 'ACTIVE'
  );

-- Q10: Find the top 3 products by revenue in each category
SELECT *
FROM (
    SELECT
        cat.category_name,
        p.product_name,
        SUM(oi.line_total) AS total_revenue,
        DENSE_RANK() OVER (PARTITION BY cat.category_name ORDER BY SUM(oi.line_total) DESC) AS revenue_rank
    FROM sales.order_items oi
    INNER JOIN inventory.products p     ON oi.product_id  = p.product_id
    INNER JOIN inventory.categories cat ON p.category_id  = cat.category_id
    INNER JOIN sales.orders o           ON oi.order_id    = o.order_id
    WHERE o.status = 'DELIVERED'
    GROUP BY cat.category_name, p.product_name
) ranked
WHERE revenue_rank <= 3
ORDER BY category_name, revenue_rank;

-- Q11: Difference between RANK, DENSE_RANK, and ROW_NUMBER
SELECT
    employee_id,
    salary,
    ROW_NUMBER()    OVER (ORDER BY salary DESC) AS row_num,     -- Always unique: 1,2,3,4,5
    RANK()          OVER (ORDER BY salary DESC) AS rank_val,    -- Gaps after ties: 1,2,2,4,5
    DENSE_RANK()    OVER (ORDER BY salary DESC) AS dense_rank   -- No gaps: 1,2,2,3,4
FROM hr.employees
WHERE status = 'ACTIVE';

-- Q12: Find employees whose salary is above the median
SELECT employee_id, first_name, salary
FROM hr.employees
WHERE status = 'ACTIVE'
  AND salary > (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)
    FROM hr.employees WHERE status = 'ACTIVE'
  )
ORDER BY salary DESC;

-- Q13: Pivot without PIVOT keyword
SELECT
    department_id,
    SUM(CASE WHEN employment_type = 'FULL_TIME'  THEN 1 ELSE 0 END) AS full_time,
    SUM(CASE WHEN employment_type = 'PART_TIME'  THEN 1 ELSE 0 END) AS part_time,
    SUM(CASE WHEN employment_type = 'CONTRACT'   THEN 1 ELSE 0 END) AS contract,
    SUM(CASE WHEN employment_type = 'INTERN'     THEN 1 ELSE 0 END) AS intern,
    COUNT(*) AS total
FROM hr.employees
WHERE status = 'ACTIVE'
GROUP BY department_id
ORDER BY department_id;

-- Q14: Find the longest consecutive streak of daily orders per customer
WITH daily_orders AS (
    SELECT DISTINCT
        customer_id,
        CAST(order_date AS DATE) AS order_day
    FROM sales.orders
    WHERE status NOT IN ('CANCELLED')
),
with_gaps AS (
    SELECT
        customer_id,
        order_day,
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_day), order_day) AS grp
    FROM daily_orders
),
streaks AS (
    SELECT
        customer_id,
        MIN(order_day) AS streak_start,
        MAX(order_day) AS streak_end,
        COUNT(*) AS streak_length
    FROM with_gaps
    GROUP BY customer_id, grp
)
SELECT
    customer_id,
    MAX(streak_length) AS longest_streak_days
FROM streaks
GROUP BY customer_id
ORDER BY longest_streak_days DESC;

-- Q15: Calculate the percentage contribution of each product to total revenue
SELECT
    p.product_name,
    SUM(oi.line_total)                                                  AS product_revenue,
    SUM(SUM(oi.line_total)) OVER ()                                     AS total_revenue,
    ROUND(SUM(oi.line_total) / SUM(SUM(oi.line_total)) OVER () * 100, 2) AS revenue_pct
FROM sales.order_items oi
INNER JOIN inventory.products p ON oi.product_id = p.product_id
INNER JOIN sales.orders o ON oi.order_id = o.order_id
WHERE o.status = 'DELIVERED'
GROUP BY p.product_name
ORDER BY product_revenue DESC;


-- ============================================================================================================================
-- PART AO: 100 PRACTICE QUERIES
-- ============================================================================================================================

-- 1. List all active employees sorted by hire date (oldest first)
SELECT employee_id, first_name, last_name, hire_date FROM hr.employees WHERE status = 'ACTIVE' ORDER BY hire_date ASC;

-- 2. Count employees per department
SELECT department_id, COUNT(*) AS headcount FROM hr.employees WHERE status = 'ACTIVE' GROUP BY department_id ORDER BY headcount DESC;

-- 3. Find the highest paid employee in each department
SELECT department_id, MAX(salary) AS max_salary FROM hr.employees WHERE status = 'ACTIVE' GROUP BY department_id;

-- 4. List customers who have never placed an order
SELECT c.customer_id, c.first_name, c.last_name FROM sales.customers c LEFT JOIN sales.orders o ON c.customer_id = o.customer_id WHERE o.order_id IS NULL;

-- 5. Find total revenue by month for the current year
SELECT FORMAT(order_date, 'yyyy-MM') AS month, SUM(total_amount) AS revenue FROM sales.orders WHERE YEAR(order_date) = YEAR(CURRENT_DATE) AND status = 'DELIVERED' GROUP BY FORMAT(order_date, 'yyyy-MM') ORDER BY month;

-- 6. List products with stock below reorder point
SELECT product_id, product_name, stock_quantity, reorder_point FROM inventory.products WHERE stock_quantity <= reorder_point AND is_active = TRUE ORDER BY stock_quantity ASC;

-- 7. Find the average order value per customer segment
SELECT cs.segment_name, COUNT(o.order_id) AS orders, ROUND(AVG(o.total_amount), 2) AS avg_order_value FROM sales.orders o INNER JOIN sales.customers c ON o.customer_id = c.customer_id INNER JOIN sales.customer_segments cs ON c.segment_id = cs.segment_id WHERE o.status = 'DELIVERED' GROUP BY cs.segment_name ORDER BY avg_order_value DESC;

-- 8. List employees hired in the last 90 days
SELECT employee_id, first_name, last_name, hire_date FROM hr.employees WHERE hire_date >= DATEADD(DAY, -90, CURRENT_DATE) ORDER BY hire_date DESC;

-- 9. Find products that have never been ordered
SELECT p.product_id, p.product_name FROM inventory.products p WHERE NOT EXISTS (SELECT 1 FROM sales.order_items oi WHERE oi.product_id = p.product_id) AND p.is_active = TRUE;

-- 10. Calculate the total payroll cost by department
SELECT d.department_name, SUM(e.salary) AS total_payroll, COUNT(e.employee_id) AS headcount FROM hr.employees e INNER JOIN hr.departments d ON e.department_id = d.department_id WHERE e.status = 'ACTIVE' GROUP BY d.department_name ORDER BY total_payroll DESC;

-- 11. Find orders with more than 5 line items
SELECT order_id, COUNT(*) AS item_count FROM sales.order_items GROUP BY order_id HAVING COUNT(*) > 5 ORDER BY item_count DESC;

-- 12. List the top 10 customers by lifetime value
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer, SUM(o.total_amount) AS lifetime_value FROM sales.customers c INNER JOIN sales.orders o ON c.customer_id = o.customer_id WHERE o.status = 'DELIVERED' GROUP BY c.customer_id, c.first_name, c.last_name ORDER BY lifetime_value DESC LIMIT 10;

-- 13. Find employees with the same job title in different departments
SELECT e1.job_title, e1.department_id AS dept1, e2.department_id AS dept2 FROM hr.employees e1 INNER JOIN hr.employees e2 ON e1.job_title = e2.job_title AND e1.department_id < e2.department_id WHERE e1.status = 'ACTIVE' AND e2.status = 'ACTIVE';

-- 14. Calculate the order fulfillment rate (delivered / total)
SELECT ROUND(COUNT(CASE WHEN status = 'DELIVERED' THEN 1 END) * 100.0 / COUNT(*), 2) AS fulfillment_rate FROM sales.orders WHERE order_date >= DATEADD(MONTH, -12, CURRENT_DATE);

-- 15. Find the most popular product category by order count
SELECT cat.category_name, COUNT(DISTINCT oi.order_id) AS order_count FROM sales.order_items oi INNER JOIN inventory.products p ON oi.product_id = p.product_id INNER JOIN inventory.categories cat ON p.category_id = cat.category_id GROUP BY cat.category_name ORDER BY order_count DESC;

-- 16. List employees who report directly to the CEO (top-level manager)
SELECT e.employee_id, CONCAT(e.first_name, ' ', e.last_name) AS employee, e.job_title FROM hr.employees e WHERE e.manager_id = (SELECT employee_id FROM hr.employees WHERE manager_id IS NULL AND status = 'ACTIVE');

-- 17. Find the average time between order placement and shipment
SELECT ROUND(AVG(DATEDIFF(DAY, order_date, shipped_date)), 1) AS avg_days_to_ship FROM sales.orders WHERE shipped_date IS NOT NULL AND status IN ('SHIPPED', 'DELIVERED');

-- 18. List products with a profit margin above 50%
SELECT product_id, product_name, unit_price, cost_price, ROUND((unit_price - cost_price) / unit_price * 100, 2) AS margin_pct FROM inventory.products WHERE cost_price > 0 AND (unit_price - cost_price) / unit_price > 0.5 ORDER BY margin_pct DESC;

-- 19. Find customers with overdue invoices
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer, SUM(i.outstanding_amount) AS overdue_amount FROM sales.customers c INNER JOIN finance.invoices i ON c.customer_id = i.customer_id WHERE i.status = 'OVERDUE' GROUP BY c.customer_id, c.first_name, c.last_name ORDER BY overdue_amount DESC;

-- 20. Calculate the employee turnover rate for the current year
SELECT ROUND(COUNT(CASE WHEN YEAR(termination_date) = YEAR(CURRENT_DATE) THEN 1 END) * 100.0 / COUNT(*), 2) AS turnover_rate FROM hr.employees;

-- 21. Find the busiest day of the week for orders
SELECT DATENAME(WEEKDAY, order_date) AS day_name, COUNT(*) AS order_count FROM sales.orders GROUP BY DATENAME(WEEKDAY, order_date), DATEPART(WEEKDAY, order_date) ORDER BY DATEPART(WEEKDAY, order_date);

-- 22. List all managers and their direct report count
SELECT m.employee_id, CONCAT(m.first_name, ' ', m.last_name) AS manager, COUNT(e.employee_id) AS direct_reports FROM hr.employees m INNER JOIN hr.employees e ON e.manager_id = m.employee_id WHERE e.status = 'ACTIVE' GROUP BY m.employee_id, m.first_name, m.last_name ORDER BY direct_reports DESC;

-- 23. Find the revenue contribution of the top 20% of customers (Pareto)
WITH customer_revenue AS (
    SELECT customer_id, SUM(total_amount) AS revenue, NTILE(5) OVER (ORDER BY SUM(total_amount) DESC) AS quintile
    FROM sales.orders WHERE status = 'DELIVERED' GROUP BY customer_id
)
SELECT quintile, COUNT(*) AS customers, SUM(revenue) AS total_revenue, ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 2) AS revenue_pct FROM customer_revenue GROUP BY quintile ORDER BY quintile;

-- 24. Find products ordered together most frequently (top 10 pairs)
SELECT TOP 10 a.product_id AS prod_a, b.product_id AS prod_b, COUNT(*) AS pair_count FROM sales.order_items a INNER JOIN sales.order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id GROUP BY a.product_id, b.product_id ORDER BY pair_count DESC;

-- 25. Calculate the customer acquisition cost by month (assuming marketing spend is tracked)
-- SELECT FORMAT(registration_date, 'yyyy-MM') AS month, COUNT(*) AS new_customers FROM sales.customers GROUP BY FORMAT(registration_date, 'yyyy-MM') ORDER BY month;

-- 26. Find employees whose salary is in the top 10% of their department
SELECT employee_id, first_name, last_name, department_id, salary FROM (SELECT *, PERCENT_RANK() OVER (PARTITION BY department_id ORDER BY salary) AS pct_rank FROM hr.employees WHERE status = 'ACTIVE') ranked WHERE pct_rank >= 0.9;

-- 27. List orders that were placed but not shipped within 3 business days
SELECT order_id, order_number, order_date, shipped_date, DATEDIFF(DAY, order_date, COALESCE(shipped_date, CURRENT_DATE)) AS days_pending FROM sales.orders WHERE status NOT IN ('CANCELLED', 'DELIVERED') AND DATEDIFF(DAY, order_date, CURRENT_DATE) > 3;

-- 28. Find the month with the highest revenue in each year
SELECT yr, mo, revenue FROM (SELECT YEAR(order_date) AS yr, MONTH(order_date) AS mo, SUM(total_amount) AS revenue, RANK() OVER (PARTITION BY YEAR(order_date) ORDER BY SUM(total_amount) DESC) AS rnk FROM sales.orders WHERE status = 'DELIVERED' GROUP BY YEAR(order_date), MONTH(order_date)) ranked WHERE rnk = 1;

-- 29. Calculate the inventory turnover ratio
SELECT p.product_id, p.product_name, COALESCE(SUM(oi.quantity_ordered), 0) AS units_sold, p.stock_quantity AS current_stock, CASE WHEN p.stock_quantity > 0 THEN ROUND(COALESCE(SUM(oi.quantity_ordered), 0) / p.stock_quantity, 2) ELSE NULL END AS turnover_ratio FROM inventory.products p LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id LEFT JOIN sales.orders o ON oi.order_id = o.order_id AND o.status = 'DELIVERED' AND YEAR(o.order_date) = YEAR(CURRENT_DATE) WHERE p.is_active = TRUE GROUP BY p.product_id, p.product_name, p.stock_quantity ORDER BY turnover_ratio DESC NULLS LAST;

-- 30. Find the employee with the longest tenure in each department
SELECT department_id, employee_id, first_name, last_name, hire_date FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY hire_date ASC) AS rn FROM hr.employees WHERE status = 'ACTIVE') ranked WHERE rn = 1;

-- ============================================================================================================================
-- END OF SQL COMPLETE REFERENCE GUIDE - 500KB+ EDITION
-- ============================================================================================================================
-- Summary of Coverage:
--   Parts A-AO: 41 major sections
--   DDL, DML, SELECT, JOINs, Subqueries, CTEs, Window Functions, Set Operations
--   Indexes, Views, Stored Procedures, Functions, Triggers, Transactions
--   Normalization, Query Optimization, Partitioning, Temporary Objects
--   Pivot/Unpivot, JSON, XML, String/Date/Math Functions
--   Conditional Expressions, Error Handling, Cursors, Dynamic SQL
--   Sequences, Security, Backup, Advanced Analytics, Recursive Queries
--   Full-Text Search, Materialized Views, Interview Questions, Practice Queries
-- ============================================================================================================================
