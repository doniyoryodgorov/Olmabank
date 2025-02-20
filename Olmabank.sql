<<<<<<< HEAD
create database Olmabank
use Olmabank
go
create schema Olmabank_core
create schema Olmabank_digital
=======
﻿create database Olmabank
use Olmabank
go
create schema Olmabank_core
create schema Olmabank_digital
create schema Olmabank_loans
create schema Olmabank_risk

/*
	CustomerID (PK)
•	FullName, DOB, Email, PhoneNumber, Address
•	NationalID, TaxID, EmploymentStatus, AnnualIncome
•	CreatedAt, UpdatedAt
*/

create table Olmabank_core.Customers (
CustomerID INT PRIMARY KEY IDENTITY(1,1),
FullName NVARCHAR(100) NOT NULL,
DOB DATE NOT NULL,
Email NVARCHAR(100) UNIQUE,
PhoneNumber NVARCHAR(50) UNIQUE,
Address NVARCHAR(200),
NationalID NVARCHAR(50) UNIQUE,
TaxID NVARCHAR(50) UNIQUE,
EmploymentStatus NVARCHAR(20),
AnnualIncome DECIMAL (20,2),
CreatedAt DATETIME DEFAULT GETDATE(),
UpdatedAt DATETIME DEFAULT GETDATE()
);

/*
INSERT INTO olmabank_core.Customers (FullName, DOB, Email, PhoneNumber, Address, NationalID, TaxID, EmploymentStatus, AnnualIncome, CreatedAt)
SELECT TOP 10000
    'Customer ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NVARCHAR), 
    DATEADD(YEAR, -FLOOR(RAND()*50 + 18), GETDATE()), 
    'customer' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NVARCHAR) + '@email.com',
    CAST(1000000000 + FLOOR(RAND() * 9000000000) AS NVARCHAR),
    'Random Address ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NVARCHAR),
    CONVERT(NVARCHAR(50), NEWID()),  -- 100% UNIQUE NationalID
    CONVERT(NVARCHAR(50), NEWID()),  -- 100% UNIQUE TaxID
    CASE WHEN RAND() > 0.5 THEN 'Employed' ELSE 'Unemployed' END,
    FLOOR(RAND() * 100000 + 20000),
    GETDATE()
FROM master.dbo.spt_values a  
CROSS JOIN master.dbo.spt_values b;
*/
--To quickly add large amounts of customer data, we'll use chatgpt query of containing 10000+ rows
use Olmabank
go

create table Olmabank_core.Accounts(
AccountID INT PRIMARY KEY IDENTITY(1,1),
CustomerID INT NOT NULL,
AccountType NVARCHAR(20) CHECK (AccountType IN ('Savings', 'Checking', 'Business')),
Balance DECIMAL(30,2) DEFAULT 0.00,
Currency NVARCHAR(10) DEFAULT 'USD',
Status NVARCHAR(20) CHECK (Status IN ('Active', 'Inactive', 'Closed')),
BranchID INT NOT NULL, 
CreatedDate DATETIME DEFAULT GETDATE(),
CONSTRAINT FK_Accounts_Customers FOREIGN KEY(CustomerID) REFERENCES olmabank_core.Customers(CustomerID)
);

--Olmabank_core.Accounts tablega ma'lumotlar chatgpt yordamida query yasalib, insert qilindi.

create table Olmabank_core.Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT NOT NULL,
    TransactionType NVARCHAR(20) CHECK (TransactionType IN ('Deposit', 'Withdrawal', 'Transfer', 'Payment')),
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
    Currency NVARCHAR(3) DEFAULT 'USD',
    Date DATETIME,
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Completed', 'Failed')),
    ReferenceNo NVARCHAR(50) UNIQUE,
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountID) REFERENCES olmabank_core.Accounts(AccountID)
);

--Olmabank_core.Transactions tablega ma'lumotlar chatgpt yordamida query yasalib, insert qilindi.

CREATE TABLE Olmabank_core.Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT NULL,  -- BranchID NULL bo‘lishi mumkin, chunki filial hali aniqlanmagan bo‘lishi mumkin
    FullName NVARCHAR(100) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    Department NVARCHAR(50) NOT NULL,
    Salary DECIMAL(18,2) CHECK (Salary > 0),
    HireDate DATE,
    Status NVARCHAR(20) CHECK (Status IN ('Active', 'Inactive'))
);

