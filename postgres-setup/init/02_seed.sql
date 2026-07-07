-- Sample seed data. Feel free to expand/replace per-phase as you tackle problems
-- that need different table shapes (e.g. dimensional modeling tables in phase 09).

INSERT INTO department (name) VALUES
('IT'), ('Sales'), ('Marketing');

INSERT INTO employee (name, salary, department_id, manager_id) VALUES
('Joe',   85000, 1, NULL),
('Henry', 80000, 2, NULL),
('Sam',   60000, 2, 2),
('Max',   90000, 1, 1),
('Alice', 95000, 1, 1),
('Ella',  62000, 3, NULL),
('Anna',  60000, 3, 6);

INSERT INTO product (product_name) VALUES
('Laptop'), ('Monitor'), ('Keyboard'), ('Mouse');

INSERT INTO sales (product_id, sale_year, quantity, price) VALUES
(1, 2023, 10, 1200.00),
(1, 2024, 15, 1250.00),
(2, 2023, 20, 300.00),
(2, 2024, 18, 320.00),
(3, 2023, 50, 40.00),
(4, 2024, 60, 25.00);

INSERT INTO customer (name, referee_id) VALUES
('Will',  NULL),
('Jane',  NULL),
('Alex',  2),
('Bill',  NULL),
('Zack',  1),
('Mark',  2);

INSERT INTO orders (customer_id, order_date, amount) VALUES
(1, '2024-01-05', 250.00),
(1, '2024-02-10', 150.00),
(2, '2024-01-20', 400.00),
(3, '2024-03-01', 100.00);

INSERT INTO weather (record_date, temperature) VALUES
('2024-01-01', 10),
('2024-01-02', 25),
('2024-01-03', 20),
('2024-01-04', 30);
