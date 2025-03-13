import sqlite3

# Connect to SQLite database (creates file if not exists)
conn = sqlite3.connect("students.db")
cursor = conn.cursor()

# Create table for student marks
cursor.execute('''
    CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        marks INTEGER NOT NULL
    )
''')

# Commit and close connection
conn.commit()
conn.close()

print("✅ Database and table created successfully!")
