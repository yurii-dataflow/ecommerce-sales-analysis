-- ============================================================
-- 📊 E-COMMERCE SALES ANALYSIS / E-COMMERCE VERKAUFSANALYSE
-- Author / Autor: Yurii Oleschuk
-- DB: SQLite | Table / Tabelle: sales
-- ============================================================
-- EN Data notes:
--   Negative Quantity = returns  -> excluded (Quantity > 0)
--   UnitPrice = 0 = bad data    -> excluded (UnitPrice > 0)
--   POSTAGE / MANUAL etc.       -> excluded via Description filter
-- DE Datenhinweise:
--   Negative Menge = Rücksendungen -> ausgeschlossen (Quantity > 0)
--   UnitPrice = 0 = ungültige Daten -> ausgeschlossen (UnitPrice > 0)
--   POSTAGE / MANUAL usw.          -> über Beschreibungsfilter ausgeschlossen
-- ============================================================


-- ============================================================
-- 0. BASE VIEW / BASISANSICHT
-- ============================================================

-- EN Use this view as the foundation for all queries below
-- DE Diese Ansicht als Grundlage für alle folgenden Abfragen verwenden

CREATE VIEW IF NOT EXISTS clean_sales AS
SELECT *,
       Quantity * UnitPrice AS Revenue
FROM   sales
WHERE  Quantity  > 0
  AND  UnitPrice > 0
  AND  CustomerID IS NOT NULL
  AND  Description NOT LIKE '%POSTAGE%'
  AND  Description NOT LIKE '%DOTCOM%'
  AND  Description NOT LIKE '%MANUAL%'
  AND  Description NOT LIKE '%BANK CHARGES%';


-- ============================================================
-- 1. KPI SUMMARY / KENNZAHLENÜBERSICHT
-- ============================================================

SELECT
    ROUND(SUM(Revenue), 2)                               AS total_revenue,
    COUNT(DISTINCT InvoiceNo)                            AS total_orders,
    COUNT(DISTINCT CustomerID)                           AS unique_customers,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2)  AS avg_order_value,
    ROUND(SUM(Revenue) / COUNT(DISTINCT CustomerID), 2) AS avg_revenue_per_customer
FROM clean_sales;

-- EN Insight: Single-row KPI snapshot — ideal for a dashboard header card.
-- DE Erkenntnis: Einzeilige KPI-Übersicht — ideal für Dashboard-Header.


-- ============================================================
-- 2. TOP 10 PRODUCTS BY REVENUE / TOP-10-PRODUKTE NACH UMSATZ
-- ============================================================

WITH product_revenue AS (
    SELECT
        Description,
        ROUND(SUM(Revenue), 2)    AS revenue,
        SUM(Quantity)             AS total_qty,
        COUNT(DISTINCT InvoiceNo) AS order_count
    FROM   clean_sales
    GROUP  BY Description
),
total AS (
    SELECT SUM(revenue) AS grand_total FROM product_revenue
)
SELECT
    p.Description,
    p.revenue,
    p.total_qty,
    p.order_count,
    ROUND(p.revenue * 100.0 / t.grand_total, 2) AS revenue_pct,
    ROUND(SUM(p.revenue) OVER (ORDER BY p.revenue DESC)
          * 100.0 / t.grand_total, 2)            AS cumulative_pct
FROM   product_revenue p, total t
ORDER  BY p.revenue DESC
LIMIT  10;

-- EN Insight: cumulative_pct shows the Pareto effect.
--    Top products reaching 80% should be prioritised in inventory and marketing.
-- DE Erkenntnis: cumulative_pct zeigt den Pareto-Effekt.
--    Produkte, die 80% erreichen, in Lager und Marketing priorisieren.


-- ============================================================
-- 3. MONTHLY REVENUE WITH MoM GROWTH / MONATSUMSATZ MIT MoM-WACHSTUM
-- ============================================================

WITH monthly AS (
    SELECT
        STRFTIME('%Y-%m', InvoiceDate)    AS month,
        ROUND(SUM(Revenue), 2)            AS revenue,
        COUNT(DISTINCT InvoiceNo)         AS orders,
        COUNT(DISTINCT CustomerID)        AS customers
    FROM   clean_sales
    GROUP  BY month
)
SELECT
    month,
    revenue,
    orders,
    customers,
    LAG(revenue) OVER (ORDER BY month)                       AS prev_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / LAG(revenue) OVER (ORDER BY month), 1
    )                                                         AS mom_growth_pct
FROM   monthly
ORDER  BY month;

-- EN Insight: MoM growth reveals acceleration/deceleration of the business.
--    Negative growth after a peak signals end of seasonal demand.
-- DE Erkenntnis: MoM-Wachstum zeigt Beschleunigung/Verlangsamung des Geschäfts.
--    Negatives Wachstum nach dem Höhepunkt signalisiert das Ende der Saison.


-- ============================================================
-- 4. AVERAGE ORDER VALUE / DURCHSCHNITTLICHER BESTELLWERT
-- ============================================================