----Olmabank_core.Employees jadvaliga ma'lumotni avtomat tartibda yaratib qo'shamiz

CREATE TABLE Olmabank_core.Branches (
    BranchID INT PRIMARY KEY IDENTITY(1,1),
    BranchName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    State NVARCHAR(50),
    Country NVARCHAR(50) NOT NULL,
    ManagerID INT UNIQUE NULL,
    ContactNumber NVARCHAR(20),
    CONSTRAINT FK_Branches_Manager FOREIGN KEY (ManagerID) REFERENCES olmabank_core.Employees(EmployeeID)
);

--Olmabank_core.Branches  jadvaliga ma'lumotni avtomat tartibda yaratib qo'shamiz.

CREATE TABLE olmabank_core.CreditCards (
    CardID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    CardNumber NVARCHAR(16) UNIQUE NOT NULL,
    CardType NVARCHAR(20) CHECK (CardType IN ('Visa', 'MasterCard', 'American Express', 'UzCard', 'Humo')),
    CVV NVARCHAR(3) NOT NULL,
    ExpiryDate DATE NOT NULL,
    Limit DECIMAL(18,2) CHECK (Limit >= 0),
    Status NVARCHAR(20) CHECK (Status IN ('Active', 'Blocked', 'Expired')),
    CONSTRAINT FK_CreditCards_Customers FOREIGN KEY (CustomerID) REFERENCES olmabank_core.Customers(CustomerID)
);

--olmabank_core.CreditCards  jadvaliga ma'lumotni avtomat tartibda yaratib qo'shamiz.

CREATE TABLE Olmabank_digital.CreditCardTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    CardID INT NOT NULL,
    Merchant NVARCHAR(100) NOT NULL,
    Amount DECIMAL(20,2) CHECK (Amount > 0) NOT NULL,
    Currency NVARCHAR(3) DEFAULT 'USD',
    Date DATETIME,
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Completed', 'Failed')),
    CONSTRAINT FK_CreditCardTransactions_CreditCards FOREIGN KEY (CardID) REFERENCES olmabank_digital.CreditCards(CardID)
);


USE olmabank;
GO

DECLARE @i INT = 1;

WHILE @i <= 10000
BEGIN
    INSERT INTO Olmabank_digital.CreditCardTransactions (CardID, Merchant, Amount, Currency, Date, Status)
    VALUES (
        -- CardID: 1 dan 10000 gacha (tasodifiy)
        CAST(ABS(CHECKSUM(NEWID())) % 10000 + 1 AS INT),
        
        -- Merchant: tasodifiy tanlangan
        (SELECT TOP 1 Merchant 
         FROM (VALUES ('Amazon'), ('Walmart'), ('Apple Store'), ('Google Play'), ('Netflix'), ('McDonalds'), ('Starbucks Coffee'), ('Uber'), ('Booking.com'), ('AliExpress')) AS Merchants(Merchant)
         ORDER BY NEWID()),
         
        -- Amount: $5 - $5000 oralig‘ida tasodifiy qiymat
        ROUND(RAND(CHECKSUM(NEWID())) * 4995 + 5, 2),
        
        -- Currency: 'USD', 'EUR' yoki 'UZS'
        (SELECT TOP 1 Currency 
         FROM (VALUES ('USD'), ('EUR'), ('UZS')) AS Currencies(Currency)
         ORDER BY NEWID()),
         
        -- Date: hozirgi sanadan maksimal 365 kun oldingi tasodifiy sana (so‘nggi 1 yil ichida)
        DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 365), GETDATE()),
        
        -- Status: 'Pending', 'Completed' yoki 'Failed'
        (SELECT TOP 1 Status 
         FROM (VALUES ('Pending'), ('Completed'), ('Failed')) AS Statuses(Status)
         ORDER BY NEWID())
    );
    SET @i = @i + 1;
END;
GO

--funksiya orqali 10000+qatorlar yasaldi.

CREATE TABLE Olmabank_digital.OnlineBankingUsers(
	UserID INT PRIMARY KEY IDENTITY(1,1),
	CustomerID INT NOT NULL,
	Username NVARCHAR(30) NOT NULL UNIQUE,
	PasswordHash NVARCHAR(90) NOT NULL,
	LastLogin DATETIME NULL,
	CONSTRAINT FK_OnlineBankingUsers_Customers FOREIGN KEY (CustomerID)
        REFERENCES olmabank_core.Customers(CustomerID)
);

