-- ============================================================
-- PRT563 ADVANCED DATA MANAGEMENT
-- Darwin Group 7
--
-- Aged-Care & Disability-Support
-- Service Management System
--
-- MySQL Database Implementation
-- ============================================================


-- ============================================================
-- 1. CREATE / SELECT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS aged_care_support_db;

USE aged_care_support_db;


-- ============================================================
-- 2. DROP EXISTING TABLES
-- Reverse dependency order
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Invoice_Line;
DROP TABLE IF EXISTS Invoice;
DROP TABLE IF EXISTS Funding_Allocation;
DROP TABLE IF EXISTS Funding_Body;
DROP TABLE IF EXISTS Incident_Report;
DROP TABLE IF EXISTS Progress_Note;
DROP TABLE IF EXISTS Service_Delivery;
DROP TABLE IF EXISTS Service_Booking;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Service_Type;
DROP TABLE IF EXISTS Worker_Qualification;
DROP TABLE IF EXISTS Qualification;
DROP TABLE IF EXISTS Care_Plan;
DROP TABLE IF EXISTS Service_Agreement;
DROP TABLE IF EXISTS Support_Worker;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Person;

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- 3. PERSON
-- Supertype
-- ============================================================

CREATE TABLE Person (

    person_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),

    PRIMARY KEY (person_id),

    CONSTRAINT uq_person_email
        UNIQUE (email)

) ENGINE = InnoDB;


-- ============================================================
-- 4. CLIENT
-- Subtype of PERSON
-- ============================================================

