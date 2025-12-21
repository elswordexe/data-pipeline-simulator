import pandas as pd
import random
from random import randint
from faker import Faker
import faker_commerce

faker = Faker(['fr_FR'])
faker.add_provider(faker_commerce.Provider)

class EcommerceDataGenerator:

    @staticmethod
    def generate_user(n):
        faker.unique.clear()
        users = []

        for _ in range(n):
            users.append({
                "id": faker.unique.random_int(min=1, max=10000),
                "username": faker.user_name(),
                "email": faker.unique.email(),
                "password": faker.password(length=10)
            })

        return pd.DataFrame(users)

    @staticmethod
    def generate_product(n):
        faker.unique.clear()
        products = []

        for _ in range(n):
            products.append({
                "id": faker.unique.random_int(min=1, max=10000),
                "name": faker.ecommerce_name(),
                "price": round(faker.pyfloat(min_value=5, max_value=500), 2),
                "stock": randint(0, 200)
            })

        return pd.DataFrame(products)

    @staticmethod
    def generate_orders(n, users_df):
        faker.unique.clear()
        orders = []

        for _ in range(n):
            order_date = faker.date_time_this_year()

            # Weekend boost (+30%)
            if order_date.weekday() >= 5 and random.random() < 0.3:
                continue

            status = random.choices(
                ["completed", "cancelled", "pending", "refunded"],
                weights=[70, 15, 10, 5],
                k=1
            )[0]

            is_fraud = random.random() < 0.02

            orders.append({
                "id": faker.unique.random_int(min=1, max=100000),
                "user_id": users_df.sample(1).iloc[0]["id"],
                "status": status,
                "order_date": order_date,
                "is_fraud": is_fraud,
                "total_amount": 0.0
            })

        return pd.DataFrame(orders)

    @staticmethod
    def generate_order_items(orders_df, products_df):
        order_items = []

        for _, order in orders_df.iterrows():
            if order["status"] == "cancelled":
                continue

            n_items = randint(1, 5)
            total = 0

            for _ in range(n_items):
                product = products_df.sample(1).iloc[0]
                quantity = randint(1, 3)
                price = round(product["price"], 2)

                total += quantity * price

                order_items.append({
                    "id": faker.unique.random_int(min=1, max=100000),
                    "order_id": order["id"],
                    "product_id": product["id"],
                    "quantity": quantity,
                    "price": price
                })

            orders_df.loc[
                orders_df["id"] == order["id"], "total_amount"
            ] = round(total, 2)

        return pd.DataFrame(order_items), orders_df

users_df = EcommerceDataGenerator.generate_user(1000)
products_df = EcommerceDataGenerator.generate_product(200)

orders_df = EcommerceDataGenerator.generate_orders(5000, users_df)
order_items_df, orders_df = EcommerceDataGenerator.generate_order_items(
    orders_df, products_df
)

users_df.to_csv("users.csv", index=False)
products_df.to_csv("products.csv", index=False)
orders_df.to_csv("orders.csv", index=False)
order_items_df.to_csv("order_items.csv", index=False)

print(users_df.head())
print(products_df.head())
print(orders_df.head())