--Olmabank_digital.OnlineBankingUsers  jadvaliga ma'lumotni avtomat tartibda yaratib qo'shamiz.

CREATE TABLE Olmabank_digital.BillPayments(
	PaymentID INT PRIMARY KEY IDENTITY(1,1),
	 CustomerID INT NOT NULL,
    BillerName NVARCHAR(100) NOT NULL,
    Amount DECIMAL(18,2) CHECK (Amount > 0) NOT NULL,
    Date DATETIME,
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Completed', 'Failed')),
    CONSTRAINT FK_BillPayments_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID)
);
GO

-- Olmabank_digital.BillPayments jadvaliga ma'lumotni avtomat tartibda yaratib qo'shamiz.

CREATE TABLE Olmabank_digital.MobileBankingTransactions(
	TransactionID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    DeviceID NVARCHAR(50) NOT NULL,
    AppVersion NVARCHAR(10) NOT NULL,
    TransactionType NVARCHAR(20) CHECK (TransactionType IN ('Deposit', 'Withdrawal', 'Transfer', 'Payment')),
    Amount DECIMAL(18,2) CHECK (Amount > 0) NOT NULL,
    Date DATETIME,
    CONSTRAINT FK_MobileBankingTransactions_Customers FOREIGN KEY (CustomerID)
        REFERENCES olmabank_core.Customers(CustomerID)
);

--Olmabank_digital.MobileBankingTransactions jadvaliga ma'lumotni avtomat tartibda yaratib qo'shamiz.

CREATE TABLE Olmabank_loans.Loans (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    LoanType NVARCHAR(20) CHECK (LoanType IN ('Mortgage', 'Personal', 'Auto', 'Business')),
    Amount DECIMAL(18,2) CHECK (Amount > 0) NOT NULL,
    InterestRate DECIMAL(5,2) CHECK (InterestRate > 0) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Active', 'Closed', 'Defaulted')),
    CONSTRAINT FK_Loans_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID)
	);

CREATE TABLE Olmabank_loans.LoanPayments(
	PaymentID INT PRIMARY KEY IDENTITY(1,1),
	LoanID INT NOT NULL,
	AmountPaid DECIMAL(18,2) CHECK (AmountPaid > 0) NOT NULL,
	PaymentDate DATE,
	RemainingBalance DECIMAL(18,2) CHECK (RemainingBalance >= 0) NOT NULL
	CONSTRAINT FK_LoanPayments_Loans FOREIGN KEY(LoanID)
	REFERENCES Olmabank_loans.Loans (LoanID)
	);

USE olmabank;
GO

DECLARE @i INT = 1;
DECLARE @LoanID INT;
DECLARE @LoanAmount DECIMAL(18,2);
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
DECLARE @AmountPaid DECIMAL(18,2);
DECLARE @PaymentDate DATE;
DECLARE @RemainingBalance DECIMAL(18,2);

WHILE @i <= 10000
BEGIN
    -- LoanID ni tasodifiy tanlaymiz
    SELECT TOP 1 @LoanID = LoanID, 
                 @LoanAmount = Amount, 
                 @StartDate = StartDate, 
                 @EndDate = EndDate
    FROM olmabank_loans.Loans 
    ORDER BY NEWID();

    -- To'lov miqdorini aniqlaymiz (10% - 90% oralig'ida)
    SET @AmountPaid = ROUND((RAND() * (@LoanAmount * 0.8) + (@LoanAmount * 0.1)), 2);

    -- PaymentDate kredit boshlanishidan oldin emas va tugash sanasidan keyin emas
    SET @PaymentDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 365), @StartDate);
    IF @PaymentDate > @EndDate
        SET @PaymentDate = @EndDate;

    -- Qolgan balans (to'lovdan keyin)
    SET @RemainingBalance = @LoanAmount - @AmountPaid;
    IF @RemainingBalance < 0 
        SET @RemainingBalance = 0;

    -- Ma'lumotlarni LoanPayments jadvaliga qo'shish
    INSERT INTO olmabank_loans.LoanPayments (LoanID, AmountPaid, PaymentDate, RemainingBalance)
    VALUES (@LoanID, @AmountPaid, @PaymentDate, @RemainingBalance);

    SET @i = @i + 1;
END;
GO

USE olmabank;
GO

CREATE TABLE Olmabank_loans.CreditScores(
	CustomerID INT NOT NULL,
	CreditScore INT CHECK (CreditScore BETWEEN 300 AND 850) NOT NULL,
	UpdatedAt DATE,
	CONSTRAINT FK_CreditScores_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID)
);
GO

