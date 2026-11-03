-- PROGETTO DI PORTFOLIO: vendite e-commerce SINTETICHE, anno 2025.
-- Apri Query Tool del database portfolio_ecommerce e lancia questo file UNA SOLA VOLTA.
-- NON esegue cancellazioni dei dati esistenti.
CREATE SCHEMA IF NOT EXISTS portfolio;

CREATE TABLE IF NOT EXISTS portfolio.customers (
    customer_id INTEGER PRIMARY KEY,
    city VARCHAR(80) NOT NULL,
    region VARCHAR(80) NOT NULL,
    registration_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS portfolio.products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(80) NOT NULL,
    list_price NUMERIC(10,2) NOT NULL CHECK (list_price > 0),
    unit_cost NUMERIC(10,2) NOT NULL CHECK (unit_cost >= 0)
);

CREATE TABLE IF NOT EXISTS portfolio.orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES portfolio.customers(customer_id),
    order_date DATE NOT NULL,
    channel VARCHAR(40) NOT NULL
);

CREATE TABLE IF NOT EXISTS portfolio.order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES portfolio.orders(order_id),
    product_id INTEGER NOT NULL REFERENCES portfolio.products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    discount_pct NUMERIC(5,2) NOT NULL CHECK (discount_pct BETWEEN 0 AND 100),
    is_returned BOOLEAN NOT NULL,
    CONSTRAINT uq_item_per_order UNIQUE(order_id, product_id)
);


SELECT
    channel,
    COUNT(*) AS numero_ordini
FROM portfolio.orders
GROUP BY channel
ORDER BY numero_ordini DESC;