
CREATE DATABASE IF NOT EXISTS VehicleRentalDB;
USE VehicleRentalDB;

CREATE TABLE Branch (
    BranchID      INT PRIMARY KEY AUTO_INCREMENT,
    BranchName    VARCHAR(100)  NOT NULL,
    Location      VARCHAR(200)  NOT NULL,
    City          VARCHAR(80)   NOT NULL,
    Phone         VARCHAR(15)   NOT NULL,
    Email         VARCHAR(100)  UNIQUE NOT NULL,
    ManagerID     INT        
);

CREATE TABLE Staff (
    StaffID       INT PRIMARY KEY AUTO_INCREMENT,
    FirstName     VARCHAR(60)   NOT NULL,
    LastName      VARCHAR(60)   NOT NULL,
    Role          ENUM('Manager','Agent','Mechanic','Cleaner') NOT NULL,
    Email         VARCHAR(100)  UNIQUE NOT NULL,
    Phone         VARCHAR(15)   NOT NULL,
    HireDate      DATE          NOT NULL,
    Salary        DECIMAL(10,2) NOT NULL,
    BranchID      INT           NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID) ON DELETE RESTRICT
);

ALTER TABLE Branch
    ADD CONSTRAINT fk_branch_manager
    FOREIGN KEY (ManagerID) REFERENCES Staff(StaffID) ON DELETE SET NULL;

CREATE TABLE Customer (
    CustomerID    INT PRIMARY KEY AUTO_INCREMENT,
    FirstName     VARCHAR(60)   NOT NULL,
    LastName      VARCHAR(60)   NOT NULL,
    Email         VARCHAR(100)  UNIQUE NOT NULL,
    Phone         VARCHAR(15)   NOT NULL,
    LicenseNo     VARCHAR(30)   UNIQUE NOT NULL,
    LicenseExpiry DATE          NOT NULL,
    DOB           DATE          NOT NULL,
    Address       VARCHAR(250)  NOT NULL,
    City          VARCHAR(80)   NOT NULL,
    RegisteredOn  DATETIME      DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE VehicleCategory (
    CategoryID    INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName  VARCHAR(60)   NOT NULL,
    Description   TEXT
);

CREATE TABLE Vehicle (
    VehicleID     INT PRIMARY KEY AUTO_INCREMENT,
    Make          VARCHAR(60)   NOT NULL,
    Model         VARCHAR(60)   NOT NULL,
    Year          YEAR          NOT NULL,
    LicensePlate  VARCHAR(20)   UNIQUE NOT NULL,
    Color         VARCHAR(30)   NOT NULL,
    CategoryID    INT           NOT NULL,
    FuelType      ENUM('Petrol','Diesel','Electric','Hybrid') NOT NULL,
    Transmission  ENUM('Manual','Automatic') NOT NULL,
    Seats         TINYINT       NOT NULL,
    DailyRate     DECIMAL(8,2)  NOT NULL,
    Status        ENUM('Available','Rented','Under Maintenance','Retired') DEFAULT 'Available',
    BranchID      INT           NOT NULL,
    Mileage       INT           DEFAULT 0,
    FOREIGN KEY (CategoryID) REFERENCES VehicleCategory(CategoryID),
    FOREIGN KEY (BranchID)   REFERENCES Branch(BranchID)
);

CREATE TABLE Insurance (
    InsuranceID   INT PRIMARY KEY AUTO_INCREMENT,
    VehicleID     INT           NOT NULL,
    Provider      VARCHAR(100)  NOT NULL,
    PolicyNo      VARCHAR(50)   UNIQUE NOT NULL,
    StartDate     DATE          NOT NULL,
    EndDate       DATE          NOT NULL,
    PremiumAmount DECIMAL(10,2) NOT NULL,
    CoverageType  VARCHAR(100),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE CASCADE
);

-- 2.7  Rental
CREATE TABLE Rental (
    RentalID       INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID     INT           NOT NULL,
    VehicleID      INT           NOT NULL,
    StaffID        INT           NOT NULL,   
    StartDate      DATE          NOT NULL,
    ExpectedReturn DATE          NOT NULL,
    ActualReturn   DATE,
    PickupBranch   INT           NOT NULL,
    DropBranch     INT           NOT NULL,
    DailyRate      DECIMAL(8,2)  NOT NULL,
    TotalDays      INT,
    SubTotal       DECIMAL(10,2),
    TaxAmount      DECIMAL(10,2) DEFAULT 0,
    TotalCost      DECIMAL(10,2),
    Status         ENUM('Active','Completed','Cancelled','Overdue') DEFAULT 'Active',
    Notes          TEXT,
    CreatedAt      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID)   REFERENCES Customer(CustomerID),
    FOREIGN KEY (VehicleID)    REFERENCES Vehicle(VehicleID),
    FOREIGN KEY (StaffID)      REFERENCES Staff(StaffID),
    FOREIGN KEY (PickupBranch) REFERENCES Branch(BranchID),
    FOREIGN KEY (DropBranch)   REFERENCES Branch(BranchID)
);

