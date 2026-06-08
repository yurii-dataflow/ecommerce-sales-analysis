# 📊 E-Commerce Sales Analysis / E-Commerce Verkaufsanalyse

**Author / Autor:** Yurii Oleschuk  
**Dataset / Datensatz:** UCI Online Retail (541,909 transactions · Dec 2010 – Dec 2011)  
**Stack:** Python · SQL (SQLite) · Power BI · GitHub  

---

## 🔍 Project Overview / Projektübersicht

### EN English
This project demonstrates a full-cycle data analysis process using a real e-commerce dataset.
The goal is to extract actionable business insights, identify trends, and provide concrete recommendations.

**Covers:** Data cleaning · SQL analysis · Python EDA · Cohort analysis · RFM segmentation · Forecasting · Dashboard

### DE Deutsch
Dieses Projekt demonstriert einen vollständigen Datenanalyseprozess anhand eines realen E-Commerce-Datensatzes.
Ziel ist es, umsetzbare Geschäftserkenntnisse zu gewinnen, Trends zu identifizieren und konkrete Empfehlungen zu geben.

**Umfasst:** Datenbereinigung · SQL-Analyse · Python-EDA · Kohortenanalyse · RFM-Segmentierung · Prognose · Dashboard

---

## 🎯 Business Questions / Geschäftsfragen

| # | EN English | DE Deutsch |
|---|---|---|
| 1 | Which products drive the most revenue? | Welche Produkte generieren den meisten Umsatz? |
| 2 | How does customer retention change over time? | Wie verändert sich die Kundenbindung über die Zeit? |
| 3 | What are the key customer segments? | Welche Kundensegmente gibt es? |
| 4 | When do customers buy most? | Wann kaufen Kunden am häufigsten? |
| 5 | What is the revenue forecast for next quarter? | Wie lautet die Umsatzprognose für das nächste Quartal? |

---

## 🔍 Key Findings / Wichtigste Erkenntnisse

| EN Finding | DE Erkenntnis | Detail |
|---|---|---|
| Pareto confirmed | Pareto bestätigt | Top ~10% of SKUs → 80% of revenue |
| Retention problem | Bindungsproblem | Only ~25% of customers return after month 1 |
| Champions are critical | Champions sind entscheidend | Highest revenue at near-zero acquisition cost |
| Q4 seasonality | Q4-Saisonalität | November is the clear revenue peak |
| B2B buying pattern | B2B-Kaufmuster | Peak hours: Tue–Thu 9:00–12:00 |
| International upside | Internationales Potenzial | Netherlands, EIRE, Germany show high AOV |

---

## 💡 Recommendations / Empfehlungen

| Priority / Priorität | EN Action | DE Maßnahme |
|---|---|---|
| 🔴 High / Hoch | 30-day post-purchase email sequence | 30-Tage-E-Mail-Sequenz nach dem Kauf |
| 🔴 High / Hoch | VIP loyalty programme for Champions | VIP-Treueprogramm für Champions |
| 🟡 Med / Mittel | Pre-stock top SKUs by October | Top-SKUs bis Oktober bevorraten |
| 🟡 Med / Mittel | Win-back campaign for At Risk segment | Rückgewinnungskampagne für At-Risk-Segment |
| 🟢 Low / Niedrig | B2B outreach in Netherlands & EIRE | B2B-Akquise in Niederlande & Irland |
| 🟢 Low / Niedrig | Schedule emails Tue–Thu 9:00–11:00 | E-Mails Di–Do 9:00–11:00 planen |

---

## 🛠️ Tech Stack

| Tool | EN Purpose | 🇩🇪 Zweck |
|---|---|---|
| Python (Pandas, Matplotlib, Seaborn, SciPy) | Data cleaning, EDA, cohort, RFM, forecast | Datenbereinigung, EDA, Kohortenanalyse, RFM, Prognose |
| SQL (SQLite) | Aggregations, window functions, CTEs | Aggregationen, Fensterfunktionen, CTEs |
| Power BI | Interactive dashboard with DAX measures | Interaktives Dashboard mit DAX-Kennzahlen |
| GitHub | Version control | Versionskontrolle |

---

