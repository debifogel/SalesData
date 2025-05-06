# Logsys BI Tasks - README

## Overview
This project includes SQL queries, view creation, data summarization, and optimization algorithms based on a mock business database provided by Logsys. The tasks are divided into three parts:

---

## Part A - SQL Queries

### Tables Used:
- `SalesHeader`: Invoice headers with discount and salesperson.
- `SalesLine`: Line items per invoice.
- `Items`: Product categories.
- `SalesPerson`: Salespeople details.

### Tasks:
1. **Item Summary Report**: Query showing quantity sold, total sales, and number of invoices per item.
2. **Invoice Filter**: Query showing invoices that include both item 3611010 and 3611600.
3. **Full Catalog Sellers**: Query listing salespeople who sold every item in the catalog.
4. **Variety vs. Quantity**: 
   - Identify the salesperson who sold the most diverse range of items.
   - List items sold by this person but not by the top-quantity seller.
5. **Below Average Sales**:
   - For each salesperson, find items sold below their average.
   - Show average sales per item and total sales.

> **Notes**:
- Use SQL Server syntax.
- Total sales is the value **after discount**.

---

## Part B - Monthly Sales Summary from CSV

### Input:
- `SalesData.csv` with historical sales data (must be imported into SQL Server).

### View Creation:
Create a `VIEW` that shows, for each product and month:
- Monthly quantity sold.
- Sum of quantities over the **last 12 calendar months** (even with zero sales).
- Sum of quantities over the **last 12 months with sales only**.

### Considerations:
- Handle months without sales.
- Use recursive CTEs if needed (e.g., `dbo.AutoGenerate()`).
- No use of loops.

### Output View Format:
| Product | Year-Month | MonthlyQty | SumLast12CalMonths | SumLast12SalesMonths |
|---------|------------|------------|---------------------|------------------------|

---

## Part C - Operational Cost Optimization

### Problem:
Given monthly operating costs for two cities (Jerusalem and Bnei Brak), and a fixed switching cost between them, find the **minimum total cost** plan for operating across several months.

### Requirements:
1. **Stored Procedure**:
   - Input: `@switchCost INT`
   - Output: Total minimal cost (no need to return the path).
2. **Explanation**:
   - Include a brief, free-text explanation of the chosen approach and why it works.
   - Support two scenarios:
     - One switch allowed at most.
     - Unlimited switches.

---

## Deliverables
- SQL queries for Part A.
- SQL `VIEW` definition for Part B.
- SQL stored procedure for Part C.
- Optional: documentation/explanation as `.md` or `.pdf`.

## Tools & Environment
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)

---