CREATE TABLE Payment (
    PaymentID     INT PRIMARY KEY AUTO_INCREMENT,
    RentalID      INT           NOT NULL,
    Amount        DECIMAL(10,2) NOT NULL,
    PaymentDate   DATETIME      DEFAULT CURRENT_TIMESTAMP,
    Method        ENUM('Cash','Credit Card','Debit Card','UPI','Net Banking') NOT NULL,
    Status        ENUM('Pending','Completed','Failed','Refunded') DEFAULT 'Pending',
    TransactionRef VARCHAR(80),
    FOREIGN KEY (RentalID) REFERENCES Rental(RentalID) ON DELETE CASCADE
);

CREATE TABLE Maintenance (
    MaintenanceID INT PRIMARY KEY AUTO_INCREMENT,
    VehicleID     INT           NOT NULL,
    StaffID       INT,
    ServiceDate   DATE          NOT NULL,
    ServiceType   VARCHAR(100)  NOT NULL,
    Description   TEXT,
    Cost          DECIMAL(10,2) NOT NULL DEFAULT 0,
    Status        ENUM('Scheduled','In Progress','Completed') DEFAULT 'Scheduled',
    NextServiceDue DATE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE CASCADE,
    FOREIGN KEY (StaffID)   REFERENCES Staff(StaffID) ON DELETE SET NULL
);

-- 2.10  Damage Report
CREATE TABLE DamageReport (
    DamageID      INT PRIMARY KEY AUTO_INCREMENT,
    RentalID      INT           NOT NULL,
    ReportedBy    INT           NOT NULL, 
    DamageDate    DATE          NOT NULL,
    Description   TEXT          NOT NULL,
    RepairCost    DECIMAL(10,2) DEFAULT 0,
    Resolved      BOOLEAN       DEFAULT FALSE,
    FOREIGN KEY (RentalID)   REFERENCES Rental(RentalID),
    FOREIGN KEY (ReportedBy) REFERENCES Staff(StaffID)
);

INSERT INTO VehicleCategory (CategoryName, Description) VALUES
('Economy',    'Budget-friendly compact cars for city travel'),
('Sedan',      'Comfortable mid-size cars for everyday use'),
('SUV',        'Sports Utility Vehicles with high ground clearance'),
('Luxury',     'Premium vehicles for executive travel'),
('Van',        'Large capacity vehicles for groups or cargo'),
('Motorcycle', 'Two-wheelers for agile urban commuting');

INSERT INTO Branch (BranchName, Location, City, Phone, Email) VALUES
('VRS Downtown',  '12 MG Road, Near Central Park', 'Chennai',   '04422334455', 'downtown@vrs.com'),
('VRS Airport',   'Terminal 2, GST Road',           'Chennai',   '04422991122', 'airport@vrs.com'),
('VRS North Hub', '45 Anna Salai, Ambattur',        'Chennai',   '04422556677', 'north@vrs.com'),
('VRS Bangalore', '88 Residency Road',              'Bangalore', '08044112233', 'blr@vrs.com');

