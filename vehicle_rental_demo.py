"""
=============================================================
  VEHICLE RENTAL SYSTEM - MySQL Demo
  Team: 24BPS / 24BAI Batch
=============================================================
  Requirements:
      pip install mysql-connector-python tabulate
  
  Usage:
      python vehicle_rental_demo.py
=============================================================
"""

import mysql.connector
from mysql.connector import Error
from tabulate import tabulate
from datetime import date, datetime
import sys
import os

# ─────────────────────────────────────────────
#  DATABASE CONNECTION CONFIG — edit as needed
# ─────────────────────────────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "port":     3306,
    "user":     "root",        # change to your MySQL username
    "password": "",            # change to your MySQL password
    "database": "VehicleRentalDB",
}

# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────

def connect():
    """Return a live MySQL connection or exit on failure."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        if conn.is_connected():
            return conn
    except Error as e:
        print(f"\n  [ERROR] Could not connect to MySQL: {e}")
        print("  Make sure MySQL is running and DB_CONFIG is correct.\n")
        sys.exit(1)


def run_query(conn, sql, params=None, fetch=True):
    """Execute a query and return rows + column names."""
    cursor = conn.cursor()
    cursor.execute(sql, params or ())
    if fetch:
        rows    = cursor.fetchall()
        columns = [d[0] for d in cursor.description]
        cursor.close()
        return rows, columns
    else:
        conn.commit()
        affected = cursor.rowcount
        cursor.close()
        return affected


def pretty(rows, columns, title=""):
    """Print a nicely formatted table."""
    if title:
        print(f"\n  {'─'*60}")
        print(f"  {title}")
        print(f"  {'─'*60}")
    if rows:
        print(tabulate(rows, headers=columns, tablefmt="rounded_outline",
                       numalign="right", stralign="left"))
    else:
        print("  (no records found)")
    print()


def section(label):
    width = 62
    print("\n" + "═" * width)
    print(f"  {label}")
    print("═" * width)


def pause():
    input("\n  ▶  Press Enter to continue...")


# ─────────────────────────────────────────────
#  DEMO MODULES
# ─────────────────────────────────────────────

def demo_branch_overview(conn):
    section("1.  BRANCH OVERVIEW")
    sql = """
        SELECT b.BranchName, b.City, b.Phone,
               CONCAT(s.FirstName,' ',s.LastName) AS Manager,
               COUNT(v.VehicleID)                 AS TotalVehicles
        FROM   Branch b
        LEFT JOIN Staff   s ON s.StaffID  = b.ManagerID
        LEFT JOIN Vehicle v ON v.BranchID = b.BranchID
        GROUP BY b.BranchID
        ORDER BY b.BranchID;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "All Branches & Their Managers")
    pause()


def demo_vehicle_availability(conn):
    section("2.  VEHICLE AVAILABILITY")
    sql = """
        SELECT v.VehicleID,
               CONCAT(v.Make,' ',v.Model,'  (',v.Year,')') AS Vehicle,
               vc.CategoryName, v.FuelType, v.Transmission,
               v.Seats, v.DailyRate, v.Status, b.BranchName
        FROM   Vehicle v
        JOIN   VehicleCategory vc ON vc.CategoryID = v.CategoryID
        JOIN   Branch          b  ON b.BranchID    = v.BranchID
        ORDER  BY v.Status, v.DailyRate;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "Full Vehicle Fleet")

    # availability summary by branch
    sql2 = """
        SELECT BranchName, City, Available, Rented, UnderMaintenance, Total
        FROM   vw_VehicleAvailability;
    """
    rows2, cols2 = run_query(conn, sql2)
    pretty(rows2, cols2, "Availability Summary by Branch")
    pause()


def demo_customer_list(conn):
    section("3.  REGISTERED CUSTOMERS")
    sql = """
        SELECT CustomerID,
               CONCAT(FirstName,' ',LastName) AS Name,
               Email, Phone, City,
               DATE_FORMAT(RegisteredOn,'%d %b %Y') AS RegisteredOn
        FROM   Customer
        ORDER  BY CustomerID;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "All Registered Customers")
    pause()


