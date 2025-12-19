import pandas as pd
from random import randint
from uuid import uuid4
from faker import Faker
import faker_commerce

faker = Faker(['fr_FR'])
faker.add_provider(faker_commerce.Provider)

class EcommerceDataGenerator:

    @staticmethod
    def generate_user(n):
        faker.unique.clear()
        user_list = []

        for _ in range(n):
            user_list.append({
                "id": faker.unique.random_int(min=1, max=10000),
                "username": faker.user_name(),
                "email": faker.unique.email(),
                "password": faker.password(length=10)
            })

        return pd.DataFrame(user_list)

    @staticmethod
    def generate_product(n):
        faker.unique.clear()
        product_list = []

        for _ in range(n):
            product_list.append({
                "id": faker.unique.random_int(min=1, max=10000),
                "name": faker.ecommerce_name(),
                "price": round(faker.pyfloat(min_value=5, max_value=500), 2),
                "stock": randint(0, 200)
            })

        return pd.DataFrame(product_list)


users_df = EcommerceDataGenerator.generate_user(1000)
products_df = EcommerceDataGenerator.generate_product(200)

users_df.to_csv("users.csv", index=False, encoding="utf-8")
products_df.to_csv("products.csv", index=False, encoding="utf-8")

print(users_df.head())
print(products_df.head())
