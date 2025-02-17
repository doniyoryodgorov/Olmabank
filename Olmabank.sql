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

