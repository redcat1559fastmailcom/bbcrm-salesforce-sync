import pyodbc
import uuid
from faker import Faker
from random import choice, randint

fake = Faker()

# Connect to SQL Server
conn = pyodbc.connect(
    "DRIVER={SQL Server};"
    "SERVER=LOGISMOS;"
    "DATABASE=BBCRM;"
    "Trusted_Connection=yes;"
)
conn.autocommit = False
cursor = conn.cursor()

try:
    # Step 1: Insert Address Type Codes
    address_type_map = {}
    address_types = ['Home', 'Business', 'Billing', 'Seasonal']

    for desc in address_types:
        type_id = uuid.uuid4()
        address_type_map[desc] = type_id
        cursor.execute("""
            INSERT INTO BBCRM_Address_Type (ID, Type_Description, DateChanged)
            VALUES (?, ?, ?)
        """, str(type_id), desc, fake.date_time_this_decade())

    # Step 2: Insert Interaction Type Codes
    interaction_type_map = {}
    interaction_types = ['Phone Call', 'Email', 'Meeting', 'Text Message', 'Postal Mail']

    for desc in interaction_types:
        type_id = uuid.uuid4()
        interaction_type_map[desc] = type_id
        cursor.execute("""
            INSERT INTO BBCRM_Interaction_Type (ID, Type_Description, DateChanged)
            VALUES (?, ?, ?)
        """, str(type_id), desc, fake.date_time_this_decade())

    # Step 3: Insert Constituents
    constituent_ids = []
    for _ in range(1000):
        cid = uuid.uuid4()
        constituent_ids.append(cid)
        cursor.execute("""
            INSERT INTO BBCRM_Constituent (BBCRM_ID, FirstName, LastName, Email, DateChanged)
            VALUES (?, ?, ?, ?, ?)
        """, str(cid), fake.first_name(), fake.last_name(), fake.email(), fake.date_time_this_decade())

    # Step 4: Insert Addresses (~1–4 per constituent)
    for cid in constituent_ids:
        for _ in range(randint(1, 4)):
            addr_type = choice(address_types)
            cursor.execute("""
                INSERT INTO BBCRM_Address (Address_ID, Constituent_ID, Street, City, [State], ZIP, Address_Type_Code, DateChanged)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, str(uuid.uuid4()), str(cid),
                 fake.street_address(), fake.city(), fake.state(), fake.zipcode(),
                 str(address_type_map[addr_type]), fake.date_time_this_year())

    # Step 5: Insert Interactions (~2–6 per constituent)
    for cid in constituent_ids:
        for _ in range(randint(2, 6)):
            interaction_type = choice(interaction_types)
            cursor.execute("""
                INSERT INTO BBCRM_Interaction (Interaction_ID, Constituent_ID, Interaction_Date, Notes, Interaction_Type_Code, DateChanged)
                VALUES (?, ?, ?, ?, ?, ?)
            """, str(uuid.uuid4()), str(cid),
                 fake.date_time_this_year(), fake.paragraph(nb_sentences=2),
                 str(interaction_type_map[interaction_type]), fake.date_time_this_year())

    # Commit if all inserts succeed
    conn.commit()
    print("✅ Mock BBCRM data inserted successfully.")

except Exception as e:
    conn.rollback()
    print("❌ Error occurred during data insertion:", e)

finally:
    cursor.close()
    conn.close()