-- EN Overall AOV / DE Gesamt-Ø-Bestellwert
SELECT ROUND(AVG(order_value), 2) AS overall_aov
FROM (
    SELECT InvoiceNo, SUM(Revenue) AS order_value
    FROM   clean_sales
    GROUP  BY InvoiceNo
);

-- EN AOV by country (excl. UK) / DE Ø-Bestellwert nach Land (ohne UK)
WITH order_vals AS (
    SELECT InvoiceNo, Country, SUM(Revenue) AS order_value
    FROM   clean_sales
    GROUP  BY InvoiceNo, Country
)
SELECT
    Country,
    COUNT(*)                    AS orders,
    ROUND(AVG(order_value), 2)  AS aov,
    ROUND(SUM(order_value), 2)  AS total_revenue
FROM   order_vals
WHERE  Country != 'United Kingdom'
GROUP  BY Country
ORDER  BY aov DESC
LIMIT  10;

-- EN Insight: High-AOV countries indicate B2B wholesale buyers.
--    Target with volume discounts and direct sales outreach.
-- DE Erkenntnis: Länder mit hohem AOV haben B2B-Großhandelskäufer.
--    Mit Mengenrabatten und direkter Vertriebsansprache ansprechen.


-- ============================================================
-- 5. TOP 10 CUSTOMERS / TOP-10-KUNDEN
-- ============================================================

SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2)                              AS total_spent,
    COUNT(DISTINCT InvoiceNo)                           AS orders_count,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS customer_aov,
    MIN(DATE(InvoiceDate))                              AS first_purchase,
    MAX(DATE(InvoiceDate))                              AS last_purchase
FROM   clean_sales
GROUP  BY CustomerID
ORDER  BY total_spent DESC
LIMIT  10;

-- EN Insight: Top customers are likely B2B wholesale buyers.
--    Build dedicated key account management relationships.
-- DE Erkenntnis: Top-Kunden sind wahrscheinlich B2B-Großhandelskäufer.
--    Dedizierte Key-Account-Beziehungen aufbauen.


-- ============================================================
-- 6. RFM SEGMENTATION / RFM-SEGMENTIERUNG
-- ============================================================

WITH rfm_raw AS (
    SELECT
        CustomerID,
        CAST(JULIANDAY('2011-12-10') - JULIANDAY(MAX(InvoiceDate)) AS INTEGER) AS recency_days,
        COUNT(DISTINCT InvoiceNo)                                               AS frequency,
        ROUND(SUM(Revenue), 2)                                                  AS monetary
    FROM   clean_sales
    GROUP  BY CustomerID
),
rfm_scored AS (
    SELECT *,
        -- EN R: lower recency = higher score / DE R: kürzere Aktualität = höhere Bewertung
        CASE
            WHEN recency_days <= 30  THEN 4
            WHEN recency_days <= 90  THEN 3
            WHEN recency_days <= 180 THEN 2
            ELSE 1
        END AS r_score,
        -- EN F: higher frequency = higher score / DE F: höhere Häufigkeit = höhere Bewertung
        CASE
            WHEN frequency >= 10 THEN 4
            WHEN frequency >= 5  THEN 3
            WHEN frequency >= 2  THEN 2
            ELSE 1
        END AS f_score,
        -- EN M: higher monetary = higher score / DE M: höherer Geldwert = höhere Bewertung
        CASE
            WHEN monetary >= 5000 THEN 4
            WHEN monetary >= 1000 THEN 3
            WHEN monetary >= 300  THEN 2
            ELSE 1
        END AS m_score
    FROM rfm_raw
),
segmented AS (
    SELECT *,
        CASE
            WHEN r_score = 4 AND f_score = 4   THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3  THEN 'Loyal Customers'
            WHEN r_score = 4                   THEN 'Recent Customers'
            WHEN r_score = 3                   THEN 'Potential Loyalists'
            WHEN r_score = 2 AND f_score >= 2  THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
            ELSE 'Need Attention'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*)                     AS customers,
    ROUND(AVG(recency_days), 0)  AS avg_recency,
    ROUND(AVG(frequency), 1)     AS avg_frequency,
    ROUND(AVG(monetary), 0)      AS avg_monetary,
    ROUND(SUM(monetary), 0)      AS total_revenue
FROM   segmented
GROUP  BY segment
ORDER  BY total_revenue DESC;

-- EN Insight: Champions and Loyal Customers generate the most revenue
--    at the lowest acquisition cost. Protect these segments first.
-- DE Erkenntnis: Champions und treue Kunden generieren den höchsten Umsatz
--    bei niedrigsten Akquisitionskosten. Diese Segmente zuerst schützen.


-- ============================================================
-- 7. COHORT RETENTION / KOHORTENRETENTION
-- ============================================================