INSERT INTO Staff (FirstName, LastName, Role, Email, Phone, HireDate, Salary, BranchID) VALUES
('Arjun',    'Sharma',    'Manager',  'arjun.sharma@vrs.com',    '9876543210', '2020-03-15', 65000.00, 1),
('Priya',    'Nair',      'Manager',  'priya.nair@vrs.com',      '9876543211', '2019-07-01', 68000.00, 2),
('Karthik',  'Raj',       'Agent',    'karthik.raj@vrs.com',     '9876543212', '2021-01-10', 38000.00, 1),
('Deepa',    'Menon',     'Agent',    'deepa.menon@vrs.com',     '9876543213', '2022-06-20', 36000.00, 2),
('Ramesh',   'Kumar',     'Mechanic', 'ramesh.kumar@vrs.com',    '9876543214', '2020-11-05', 42000.00, 1),
('Sunita',   'Verma',     'Mechanic', 'sunita.verma@vrs.com',    '9876543215', '2021-03-22', 40000.00, 3),
('Vijay',    'Krishnan',  'Manager',  'vijay.k@vrs.com',         '9876543216', '2018-09-01', 72000.00, 3),
('Lakshmi',  'Iyer',      'Agent',    'lakshmi.iyer@vrs.com',    '9876543217', '2023-02-14', 35000.00, 4),
('Anand',    'Pillai',    'Manager',  'anand.pillai@vrs.com',    '9876543218', '2017-05-10', 75000.00, 4),
('Meena',    'Rajan',     'Cleaner',  'meena.rajan@vrs.com',     '9876543219', '2022-08-30', 25000.00, 1);

UPDATE Branch SET ManagerID = 1 WHERE BranchID = 1;
UPDATE Branch SET ManagerID = 2 WHERE BranchID = 2;
UPDATE Branch SET ManagerID = 7 WHERE BranchID = 3;
UPDATE Branch SET ManagerID = 9 WHERE BranchID = 4;

INSERT INTO Customer (FirstName, LastName, Email, Phone, LicenseNo, LicenseExpiry, DOB, Address, City) VALUES
('Aditya',   'Mehta',    'aditya.mehta@gmail.com',    '9001234567', 'TN01-2018-0012345', '2028-04-10', '1993-07-15', '22 Besant Nagar, 4th Lane',   'Chennai'),
('Sneha',    'Patel',    'sneha.patel@gmail.com',     '9001234568', 'TN02-2020-0054321', '2030-09-20', '1998-02-28', '7 T Nagar Main Road',          'Chennai'),
('Rahul',    'Gupta',    'rahul.gupta@gmail.com',     '9001234569', 'KA01-2019-0099876', '2029-05-15', '1990-11-12', '55 Indiranagar, 12th Cross',   'Bangalore'),
('Ananya',   'Bose',     'ananya.bose@gmail.com',     '9001234570', 'TN03-2021-0011122', '2031-03-30', '1996-08-05', '10 Adyar Bridge Road',         'Chennai'),
('Kiran',    'Joshi',    'kiran.joshi@gmail.com',     '9001234571', 'MH01-2017-0077665', '2027-11-22', '1985-03-25', '33 Juhu Beach Colony',         'Mumbai'),
('Divya',    'Nair',     'divya.nair@gmail.com',      '9001234572', 'TN04-2022-0034567', '2032-07-18', '2000-06-14', '18 Velachery Main Road',       'Chennai'),
('Suresh',   'Babu',     'suresh.babu@gmail.com',     '9001234573', 'TN05-2016-0009988', '2026-08-01', '1980-12-30', '5 Anna Nagar 3rd Avenue',      'Chennai'),
('Pooja',    'Sinha',    'pooja.sinha@gmail.com',     '9001234574', 'DL01-2020-0043210', '2030-12-05', '1995-04-22', '77 CP Colony, Block B',        'Delhi'),
('Manoj',    'Reddy',    'manoj.reddy@gmail.com',     '9001234575', 'TG01-2018-0056789', '2028-06-15', '1988-09-17', '14 Jubilee Hills, Road No 10', 'Hyderabad'),
('Kavitha',  'Sundaram', 'kavitha.s@gmail.com',       '9001234576', 'TN06-2019-0022334', '2029-10-10', '1992-01-08', '9 Mylapore Tank Square',       'Chennai');

