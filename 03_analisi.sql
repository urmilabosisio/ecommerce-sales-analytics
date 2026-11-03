-- ANALISI DEI DATI SINTETICI: esegui UNA query selezionata per volta.
-- Prerequisito: eseguire 04_vista_powerbi.sql per creare la vista portfolio.v_sales_lines.

-- 1. KPI principali: ricavi netti, margine lordo, ordini, scontrino medio.
SELECT ROUND(SUM(net_revenue), 2) AS ricavi_netti_eur,
       ROUND(SUM(gross_profit), 2) AS margine_lordo_eur,
       ROUND(100 * SUM(gross_profit) / NULLIF(SUM(net_revenue),0), 2) AS margine_lordo_percentuale,
       COUNT(DISTINCT order_id) AS numero_ordini,
       ROUND(SUM(net_revenue) / NULLIF(COUNT(DISTINCT order_id),0), 2) AS scontrino_medio_eur
FROM portfolio.v_sales_lines;

-- 2. Fatturato e margine per categoria (ordina per ricavi decrescenti).
SELECT category,
       ROUND(SUM(net_revenue),2) AS ricavi_eur,
       ROUND(SUM(gross_profit),2) AS margine_lordo_eur,
       ROUND(100 * SUM(gross_profit) / NULLIF(SUM(net_revenue),0),2) AS margine_pct,
       ROUND(100.0 * SUM(CASE WHEN is_returned THEN quantity ELSE 0 END) / NULLIF(SUM(quantity),0),2) AS tasso_resi_unita_pct
FROM portfolio.v_sales_lines
GROUP BY category
ORDER BY ricavi_eur DESC;

-- 3. Andamento mensile: stagionalita' e marginalita'.
SELECT order_month,
       ROUND(SUM(net_revenue),2) AS ricavi_eur,
       ROUND(SUM(gross_profit),2) AS margine_eur,
       ROUND(100 * SUM(gross_profit)/NULLIF(SUM(net_revenue),0),2) AS margine_pct
FROM portfolio.v_sales_lines
GROUP BY order_month
ORDER BY order_month;

-- 4. Confronto tra canali (NON e' conversion rate e NON e' ROI: mancano visite/spese pubblicitarie).
SELECT channel,
       COUNT(DISTINCT order_id) AS ordini,
       ROUND(SUM(net_revenue),2) AS ricavi_eur,
       ROUND(SUM(gross_profit),2) AS margine_eur,
       ROUND(100 * SUM(gross_profit)/NULLIF(SUM(net_revenue),0),2) AS margine_pct,
       ROUND(100.0*SUM(CASE WHEN is_returned THEN quantity ELSE 0 END)/NULLIF(SUM(quantity),0),2) AS tasso_resi_unita_pct
FROM portfolio.v_sales_lines
GROUP BY channel
ORDER BY ricavi_eur DESC;

-- 5. Sconti e redditivita': associazioni descrittive, non relazioni causali.
WITH fasce AS (
    SELECT *,
           CASE WHEN discount_pct = 0 THEN '0%'
                WHEN discount_pct <= 10 THEN '1-10%'
                WHEN discount_pct <= 20 THEN '11-20%'
                ELSE 'oltre 20%' END AS fascia_sconto,
           CASE WHEN discount_pct = 0 THEN 1
                WHEN discount_pct <= 10 THEN 2
                WHEN discount_pct <= 20 THEN 3 ELSE 4 END AS ordine_fascia
    FROM portfolio.v_sales_lines
)
SELECT fascia_sconto,
       COUNT(*) AS righe_vendita,
       ROUND(SUM(net_revenue),2) AS ricavi_eur,
       ROUND(SUM(gross_profit),2) AS margine_eur,
       ROUND(100*SUM(gross_profit)/NULLIF(SUM(net_revenue),0),2) AS margine_pct
FROM fasce
GROUP BY fascia_sconto, ordine_fascia
ORDER BY ordine_fascia;

-- 6. Top 10 prodotti per ricavi.
SELECT product_name, category,
       ROUND(SUM(net_revenue),2) AS ricavi_eur,
       ROUND(SUM(gross_profit),2) AS margine_eur
FROM portfolio.v_sales_lines
GROUP BY product_name, category
ORDER BY ricavi_eur DESC
LIMIT 10;

-- 7. Clienti ricorrenti sul 2025 (basato su ordini, NON su acquisizioni).
WITH ordini_cliente AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS numero_ordini
    FROM portfolio.orders
    GROUP BY customer_id
)
SELECT COUNT(*) AS clienti_con_acquisti,
       COUNT(*) FILTER (WHERE numero_ordini >= 2) AS clienti_ricorrenti,
       ROUND(100.0 * COUNT(*) FILTER (WHERE numero_ordini >= 2) / NULLIF(COUNT(*),0),2) AS percentuale_ricorrenti
FROM ordini_cliente;

-- 8. Confronto per area (i clienti sono sintetici).
SELECT region, COUNT(DISTINCT order_id) AS ordini,
       ROUND(SUM(net_revenue),2) AS ricavi_eur
FROM portfolio.v_sales_lines
GROUP BY region
ORDER BY ricavi_eur DESC;
