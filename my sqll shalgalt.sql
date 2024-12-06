CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK(price >= 10000),
    category VARCHAR(255) NOT NULL,
    stock_quantity INT NOT NULL
);

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Order_Details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
-- Бүх бүтээгдэхүүний нэр болон үнэ
SELECT name, price FROM Products;

-- Захиалгад орсон бараа бүтээгдэхүүнүүд болон нийт үнэ
SELECT p.name, p.price, od.quantity, (p.price * od.quantity) AS total_price
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id
WHERE od.order_id = 1;

-- Хувь хэрэглэгчдийн нийт захиалгын тоо болон нийт зарцуулсан мөнгө
SELECT u.name, COUNT(o.order_id) AS total_orders, SUM(o.total_price) AS total_spent
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
GROUP BY u.user_id;
CREATE VIEW order_summary AS
SELECT o.order_id, o.order_date, u.name AS customer_name, p.name AS product_name, od.quantity, (p.price * od.quantity) AS total_price
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id;
-- Products хүснэгтийн stock_quantity баганын утгыг өөрчлөх
UPDATE Products SET stock_quantity = 120 WHERE product_id = 1;

-- Захиалгын барааг устгах
DELETE FROM Order_Details WHERE order_detail_id = 1;
CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255)
);

-- Бараа нийлүүлэгчтэй холбох харилцаа үүсгэх
ALTER TABLE Products ADD supplier_id INT, FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id);
CREATE VIEW supplier_product_summary AS
SELECT s.name AS supplier_name, p.name AS product_name, p.category
FROM Suppliers s
JOIN Products p ON s.supplier_id = p.supplier_id;
-- Барааны үлдэгдэл 0 болсон эсвэл хугацаа хэтэрсэн бүтээгдэхүүнийг устгах
DELETE FROM Products WHERE stock_quantity = 0;
-- 100,000₮-өөс дээш үнэтэй бүх бүтээгдэхүүнийг ол
SELECT name, price FROM Products WHERE price >= 100000;

-- @gmail.com хаягтай хэрэглэгчдийг жагсаа
SELECT name, email FROM Users WHERE email LIKE '%@gmail.com';
-- Захиалгад хамгийн их бараа багтсан хэрэглэгчийн нэрийг ол
SELECT name FROM Users WHERE user_id = (
    SELECT user_id FROM Orders WHERE order_id = (
        SELECT order_id FROM Order_Details WHERE quantity = (
            SELECT MAX(quantity) FROM Order_Details
        )
    )
);

-- Хамгийн их бараа зарагдсан категориудыг ол
SELECT category FROM Products WHERE product_id IN (
    SELECT product_id FROM Order_Details WHERE order_id IN (
        SELECT order_id FROM Orders WHERE order_date >= '2024-01-01'
    )
);
-- Бүтээгдэхүүний үнэнд доод хязгаарлалт тогтоох
ALTER TABLE Products ADD CONSTRAINT price_check CHECK (price >= 10000);
SELECT u.name, SUM(od.quantity) AS total_items, o.order_date
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
JOIN Order_Details od ON o.order_id = od.order_id
GROUP BY u.user_id, o.order_date;
CREATE TABLE Product_Category_Summary (
    category_name VARCHAR(255),
    total_quantity INT
);

INSERT INTO Product_Category_Summary (category_name, total_quantity)
SELECT category, SUM(stock_quantity) FROM Products GROUP BY category;
-- Хэрэглэгчдийн хамгийн сүүлд хийсэн захиалга
SELECT u.name, o.order_date
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
WHERE o.order_date = (SELECT MAX(order_date) FROM Orders WHERE user_id = u.user_id);

-- Нийт хамгийн их борлуулалттай бараа
SELECT name FROM Products WHERE product_id IN (
    SELECT product_id FROM Order_Details
    GROUP BY product_id ORDER BY SUM(quantity) DESC LIMIT 1
);