USE olmabank;
GO

-- 1️⃣ `CreditScores` jadvalini yaratamiz
IF OBJECT_ID('olmabank_loans.CreditScores', 'U') IS NOT NULL
    DROP TABLE olmabank_loans.CreditScores;
GO

CREATE TABLE olmabank_loans.CreditScores (
    CustomerID INT NOT NULL,
    CreditScore INT CHECK (CreditScore BETWEEN 300 AND 400) NOT NULL, -- Max 400
    UpdatedAt DATE NOT NULL,
    CONSTRAINT FK_CreditScores_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID)
);
GO

-- 2️⃣ `CreditScores` jadvaliga 10,000+ qator qo‘shish uchun `WHILE` sikli
DECLARE @i INT = 1;
DECLARE @CustomerID INT;
DECLARE @CreditScore INT;
DECLARE @LoanStartDate DATE;
DECLARE @UpdatedAt DATE;

WHILE @i <= 10000
BEGIN
    -- CustomerID ni tasodifiy tanlaymiz
    SELECT TOP 1 @CustomerID = CustomerID 
    FROM olmabank_core.Customers 
    ORDER BY NEWID();

    -- Kredit olgan mijozni tanlaymiz va kredit boshlanish sanasini olamiz
    SELECT TOP 1 @LoanStartDate = StartDate 
    FROM olmabank_loans.Loans 
    WHERE CustomerID = @CustomerID
    ORDER BY NEWID();

    -- Agar mijoz kredit olgan bo'lsa, `CreditScores` qo‘shamiz
    IF @LoanStartDate IS NOT NULL
    BEGIN
        -- Tasodifiy `CreditScore` yaratamiz (300 - 400 oralig‘ida)
        SET @CreditScore = 300 + ABS(CHECKSUM(NEWID()) % 101); 

        -- `UpdatedAt` kredit start sanasidan oldin bo‘lishi kerak
        SET @UpdatedAt = DATEADD(YEAR, -ABS(CHECKSUM(NEWID()) % 5), @LoanStartDate);

        -- Ma’lumotlarni qo‘shamiz
        INSERT INTO olmabank_loans.CreditScores (CustomerID, CreditScore, UpdatedAt)
        VALUES (@CustomerID, @CreditScore, @UpdatedAt);
    END;

    SET @i = @i + 1;
END;
GO

USE olmabank;
GO

CREATE TABLE Olmabank_loans.DebtCollection(
	DebtID INT PRIMARY KEY IDENTITY(1,1),
	CustomerID INT NOT NULL,
	AmountDue DECIMAL(18,2)CHECK (AmountDue > 0) NOT NULL,
	DueDate DATE,
	CollectorAssigned NVARCHAR(100) NOT NULL,
	CONSTRAINT FK_DebtCollection_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID)
);
GO


CREATE TABLE olmabank_risk.KYC (
    KYCID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    DocumentType NVARCHAR(50) NOT NULL,
    DocumentNumber NVARCHAR(50) UNIQUE NOT NULL,
    VerifiedBy NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_KYC_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID)
);
GO

USE olmabank;
GO

DECLARE @i INT = 1;
DECLARE @CustomerID INT;
DECLARE @DocumentType NVARCHAR(50);
DECLARE @DocumentNumber NVARCHAR(50);
DECLARE @VerifiedBy NVARCHAR(100);

WHILE @i <= 10000
BEGIN
    -- Tasodifiy CustomerID
    SET @CustomerID = (SELECT TOP 1 CustomerID FROM olmabank_core.Customers ORDER BY NEWID());

    -- Tasodifiy hujjat turi
    SET @DocumentType = (SELECT TOP 1 DocumentType FROM (VALUES ('Passport'), ('National ID'), ('Tax Document'), ('Driver''s License')) AS Docs(DocumentType));

    -- Noyob hujjat raqami
    SET @DocumentNumber = CAST(ABS(CHECKSUM(NEWID())) % 900000000 + 100000000 AS NVARCHAR(50)) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 900 + 100 AS NVARCHAR(50));

    -- Tasodifiy tasdiqlovchi xodim
    SET @VerifiedBy = 'Officer ' + CAST(ABS(CHECKSUM(NEWID())) % 100 + 1 AS NVARCHAR(10));

    -- Ma'lumotlarni jadvalga kiritish
    INSERT INTO olmabank_risk.KYC (CustomerID, DocumentType, DocumentNumber, VerifiedBy)
    VALUES (@CustomerID, @DocumentType, @DocumentNumber, @VerifiedBy);

    SET @i = @i + 1;
