-- =============================================
-- DATABASE SCHEMA SCRIPT FOR FINORA (SQL SERVER)
-- =============================================

-- 1. Users Table
CREATE TABLE Users (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Email NVARCHAR(256) NOT NULL UNIQUE,
    FullName NVARCHAR(100) NOT NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    PinHash NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0
);
GO

-- 2. Wallets Table
CREATE TABLE Wallets (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Name NVARCHAR(100) NOT NULL,
    Type INT NOT NULL, -- 1=Cash, 2=Bank, 3=EWallet
    Balance DECIMAL(18,2) DEFAULT 0,
    Icon NVARCHAR(50) NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0
);
GO

-- 3. Categories Table
CREATE TABLE Categories (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NULL FOREIGN KEY REFERENCES Users(Id), -- NULL means System Default
    Name NVARCHAR(100) NOT NULL,
    Type INT NOT NULL, -- 1=Income, 2=Expense
    Icon NVARCHAR(50) NULL,
    IsDeleted BIT DEFAULT 0
);
GO

-- 4. Transactions Table
CREATE TABLE Transactions (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    WalletId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Wallets(Id),
    CategoryId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Categories(Id),
    Type INT NOT NULL, -- 1=Income, 2=Expense
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
    Note NVARCHAR(500) NULL,
    TransactionDate DATETIME2 NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0
);
GO

-- 5. Budgets Table
CREATE TABLE Budgets (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Users(Id),
    CategoryId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Categories(Id),
    BaseAmount DECIMAL(18,2) NOT NULL CHECK (BaseAmount > 0),
    StartDate DATE NOT NULL,
    IsDeleted BIT DEFAULT 0
);
GO

-- 6. Goals Table
CREATE TABLE Goals (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Name NVARCHAR(100) NOT NULL,
    TargetAmount DECIMAL(18,2) NOT NULL CHECK (TargetAmount > 0),
    CurrentAmount DECIMAL(18,2) DEFAULT 0,
    Deadline DATE NOT NULL,
    Icon NVARCHAR(50) NULL,
    IsDeleted BIT DEFAULT 0
);
GO

-- 7. GoalContributions Table
CREATE TABLE GoalContributions (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    GoalId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Goals(Id),
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
    ContributionDate DATETIME2 NOT NULL,
    Note NVARCHAR(500) NULL,
    IsDeleted BIT DEFAULT 0
);
GO

-- =============================================
-- INDEXES (For Query Performance)
-- =============================================
CREATE INDEX IX_Transactions_WalletId ON Transactions(WalletId);
CREATE INDEX IX_Transactions_CategoryId ON Transactions(CategoryId);
CREATE INDEX IX_Transactions_TransactionDate ON Transactions(TransactionDate);
CREATE INDEX IX_Budgets_UserId_CategoryId ON Budgets(UserId, CategoryId);
CREATE INDEX IX_Goals_UserId ON Goals(UserId);
GO
