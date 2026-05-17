# Firoz's Pizza Express | Data Analysis Project
### SQL + Python Analysis | Delivery Operations & Business Insights | By Aryan Rai

---

## Overview

This project performs an end-to-end data analysis of Firoz's Pizza Express — a fictional pizza delivery business. Using SQL (PostgreSQL) for structured querying and Python (Pandas, Matplotlib) for exploration and visualization, the project uncovers key insights around delivery performance, customer behaviour, runner efficiency, and revenue patterns.

---

## Key Business Questions Answered

- Which runners are most efficient, and how does delivery time vary?
- What are the most popular pizza types and customer ordering patterns?
- How does ingredient usage affect cost and waste?
- Which time slots and days generate the most orders?
- What is the overall revenue and delivery success rate?

---

## Key Findings

| Area | Finding |
|------|---------|
| Delivery Success | Not all orders were successfully delivered — cancellations impacted revenue |
| Runner Performance | Significant variation in average delivery time across runners |
| Popular Items | Meat Lovers and Vegetarian pizzas are top sellers by volume |
| Peak Hours | Evening time slots generate the highest order volume |
| Ingredient Waste | Certain exclusion/extras patterns indicate topping optimization opportunities |

---

## Tools & Technologies

| Tool | Usage |
|------|-------|
| PostgreSQL | Structured data querying & business logic |
| Python (Pandas) | Data cleaning, transformation, EDA |
| Matplotlib | Data visualisation |
| Jupyter Notebook | Analysis environment |

---

## SQL Skills Demonstrated

```sql
-- Example: Runner delivery efficiency
SELECT
    runner_id,
    COUNT(order_id) AS total_deliveries,
    ROUND(AVG(duration), 2) AS avg_delivery_time_mins,
    ROUND(AVG(distance), 2) AS avg_distance_km
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY avg_delivery_time_mins;
```

Key SQL concepts applied:
- `JOIN` (INNER, LEFT) across multiple tables
- Aggregate functions (`COUNT`, `SUM`, `AVG`, `ROUND`)
- `GROUP BY`, `ORDER BY`, `HAVING`
- String functions for data cleaning (`TRIM`, `LOWER`, `REPLACE`)
- `CASE WHEN` for conditional logic
- CTEs (`WITH`) for readable multi-step queries
- Window functions (`ROW_NUMBER`, `RANK`)

---

## Python Analysis Highlights

```python
import pandas as pd
import matplotlib.pyplot as plt

# Load and clean data
df = pd.read_csv('pizza_orders.csv')
df.dropna(subset=['order_time', 'runner_id'], inplace=True)

# Orders by hour
df['hour'] = pd.to_datetime(df['order_time']).dt.hour
df.groupby('hour')['order_id'].count().plot(kind='bar', title='Orders by Hour')
plt.xlabel('Hour of Day')
plt.ylabel('Number of Orders')
plt.tight_layout()
plt.show()
```

Key Python techniques applied:
- Data cleaning with Pandas (null handling, type conversion, string normalization)
- Exploratory Data Analysis (EDA)
- Groupby aggregations and pivot tables
- Visualization with Matplotlib (bar charts, line plots, histograms)

---

## Dataset Description

The project uses a relational dataset with the following tables:

| Table | Description |
|-------|-------------|
| `customer_orders` | Each pizza ordered per customer with exclusions/extras |
| `runner_orders` | Delivery details — runner, distance, duration, cancellation |
| `pizza_names` | Pizza ID to name mapping |
| `pizza_recipes` | Standard toppings per pizza |
| `pizza_toppings` | Topping ID to name mapping |
| `runners` | Runner ID and registration date |

---

## File Structure

```
firoz-pizza-express-analysis/
│
├── Firoz's_pizza_express.ipynb        # Full Python analysis notebook
├── Firoz's_pizza_express_sql.sql      # All SQL queries used in analysis
├── Firoz's Pizza Express.pdf          # Project report / documentation
├── Firoz's_Pizza_Dataset.pdf          # Dataset reference and schema
└── README.md                          # Project documentation
```

---

## How to Use

1. **SQL Analysis:** Open `Firoz's_pizza_express_sql.sql` in any PostgreSQL client (pgAdmin, DBeaver) and run queries sequentially.
2. **Python Analysis:** Open `Firoz's_pizza_express.ipynb` in Jupyter Notebook or VS Code. Run all cells top to bottom.
3. **Report:** Open `Firoz's Pizza Express.pdf` for the complete project write-up and findings.

---

## Author

**Aryan Rai**  
BS Data Science — IIT Madras  
Data Analytics Certification — NDMIT Varanasi  
📧 aryanrai2555@gmail.com  
📞 9670262555  
🔗 [LinkedIn](https://www.linkedin.com/in/aryan-rai-590549310)

---

*Built as part of NDMIT Data Analytics Certification coursework.*