def demo_active_rentals(conn):
    section("4.  ACTIVE RENTALS")
    sql = """
        SELECT r.RentalID,
               CONCAT(c.FirstName,' ',c.LastName)       AS Customer,
               CONCAT(v.Make,' ',v.Model)                AS Vehicle,
               v.LicensePlate,
               r.StartDate, r.ExpectedReturn,
               r.TotalCost,
               bp.BranchName AS PickupBranch,
               bd.BranchName AS DropBranch,
               r.Status
        FROM   Rental   r
        JOIN   Customer c  ON c.CustomerID   = r.CustomerID
        JOIN   Vehicle  v  ON v.VehicleID    = r.VehicleID
        JOIN   Branch   bp ON bp.BranchID    = r.PickupBranch
        JOIN   Branch   bd ON bd.BranchID    = r.DropBranch
        WHERE  r.Status IN ('Active','Overdue')
        ORDER  BY r.StartDate;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "Currently Active / Overdue Rentals")
    pause()


def demo_create_rental(conn):
    section("5.  CREATE A NEW RENTAL  (Stored Procedure Demo)")

    # Show available vehicles
    sql_av = """
        SELECT v.VehicleID,
               CONCAT(v.Make,' ',v.Model) AS Vehicle,
               v.DailyRate, b.BranchName
        FROM   Vehicle v
        JOIN   Branch  b ON b.BranchID = v.BranchID
        WHERE  v.Status = 'Available'
        LIMIT  8;
    """
    rows, cols = run_query(conn, sql_av)
    pretty(rows, cols, "Available Vehicles (sample)")

    # Show customers
    sql_cu = """
        SELECT CustomerID, CONCAT(FirstName,' ',LastName) AS Name
        FROM   Customer LIMIT 10;
    """
    rows2, cols2 = run_query(conn, sql_cu)
    pretty(rows2, cols2, "Customers (sample)")

    print("  We will now create a DEMO rental using:")
    print("    Customer  → ID 3  (Ishant Gupta)")
    print("    Vehicle   → ID 1  (Maruti Swift  –  ₹999/day)")
    print("    Staff     → ID 3  (Caleb George, Agent)")
    print("    Period    → 2024-12-01  to  2024-12-05  (4 days)")
    print("    Branch    → Pickup: 1  |  Drop: 1")
    pause()

    try:
        cursor = conn.cursor()
        cursor.callproc("sp_CreateRental",
                        (3, 1, 3,
                         "2024-12-01", "2024-12-05",
                         1, 1))
        conn.commit()
        cursor.close()
        print("\n  ✅  Rental created successfully via sp_CreateRental!")
    except Error as e:
        print(f"\n  ⚠️   Could not create rental: {e}")
        print("      (This likely means the vehicle is already rented — re-run the SQL file to reset.)")

    pause()


def demo_complete_rental(conn):
    section("6.  COMPLETE A RENTAL  (Stored Procedure Demo)")

    # Show the most recently created active rental
    sql = """
        SELECT r.RentalID,
               CONCAT(c.FirstName,' ',c.LastName) AS Customer,
               CONCAT(v.Make,' ',v.Model)          AS Vehicle,
               r.StartDate, r.ExpectedReturn, r.TotalCost
        FROM   Rental   r
        JOIN   Customer c ON c.CustomerID = r.CustomerID
        JOIN   Vehicle  v ON v.VehicleID  = r.VehicleID
        WHERE  r.Status = 'Active'
        ORDER  BY r.RentalID DESC
        LIMIT  5;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "Active Rentals (most recent first)")

    if not rows:
        print("  No active rentals to complete right now.")
        pause()
        return

    rental_id = rows[0][0]
    print(f"  Completing Rental ID → {rental_id}  with ActualReturn = 2024-12-05")
    pause()

    try:
        cursor = conn.cursor()
        cursor.callproc("sp_CompleteRental", (rental_id, "2024-12-05"))
        conn.commit()
        cursor.close()
        print(f"\n  ✅  Rental {rental_id} marked Completed!")
    except Error as e:
        print(f"\n  ⚠️   Could not complete rental: {e}")

    pause()