END;
GO

USE olmabank;
GO

CREATE TABLE olmabank_risk.FraudDetection (
    FraudID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    TransactionID INT NOT NULL,
    RiskLevel NVARCHAR(20) CHECK (RiskLevel IN ('Low', 'Medium', 'High')) NOT NULL,
    ReportedDate DATE NOT NULL,
    CONSTRAINT FK_FraudDetection_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID),
    CONSTRAINT FK_FraudDetection_Transactions FOREIGN KEY (TransactionID) 
        REFERENCES olmabank_core.Transactions(TransactionID)
);
GO


USE olmabank;
GO

DECLARE @i INT = 1;
DECLARE @CustomerID INT;
DECLARE @TransactionID INT;
DECLARE @RiskLevel NVARCHAR(20);
DECLARE @ReportedDate DATE;

WHILE @i <= 10000
BEGIN
    -- Mavjud tranzaksiyalarni mijoz bilan bog‘lab tanlaymiz
    SELECT TOP 1 @TransactionID = t.TransactionID, @CustomerID = a.CustomerID
    FROM olmabank_core.Transactions t
    INNER JOIN olmabank_core.Accounts a ON t.AccountID = a.AccountID
    ORDER BY NEWID();

    -- Agar TransactionID va CustomerID mavjud bo‘lsa, FraudDetection jadvaliga qo‘shish
    IF @TransactionID IS NOT NULL AND @CustomerID IS NOT NULL
    BEGIN
        -- Risk Level tasodifiy tanlash (barchasi `Low` bo‘lib qolmasligi uchun)
        SET @RiskLevel = 
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 3 = 0 THEN 'Low'
                WHEN ABS(CHECKSUM(NEWID())) % 3 = 1 THEN 'Medium'
                ELSE 'High'
            END;

        -- Firibgarlik aniqlangan sanani tasodifiy tanlash
        SET @ReportedDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE());

        -- Ma’lumotlarni qo‘shish
        INSERT INTO olmabank_risk.FraudDetection (CustomerID, TransactionID, RiskLevel, ReportedDate)
        VALUES (@CustomerID, @TransactionID, @RiskLevel, @ReportedDate);
    END;

    SET @i = @i + 1;
END;
GO

USE olmabank;
GO

CREATE TABLE olmabank_risk.AML_Cases (
    CaseID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    CaseType NVARCHAR(100) NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Open', 'Under Investigation', 'Closed')) NOT NULL,
    InvestigatorID INT NOT NULL,
    CONSTRAINT FK_AML_Cases_Customers FOREIGN KEY (CustomerID) 
        REFERENCES olmabank_core.Customers(CustomerID)
);
GO

--Ma'lumotlar avtomatik tarzda insert qilindi

USE olmabank;
GO

truncate table olmabank_risk.RegulatoryReports

USE olmabank;
GO

DECLARE @i INT = 1;
DECLARE @ReportType NVARCHAR(100);
DECLARE @SubmissionDate DATE;
DECLARE @Year INT;
DECLARE @Month INT;

WHILE @i <= 2000
BEGIN
    -- Tasodifiy yilni tanlaymiz (2022, 2023, 2024)
    SET @Year = 2022 + ABS(CHECKSUM(NEWID()) % 3);

    -- Tasodifiy hisobot turini tanlaymiz
    SET @ReportType = (SELECT TOP 1 ReportType 
                       FROM (VALUES ('AML Compliance'), 
                                    ('Fraud Report'), 
                                    ('Regulatory Audit'), 
                                    ('Customer Due Diligence')) AS Reports(ReportType));

    -- Hisobot turiga qarab submission_date belgilaymiz
    IF @ReportType IN ('AML Compliance', 'Fraud Report', 'Customer Due Diligence')
    BEGIN
        -- Har oylik (1 dan 12 gacha)
        SET @Month = ABS(CHECKSUM(NEWID()) % 12) + 1;
        SET @SubmissionDate = DATEFROMPARTS(@Year, @Month, 1);
    END
    ELSE IF @ReportType = 'Regulatory Audit'
    BEGIN
        -- Har yillik
        SET @SubmissionDate = DATEFROMPARTS(@Year, 1, 1);
    END

    -- Ma’lumotlarni RegulatoryReports jadvaliga qo‘shamiz
    INSERT INTO olmabank_risk.RegulatoryReports (ReportType, SubmissionDate)
    VALUES (@ReportType, @SubmissionDate);

    SET @i = @i + 1;
