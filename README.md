# Aged-Care & Disability-Support Service Management System

**PRT563 Advanced Data Management — Assessment 2 (Group Project)**
Charles Darwin University · Darwin Group 7

A relational database for an Australian aged-care and disability-support provider. The project covers conceptual modelling (EER in Chen's notation and a UML class diagram), mapping to the relational model, normalisation to Third Normal Form (3NF), a SQLite implementation with sample data, and the four required SQL query use cases.

---

## Team

| Member            | Primary contribution                              |
|-------------------|---------------------------------------------------|
| Ayush Bhusal      | Requirements, business problem and project scope  |
| Hemraj Budhathoki | Conceptual modelling — EER and UML diagrams       |
| Sangam GC         | EER-to-relational mapping and SQLite build        |
| Sujan Gautam      | SQL queries, testing, limitations and conclusion  |

---

## Repository structure

    .
    ├── sql/
    │   └── aged_care_support_FINAL.sql     # single reconstructable script (schema + data + queries)
    ├── diagrams/
    │   ├── EER_Chen_notation.png           # Enhanced EER (Chen's notation)
    │   ├── final_uml.png                   # UML class diagram
    │   ├── eer_to_relational_mapping.png   # EER to relational model mapping
    │   └── PRT563_Diagrams_Package.pdf     # all three diagrams in one PDF
    ├── presentation/
    │   └── PRT563_Aged_Care_DB_Presentation_FINAL_REVIEWED.pptx
    ├── docs/
    │   └── SQL_VALIDATION_REPORT.txt       # automated reconstruction / query test
    ├── database/
    │   └── aged_care_support.db            # prebuilt SQLite DB (optional, regenerable from the .sql)
    └── README.md

---

## How to build the database

1. Open **DB Browser for SQLite** → *New Database* (or a blank database).
2. **Execute SQL** tab → open `sql/aged_care_support_FINAL.sql` → **Run**.
3. The script:
   - enables foreign-key enforcement (`PRAGMA foreign_keys = ON`),
   - drops any existing tables (`DROP TABLE IF EXISTS`) so it is re-runnable,
   - creates 18 tables with PK, FK, CHECK and UNIQUE constraints and `ON UPDATE CASCADE`,
   - inserts sample data (parent tables first),
   - runs an UPDATE demonstration, then the four queries.

Verified: 18 tables, 0 foreign-key violations, no execution errors.

---

## Data model

- **Specialisation:** `PERSON` is a supertype, specialised (total, disjoint) into `CLIENT` and `SUPPORT_WORKER`.
- **Many-to-many:** worker ↔ qualification resolved via the `WORKER_QUALIFICATION` associative entity.
- **Derived attribute:** `invoice_total` is derived as `SUM(INVOICE_LINE.billed_amount)` and is not stored physically.
- **Normalisation:** all relations are in 3NF.

---

## SQL query use cases

| # | Type     | Scenario                                                | Result |
|---|----------|---------------------------------------------------------|--------|
| 1 | Simple   | Upcoming scheduled bookings (`=`, `BETWEEN`, `IN`)      | 3 rows |
| 2 | Simple   | Active funding allocations + remaining balance          | 5 rows |
| 3 | Moderate | Clients with agreement/booking counts (LEFT OUTER JOIN) | 8 rows |
| 4 | Complex  | Workers above the average delivery count (subquery)     | 1 row  |

---

## Notes

- Sample data is synthetic — no real client information is used.
- The recorded presentation is submitted separately as an unlisted YouTube link.
- Scope is operational service management (clients, agreements, bookings, delivery, incidents, invoicing, payments); payroll, award rates, clinical diagnosis and government claim processing are out of scope.
