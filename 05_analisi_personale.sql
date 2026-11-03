-- ANALISI 1: verifica del numero di clienti
SELECT COUNT(*)
FROM portfolio.customers;

-- ANALISI 2: ricavi e margine complessivi
SELECT
    ROUND(SUM(net_revenue), 2) AS ricavi_netti,
    ROUND(SUM(gross_profit), 2) AS margine_lordo
FROM portfolio.v_sales_lines;

-- ANALISI 3: andamento mensile delle vendite
SELECT
    order_month,
    ROUND(SUM(net_revenue), 2) AS ricavi,
    ROUND(SUM(gross_profit), 2) AS margine
FROM portfolio.v_sales_lines
GROUP BY order_month
ORDER BY order_month;



-- =====================================================
-- ANALISI 4: FATTURATO E REDDITIVITÀ PER CATEGORIA
-- =====================================================
-- Obiettivo:
-- Identificare le categorie che generano maggiori
-- ricavi e confrontarne la marginalità.
--
-- KPI analizzati:
-- 1. Ricavi netti per categoria
-- 2. Margine lordo per categoria
-- 3. Margine lordo percentuale
--
-- Business insight:
-- Una categoria con fatturato elevato non è
-- necessariamente quella con la maggiore redditività.

SELECT
    category,
    ROUND(SUM(net_revenue), 2) AS ricavi,
    ROUND(SUM(gross_profit), 2) AS margine,
    ROUND(
        100 * SUM(gross_profit) /
        NULLIF(SUM(net_revenue), 0), 2
    ) AS margine_percentuale
FROM portfolio.v_sales_lines
GROUP BY category
ORDER BY ricavi DESC;


-- =====================================================
-- ANALISI 5: TASSO DI RESO PER CATEGORIA
-- =====================================================
-- Obiettivo:
-- Individuare le categorie che presentano
-- una maggiore incidenza di prodotti restituiti.
--
-- KPI analizzati:
-- 1. Quantità totale di prodotti ordinati
-- 2. Quantità totale di prodotti restituiti
-- 3. Percentuale di prodotti restituiti
--
-- Business insight:
-- Un tasso di reso elevato può indicare
-- possibili criticità da approfondire.
--
-- Possibili azioni aziendali:
-- Analizzare le motivazioni dei resi,
-- migliorare le descrizioni dei prodotti
-- e verificare la qualità delle informazioni.

SELECT
    category,
    SUM(quantity) AS pezzi_venduti,
    COALESCE(
        SUM(quantity) FILTER (
            WHERE is_returned = TRUE
        ), 0
    ) AS pezzi_resi,
    ROUND(
        100.0 *
        COALESCE(
            SUM(quantity) FILTER (
                WHERE is_returned = TRUE
            ), 0
        ) /
        NULLIF(SUM(quantity), 0),
        2
    ) AS tasso_reso_percentuale
FROM portfolio.v_sales_lines
GROUP BY category
ORDER BY tasso_reso_percentuale DESC;


-- =====================================================
-- ANALISI 6: TOP 10 PRODOTTI PER FATTURATO
-- =====================================================
-- Obiettivo:
-- Identificare i dieci prodotti che generano
-- il maggior fatturato netto.
--
-- KPI analizzati:
-- 1. Ricavi netti per prodotto
-- 2. Margine lordo per prodotto
--
-- Business insight:
-- I prodotti con i maggiori ricavi non sono
-- necessariamente quelli che generano
-- i margini più elevati.
--
-- Possibili azioni aziendali:
-- Ottimizzare l'assortimento,
-- individuare i prodotti strategici
-- e valutare le politiche di prezzo.

SELECT
    product_name,
    category,
    ROUND(SUM(net_revenue), 2) AS ricavi,
    ROUND(SUM(gross_profit), 2) AS margine
FROM portfolio.v_sales_lines
GROUP BY product_name, category
ORDER BY ricavi DESC
LIMIT 10;