INSERT INTO Vehicle (Make, Model, Year, LicensePlate, Color, CategoryID, FuelType, Transmission, Seats, DailyRate, Status, BranchID, Mileage) VALUES
('Maruti',   'Swift',        2021, 'TN01AB1234', 'White',      1, 'Petrol',   'Manual',    5,  999.00,  'Available',          1, 25000),
('Honda',    'City',         2022, 'TN01AB5678', 'Silver',     2, 'Petrol',   'Automatic', 5, 1499.00,  'Available',          1, 18000),
('Toyota',   'Fortuner',     2023, 'TN02CD1122', 'Black',      3, 'Diesel',   'Automatic', 7, 3500.00,  'Rented',             2, 12000),
('BMW',      '3 Series',     2022, 'TN02CD3344', 'Blue',       4, 'Petrol',   'Automatic', 5, 5500.00,  'Available',          2,  8000),
('Tata',     'Ace',          2020, 'TN03EF5566', 'White',      5, 'Diesel',   'Manual',    2, 1200.00,  'Available',          3, 40000),
('Royal Enfield', 'Classic 350', 2022, 'TN01GH7788', 'Black',  6, 'Petrol',   'Manual',    2,  600.00,  'Available',          1, 15000),
('Hyundai',  'Creta',        2023, 'TN04IJ9900', 'Red',        3, 'Petrol',   'Automatic', 5, 2500.00,  'Available',          4, 11000),
('Maruti',   'Ertiga',       2021, 'TN03KL1234', 'Grey',       5, 'Petrol',   'Manual',    7, 1800.00,  'Under Maintenance',  3, 32000),
('Mercedes', 'E-Class',      2023, 'TN02MN5678', 'White',      4, 'Petrol',   'Automatic', 5, 8000.00,  'Available',          2,  5000),
('Tata',     'Nexon EV',     2023, 'TN01OP9012', 'Blue',       3, 'Electric', 'Automatic', 5, 2200.00,  'Available',          1,  7000),
('Maruti',   'Alto',         2020, 'TN01QR3456', 'Red',        1, 'Petrol',   'Manual',    5,  799.00,  'Rented',             1, 45000),
('Toyota',   'Camry',        2022, 'TN04ST7890', 'Black',      4, 'Hybrid',   'Automatic', 5, 4500.00,  'Available',          4,  9500);

INSERT INTO Insurance (VehicleID, Provider, PolicyNo, StartDate, EndDate, PremiumAmount, CoverageType) VALUES
(1,  'HDFC Ergo',   'HDFC-2023-V001', '2023-01-01', '2024-12-31', 12000.00, 'Comprehensive'),
(2,  'ICICI Lombard','ICICI-2022-V002','2022-06-01', '2024-05-31', 18000.00, 'Comprehensive'),
(3,  'New India',   'NIA-2023-V003',  '2023-03-15', '2025-03-14', 25000.00, 'Comprehensive'),
(4,  'Bajaj Allianz','BAJ-2022-V004', '2022-09-01', '2024-08-31', 40000.00, 'Comprehensive'),
(5,  'United India', 'UII-2020-V005', '2020-07-01', '2024-06-30',  8000.00, 'Third Party'),
(6,  'HDFC Ergo',   'HDFC-2022-V006', '2022-04-01', '2024-03-31',  6000.00, 'Third Party'),
(7,  'ICICI Lombard','ICICI-2023-V007','2023-01-10', '2024-12-09', 20000.00, 'Comprehensive'),
(9,  'Bajaj Allianz','BAJ-2023-V009', '2023-05-01', '2025-04-30', 60000.00, 'Comprehensive'),
(10, 'HDFC Ergo',   'HDFC-2023-V010', '2023-07-01', '2025-06-30', 22000.00, 'Comprehensive');

INSERT INTO Rental (CustomerID, VehicleID, StaffID, StartDate, ExpectedReturn, ActualReturn,
                    PickupBranch, DropBranch, DailyRate, TotalDays, SubTotal, TaxAmount, TotalCost, Status) VALUES
(1,  3,  3, '2024-01-05', '2024-01-10', '2024-01-10', 2, 2, 3500.00, 5,  17500.00, 2625.00, 20125.00, 'Completed'),
(2,  11, 4, '2024-01-12', '2024-01-15', '2024-01-15', 1, 1,  799.00, 3,   2397.00,  359.55,  2756.55, 'Completed'),
(3,  7,  8, '2024-02-01', '2024-02-07', '2024-02-07', 4, 4, 2500.00, 6,  15000.00, 2250.00, 17250.00, 'Completed'),
(4,  1,  3, '2024-02-14', '2024-02-17', '2024-02-18', 1, 1,  999.00, 4,   3996.00,  599.40,  4595.40, 'Completed'),
(5,  4,  4, '2024-02-20', '2024-02-25', '2024-02-25', 2, 2, 5500.00, 5,  27500.00, 4125.00, 31625.00, 'Completed'),
(6,  2,  3, '2024-03-01', '2024-03-05', NULL,          1, 1, 1499.00, 4,   5996.00,  899.40,  6895.40, 'Active'),
(7,  6,  3, '2024-03-10', '2024-03-12', '2024-03-12', 1, 1,  600.00, 2,   1200.00,  180.00,  1380.00, 'Completed'),
(8,  9,  4, '2024-03-15', '2024-03-18', NULL,          2, 4, 8000.00, 3,  24000.00, 3600.00, 27600.00, 'Active'),
(9,  10, 3, '2024-03-20', '2024-03-25', NULL,          1, 1, 2200.00, 5,  11000.00, 1650.00, 12650.00, 'Active'),
(10, 12, 8, '2024-03-22', '2024-03-28', '2024-03-28', 4, 4, 4500.00, 6,  27000.00, 4050.00, 31050.00, 'Completed');