def demo_revenue_report(conn):
    section("7.  REVENUE REPORTS")

    sql1 = """
        SELECT b.BranchName, b.City,
               COUNT(r.RentalID)  AS TotalRentals,
               SUM(r.TotalCost)   AS TotalRevenue,
               AVG(r.TotalCost)   AS AvgRentalValue
        FROM   Branch b
        LEFT JOIN Vehicle v ON v.BranchID   = b.BranchID
        LEFT JOIN Rental  r ON r.VehicleID  = v.VehicleID
                            AND r.Status = 'Completed'
        GROUP BY b.BranchID, b.BranchName, b.City
        ORDER BY TotalRevenue DESC;
    """
    rows1, cols1 = run_query(conn, sql1)
    pretty(rows1, cols1, "Revenue by Branch")

    sql2 = """
        SELECT v.VehicleID,
               CONCAT(v.Make,' ',v.Model) AS Vehicle,
               v.LicensePlate,
               COUNT(r.RentalID)          AS TimesRented,
               SUM(r.TotalCost)           AS TotalRevenue
        FROM   Vehicle v
        JOIN   Rental  r ON r.VehicleID = v.VehicleID
        GROUP  BY v.VehicleID
        ORDER  BY TimesRented DESC
        LIMIT  5;
    """
    rows2, cols2 = run_query(conn, sql2)
    pretty(rows2, cols2, "Top 5 Most Rented Vehicles")

    sql3 = """
        SELECT c.CustomerID,
               CONCAT(c.FirstName,' ',c.LastName) AS CustomerName,
               c.Email,
               COUNT(r.RentalID)                  AS CompletedRentals,
               SUM(r.TotalCost)                   AS LifetimeSpend
        FROM   Customer c
        JOIN   Rental   r ON r.CustomerID = c.CustomerID
                          AND r.Status = 'Completed'
        GROUP  BY c.CustomerID
        HAVING CompletedRentals > 0
        ORDER  BY LifetimeSpend DESC
        LIMIT  8;
    """
    rows3, cols3 = run_query(conn, sql3)
    pretty(rows3, cols3, "Top Customers by Lifetime Spend")
    pause()


def demo_maintenance(conn):
    section("8.  MAINTENANCE TRACKER")

    sql1 = """
        SELECT m.MaintenanceID,
               CONCAT(v.Make,' ',v.Model) AS Vehicle,
               v.LicensePlate,
               m.ServiceType, m.ServiceDate,
               m.Cost, m.Status, m.NextServiceDue,
               CONCAT(s.FirstName,' ',s.LastName) AS AssignedTo
        FROM   Maintenance m
        JOIN   Vehicle v ON v.VehicleID = m.VehicleID
        LEFT JOIN Staff  s ON s.StaffID  = m.StaffID
        ORDER  BY m.ServiceDate DESC;
    """
    rows1, cols1 = run_query(conn, sql1)
    pretty(rows1, cols1, "All Maintenance Records")

    sql2 = """
        SELECT v.VehicleID,
               CONCAT(v.Make,' ',v.Model) AS Vehicle,
               v.LicensePlate, v.Mileage,
               MAX(m.ServiceDate)          AS LastServiced
        FROM   Vehicle v
        LEFT JOIN Maintenance m ON m.VehicleID = v.VehicleID
                               AND m.Status = 'Completed'
        GROUP  BY v.VehicleID
        HAVING LastServiced IS NULL
            OR LastServiced < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
    """
    rows2, cols2 = run_query(conn, sql2)
    pretty(rows2, cols2, "Vehicles Due for Service (>6 months since last service)")
    pause()


def demo_damage_reports(conn):
    section("9.  DAMAGE REPORTS")
    sql = """
        SELECT d.DamageID,
               CONCAT(c.FirstName,' ',c.LastName)  AS Customer,
               CONCAT(v.Make,' ',v.Model)           AS Vehicle,
               d.DamageDate, d.Description,
               d.RepairCost,
               IF(d.Resolved,'✅ Resolved','❌ Pending') AS Status
        FROM   DamageReport d
        JOIN   Rental   r ON r.RentalID   = d.RentalID
        JOIN   Customer c ON c.CustomerID = r.CustomerID
        JOIN   Vehicle  v ON v.VehicleID  = r.VehicleID
        ORDER  BY d.DamageDate DESC;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "All Damage Reports")
    pause()


def demo_payment_summary(conn):
    section("10. PAYMENT SUMMARY")
    sql = """
        SELECT p.PaymentID,
               CONCAT(c.FirstName,' ',c.LastName) AS Customer,
               p.Amount,
               DATE_FORMAT(p.PaymentDate,'%d %b %Y %H:%i') AS PaidOn,
               p.Method, p.Status, p.TransactionRef
        FROM   Payment  p
        JOIN   Rental   r ON r.RentalID   = p.RentalID
        JOIN   Customer c ON c.CustomerID = r.CustomerID
        ORDER  BY p.PaymentDate DESC;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "All Payment Transactions")

    sql2 = """
        SELECT Method,
               COUNT(*)       AS Transactions,
               SUM(Amount)    AS TotalAmount,
               AVG(Amount)    AS AvgAmount
        FROM   Payment
        WHERE  Status = 'Completed'
        GROUP  BY Method
        ORDER  BY TotalAmount DESC;
    """
    rows2, cols2 = run_query(conn, sql2)
    pretty(rows2, cols2, "Revenue by Payment Method")
    pause()


