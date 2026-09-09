# E-Commerce Sales Analytics - Python Analysis
import pandas as pd
import matplotlib.pyplot as plt

orders = pd.read_csv("../data/ecommerce_orders.csv", parse_dates=["order_date"])

valid = orders[orders["order_status"] != "Cancelled"].copy()

print("Total Sales:", round(valid["sales"].sum(),2))
print("Total Profit:", round(valid["profit"].sum(),2))
print("Orders:", valid["order_id"].nunique())
print("Customers:", valid["customer_id"].nunique())
print("Profit Margin %:", round(valid["profit"].sum()/valid["sales"].sum()*100,2))

monthly = valid.groupby(valid["order_date"].dt.to_period("M")).agg(
    sales=("sales","sum"),
    profit=("profit","sum"),
    orders=("order_id","nunique")
).reset_index()
monthly["order_date"] = monthly["order_date"].dt.to_timestamp()

plt.figure(figsize=(10,5))
plt.plot(monthly["order_date"], monthly["sales"])
plt.title("Monthly Revenue Trend")
plt.xlabel("Month")
plt.ylabel("Sales")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

category = valid.groupby("category").agg(
    sales=("sales","sum"),
    profit=("profit","sum"),
    units=("quantity","sum")
).sort_values("sales", ascending=False)

print(category)

plt.figure(figsize=(9,5))
category["sales"].plot(kind="bar")
plt.title("Sales by Category")
plt.xlabel("Category")
plt.ylabel("Sales")
plt.xticks(rotation=35)
plt.tight_layout()
plt.show()

top_products = valid.groupby(["product_id","product_name"]).agg(
    sales=("sales","sum"),
    profit=("profit","sum"),
    units=("quantity","sum")
).sort_values("sales", ascending=False).head(10)

print(top_products)

region = valid.groupby("region").agg(
    sales=("sales","sum"),
    profit=("profit","sum"),
    orders=("order_id","nunique")
).sort_values("sales", ascending=False)

print(region)