INSERT INTO Payment (RentalID, Amount, PaymentDate, Method, Status, TransactionRef) VALUES
(1,  20125.00, '2024-01-05 10:30:00', 'Credit Card',  'Completed', 'TXN2024010501'),
(2,   2756.55, '2024-01-12 14:00:00', 'UPI',          'Completed', 'TXN2024011201'),
(3,  17250.00, '2024-02-01 09:00:00', 'Debit Card',   'Completed', 'TXN2024020101'),
(4,   4595.40, '2024-02-14 11:00:00', 'Cash',         'Completed', 'TXN2024021401'),
(5,  31625.00, '2024-02-20 16:00:00', 'Net Banking',  'Completed', 'TXN2024022001'),
(6,   6895.40, '2024-03-01 09:30:00', 'Credit Card',  'Pending',   'TXN2024030101'),
(7,   1380.00, '2024-03-10 12:00:00', 'Cash',         'Completed', 'TXN2024031001'),
(8,  27600.00, '2024-03-15 10:00:00', 'Credit Card',  'Pending',   'TXN2024031501'),
(9,  12650.00, '2024-03-20 11:30:00', 'UPI',          'Pending',   'TXN2024032001'),
(10, 31050.00, '2024-03-22 14:00:00', 'Debit Card',   'Completed', 'TXN2024032201');

INSERT INTO Maintenance (VehicleID, StaffID, ServiceDate, ServiceType, Description, Cost, Status, NextServiceDue) VALUES
(8,  5, '2024-03-01', 'Regular Service',  'Oil change, filter replacement, brake inspection', 3500.00, 'Completed', '2024-09-01'),
(1,  5, '2024-02-15', 'Tyre Rotation',    'All four tyres rotated and balanced',              1200.00, 'Completed', '2024-08-15'),
(5,  6, '2024-01-20', 'Engine Overhaul',  'Full engine service and belt replacement',         8500.00, 'Completed', '2025-01-20'),
(3,  5, '2024-03-25', 'Oil Change',       'Engine oil and oil filter replaced',               1500.00, 'In Progress', '2024-09-25'),
(11, 6, '2024-03-28', 'Regular Service',  'Periodic maintenance as per manufacturer schedule',2800.00, 'Scheduled', '2024-09-28');

INSERT INTO DamageReport (RentalID, ReportedBy, DamageDate, Description, RepairCost, Resolved) VALUES
(1, 3, '2024-01-10', 'Minor scratch on rear bumper from parking lot', 3500.00, TRUE),
(4, 4, '2024-02-18', 'Dent on left rear door, cause reported as a bollard hit', 8000.00, FALSE);

SELECT v.VehicleID, CONCAT(v.Make,' ',v.Model) AS Vehicle,
       v.Year, v.LicensePlate, vc.CategoryName, v.FuelType,
       v.DailyRate, b.BranchName, b.City
FROM   Vehicle v
JOIN   VehicleCategory vc ON v.CategoryID = vc.CategoryID
JOIN   Branch b            ON v.BranchID  = b.BranchID
WHERE  v.Status = 'Available'
ORDER BY v.DailyRate;

SELECT r.RentalID,
       CONCAT(c.FirstName,' ',c.LastName) AS Customer,
       CONCAT(v.Make,' ',v.Model)         AS Vehicle,
       r.StartDate, r.ExpectedReturn,
       r.TotalCost, r.Status
FROM   Rental r
JOIN   Customer c ON r.CustomerID = c.CustomerID
JOIN   Vehicle  v ON r.VehicleID  = v.VehicleID
WHERE  r.Status = 'Active';

SELECT b.BranchName, b.City,
       COUNT(r.RentalID)     AS TotalRentals,
       SUM(r.TotalCost)      AS TotalRevenue,
       AVG(r.TotalCost)      AS AvgRentalValue
