-- CONTROLLI DI QUALITA': sono parte del progetto, non solo un formalismo.
-- Esegui UNA query per volta, selezionandola e premendo Esegui in pgAdmin.

-- 1) Volume dei dati. Attesi: 800, 35, 3200, 5019.
SELECT 'customers' AS tabella, COUNT(*) AS righe FROM portfolio.customers
UNION ALL SELECT 'products', COUNT(*) FROM portfolio.products
UNION ALL SELECT 'orders', COUNT(*) FROM portfolio.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM portfolio.order_items;

-- 2) Record senza riferimento valido: attesi 0 (vincoli FK lo impediscono).
SELECT COUNT(*) AS ordini_senza_cliente
FROM portfolio.orders o
LEFT JOIN portfolio.customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- 3) Anomalie nelle date: attesi 0.
SELECT COUNT(*) AS date_anomale
FROM portfolio.orders o
JOIN portfolio.customers c USING (customer_id)
WHERE o.order_date < c.registration_date OR o.order_date NOT BETWEEN DATE '2025-01-01' AND DATE '2025-12-31';

-- 4) Dupliche delle righe di acquisto in un ordine: attesi 0.
SELECT order_id, product_id, COUNT(*) AS occorrenze
FROM portfolio.order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- 5) Dati potenzialmente sospetti nelle linee d'ordine: attesi 0.
SELECT COUNT(*) AS righe_con_valori_anomali
FROM portfolio.order_items
WHERE quantity <= 0 OR unit_price <= 0 OR discount_pct NOT BETWEEN 0 AND 100;

-- 6) Confronto descrittivo tra righe totali, righe rese, righe non rese.
SELECT COUNT(*) AS righe_totali,
       COUNT(*) FILTER (WHERE is_returned) AS righe_rese,
       COUNT(*) FILTER (WHERE NOT is_returned) AS righe_vendute
FROM portfolio.order_items;
