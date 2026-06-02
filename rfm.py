import pandas as pd

# ==================================================
# LOAD CSV
# ==================================================
df = pd.read_csv(
    r'C:\Users\admin\Desktop\PROJECT 2026\Ecommerce-sales-analysis\sales.csv',
    encoding='ISO-8859-1'
)

# ==================================================
# CLEAN DATA
# ==================================================

# remove missing customers
df = df[df['CustomerID'].notna()]

# remove returns/cancellations
df = df[df['Quantity'] > 0]

# remove invalid prices
df = df[df['UnitPrice'] > 0]

# ==================================================
# CREATE REVENUE COLUMN
# ==================================================
df['Revenue'] = df['Quantity'] * df['UnitPrice']

# ==================================================
# CONVERT DATE
# ==================================================
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

# ==================================================
# CREATE SNAPSHOT DATE
# ==================================================
snapshot_date = df['InvoiceDate'].max() + pd.Timedelta(days=1)

# ==================================================
# BUILD RFM TABLE
# ==================================================
rfm = df.groupby('CustomerID').agg(

    Recency=(
        'InvoiceDate',
        lambda x: (snapshot_date - x.max()).days
    ),

    Frequency=(
        'InvoiceNo',
        'nunique'
    ),

    Monetary=(
        'Revenue',
        'sum'
    )

).reset_index()

# ==================================================
# CREATE RFM SCORES
# ==================================================

# Recency score
rfm['R_score'] = pd.qcut(
    rfm['Recency'].rank(method='first'),
    4,
    labels=[4, 3, 2, 1]
).astype(int)

# Frequency score
rfm['F_score'] = pd.qcut(
    rfm['Frequency'].rank(method='first'),
    4,
    labels=[1, 2, 3, 4]
).astype(int)

# Monetary score
rfm['M_score'] = pd.qcut(
    rfm['Monetary'].rank(method='first'),
    4,
    labels=[1, 2, 3, 4]
).astype(int)

# ==================================================
# CREATE FINAL RFM SCORE
# ==================================================
rfm['RFM_Score'] = (
    rfm['R_score'].astype(str) +
    rfm['F_score'].astype(str) +
    rfm['M_score'].astype(str)
)

# ==================================================
# CREATE CUSTOMER SEGMENTS
# ==================================================
def rfm_segment(row):

    r = row['R_score']
    f = row['F_score']
    m = row['M_score']

    if r >= 4 and f >= 4 and m >= 4:
        return 'Champions'

    elif r >= 3 and f >= 3:
        return 'Loyal Customers'

    elif r >= 4:
        return 'Recent Customers'

    elif r >= 3 and m >= 3:
        return 'Potential Loyalists'

    elif r <= 2 and f >= 3:
        return 'At Risk'

    elif r <= 2 and f <= 2:
        return 'Lost'

    else:
        return 'Need Attention'

rfm['Segment'] = rfm.apply(rfm_segment, axis=1)

# ==================================================
# EXPORT FINAL CSV FOR POWER BI
# ==================================================
rfm.to_csv(
    r'C:\Users\admin\Desktop\PROJECT 2026\Ecommerce-sales-analysis\rfm.csv',
    index=False
)

# ==================================================
# SUCCESS MESSAGE
# ==================================================
print('✅ rfm.csv created successfully!')
print('📁 File saved here:')
print(r'C:\Users\admin\Desktop\PROJECT 2026\Ecommerce-sales-analysis\rfm.csv')