FROM   Branch b
LEFT JOIN Vehicle v  ON v.BranchID   = b.BranchID
LEFT JOIN Rental  r  ON r.VehicleID  = v.VehicleID AND r.Status = 'Completed'
GROUP BY b.BranchID, b.BranchName, b.City
ORDER BY TotalRevenue DESC;

SELECT v.VehicleID, CONCAT(v.Make,' ',v.Model) AS Vehicle,
       v.LicensePlate, COUNT(r.RentalID) AS TimesRented,
       SUM(r.TotalCost) AS TotalRevenue
FROM   Vehicle v
JOIN   Rental  r ON r.VehicleID = v.VehicleID
GROUP BY v.VehicleID
ORDER BY TimesRented DESC
LIMIT 5;

SELECT c.CustomerID,
       CONCAT(c.FirstName,' ',c.LastName) AS CustomerName,
       c.Email, COUNT(r.RentalID)         AS CompletedRentals,
       SUM(r.TotalCost)                   AS LifetimeSpend
FROM   Customer c
JOIN   Rental   r ON r.CustomerID = c.CustomerID AND r.Status = 'Completed'
GROUP BY c.CustomerID
HAVING CompletedRentals > 1
ORDER BY LifetimeSpend DESC;

SELECT r.RentalID,
       CONCAT(c.FirstName,' ',c.LastName) AS Customer,
       c.Phone,
       CONCAT(v.Make,' ',v.Model)         AS Vehicle,
       v.LicensePlate,
       r.ExpectedReturn,
       DATEDIFF(CURDATE(), r.ExpectedReturn) AS DaysOverdue
FROM   Rental   r
JOIN   Customer c ON r.CustomerID = c.CustomerID
JOIN   Vehicle  v ON r.VehicleID  = v.VehicleID
WHERE  r.Status = 'Active'
  AND  r.ExpectedReturn < CURDATE();

SELECT YEAR(r.CreatedAt) AS Year, MONTH(r.CreatedAt) AS Month,
       COUNT(*) AS Rentals, SUM(r.TotalCost) AS Revenue
FROM   Rental r
WHERE  r.Status = 'Completed'
GROUP BY YEAR(r.CreatedAt), MONTH(r.CreatedAt)
ORDER BY Year, Month;

SELECT v.VehicleID, CONCAT(v.Make,' ',v.Model) AS Vehicle,
       v.LicensePlate, v.Mileage,
       MAX(m.ServiceDate)  AS LastServiced
FROM   Vehicle v
LEFT JOIN Maintenance m ON m.VehicleID = v.VehicleID AND m.Status = 'Completed'
GROUP BY v.VehicleID
HAVING LastServiced IS NULL OR LastServiced < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

SELECT CONCAT(s.FirstName,' ',s.LastName) AS StaffName, s.Role,
       b.BranchName,
       COUNT(r.RentalID)  AS RentalsProcessed,
       SUM(r.TotalCost)   AS RevenueHandled
FROM   Staff  s
JOIN   Branch b ON s.BranchID  = b.BranchID
LEFT JOIN Rental r ON r.StaffID = s.StaffID
WHERE  s.Role = 'Agent'
GROUP BY s.StaffID
ORDER BY RevenueHandled DESC;

SELECT vc.CategoryName,
       COUNT(v.VehicleID) AS VehicleCount,
       AVG(v.DailyRate)   AS AvgDailyRate,
       MIN(v.DailyRate)   AS MinRate,
       MAX(v.DailyRate)   AS MaxRate
FROM   VehicleCategory vc
JOIN   Vehicle v ON v.CategoryID = vc.CategoryID
GROUP BY vc.CategoryID
ORDER BY AvgDailyRate;

CREATE OR REPLACE VIEW vw_RentalDetails AS
SELECT r.RentalID,
       CONCAT(c.FirstName,' ',c.LastName)  AS CustomerName,
       c.Phone                              AS CustomerPhone,
       CONCAT(v.Make,' ',v.Model,' (',v.Year,')') AS Vehicle,
       v.LicensePlate,
       vc.CategoryName,
       bp.BranchName   AS PickupBranch,
       bd.BranchName   AS DropBranch,
       r.StartDate, r.ExpectedReturn, r.ActualReturn,
       r.DailyRate, r.TotalDays, r.TotalCost, r.Status