END;
GO


USE olmabank;
GO

create schema Olmabank_hr;
create schema Olmabank_investments;
create schema Olmabank_insurance;

USE olmabank;
GO

-- 1️⃣ Departments (Bo‘limlar jadvali)
CREATE TABLE olmabank_hr.Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL,
    ManagerID INT NOT NULL
);
GO

--olmabank_hr.Departments jadvali avtomatik ravishda yaratildi

-- 2️⃣ Salaries (Xodimlarning ish haqi jadvali)
CREATE TABLE olmabank_hr.Salaries (
    SalaryID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    BaseSalary DECIMAL(18,2) NOT NULL CHECK (BaseSalary > 0),
    Bonus DECIMAL(18,2) DEFAULT 0.00,
    Deductions DECIMAL(18,2) DEFAULT 0.00,
    PaymentDate DATE NOT NULL,
    CONSTRAINT FK_Salaries_Employees FOREIGN KEY (EmployeeID) REFERENCES olmabank_core.Employees(EmployeeID)
);
GO

-- 3️⃣ EmployeeAttendance (Xodimlarning qatnovi jadvali)


CREATE TABLE olmabank_hr.EmployeeAttendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    CheckInTime DATETIME NOT NULL,
    CheckOutTime DATETIME NOT NULL,
    TotalHours DECIMAL(5,2) NOT NULL CHECK (TotalHours >= 0),
    CONSTRAINT FK_EmployeeAttendance_Employees FOREIGN KEY (EmployeeID) REFERENCES olmabank_core.Employees(EmployeeID)
);
GO

USE olmabank;
GO

DECLARE @EmployeeID INT;
DECLARE @CheckInTime DATETIME;
DECLARE @CheckOutTime DATETIME;
DECLARE @TotalHours DECIMAL(5,2);
DECLARE @CurrentDate DATE = '2022-02-01';
DECLARE @HireDate DATE;

WHILE @CurrentDate <= '2025-02-01'
BEGIN
    -- Faqat ish kunlari: Dushanbadan Jumagacha (1-5)
    IF DATEPART(WEEKDAY, @CurrentDate) IN (2,3,4,5,6) -- Monday to Friday in SQL Server (1=Sunday, 7=Saturday)
    BEGIN
        SET @EmployeeID = 1;
        
        WHILE @EmployeeID <= 1000 -- Assuming 1000 employees
        BEGIN
            -- Xodimning HireDate ni aniqlaymiz
            SELECT @HireDate = HireDate FROM olmabank_core.Employees WHERE EmployeeID = @EmployeeID;
            
            -- Agar HireDate @CurrentDate dan keyin bo'lsa, qator qo'shmaslik
            IF @HireDate IS NOT NULL AND @HireDate <= @CurrentDate
            BEGIN
                -- Tasodifiy CheckInTime (08:00 - 10:00 oralig'ida)
                SET @CheckInTime = DATEADD(MINUTE, RAND() * 120, CAST(@CurrentDate AS DATETIME) + '08:00');

                -- Tasodifiy CheckOutTime (17:30 - 20:00 oralig'ida)
                SET @CheckOutTime = DATEADD(MINUTE, RAND() * 150, CAST(@CurrentDate AS DATETIME) + '17:30');

                -- TotalHours hisoblash
                SET @TotalHours = DATEDIFF(MINUTE, @CheckInTime, @CheckOutTime) / 60.0;

                -- Ma’lumotlarni EmployeeAttendance jadvaliga qo‘shish
                INSERT INTO olmabank_hr.EmployeeAttendance (EmployeeID, CheckInTime, CheckOutTime, TotalHours)
                VALUES (@EmployeeID, @CheckInTime, @CheckOutTime, @TotalHours);
            END;

            SET @EmployeeID = @EmployeeID + 1;
        END;
    END;

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;
GO