def demo_staff_performance(conn):
    section("11. STAFF PERFORMANCE")
    sql = """
        SELECT CONCAT(s.FirstName,' ',s.LastName) AS StaffName,
               s.Role, b.BranchName,
               COUNT(r.RentalID)  AS RentalsProcessed,
               COALESCE(SUM(r.TotalCost),0) AS RevenueHandled
        FROM   Staff  s
        JOIN   Branch b ON b.BranchID  = s.BranchID
        LEFT JOIN Rental r ON r.StaffID = s.StaffID
        GROUP  BY s.StaffID
        ORDER  BY RevenueHandled DESC;
    """
    rows, cols = run_query(conn, sql)
    pretty(rows, cols, "Staff Performance Overview")
    pause()


def demo_overdue_check(conn):
    section("12. OVERDUE RENTALS CHECK")
    sql = """
        SELECT r.RentalID,
               CONCAT(c.FirstName,' ',c.LastName) AS Customer,
               c.Phone,
               CONCAT(v.Make,' ',v.Model)          AS Vehicle,
               v.LicensePlate,
               r.ExpectedReturn,
               DATEDIFF(CURDATE(), r.ExpectedReturn) AS DaysOverdue
        FROM   Rental   r
        JOIN   Customer c ON r.CustomerID = c.CustomerID
        JOIN   Vehicle  v ON r.VehicleID  = v.VehicleID
        WHERE  r.Status = 'Active'
          AND  r.ExpectedReturn < CURDATE();
    """
    rows, cols = run_query(conn, sql)
    if rows:
        pretty(rows, cols, "⚠️  Overdue Rentals")
    else:
        print("\n  ✅  No overdue rentals at this time.\n")
    pause()


# ─────────────────────────────────────────────
#  MAIN MENU
# ─────────────────────────────────────────────

MENU = [
    ("1",  "Branch Overview",                demo_branch_overview),
    ("2",  "Vehicle Availability",           demo_vehicle_availability),
    ("3",  "Customer List",                  demo_customer_list),
    ("4",  "Active Rentals",                 demo_active_rentals),
    ("5",  "Create a New Rental",            demo_create_rental),
    ("6",  "Complete a Rental",              demo_complete_rental),
    ("7",  "Revenue Reports",                demo_revenue_report),
    ("8",  "Maintenance Tracker",            demo_maintenance),
    ("9",  "Damage Reports",                 demo_damage_reports),
    ("10", "Payment Summary",                demo_payment_summary),
    ("11", "Staff Performance",              demo_staff_performance),
    ("12", "Overdue Rentals Check",          demo_overdue_check),
    ("A",  "Run Full Demo (all modules)",    None),
    ("0",  "Exit",                           None),
]


def print_menu():
    os.system("cls" if os.name == "nt" else "clear")
    print("""
╔══════════════════════════════════════════════════════════╗
║         VEHICLE RENTAL SYSTEM — MySQL Demo               ║
║         Team 24BPS / 24BAI  ·  VIT Vellore               ║
╚══════════════════════════════════════════════════════════╝
""")
    for key, label, _ in MENU:
        print(f"    [{key:>2}]  {label}")
    print()


def main():
    print("\n  Connecting to MySQL …", end=" ", flush=True)
    conn = connect()
    print("✅  Connected!\n")

    while True:
        print_menu()
        choice = input("  Select an option: ").strip().upper()

        if choice == "0":
            print("\n  Goodbye!\n")
            break

        elif choice == "A":
            for key, label, fn in MENU:
                if fn:
                    fn(conn)

        else:
            matched = [fn for k, _, fn in MENU if k == choice and fn]
            if matched:
                matched[0](conn)
            else:
                print("\n  Invalid option. Try again.")
                input("  Press Enter to continue...")

    conn.close()


if __name__ == "__main__":
    main()