FROM   Rental r
JOIN   Customer       c  ON r.CustomerID   = c.CustomerID
JOIN   Vehicle        v  ON r.VehicleID    = v.VehicleID
JOIN   VehicleCategory vc ON v.CategoryID  = vc.CategoryID
JOIN   Branch         bp ON r.PickupBranch = bp.BranchID
JOIN   Branch         bd ON r.DropBranch   = bd.BranchID;

CREATE OR REPLACE VIEW vw_VehicleAvailability AS
SELECT b.BranchName, b.City,
       COUNT(CASE WHEN v.Status='Available'          THEN 1 END) AS Available,
       COUNT(CASE WHEN v.Status='Rented'             THEN 1 END) AS Rented,
       COUNT(CASE WHEN v.Status='Under Maintenance'  THEN 1 END) AS UnderMaintenance,
       COUNT(v.VehicleID)                                        AS Total
FROM   Branch b
LEFT JOIN Vehicle v ON v.BranchID = b.BranchID
GROUP BY b.BranchID;

CREATE PROCEDURE sp_CreateRental (
    IN p_CustomerID     INT,
    IN p_VehicleID      INT,
    IN p_StaffID        INT,
    IN p_StartDate      DATE,
    IN p_ExpectedReturn DATE,
    IN p_PickupBranch   INT,
    IN p_DropBranch     INT
)
BEGIN
    DECLARE v_DailyRate  DECIMAL(8,2);
    DECLARE v_TotalDays  INT;
    DECLARE v_SubTotal   DECIMAL(10,2);
    DECLARE v_Tax        DECIMAL(10,2);
    DECLARE v_Total      DECIMAL(10,2);

    SELECT DailyRate INTO v_DailyRate FROM Vehicle WHERE VehicleID = p_VehicleID;
    SET v_TotalDays = DATEDIFF(p_ExpectedReturn, p_StartDate);
    SET v_SubTotal  = v_DailyRate * v_TotalDays;
    SET v_Tax       = v_SubTotal  * 0.15;   -- 15% tax
    SET v_Total     = v_SubTotal  + v_Tax;

    INSERT INTO Rental (CustomerID, VehicleID, StaffID, StartDate, ExpectedReturn,
                        PickupBranch, DropBranch, DailyRate, TotalDays,
                        SubTotal, TaxAmount, TotalCost, Status)
    VALUES (p_CustomerID, p_VehicleID, p_StaffID, p_StartDate, p_ExpectedReturn,
            p_PickupBranch, p_DropBranch, v_DailyRate, v_TotalDays,
            v_SubTotal, v_Tax, v_Total, 'Active');

    UPDATE Vehicle SET Status = 'Rented' WHERE VehicleID = p_VehicleID;
END$$

CREATE PROCEDURE sp_CompleteRental (
    IN p_RentalID    INT,
    IN p_ActualReturn DATE
)
BEGIN
    DECLARE v_VehicleID INT;
    UPDATE Rental
    SET    ActualReturn = p_ActualReturn,
           Status       = 'Completed'
    WHERE  RentalID = p_RentalID;

    SELECT VehicleID INTO v_VehicleID FROM Rental WHERE RentalID = p_RentalID;
    UPDATE Vehicle SET Status = 'Available' WHERE VehicleID = v_VehicleID;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_CheckVehicleAvailability
BEFORE INSERT ON Rental
FOR EACH ROW
BEGIN
    DECLARE v_Status VARCHAR(25);
    SELECT Status INTO v_Status FROM Vehicle WHERE VehicleID = NEW.VehicleID;
    IF v_Status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vehicle is not available for rental.';
    END IF;
END$$

CREATE TRIGGER trg_SetOverdue
BEFORE UPDATE ON Rental
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Active' AND NEW.ExpectedReturn < CURDATE() AND NEW.ActualReturn IS NULL THEN
        SET NEW.Status = 'Overdue';
    END IF;
END$$

DELIMITER ;

CREATE INDEX idx_rental_customer    ON Rental(CustomerID);
CREATE INDEX idx_rental_vehicle     ON Rental(VehicleID);
CREATE INDEX idx_rental_status      ON Rental(Status);
CREATE INDEX idx_vehicle_status     ON Vehicle(Status);
CREATE INDEX idx_vehicle_branch     ON Vehicle(BranchID);
CREATE INDEX idx_payment_rental     ON Payment(RentalID);
CREATE INDEX idx_maintenance_vehicle ON Maintenance(VehicleID);

SELECT 'Vehicle Rental System database created and populated successfully!' AS Message;