CREATE TABLE Client (

    person_id INT,
    date_of_birth DATE NOT NULL,
    address VARCHAR(255),
    emergency_contact VARCHAR(150),
    client_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (person_id),

    CONSTRAINT fk_client_person
        FOREIGN KEY (person_id)
        REFERENCES Person(person_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_client_status
        CHECK (
            client_status IN (
                'Active',
                'Inactive',
                'Suspended'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 5. SUPPORT_WORKER
-- Subtype of PERSON
-- ============================================================

CREATE TABLE Support_Worker (

    person_id INT,
    employment_status VARCHAR(30) NOT NULL,
    hire_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,

    PRIMARY KEY (person_id),

    CONSTRAINT fk_worker_person
        FOREIGN KEY (person_id)
        REFERENCES Person(person_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_worker_status
        CHECK (
            status IN (
                'Active',
                'Inactive',
                'On Leave'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 6. SERVICE_AGREEMENT
-- CLIENT 1 : 0..* SERVICE_AGREEMENT
-- ============================================================

CREATE TABLE Service_Agreement (

    agreement_id INT AUTO_INCREMENT,
    client_person_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    agreement_type VARCHAR(50) NOT NULL,
    agreement_status VARCHAR(20) NOT NULL,
    total_budget DECIMAL(12,2) NOT NULL,

    PRIMARY KEY (agreement_id),

    CONSTRAINT fk_agreement_client
        FOREIGN KEY (client_person_id)
        REFERENCES Client(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_agreement_budget
        CHECK (total_budget >= 0),

    CONSTRAINT chk_agreement_dates
        CHECK (
            end_date IS NULL
            OR end_date >= start_date
        ),

    CONSTRAINT chk_agreement_status
        CHECK (
            agreement_status IN (
                'Active',
                'Inactive',
                'Expired',
                'Suspended'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 7. CARE_PLAN
-- CLIENT 1 : 0..* CARE_PLAN
-- ============================================================

CREATE TABLE Care_Plan (

    care_plan_id INT AUTO_INCREMENT,
    client_person_id INT NOT NULL,
    plan_date DATE NOT NULL,
    review_date DATE,
    goals TEXT,
    support_needs TEXT,
    plan_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (care_plan_id),

    CONSTRAINT fk_care_plan_client
        FOREIGN KEY (client_person_id)
        REFERENCES Client(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_care_plan_dates
        CHECK (
            review_date IS NULL
            OR review_date >= plan_date
        ),

    CONSTRAINT chk_plan_status
        CHECK (
            plan_status IN (
                'Active',
                'Under Review',
                'Completed',
                'Inactive'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 8. QUALIFICATION
-- ============================================================

CREATE TABLE Qualification (

    qualification_id INT AUTO_INCREMENT,
    qualification_name VARCHAR(100) NOT NULL,
    issuing_organisation VARCHAR(150),
    description VARCHAR(255),

    PRIMARY KEY (qualification_id),

    CONSTRAINT uq_qualification_name
        UNIQUE (qualification_name)

) ENGINE = InnoDB;


-- ============================================================
-- 9. WORKER_QUALIFICATION
-- Associative relation
-- SUPPORT_WORKER M:N QUALIFICATION
-- ============================================================

CREATE TABLE Worker_Qualification (

    worker_qualification_id INT AUTO_INCREMENT,
    worker_person_id INT NOT NULL,
    qualification_id INT NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE,
    status VARCHAR(20) NOT NULL,

    PRIMARY KEY (worker_qualification_id),

    CONSTRAINT fk_wq_worker
        FOREIGN KEY (worker_person_id)
        REFERENCES Support_Worker(person_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_wq_qualification
        FOREIGN KEY (qualification_id)
        REFERENCES Qualification(qualification_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_worker_qualification
        UNIQUE (
            worker_person_id,
            qualification_id
        ),

    CONSTRAINT chk_qualification_dates
        CHECK (
            expiry_date IS NULL
            OR expiry_date >= issue_date
        ),

    CONSTRAINT chk_worker_qualification_status
        CHECK (
            status IN (
                'Current',
                'Expired',
                'Suspended'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 10. SERVICE_TYPE
-- ============================================================

CREATE TABLE Service_Type (

    service_type_id INT AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    standard_duration INT NOT NULL,
    standard_rate DECIMAL(10,2) NOT NULL,
    service_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (service_type_id),

    CONSTRAINT uq_service_name
        UNIQUE (service_name),

    CONSTRAINT chk_standard_duration
        CHECK (
            standard_duration > 0
        ),

    CONSTRAINT chk_standard_rate
        CHECK (
            standard_rate >= 0
        ),

    CONSTRAINT chk_service_status
        CHECK (
            service_status IN (
                'Active',
                'Inactive'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 11. LOCATION
-- ============================================================

CREATE TABLE Location (

    location_id INT AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    suburb VARCHAR(100),
    state VARCHAR(50),
    postcode VARCHAR(10),
    location_type VARCHAR(30),

    PRIMARY KEY (location_id)

) ENGINE = InnoDB;


-- ============================================================
-- 12. SERVICE_BOOKING
--
-- SERVICE_AGREEMENT 1 : 0..* SERVICE_BOOKING
-- SUPPORT_WORKER    1 : 0..* SERVICE_BOOKING
-- SERVICE_TYPE      1 : 0..* SERVICE_BOOKING
-- LOCATION          1 : 0..* SERVICE_BOOKING
-- ============================================================

CREATE TABLE Service_Booking (

    booking_id INT AUTO_INCREMENT,
    agreement_id INT NOT NULL,
    worker_person_id INT NOT NULL,
    service_type_id INT NOT NULL,
    location_id INT NOT NULL,
    scheduled_start DATETIME NOT NULL,
    scheduled_end DATETIME NOT NULL,
    booking_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (booking_id),

    CONSTRAINT fk_booking_agreement
        FOREIGN KEY (agreement_id)
        REFERENCES Service_Agreement(agreement_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_booking_worker
        FOREIGN KEY (worker_person_id)
        REFERENCES Support_Worker(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_booking_service_type
        FOREIGN KEY (service_type_id)
        REFERENCES Service_Type(service_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_booking_location
        FOREIGN KEY (location_id)
        REFERENCES Location(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_booking_time
        CHECK (
            scheduled_end > scheduled_start
        ),

    CONSTRAINT chk_booking_status
        CHECK (
            booking_status IN (
                'Scheduled',
                'Completed',
                'Cancelled',
                'No Show'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 13. SERVICE_DELIVERY
--
-- SERVICE_BOOKING 1 : 0..1 SERVICE_DELIVERY
--
-- UNIQUE booking_id ensures that one booking
-- can create at most one service delivery.
-- ============================================================

CREATE TABLE Service_Delivery (

    delivery_id INT AUTO_INCREMENT,
    booking_id INT NOT NULL,
    actual_start DATETIME NOT NULL,
    actual_end DATETIME NOT NULL,
    units_delivered DECIMAL(10,2) NOT NULL,
    delivery_status VARCHAR(20) NOT NULL,
    delivery_outcome VARCHAR(255),

    PRIMARY KEY (delivery_id),

    CONSTRAINT uq_delivery_booking
        UNIQUE (booking_id),

    CONSTRAINT fk_delivery_booking
        FOREIGN KEY (booking_id)
        REFERENCES Service_Booking(booking_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_delivery_time
        CHECK (
            actual_end >= actual_start
        ),

    CONSTRAINT chk_units_delivered
        CHECK (
            units_delivered >= 0
        ),

    CONSTRAINT chk_delivery_status
        CHECK (
            delivery_status IN (
                'Completed',
                'Partially Completed',
                'Cancelled'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 14. PROGRESS_NOTE
-- ============================================================

CREATE TABLE Progress_Note (

    note_id INT AUTO_INCREMENT,
    delivery_id INT NOT NULL,
    author_worker_person_id INT NOT NULL,
    note_date_time DATETIME NOT NULL,
    note_text TEXT NOT NULL,

    PRIMARY KEY (note_id),

    CONSTRAINT fk_note_delivery
        FOREIGN KEY (delivery_id)
        REFERENCES Service_Delivery(delivery_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_note_worker
        FOREIGN KEY (author_worker_person_id)
        REFERENCES Support_Worker(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE = InnoDB;


-- ============================================================
-- 15. INCIDENT_REPORT
-- ============================================================

CREATE TABLE Incident_Report (

    incident_id INT AUTO_INCREMENT,
    delivery_id INT NOT NULL,
    reported_by_worker_person_id INT NOT NULL,
    incident_date_time DATETIME NOT NULL,
    incident_type VARCHAR(100) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    action_taken TEXT,
    incident_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (incident_id),

    CONSTRAINT fk_incident_delivery
        FOREIGN KEY (delivery_id)
        REFERENCES Service_Delivery(delivery_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_incident_worker
        FOREIGN KEY (reported_by_worker_person_id)
        REFERENCES Support_Worker(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_incident_severity
        CHECK (
            severity IN (
                'Low',
                'Medium',
                'High',
                'Critical'
            )
        ),

    CONSTRAINT chk_incident_status
        CHECK (
            incident_status IN (
                'Open',
                'Under Review',
                'Resolved',
                'Closed'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 16. FUNDING_BODY
-- ============================================================

CREATE TABLE Funding_Body (

    funding_body_id INT AUTO_INCREMENT,
    funding_body_name VARCHAR(150) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),

    PRIMARY KEY (funding_body_id),

    CONSTRAINT uq_funding_body_name
        UNIQUE (funding_body_name)

) ENGINE = InnoDB;


-- ============================================================
-- 17. FUNDING_ALLOCATION
-- ============================================================

CREATE TABLE Funding_Allocation (

    allocation_id INT AUTO_INCREMENT,
    agreement_id INT NOT NULL,
    funding_body_id INT NOT NULL,
    allocation_amount DECIMAL(12,2) NOT NULL,
    amount_used DECIMAL(12,2)
        NOT NULL DEFAULT 0.00,
    start_date DATE NOT NULL,
    end_date DATE,
    allocation_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (allocation_id),

    CONSTRAINT fk_allocation_agreement
        FOREIGN KEY (agreement_id)
        REFERENCES Service_Agreement(agreement_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_allocation_body
        FOREIGN KEY (funding_body_id)
        REFERENCES Funding_Body(funding_body_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_allocation_amount
        CHECK (
            allocation_amount >= 0
        ),

    CONSTRAINT chk_amount_used
        CHECK (
            amount_used >= 0
            AND amount_used <= allocation_amount
        ),

    CONSTRAINT chk_allocation_dates
        CHECK (
            end_date IS NULL
            OR end_date >= start_date
        ),

    CONSTRAINT chk_allocation_status
        CHECK (
            allocation_status IN (
                'Active',
                'Exhausted',
                'Expired',
                'Suspended'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 18. INVOICE
--
-- /invoice_total is a DERIVED attribute.
--
-- It is deliberately NOT stored here.
--
-- Invoice total will be calculated using:
--
-- SUM(Invoice_Line.billed_amount)
-- ============================================================

CREATE TABLE Invoice (

    invoice_id INT AUTO_INCREMENT,
    agreement_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (invoice_id),

    CONSTRAINT fk_invoice_agreement
        FOREIGN KEY (agreement_id)
        REFERENCES Service_Agreement(agreement_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_invoice_dates
        CHECK (
            due_date >= invoice_date
        ),

    CONSTRAINT chk_invoice_status
        CHECK (
            invoice_status IN (
                'Draft',
                'Issued',
                'Partially Paid',
                'Paid',
                'Overdue',
                'Cancelled'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 19. INVOICE_LINE
--
-- INVOICE 1 : 1..* INVOICE_LINE
--
-- SERVICE_DELIVERY 1 : 0..1 INVOICE_LINE
--
-- UNIQUE delivery_id prevents the same delivery
-- from appearing on multiple invoice lines.
-- ============================================================

CREATE TABLE Invoice_Line (

    invoice_line_id INT AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    delivery_id INT NOT NULL,
    billed_amount DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (invoice_line_id),

    CONSTRAINT fk_line_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES Invoice(invoice_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_line_delivery
        FOREIGN KEY (delivery_id)
        REFERENCES Service_Delivery(delivery_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_invoice_line_delivery
        UNIQUE (delivery_id),

    CONSTRAINT chk_billed_amount
        CHECK (
            billed_amount >= 0
        )

) ENGINE = InnoDB;


-- ============================================================
-- 20. PAYMENT
-- ============================================================

CREATE TABLE Payment (

    payment_id INT AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    reference_number VARCHAR(100),

    PRIMARY KEY (payment_id),

    CONSTRAINT fk_payment_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES Invoice(invoice_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_payment_amount
        CHECK (
            payment_amount > 0
        ),

    CONSTRAINT chk_payment_status
        CHECK (
            payment_status IN (
                'Pending',
                'Completed',
                'Failed',
                'Refunded'
            )
        )

) ENGINE = InnoDB;


-- ============================================================
-- 21. VERIFY DATABASE STRUCTURE
-- ============================================================

SHOW TABLES;


-- ============================================================
-- OPTIONAL: VERIFY EXACT TABLE COUNT
-- Expected result = 18
-- ============================================================

SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'aged_care_support_db';


-- ============================================================
-- OPTIONAL: VIEW TABLE STRUCTURES
-- ============================================================

DESCRIBE Person;
DESCRIBE Client;
DESCRIBE Support_Worker;
DESCRIBE Service_Agreement;
DESCRIBE Care_Plan;
DESCRIBE Qualification;
DESCRIBE Worker_Qualification;
DESCRIBE Service_Type;
DESCRIBE Location;
DESCRIBE Service_Booking;
DESCRIBE Service_Delivery;
DESCRIBE Progress_Note;
DESCRIBE Incident_Report;
DESCRIBE Funding_Body;
DESCRIBE Funding_Allocation;
DESCRIBE Invoice;
DESCRIBE Invoice_Line;
DESCRIBE Payment;
show tables;
SHOW CREATE TABLE Payment;
SELECT * FROM Payment;
SELECT COUNT(*) AS total_payments
FROM Payment;

-- ============================================================
-- PRT563 ADVANCED DATA MANAGEMENT
-- SAMPLE DATA
-- Aged-Care & Disability-Support Service Management System
-- ============================================================

USE aged_care_support_db;

START TRANSACTION;


-- ============================================================
-- 1. PERSON
-- Clients: 1-8
-- Support Workers: 101-106
-- ============================================================

INSERT INTO Person
(person_id, first_name, last_name, phone, email)
VALUES
(1, 'Mary', 'Wilson', '0412345001', 'mary.wilson@example.com'),
(2, 'John', 'Harris', '0412345002', 'john.harris@example.com'),
(3, 'Alice', 'Brown', '0412345003', 'alice.brown@example.com'),
(4, 'Robert', 'Lee', '0412345004', 'robert.lee@example.com'),
(5, 'Patricia', 'Green', '0412345005', 'patricia.green@example.com'),
(6, 'Michael', 'Clark', '0412345006', 'michael.clark@example.com'),
(7, 'Susan', 'Evans', '0412345007', 'susan.evans@example.com'),
(8, 'David', 'Turner', '0412345008', 'david.turner@example.com'),

(101, 'Emma', 'Nguyen', '0423456101', 'emma.nguyen@care.example.com'),
(102, 'Liam', 'Patel', '0423456102', 'liam.patel@care.example.com'),
(103, 'Noah', 'Williams', '0423456103', 'noah.williams@care.example.com'),
(104, 'Olivia', 'Martin', '0423456104', 'olivia.martin@care.example.com'),
(105, 'Ethan', 'Singh', '0423456105', 'ethan.singh@care.example.com'),
(106, 'Ava', 'Thompson', '0423456106', 'ava.thompson@care.example.com');


-- ============================================================
-- 2. CLIENT
-- ============================================================

INSERT INTO Client
(person_id, date_of_birth, address, emergency_contact, client_status)
VALUES
(1, '1948-05-14', '12 Smith Street, Darwin NT', 'Helen Wilson - 0411001001', 'Active'),
(2, '1952-11-22', '45 Mitchell Street, Darwin NT', 'Sarah Harris - 0411001002', 'Active'),
(3, '1960-03-08', '7 Palmerston Circuit, Palmerston NT', 'James Brown - 0411001003', 'Active'),
(4, '1945-08-17', '19 Casuarina Drive, Casuarina NT', 'Grace Lee - 0411001004', 'Active'),
(5, '1958-01-30', '22 Nightcliff Road, Nightcliff NT', 'Peter Green - 0411001005', 'Active'),
(6, '1965-06-12', '30 Stuart Highway, Stuart Park NT', 'Anna Clark - 0411001006', 'Active'),
(7, '1955-09-25', '15 Rapid Creek Road, Rapid Creek NT', 'Mark Evans - 0411001007', 'Active'),
(8, '1949-12-03', '8 Fannie Bay Place, Fannie Bay NT', 'Jane Turner - 0411001008', 'Active');


-- ============================================================
-- 3. SUPPORT_WORKER
--
-- employment_status:
-- Full-time / Part-time / Casual
--
-- status:
-- Active / Inactive / On Leave
-- ============================================================

INSERT INTO Support_Worker
(person_id, employment_status, hire_date, status)
VALUES
(101, 'Full-time', '2024-02-12', 'Active'),
(102, 'Part-time', '2024-07-01', 'Active'),
(103, 'Full-time', '2023-11-20', 'Active'),
(104, 'Casual', '2025-03-15', 'Active'),
(105, 'Part-time', '2025-01-10', 'Active'),
(106, 'Full-time', '2024-09-05', 'Active');


-- ============================================================
-- 4. SERVICE AGREEMENT
-- Client 8 deliberately has no service agreement yet.
-- This will be useful for an OUTER JOIN query.
-- ============================================================

INSERT INTO Service_Agreement
(agreement_id, client_person_id, start_date, end_date,
 agreement_type, agreement_status, total_budget)
VALUES
(1, 1, '2026-01-01', '2026-12-31', 'Aged Care Support', 'Active', 18000.00),
(2, 2, '2026-02-01', '2027-01-31', 'NDIS Support', 'Active', 24000.00),
(3, 3, '2026-01-15', '2026-12-31', 'NDIS Support', 'Active', 21000.00),
(4, 4, '2026-03-01', '2027-02-28', 'Aged Care Support', 'Active', 19500.00),
(5, 5, '2026-01-01', '2026-12-31', 'Community Support', 'Active', 15000.00),
(6, 6, '2026-04-01', '2027-03-31', 'NDIS Support', 'Active', 27000.00),
(7, 7, '2026-02-15', '2027-02-14', 'Aged Care Support', 'Active', 17500.00);


-- ============================================================
-- 5. CARE PLAN
-- ============================================================

INSERT INTO Care_Plan
(care_plan_id, client_person_id, plan_date, review_date,
 goals, support_needs, plan_status)
VALUES
(1, 1, '2026-01-05', '2026-07-05',
 'Maintain independence at home',
 'Personal care and domestic assistance',
 'Active'),

(2, 2, '2026-02-05', '2026-08-05',
 'Increase community participation',
 'Community access and transport support',
 'Active'),

(3, 3, '2026-01-20', '2026-07-20',
 'Improve daily living independence',
 'Personal care and community access',
 'Active'),

(4, 4, '2026-03-05', '2026-09-05',
 'Remain safely at home',
 'Respite and personal care',
 'Under Review'),

(5, 5, '2026-01-08', '2026-07-08',
 'Maintain access to essential appointments',
 'Transport and domestic assistance',
 'Active'),

(6, 6, '2026-04-05', '2026-10-05',
 'Develop independent living skills',
 'Personal care and community participation',
 'Active'),

(7, 7, '2026-02-20', '2026-08-20',
 'Improve social participation',
 'Community access and domestic assistance',
 'Active'),

(8, 8, '2026-08-15', '2027-02-15',
 'Assess ongoing support requirements',
 'Initial assessment and care planning',
 'Active');


-- ============================================================
-- 6. QUALIFICATION
-- ============================================================

INSERT INTO Qualification
(qualification_id, qualification_name, issuing_organisation, description)
VALUES
(1, 'First Aid Certificate', 'Australian Training Provider',
 'Current first aid competency'),

(2, 'CPR Certificate', 'Australian Training Provider',
 'Cardiopulmonary resuscitation competency'),

(3, 'Certificate III in Individual Support', 'Registered Training Organisation',
 'Qualification in aged care and disability support'),

(4, 'NDIS Worker Orientation', 'NDIS Quality and Safeguards Commission',
 'Worker orientation training'),

(5, 'Medication Assistance Training', 'Registered Training Organisation',
 'Training for safe assistance with medication');


-- ============================================================
-- 7. WORKER QUALIFICATION
-- ============================================================

INSERT INTO Worker_Qualification
(worker_qualification_id, worker_person_id, qualification_id,
 issue_date, expiry_date, status)
VALUES
(1, 101, 1, '2025-06-10', '2028-06-10', 'Current'),
(2, 101, 3, '2023-12-15', NULL, 'Current'),
(3, 101, 4, '2024-02-15', NULL, 'Current'),

(4, 102, 1, '2025-08-01', '2028-08-01', 'Current'),
(5, 102, 2, '2026-01-10', '2027-01-10', 'Current'),

(6, 103, 3, '2023-05-15', NULL, 'Current'),
(7, 103, 4, '2024-01-12', NULL, 'Current'),

(8, 104, 1, '2025-03-20', '2028-03-20', 'Current'),
(9, 104, 5, '2025-04-15', '2027-04-15', 'Current'),

(10, 105, 2, '2026-02-01', '2027-02-01', 'Current'),
(11, 105, 4, '2025-01-15', NULL, 'Current'),

(12, 106, 1, '2025-09-10', '2028-09-10', 'Current'),
(13, 106, 3, '2024-07-20', NULL, 'Current');


-- ============================================================
-- 8. SERVICE TYPE
--
-- standard_duration is stored in minutes.
-- ============================================================

INSERT INTO Service_Type
(service_type_id, service_name, standard_duration,
 standard_rate, service_status)
VALUES
(1, 'Personal Care', 60, 65.00, 'Active'),
(2, 'Domestic Assistance', 90, 58.00, 'Active'),
(3, 'Community Access', 120, 70.00, 'Active'),
(4, 'Transport Support', 60, 55.00, 'Active'),
(5, 'Respite Support', 180, 75.00, 'Active');


-- ============================================================
-- 9. LOCATION
-- ============================================================

INSERT INTO Location
(location_id, location_name, address, suburb,
 state, postcode, location_type)
VALUES
(1, 'Mary Wilson Residence', '12 Smith Street', 'Darwin', 'NT', '0800', 'Client Home'),
(2, 'Darwin Community Centre', '25 Cavenagh Street', 'Darwin', 'NT', '0800', 'Community Centre'),
(3, 'Alice Brown Residence', '7 Palmerston Circuit', 'Palmerston', 'NT', '0830', 'Client Home'),
(4, 'Robert Lee Residence', '19 Casuarina Drive', 'Casuarina', 'NT', '0810', 'Client Home'),
(5, 'Darwin Health Precinct', '105 Rocklands Drive', 'Tiwi', 'NT', '0810', 'Health Facility'),
(6, 'Michael Clark Residence', '30 Stuart Highway', 'Stuart Park', 'NT', '0820', 'Client Home');


-- ============================================================
-- 10. SERVICE BOOKING
--
-- 12 completed
-- 3 scheduled
-- 1 cancelled
-- ============================================================

INSERT INTO Service_Booking
(booking_id, agreement_id, worker_person_id,
 service_type_id, location_id,
 scheduled_start, scheduled_end, booking_status)
VALUES
(1, 1, 101, 1, 1,
 '2026-08-20 09:00:00', '2026-08-20 10:00:00', 'Completed'),

(2, 1, 102, 2, 1,
 '2026-08-22 10:00:00', '2026-08-22 11:30:00', 'Completed'),

(3, 2, 103, 3, 2,
 '2026-08-21 13:00:00', '2026-08-21 15:00:00', 'Completed'),

(4, 3, 101, 1, 3,
 '2026-08-24 08:00:00', '2026-08-24 09:00:00', 'Completed'),

(5, 4, 104, 5, 4,
 '2026-08-25 09:00:00', '2026-08-25 12:00:00', 'Completed'),

(6, 5, 105, 4, 5,
 '2026-08-26 10:00:00', '2026-08-26 11:00:00', 'Completed'),

(7, 6, 101, 1, 6,
 '2026-08-27 14:00:00', '2026-08-27 15:00:00', 'Completed'),

(8, 7, 106, 3, 2,
 '2026-08-28 09:00:00', '2026-08-28 11:00:00', 'Completed'),

(9, 2, 102, 2, 2,
 '2026-09-01 11:00:00', '2026-09-01 12:30:00', 'Completed'),

(10, 3, 103, 3, 3,
 '2026-09-02 13:00:00', '2026-09-02 15:00:00', 'Completed'),

(11, 4, 104, 5, 4,
 '2026-09-03 09:00:00', '2026-09-03 12:00:00', 'Completed'),

(12, 5, 105, 4, 5,
 '2026-09-04 10:00:00', '2026-09-04 11:00:00', 'Completed'),

(13, 1, 101, 1, 1,
 '2026-09-10 09:00:00', '2026-09-10 10:00:00', 'Scheduled'),

(14, 6, 106, 2, 6,
 '2026-09-11 10:00:00', '2026-09-11 11:30:00', 'Scheduled'),

(15, 7, 102, 3, 2,
 '2026-09-12 13:00:00', '2026-09-12 15:00:00', 'Scheduled'),

(16, 2, 103, 1, 2,
 '2026-09-05 09:00:00', '2026-09-05 10:00:00', 'Cancelled');


-- ============================================================
-- 11. SERVICE DELIVERY
--
-- Only completed bookings have deliveries.
-- booking_id is UNIQUE.
-- ============================================================

INSERT INTO Service_Delivery
(delivery_id, booking_id, actual_start, actual_end,
 units_delivered, delivery_status, delivery_outcome)
VALUES
(1, 1,
 '2026-08-20 09:03:00', '2026-08-20 10:00:00',
 1.00, 'Completed',
 'Personal care completed successfully'),

(2, 2,
 '2026-08-22 10:05:00', '2026-08-22 11:32:00',
 1.50, 'Completed',
 'Domestic assistance completed'),

(3, 3,
 '2026-08-21 13:00:00', '2026-08-21 15:00:00',
 2.00, 'Completed',
 'Client participated in community activity'),

(4, 4,
 '2026-08-24 08:00:00', '2026-08-24 09:00:00',
 1.00, 'Completed',
 'Morning personal care completed'),

(5, 5,
 '2026-08-25 09:05:00', '2026-08-25 12:00:00',
 3.00, 'Completed',
 'Respite support completed'),

(6, 6,
 '2026-08-26 10:00:00', '2026-08-26 11:00:00',
 1.00, 'Completed',
 'Transport to health appointment completed'),

(7, 7,
 '2026-08-27 14:02:00', '2026-08-27 15:00:00',
 1.00, 'Completed',
 'Personal care completed'),

(8, 8,
 '2026-08-28 09:00:00', '2026-08-28 11:00:00',
 2.00, 'Completed',
 'Community access activity completed'),

(9, 9,
 '2026-09-01 11:05:00', '2026-09-01 12:30:00',
 1.50, 'Completed',
 'Domestic assistance completed'),

(10, 10,
 '2026-09-02 13:00:00', '2026-09-02 15:00:00',
 2.00, 'Completed',
 'Community participation goals addressed'),

(11, 11,
 '2026-09-03 09:00:00', '2026-09-03 11:45:00',
 3.00, 'Partially Completed',
 'Session ended early at client request'),

(12, 12,
 '2026-09-04 10:00:00', '2026-09-04 11:00:00',
 1.00, 'Completed',
 'Transport service completed');


-- ============================================================
-- 12. PROGRESS NOTE
-- ============================================================

INSERT INTO Progress_Note
(note_id, delivery_id, author_worker_person_id,
 note_date_time, note_text)
VALUES
(1, 1, 101, '2026-08-20 10:10:00',
 'Client was comfortable and participated in personal care activities.'),

(2, 2, 102, '2026-08-22 11:40:00',
 'Cleaning and meal preparation tasks completed.'),

(3, 3, 103, '2026-08-21 15:10:00',
 'Client engaged positively in community activities.'),

(4, 4, 101, '2026-08-24 09:10:00',
 'Morning routine completed without concerns.'),

(5, 5, 104, '2026-08-25 12:10:00',
 'Respite session completed. Client remained settled.'),

(6, 6, 105, '2026-08-26 11:10:00',
 'Client transported safely to and from appointment.'),

(7, 7, 101, '2026-08-27 15:10:00',
 'Personal care goals achieved during session.'),

(8, 8, 106, '2026-08-28 11:10:00',
 'Client participated well in scheduled community activity.'),

(9, 9, 102, '2026-09-01 12:40:00',
 'Domestic tasks completed as specified in support plan.'),

(10, 10, 103, '2026-09-02 15:10:00',
 'Client showed increased confidence during community activity.'),

(11, 11, 104, '2026-09-03 12:00:00',
 'Respite session shortened following client request.'),

(12, 12, 105, '2026-09-04 11:10:00',
 'Transport support completed with no major concerns.');


-- ============================================================
-- 13. INCIDENT REPORT
-- ============================================================

INSERT INTO Incident_Report
(incident_id, delivery_id, reported_by_worker_person_id,
 incident_date_time, incident_type, severity,
 description, action_taken, incident_status)
VALUES
(1, 3, 103,
 '2026-08-21 14:10:00',
 'Minor Trip',
 'Low',
 'Client briefly lost balance while walking in the community centre.',
 'Worker provided immediate assistance and monitored the client.',
 'Resolved'),

(2, 5, 104,
 '2026-08-25 10:30:00',
 'Medication Concern',
 'Medium',
 'Client reported uncertainty about whether morning medication had been taken.',
 'Medication was not administered and supervisor was contacted.',
 'Closed'),

(3, 10, 103,
 '2026-09-02 14:20:00',
 'Behavioural Distress',
 'Medium',
 'Client became distressed due to a change in activity schedule.',
 'Worker moved client to a quiet area and followed support strategies.',
 'Resolved'),

(4, 11, 104,
 '2026-09-03 11:30:00',
 'Early Service Termination',
 'Low',
 'Client requested that the respite session finish early.',
 'Worker confirmed client safety and notified coordinator.',
 'Closed');


-- ============================================================
-- 14. FUNDING BODY
-- ============================================================

INSERT INTO Funding_Body
(funding_body_id, funding_body_name, contact_name, phone, email)
VALUES
(1, 'NDIS', 'Funding Support Team', '1800000001', 'ndis.funding@example.com'),

(2, 'Aged Care Funding Program', 'Aged Care Support Team',
 '1800000002', 'agedcare.funding@example.com'),

(3, 'Private Self-Funded', 'Accounts Team',
 '0889000003', 'private.accounts@example.com');


-- ============================================================
-- 15. FUNDING ALLOCATION
-- ============================================================

INSERT INTO Funding_Allocation
(allocation_id, agreement_id, funding_body_id,
 allocation_amount, amount_used,
 start_date, end_date, allocation_status)
VALUES
(1, 1, 2, 18000.00, 3200.00,
 '2026-01-01', '2026-12-31', 'Active'),

(2, 2, 1, 24000.00, 4800.00,
 '2026-02-01', '2027-01-31', 'Active'),

(3, 3, 1, 21000.00, 3900.00,
 '2026-01-15', '2026-12-31', 'Active'),

(4, 4, 2, 19500.00, 4100.00,
 '2026-03-01', '2027-02-28', 'Active'),

(5, 5, 3, 15000.00, 2600.00,
 '2026-01-01', '2026-12-31', 'Active'),

(6, 6, 1, 27000.00, 5200.00,
 '2026-04-01', '2027-03-31', 'Active'),

(7, 7, 2, 17500.00, 2800.00,
 '2026-02-15', '2027-02-14', 'Active');


-- ============================================================
-- 16. INVOICE
--
-- invoice_total is NOT stored.
-- It is calculated from Invoice_Line.
-- ============================================================

INSERT INTO Invoice
(invoice_id, agreement_id, invoice_date, due_date, invoice_status)
VALUES
(1, 1, '2026-08-31', '2026-09-14', 'Paid'),
(2, 2, '2026-09-02', '2026-09-16', 'Partially Paid'),
(3, 3, '2026-09-03', '2026-09-17', 'Paid'),
(4, 4, '2026-09-04', '2026-09-18', 'Partially Paid'),
(5, 5, '2026-09-05', '2026-09-19', 'Paid'),
(6, 6, '2026-09-05', '2026-09-19', 'Paid'),
(7, 7, '2026-09-05', '2026-09-19', 'Issued');


-- ============================================================
-- 17. INVOICE LINE
--
-- Each delivery can appear on at most one invoice line.
-- ============================================================

INSERT INTO Invoice_Line
(invoice_line_id, invoice_id, delivery_id, billed_amount)
VALUES
(1, 1, 1, 65.00),
(2, 1, 2, 87.00),

(3, 2, 3, 140.00),
(4, 2, 9, 87.00),

(5, 3, 4, 65.00),
(6, 3, 10, 140.00),

(7, 4, 5, 225.00),
(8, 4, 11, 225.00),

(9, 5, 6, 55.00),
(10, 5, 12, 55.00),

(11, 6, 7, 65.00),

(12, 7, 8, 140.00);


-- ============================================================
-- 18. PAYMENT
-- ============================================================

INSERT INTO Payment
(payment_id, invoice_id, payment_date,
 payment_amount, payment_method,
 payment_status, reference_number)
VALUES
(1, 1, '2026-09-02', 152.00,
 'Bank Transfer', 'Completed', 'PAY-2026-001'),

(2, 2, '2026-09-05', 100.00,
 'Bank Transfer', 'Completed', 'PAY-2026-002'),

(3, 3, '2026-09-05', 205.00,
 'Card', 'Completed', 'PAY-2026-003'),

(4, 4, '2026-09-06', 200.00,
 'Bank Transfer', 'Completed', 'PAY-2026-004'),

(5, 5, '2026-09-06', 110.00,
 'Card', 'Completed', 'PAY-2026-005'),

(6, 6, '2026-09-07', 65.00,
 'Bank Transfer', 'Completed', 'PAY-2026-006'),

(7, 7, '2026-09-07', 140.00,
 'Card', 'Failed', 'PAY-2026-007');


COMMIT;


-- ============================================================
-- VERIFY DATA
-- ============================================================

SELECT * FROM Person;
SELECT * FROM Client;
SELECT * FROM Support_Worker;
SELECT * FROM Service_Agreement;
SELECT * FROM Care_Plan;
SELECT * FROM Qualification;
SELECT * FROM Worker_Qualification;
SELECT * FROM Service_Type;
SELECT * FROM Location;
SELECT * FROM Service_Booking;
SELECT * FROM Service_Delivery;
SELECT * FROM Progress_Note;
SELECT * FROM Incident_Report;
SELECT * FROM Funding_Body;
SELECT * FROM Funding_Allocation;
SELECT * FROM Invoice;
SELECT * FROM Invoice_Line;
SELECT * FROM Payment;

USE aged_care_support_db;


-- ============================================================
-- QUERY 1 — SIMPLE QUERY
-- Purpose:
-- Find upcoming scheduled service bookings during September
-- for selected active support workers.
--
-- Demonstrates:
-- SELECT, WHERE, AND, BETWEEN, IN, ORDER BY
-- ============================================================

SELECT
    booking_id,
    agreement_id,
    worker_person_id,
    service_type_id,
    scheduled_start,
    scheduled_end,
    booking_status
FROM Service_Booking
WHERE booking_status = 'Scheduled'
  AND scheduled_start BETWEEN
      '2026-09-09 00:00:00'
      AND '2026-09-30 23:59:59'
  AND worker_person_id IN (101, 102, 106)
ORDER BY scheduled_start ASC;



-- ============================================================
-- QUERY 2 — SIMPLE QUERY
-- Purpose:
-- Find active funding allocations with large budgets
-- that have used less than $5,000.
--
-- Demonstrates:
-- multiple WHERE operators, arithmetic and ORDER BY
-- ============================================================

SELECT
    allocation_id,
    agreement_id,
    allocation_amount,
    amount_used,
    (allocation_amount - amount_used) AS remaining_balance,
    allocation_status
FROM Funding_Allocation
WHERE allocation_status = 'Active'
  AND allocation_amount > 17000
  AND amount_used < 5000
ORDER BY remaining_balance DESC;



-- ============================================================
-- QUERY 3 — MODERATELY COMPLEX
-- LEFT OUTER JOIN
--
-- Purpose:
-- Show every client, including clients who currently have
-- no service agreement or bookings.
--
-- This is important because Client 8 currently has no
-- service agreement.
--
-- Demonstrates:
-- JOIN
-- LEFT OUTER JOIN
-- COUNT
-- GROUP BY
-- ORDER BY
-- ============================================================

SELECT
    c.person_id AS client_id,
    CONCAT(p.first_name, ' ', p.last_name) AS client_name,
    c.client_status,

    COUNT(DISTINCT sa.agreement_id) AS total_agreements,
    COUNT(sb.booking_id) AS total_bookings

FROM Client c

INNER JOIN Person p
    ON c.person_id = p.person_id

LEFT OUTER JOIN Service_Agreement sa
    ON c.person_id = sa.client_person_id

LEFT OUTER JOIN Service_Booking sb
    ON sa.agreement_id = sb.agreement_id

GROUP BY
    c.person_id,
    p.first_name,
    p.last_name,
    c.client_status

ORDER BY
    total_bookings DESC,
    client_name ASC;



-- ============================================================
-- QUERY 4 — COMPLEX QUERY
-- SUBQUERY + AGGREGATE
--
-- Purpose:
-- Identify support workers whose total number of completed
-- service-delivery records is greater than the average number
-- of deliveries performed by all support workers.
--
-- Demonstrates:
-- multiple JOINs
-- GROUP BY
-- COUNT()
-- HAVING
-- AVG()
-- nested subquery
-- derived result
-- ============================================================

SELECT
    sw.person_id AS worker_id,
    CONCAT(p.first_name, ' ', p.last_name) AS worker_name,
    sw.employment_status,
    COUNT(sd.delivery_id) AS total_deliveries

FROM Support_Worker sw

INNER JOIN Person p
    ON sw.person_id = p.person_id

LEFT JOIN Service_Booking sb
    ON sw.person_id = sb.worker_person_id

LEFT JOIN Service_Delivery sd
    ON sb.booking_id = sd.booking_id

GROUP BY
    sw.person_id,
    p.first_name,
    p.last_name,
    sw.employment_status

HAVING COUNT(sd.delivery_id) >
(
    SELECT AVG(delivery_count)

    FROM
    (
        SELECT
            sw2.person_id,
            COUNT(sd2.delivery_id) AS delivery_count

        FROM Support_Worker sw2

        LEFT JOIN Service_Booking sb2
            ON sw2.person_id = sb2.worker_person_id

        LEFT JOIN Service_Delivery sd2
            ON sb2.booking_id = sd2.booking_id

        GROUP BY sw2.person_id

    ) AS worker_delivery_counts
)

ORDER BY total_deliveries DESC;
-- ============================================================
-- UPDATE DEMONSTRATION
-- Update the lifecycle/status of an incident report.
-- ============================================================

SELECT
    incident_id,
    incident_type,
    incident_status,
    action_taken
FROM Incident_Report
WHERE incident_id = 3;


UPDATE Incident_Report
SET
    incident_status = 'Closed',
    action_taken =
    'Worker moved client to a quiet area and followed support strategies. Follow-up completed and case closed.'
WHERE incident_id = 3;


SELECT
    incident_id,
    incident_type,
    incident_status,
    action_taken
FROM Incident_Report
WHERE incident_id = 3;

-- ============================================================
-- ALTER TABLE DEMONSTRATION
--
-- Adds an index to improve searching/filtering of bookings
-- by status and scheduled start time.
--
-- Does NOT change the conceptual attributes.
-- Run this once.
-- ============================================================

ALTER TABLE Service_Booking
ADD INDEX idx_booking_status_start
(
    booking_status,
    scheduled_start
);
SHOW INDEX FROM Service_Booking;