## 📂 Project Structure / Projektstruktur

```
sales-analysis/
│
├── data/
│   └── sales.csv                    # EN Raw dataset / DE Rohdatensatz
│
├── python/
│   └── analysis.ipynb               # EN Full Python analysis / DE Vollständige Python-Analyse
│
├── sql/
│   ├── sql.ipynb                    # EN SQL via Python/SQLite / DE SQL über Python/SQLite
│   └── queries.sql                  # EN Raw SQL queries / DE SQL-Abfragen
│
├── dashboard/
│   ├── dashboard.pbix               # EN Power BI file / DE Power BI Datei
│   └── screenshot.pdf               # EN Dashboard preview / DE Dashboard-Vorschau
│
└── README.md
```

---

## 🧹 Data Cleaning Decisions / Datenbereinigungsentscheidungen

| EN Issue | DE Problem | Scale / Umfang | Action / Maßnahme |
|---|---|---|---|
| Negative Quantity (returns) | Negative Menge (Rücksendungen) | 10,624 rows | Removed / Entfernt |
| Zero / negative UnitPrice | Null / negativer Preis | 2,517 rows | Removed / Entfernt |
| Missing CustomerID | Fehlende Kunden-ID | 135,080 rows | Removed for customer analysis / Für Kundenanalyse entfernt |
| Non-product entries | Nicht-Produkteinträge | ~200 rows | Filtered by keyword / Nach Keyword gefiltert |
| Duplicates | Duplikate | minimal | Dropped / Entfernt |

**Clean dataset / Bereinigter Datensatz: ~391,000 rows (72% retained / behalten)**

---

## 📊 Analysis Modules / Analysemodule

| # | EN Module | DE Modul |
|---|---|---|
| 1 | KPI Dashboard | KPI-Dashboard |
| 2 | Revenue Trend & Seasonality | Umsatztrend & Saisonalität |
| 3 | Day × Hour Sales Heatmap | Tag × Stunden Umsatz-Heatmap |
| 4 | Top Products + Pareto Analysis | Top-Produkte + Pareto-Analyse |
| 5 | Cohort Retention Analysis | Kohortenanalyse zur Kundenbindung |
| 6 | RFM Customer Segmentation | RFM-Kundensegmentierung |
| 7 | Geographic Analysis | Geografische Analyse |
| 8 | Statistical Analysis (Correlation, Distribution) | Statistische Analyse (Korrelation, Verteilung) |
| 9 | Sales Forecast — Linear Trend | Umsatzprognose — Linearer Trend |

---

## 🚀 How to Run / Ausführungsanleitung

### 1. Clone repository / Repository klonen
```bash
git clone <your-repo-link>
cd sales-analysis
```

### 2. Install dependencies / Abhängigkeiten installieren
```bash
pip install pandas matplotlib seaborn scipy
```

### 3. Run Python analysis / Python-Analyse ausführen
```bash
# Open / Öffnen:
python/analysis.ipynb
# Then: Kernel -> Restart & Run All
```

### 4. Run SQL analysis / SQL-Analyse ausführen
```bash
# Open / Öffnen:
sql/sql.ipynb
# Then: Kernel -> Restart & Run All
# OR / ODER use queries from / Abfragen aus:
sql/queries.sql
```

---

## 📬 Contacts / Kontakt


- **GitHub:** https://github.com/yurii-dataflow
- **Email:** oleshchukyurii@gmail.com

---

## ⭐ Conclusion / Fazit

### EN English
This project demonstrates practical data analysis skills including data cleaning, SQL with window functions, Python EDA, cohort analysis, RFM segmentation, statistical analysis, and business-oriented thinking. It reflects the ability to turn raw data into actionable insights — a key requirement for a Data Analyst role.

### DE Deutsch
Dieses Projekt demonstriert praktische Datenanalysefähigkeiten: Datenbereinigung, SQL mit Fensterfunktionen, Python-EDA, Kohortenanalyse, RFM-Segmentierung, statistische Analyse und geschäftsorientiertes Denken. Es zeigt die Fähigkeit, Rohdaten in umsetzbare Erkenntnisse umzuwandeln — eine zentrale Anforderung für eine Data-Analyst-Stelle.
