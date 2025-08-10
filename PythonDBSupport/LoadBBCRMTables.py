import pyodbc
import random
import uuid
from datetime import datetime, timedelta

# Connect to SQL Server
conn = pyodbc.connect(
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    r'SERVER=LOGISMOS;'
    r'DATABASE=BBCRM;'
    r'Trusted_Connection=yes;'
)
cursor = conn.cursor()

# Sample data pools
first_names = ["Alice", "Bob", "Carol", "David", "Eve", "Frank", "Grace", "Hank"]
last_names = ["Johnson", "Smith", "Lee", "Brown", "Davis", "Miller", "Wilson", "Taylor"]
streets = ["Elm St", "Oak Ave", "Maple Rd", "Pine Ln", "Cedar Ct"]
cities = ["Raleigh", "Charlotte", "Durham", "Winston-Salem"]
states = ["NC", "SC", "VA"]
types = ["Individual", "Organization"]

# Lookup values
interaction_types = {1: "Phone Call", 2: "Visit"}
revenue_types = {1: "Donation", 2: "Grant"}
event_categories = {1: "Fundraiser", 2: "Education"}

def random_date(start_days_ago=365, end_days_ago=0):
    start = datetime.now() - timedelta(days=start_days_ago)
    end = datetime.now() - timedelta(days=end_days_ago)
    return (start + (end - start) * random.random()).strftime('%Y-%m-%d')

# Insert lookup values
def insert_lookup(table, values):
    for id, name in values.items():
        cursor.execute(f"INSERT INTO {table} (ID, NAME) VALUES (?, ?)", (uuid.UUID(int=id), name))

insert_lookup("REVENUE_TYPE", revenue_types)
insert_lookup("INTERACTION_TYPE", interaction_types)
insert_lookup("EVENT_CATEGORY", event_categories)

# Store GUIDs for constituents
constituents = []

# Insert constituents
for _ in range(100):
    cid = str(uuid.uuid4())
    constituents.append(cid)
    fn = random.choice(first_names)
    ln = random.choice(last_names)
    t = random.choice(types)
    cursor.execute(
        "INSERT INTO CONSTITUENT (ID, FIRSTNAME, LASTNAME, TYPE) VALUES (?, ?, ?, ?)",
        (cid, fn, ln, t)
    )

# Insert addresses
for cid in constituents:
    aid = str(uuid.uuid4())
    street = f"{random.randint(100,999)} {random.choice(streets)}"
    city = random.choice(cities)
    state = random.choice(states)
    zip_code = str(random.randint(27000, 27999))
    cursor.execute(
        "INSERT INTO ADDRESS (ID, CONSTITUENTID, STREET, CITY, STATE, ZIP) VALUES (?, ?, ?, ?, ?, ?)",
        (aid, cid, street, city, state, zip_code)
    )

# Insert revenue
for cid in constituents:
    rid = str(uuid.uuid4())
    amount = round(random.uniform(50, 5000), 2)
    date = random_date()
    type_id = uuid.UUID(int=random.choice(list(revenue_types.keys())))
    cursor.execute(
        "INSERT INTO REVENUE (ID, CONSTITUENTID, REVENUE_TYPE_ID, AMOUNT, DATE_RECEIVED) VALUES (?, ?, ?, ?, ?)",
        (rid, cid, type_id, amount, date)
    )

# Insert interactions
for cid in constituents:
    iid = str(uuid.uuid4())
    date = random_date()
    type_id = uuid.UUID(int=random.choice(list(interaction_types.keys())))
    notes = f"{interaction_types[type_id.int]} with constituent"
    cursor.execute(
        "INSERT INTO INTERACTION (ID, CONSTITUENTID, INTERACTION_TYPE_ID, DATE_OCCURRED, NOTES) VALUES (?, ?, ?, ?, ?)",
        (iid, cid, type_id, date, notes)
    )

# Insert events
for _ in range(100):
    eid = str(uuid.uuid4())
    name = f"{random.choice(['Spring', 'Fall', 'Annual'])} {random.choice(['Gala', 'Workshop', 'Summit'])}"
    cat_id = uuid.UUID(int=random.choice(list(event_categories.keys())))
    date = random_date()
    location = f"{random.choice(cities)} Convention Center"
    cursor.execute(
        "INSERT INTO EVENT (ID, EVENT_CATEGORY_ID, NAME, EVENT_DATE, LOCATION) VALUES (?, ?, ?, ?, ?)",
        (eid, cat_id, name, date, location)
    )

# Commit all inserts
conn.commit()
print("✅ All rows inserted with GUIDs.")

# Clean up
cursor.close()
conn.close()