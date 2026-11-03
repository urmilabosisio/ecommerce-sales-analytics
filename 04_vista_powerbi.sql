-- VISTA ANALITICA, una riga per prodotto venduto in un ordine.
-- Assunzioni: una linea resa e' rimborsata integralmente e rivendibile;
-- i costi unitari sono fissi nel periodo; non includiamo spedizione,
-- IVA, marketing, salari, e altri costi operativi.
-- Come indicatore supplementare ipotizziamo un costo di gestione reso
-- di 4.50 EUR per riga resa. E' una ASSUNZIONE didattica, non un dato osservato.
CREATE OR REPLACE VIEW portfolio.v_sales_lines AS
SELECT
    oi.order_item_id,
    o.order_id,
    o.customer_id,
    o.order_date,
    date_trunc('month', o.order_date)::date AS order_month,
    o.channel,
    c.city,
    c.region,
    oi.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    p.unit_cost,
    oi.discount_pct,
    oi.is_returned,
    ROUND((oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS booked_line_value,
    CASE WHEN oi.is_returned THEN 0::numeric
         ELSE ROUND((oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2)
    END AS net_revenue,
    CASE WHEN oi.is_returned THEN 0::numeric
         ELSE ROUND(oi.quantity * p.unit_cost, 2)
    END AS cogs,
    CASE WHEN oi.is_returned THEN 0::numeric
         ELSE ROUND(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0), 2) - ROUND(oi.quantity * p.unit_cost, 2)
    END AS gross_profit,
    CASE WHEN oi.is_returned THEN 4.50::numeric ELSE 0::numeric END AS assumed_return_cost
FROM portfolio.order_items oi
JOIN portfolio.orders o ON o.order_id = oi.order_id
JOIN portfolio.products p ON p.product_id = oi.product_id
JOIN portfolio.customers c ON c.customer_id = o.customer_id;

-- Test rapido della vista:
SELECT * FROM portfolio.v_sales_lines LIMIT 10;