WITH first_purchase AS (
    SELECT
        CustomerID,
        STRFTIME('%Y-%m', MIN(InvoiceDate)) AS cohort_month
    FROM   clean_sales
    GROUP  BY CustomerID
),
customer_activity AS (
    SELECT
        s.CustomerID,
        STRFTIME('%Y-%m', s.InvoiceDate) AS activity_month,
        f.cohort_month
    FROM      clean_sales s
    JOIN      first_purchase f ON s.CustomerID = f.CustomerID
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT CustomerID) AS cohort_customers
    FROM   first_purchase
    GROUP  BY cohort_month
)
SELECT
    a.cohort_month,
    cs.cohort_customers,
    COUNT(DISTINCT CASE WHEN a.activity_month > a.cohort_month
                        THEN a.CustomerID END)       AS returned,
    ROUND(
        COUNT(DISTINCT CASE WHEN a.activity_month > a.cohort_month
                            THEN a.CustomerID END)
        * 100.0 / cs.cohort_customers, 1
    )                                                AS retention_pct
FROM      customer_activity a
JOIN      cohort_size cs ON a.cohort_month = cs.cohort_month
GROUP BY  a.cohort_month, cs.cohort_customers
ORDER BY  a.cohort_month;

-- EN Insight: Cohorts with <20% retention need immediate intervention.
--    A 30-day post-purchase email sequence is the highest-ROI action.
-- DE Erkenntnis: Kohorten mit <20% Bindungsrate brauchen sofortige Maßnahmen.
--    Eine 30-Tage-E-Mail-Sequenz nach dem Kauf hat den höchsten ROI.


-- ============================================================
-- 8. DAY x HOUR HEATMAP / TAG x STUNDEN HEATMAP
-- ============================================================

SELECT
    CASE CAST(STRFTIME('%w', InvoiceDate) AS INTEGER)
        WHEN 1 THEN 'Mon' WHEN 2 THEN 'Tue' WHEN 3 THEN 'Wed'
        WHEN 4 THEN 'Thu' WHEN 5 THEN 'Fri' WHEN 6 THEN 'Sat'
    END                                          AS day_of_week,
    CAST(STRFTIME('%H', InvoiceDate) AS INTEGER) AS hour_of_day,
    ROUND(SUM(Revenue), 0)                       AS revenue,
    COUNT(DISTINCT InvoiceNo)                    AS orders
FROM   clean_sales
GROUP  BY day_of_week, hour_of_day
ORDER  BY day_of_week, hour_of_day;

-- EN Insight: Peak hours reveal when customers are most engaged.
--    Schedule email sends and paid campaigns during peak windows.
-- DE Erkenntnis: Spitzenstunden zeigen, wann Kunden am aktivsten sind.
--    E-Mails und bezahlte Kampagnen während der Spitzenzeiten planen.


-- ============================================================
-- 9. PRODUCT RETURN RATE / PRODUKTRÜCKGABEQUOTE
-- ============================================================

WITH sold AS (
    SELECT Description, SUM(Quantity) AS qty_sold
    FROM   sales
    WHERE  Quantity > 0 AND UnitPrice > 0
    GROUP  BY Description
),
returned AS (
    SELECT Description, ABS(SUM(Quantity)) AS qty_returned
    FROM   sales
    WHERE  Quantity < 0
    GROUP  BY Description
)
SELECT
    s.Description,
    s.qty_sold,
    COALESCE(r.qty_returned, 0)                                 AS qty_returned,
    ROUND(COALESCE(r.qty_returned, 0) * 100.0 / s.qty_sold, 1) AS return_rate_pct
FROM      sold s
LEFT JOIN returned r ON s.Description = r.Description
WHERE     s.qty_sold >= 50
ORDER BY  return_rate_pct DESC
LIMIT     15;

-- EN Insight: High return rate products signal quality or expectation mismatch.
--    Investigate and improve product descriptions or supplier quality.
-- DE Erkenntnis: Hohe Rückgabequoten signalisieren Qualitätsprobleme.
--    Produktbeschreibungen verbessern oder Lieferantenqualität prüfen.


-- ============================================================
-- 10. GEOGRAPHIC REVENUE / GEOGRAFISCHE UMSATZVERTEILUNG
-- ============================================================

WITH country_stats AS (
    SELECT
        Country,
        ROUND(SUM(Revenue), 0)             AS revenue,
        COUNT(DISTINCT CustomerID)         AS customers,
        COUNT(DISTINCT InvoiceNo)          AS orders,
        ROUND(SUM(Revenue)
            / COUNT(DISTINCT InvoiceNo),2) AS aov
    FROM   clean_sales
    GROUP  BY Country
),
total AS (SELECT SUM(revenue) AS grand_total FROM country_stats)
SELECT
    c.Country,
    c.revenue,
    c.customers,
    c.orders,
    c.aov,
    ROUND(c.revenue * 100.0 / t.grand_total, 2) AS revenue_share_pct
FROM   country_stats c, total t
ORDER  BY c.revenue DESC
LIMIT  15;

-- EN Insight: UK dominates (~80% revenue). Netherlands, EIRE, Germany
--    are high-value international growth opportunities.
-- DE Erkenntnis: UK dominiert (~80% Umsatz). Niederlande, Irland und Deutschland
--    sind hochwertige internationale Wachstumschancen.
