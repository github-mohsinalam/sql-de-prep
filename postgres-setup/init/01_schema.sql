-- Schema mirroring common LeetCode SQL 50 / StrataScratch table structures.
-- Add more tables here as later phases need them (e.g. dimensional modeling tables in phase 09).

CREATE TABLE department (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE employee (
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    salary        INTEGER NOT NULL,
    department_id INTEGER REFERENCES department(id),
    manager_id    INTEGER REFERENCES employee(id)
);

CREATE TABLE product (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL
);

CREATE TABLE sales (
    sale_id    SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES product(product_id),
    sale_year  INTEGER NOT NULL,
    quantity   INTEGER NOT NULL,
    price      NUMERIC(10,2) NOT NULL
);

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    referee_id  INTEGER REFERENCES customer(customer_id)
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(customer_id),
    order_date  DATE NOT NULL,
    amount      NUMERIC(10,2) NOT NULL
);

-- Weather table for classic LeetCode 197 (Rising Temperature)
CREATE TABLE weather (
    id           SERIAL PRIMARY KEY,
    record_date  DATE NOT NULL,
    temperature  INTEGER NOT NULL
);
