"""Genera un dataset didattico SINTETICO di vendite e-commerce (seed fissa)."""
from __future__ import annotations
from datetime import date, timedelta
from pathlib import Path
import csv
import random

random.seed(20261102)
ROOT = Path(__file__).resolve().parent
DATA = ROOT / "dati"
DATA.mkdir(exist_ok=True)

def write_csv(filename, columns, rows):
    path = DATA / filename
    with path.open("w", newline="", encoding="utf-8-sig") as file:
        w = csv.writer(file)
        w.writerow(columns)
        w.writerows(rows)
    print(f"Creato {path.name}: {len(rows)} righe")

places = [
    ("Milano", "Lombardia", 17), ("Roma", "Lazio", 14),
    ("Torino", "Piemonte", 10), ("Bologna", "Emilia-Romagna", 8),
    ("Firenze", "Toscana", 8), ("Napoli", "Campania", 9),
    ("Verona", "Veneto", 8), ("Padova", "Veneto", 7),
    ("Monza", "Lombardia", 9), ("Como", "Lombardia", 5),
    ("Bari", "Puglia", 5),
]
cty = [p[:2] for p in places]
weights = [p[2] for p in places]
start_registered = date(2024, 1, 1)
customers = []
for i in range(1, 801):
    city, region = random.choices(cty, weights=weights, k=1)[0]
    joined = start_registered + timedelta(days=random.randrange(365))
    customers.append((i, city, region, joined.isoformat()))
write_csv("customers.csv", ["customer_id", "city", "region", "registration_date"], customers)

products_spec = {
    "Beauty & Care": [
        ("Crema viso", 29.90), ("Siero idratante", 35.90), ("Kit skincare", 59.90),
        ("Detergente delicato", 17.90), ("Maschera viso", 22.90), ("Olio corpo", 24.90),
        ("Set beauty", 44.90),
    ],
    "Casa & Lifestyle": [
        ("Candela profumata", 19.90), ("Lampada da tavolo", 54.90), ("Diffusore ambiente", 38.90),
        ("Tazza ceramica", 15.90), ("Plaid morbido", 49.90), ("Organizer scrivania", 26.90),
        ("Set cucina", 39.90),
    ],
    "Moda & Accessori": [
        ("Borsa mini", 64.90), ("Portafoglio", 42.90), ("Cintura", 29.90),
        ("Sciarpa", 34.90), ("Occhiali moda", 39.90), ("Pochette", 27.90),
        ("Borsa shopper", 69.90),
    ],
    "Fitness & Benessere": [
        ("Tappetino yoga", 39.90), ("Borraccia termica", 26.90), ("Elastici fitness", 18.90),
        ("Set massaggio", 48.90), ("Fascia sportiva", 15.90), ("Rullo stretching", 32.90),
        ("Kit relax", 54.90),
    ],
    "Tech & Ufficio": [
        ("Supporto laptop", 44.90), ("Mouse wireless", 32.90), ("Caricatore USB", 22.90),
        ("Tastiera compatta", 59.90), ("Cuffie ufficio", 79.90), ("Agenda digitale", 49.90),
        ("Lampada LED USB", 29.90),
    ],
}
cost_share = {
    "Beauty & Care": 0.53,
    "Casa & Lifestyle": 0.64,
    "Moda & Accessori": 0.60,
    "Fitness & Benessere": 0.62,
    "Tech & Ufficio": 0.71,
}
products = []
idx = 1
for category, entries in products_spec.items():
    for name, price in entries:
        share = cost_share[category] * random.uniform(0.91, 1.09)
        products.append((idx, name, category, price, round(price * share, 2)))
        idx += 1
write_csv("products.csv", ["product_id", "product_name", "category", "list_price", "unit_cost"], products)

monthly_weights = [0.8, 0.82, 0.93, 0.92, 1.0, 1.04, 0.91, 0.82, 1.05, 1.16, 1.85, 1.55]
channels = ["Organic", "Paid Social", "Email", "Paid Search", "Referral"]
channel_weights = [32, 27, 18, 16, 7]
customer_weights = [random.gammavariate(0.85, 1) + 0.03 for _ in customers]
cat_return = {
    "Beauty & Care": 0.035,
    "Casa & Lifestyle": 0.055,
    "Moda & Accessori": 0.145,
    "Fitness & Benessere": 0.085,
    "Tech & Ufficio": 0.075,
}
cat_pop = {
    "Beauty & Care": 1.25, "Casa & Lifestyle": 0.95, "Moda & Accessori": 1.28,
    "Fitness & Benessere": 0.90, "Tech & Ufficio": 1.05,
}
product_weights = [cat_pop[p[2]] * random.uniform(0.7, 1.45) for p in products]
orders = []
items = []
item_id = 1
for order_id in range(1, 3201):
    month = random.choices(list(range(1, 13)), weights=monthly_weights, k=1)[0]
    # scegli il giorno dalla durata effettiva del mese
    first = date(2025, month, 1)
    last = date(2026, 1, 1) if month == 12 else date(2025, month + 1, 1)
    d = first + timedelta(days=random.randrange((last-first).days))
    customer = random.choices(customers, weights=customer_weights, k=1)[0]
    channel = random.choices(channels, weights=channel_weights, k=1)[0]
    orders.append((order_id, customer[0], d.isoformat(), channel))
    n_items = random.choices([1,2,3,4], weights=[58,29,11,2], k=1)[0]
    selected = []
    while len(selected) < n_items:
        prod = random.choices(products, weights=product_weights, k=1)[0]
        if prod[0] not in {x[0] for x in selected}:
            selected.append(prod)
    for prod in selected:
        qty = random.choices([1,2,3], weights=[87,11,2], k=1)[0]
        # Sconto in funzione del canale e delle promozioni del periodo
        promo = month in (11, 12)
        if channel == "Email":
            discount = random.choices([0, 5, 10, 20, 30], weights=[20, 20, 30, 20, 10], k=1)[0]
        elif channel == "Paid Social":
            discount = random.choices([0, 5, 10, 20, 30], weights=[34, 15, 27, 17, 7], k=1)[0]
        else:
            discount = random.choices([0, 5, 10, 20, 30], weights=[51, 18, 17, 11, 3], k=1)[0]
        if promo and random.random() < 0.24:
            discount = max(discount, random.choice([20, 30]))
        p_return = cat_return[prod[2]] + (0.023 if channel == "Paid Social" else 0)
        p_return += 0.026 if discount >= 20 else 0
        returned = random.random() < p_return
        items.append((item_id, order_id, prod[0], qty, f"{prod[3]:.2f}", discount, "true" if returned else "false"))
        item_id += 1

write_csv("orders.csv", ["order_id", "customer_id", "order_date", "channel"], orders)
write_csv("order_items.csv", ["order_item_id", "order_id", "product_id", "quantity", "unit_price", "discount_pct", "is_returned"], items)
print("Dataset SINTETICO: non rappresenta vendite di un'azienda reale.")
