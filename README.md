# 🚗 Vehicle Rental System — Database Project

A fully normalised relational database system designed to automate and streamline end-to-end operations of a vehicle rental business. Built as a DBMS project at **Vellore Institute of Technology (VIT)**, School of Computer Science and Engineering.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Database Schema](#database-schema)
- [ER Relationships](#er-relationships)
- [SQL Components](#sql-components)
- [Setup & Usage](#setup--usage)
- [Project Structure](#project-structure)
- [Team](#team)

---

## Overview

**VRS (Vehicle Rental Services)** is a relational database application that manages:

- Multi-branch fleet operations with real-time vehicle status tracking
- Customer registration, driving licence validation, and rental history
- Full rental lifecycle: booking → active → completion / overdue detection
- Multi-mode payment processing and financial reporting
- Scheduled maintenance tracking and damage report management
- Role-based staff management across branches

---

## Features

- ✅ **10 Normalised Tables** (3NF) with primary and foreign key constraints
- ✅ **Views** for rental details and vehicle availability
- ✅ **Stored Procedures** for creating and completing rentals
- ✅ **Triggers** for vehicle availability checks and overdue detection
- ✅ **Indexes** for query optimisation on high-frequency columns
- ✅ **Sample Data** with realistic INSERT statements
- ✅ **Business Queries** covering aggregations, joins, subqueries, and date functions

---

## Database Schema

| # | Table | Description | Primary Key |
|---|-------|-------------|-------------|
| 1 | `Branch` | Company branches / locations | BranchID |
| 2 | `Staff` | Employees: managers, agents, mechanics | StaffID |
| 3 | `Customer` | Registered customers with licence info | CustomerID |
| 4 | `VehicleCategory` | Categories: Economy, SUV, Luxury, etc. | CategoryID |
| 5 | `Vehicle` | Full fleet registry with live status | VehicleID |
| 6 | `Insurance` | Insurance policies linked to vehicles | InsuranceID |
| 7 | `Rental` | Core transaction: booking to return | RentalID |
| 8 | `Payment` | Payment records per rental | PaymentID |
| 9 | `Maintenance` | Service history and upcoming schedules | MaintenanceID |
| 10 | `DamageReport` | Damage incidents linked to rentals | DamageID |

---

## ER Relationships

```
Customer      ──< Rental >──  Vehicle
                   │               │
                   │            Branch
                   │           VehicleCategory
                 Staff          Insurance
                   │            Maintenance
              Payment
              DamageReport
```

| Entity | Relationship | Related Entity |
|--------|-------------|----------------|
| Customer | Places | Rental (1 : Many) |
| Vehicle | Belongs to | Branch (Many : 1) |
| Vehicle | Falls under | VehicleCategory (Many : 1) |
| Rental | Processed by | Staff (Many : 1) |
| Rental | Involves | Vehicle (Many : 1) |
| Rental | Has | Payment (1 : Many) |
| Rental | May have | DamageReport (1 : Many) |
| Vehicle | Covered by | Insurance (1 : Many) |
| Vehicle | Undergoes | Maintenance (1 : Many) |
| Branch | Managed by | Staff (1 : 1) |

---

## SQL Components

### Views
| View | Purpose |
|------|---------|
| `vw_RentalDetails` | Joined view of rental, customer, vehicle, and branch info |
| `vw_VehicleAvailability` | Live availability status of all vehicles |

### Stored Procedures
| Procedure | Purpose |
|-----------|---------|
| `sp_CreateRental` | Creates a new rental with automatic subtotal, 15% tax, and total cost calculation |
| `sp_CompleteRental` | Marks a rental as completed and updates vehicle status back to Available |

### Triggers
| Trigger | Purpose |
|---------|---------|
| `trg_CheckVehicleAvailability` | Prevents booking a vehicle that is not Available |
| `trg_SetOverdue` | Automatically flags rentals as Overdue past their expected return date |

### Indexes
```sql
idx_rental_customer     -- Rental(CustomerID)
idx_rental_vehicle      -- Rental(VehicleID)
idx_rental_status       -- Rental(Status)
idx_vehicle_status      -- Vehicle(Status)
idx_vehicle_branch      -- Vehicle(BranchID)
idx_payment_rental      -- Payment(RentalID)
idx_maintenance_vehicle -- Maintenance(VehicleID)
```

---

## Setup & Usage

### Prerequisites
- MySQL 8.0+ (or MariaDB 10.4+)
- MySQL Workbench / DBeaver / any SQL client

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/vehicle-rental-system.git
   cd vehicle-rental-system
   ```

2. **Run the SQL script**
   ```bash
   mysql -u root -p < vehicle_rental_system.sql
   ```
   Or open `vehicle_rental_system.sql` in MySQL Workbench and execute it.

3. **Verify the database**
   ```sql
   USE VehicleRentalDB;
   SHOW TABLES;
   ```

### Example Queries

```sql
-- Check available vehicles
SELECT * FROM vw_VehicleAvailability WHERE Status = 'Available';

-- Create a new rental
CALL sp_CreateRental(1, 3, 2, '2026-04-01', '2026-04-05', 1, 1);

-- Complete a rental
CALL sp_CompleteRental(1, '2026-04-05');

-- View full rental details
SELECT * FROM vw_RentalDetails;
```

---

## Project Structure

```
vehicle-rental-system/
├── vehicle_rental_system.sql   # Full database schema, data, and logic
├── VehicleRentalSystem_Report.docx  # Project report (VIT DA2)
└── README.md
```

---

## Team

| Name | Register No. | Role |
|------|-------------|------|
| Swapnil Jaiswal | 24BPS1002 | Database Designer |
| Tamohar Das | 24BPS1016 | SQL Developer |
| Harsh Gupta | 24BPS1021 | Documentation Lead |
| Pranav Bhatia | 24BPS1001 | Presentation & Demo Lead |

**Institute:** Vellore Institute of Technology (VIT)  
**Program:** B.Tech — Computer Science and Engineering  
**Course:** Database Management Systems (DBMS) — DA2 Project  
**Date:** March 2026

---

## License

This project was developed for academic purposes at VIT. All rights reserved by the respective team members.
