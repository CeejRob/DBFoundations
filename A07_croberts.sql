--*************************************************************************--
-- Title: Assignment07
-- Author: roberts
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2025-11-19,croberts,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Croberts')
	 Begin 
	  Alter Database [Assignment07DB_Croberts] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Croberts;
	 End
	Create Database Assignment07DB_Croberts;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Croberts;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

Print 'For Q1, jump to line 208'

	--Select * from vProducts
	--	Select ProductName as [Product], UnitPrice as [Price] from vProducts
	--	Select ProductName, '$' + cast(UnitPrice as nvarchar(50)) From vProducts
	--go

			--Select ProductName as [Product], '$' + cast((UnitPrice as [Price]) as nvarchar(50)) from vProducts
			--go

	--Select * from vProducts
	--Select ProductName as Products, UnitPrice as Cost from vProducts
	Select ProductName as Products, '$'+cast(UnitPrice as nvarchar(50)) as Cost From vProducts
	go


-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

Print 'For Q2, jump to line 219'

	--Select * from vProducts
	Select
		C.CategoryName as Category,
		P.ProductName  as [Product],
		'$'+cast(P.UnitPrice as nvarchar(50)) as [Price]
	From vProducts   AS P
	JOIN vCategories AS C
		On C.CategoryID = P.CategoryID
	order by Category, [Product];
	go


-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Print 'For Q3, jump to line 256'

/*
	Select
	P.ProductName as [Product]
	,cast(I.InventoryDate as date) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
		On P.ProductID = I.ProductID
	Order by [Product], [Date];
		go */

	Select
	ProductName as [Product]
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
		On P.ProductID = I.ProductID
	Order by ProductName, InventoryDate; --using original data rather than cast Date to ensure column in month order despite being strings on the other end of casting.
		go



-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Print 'For Q4, jump to line 425'

/*
	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventories', 'V') IS NOT NULL
	Drop View vProductInventories;
	go

	Create View vProductInventories
	As
	Select
	ProductName as [Product]
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
		On P.ProductID = I.ProductID;
	go

		Alter view vProductInventories
	As
	Select Top 1000
	ProductName as [Product]
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
		On P.ProductID = I.ProductID;
	go

	Select * From vProductInventories
	Order by [Product], [Date], Inventory;
	go


try 2
	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventories', 'V') IS NOT NULL
	Drop View vProductInventories;
	go

	Create View vProductInventories
	As
	Select
	ProductName as [Product]
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
		On P.ProductID = I.ProductID;
	go

		Alter view vProductInventories
	As
	Select Top 1000
	ProductName as [Product]
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
		On P.ProductID = I.ProductID;
	go

	Select * From vProductInventories
	Group by [Product], [Date], Inventory
	Order by [Product], [Date], Inventory;
	go

 try 3

	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventories', 'V') IS NOT NULL
	Drop View vProductInventories;
	go

	Create View vProductInventories
	As
	Select
	ProductName as [Product]
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From Products as P
	JOIN Inventories as I
		On P.ProductID = I.ProductID;
	go

		Alter view vProductInventories
	As
	Select Top 1000
	ProductName as [Product]
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From Products as P
	JOIN Inventories as I
		On P.ProductID = I.ProductID;
	go

	Select * From vProductInventories
	Order by [Product], InventoryDate, Inventory;
	go

try 4

	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventories', 'V') IS NOT NULL
	Drop View vProductInventories;
	go

	Create View vProductInventories
	As
	Select
	ProductName as [Product]
	,InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From Products as P
	JOIN Inventories as I
	On P.ProductID = I.ProductID;
	go

	Alter view vProductInventories
	As
	Select Top 1000
	ProductName as [Product]
	,InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
	On P.ProductID = I.ProductID;
	go

	Select * From vProductInventories
	Order by [Product] asc, InventoryDate, Inventory;
	go */
	

--try 5

	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventories', 'V') IS NOT NULL
	Drop View vProductInventories;
	go

	Create or Alter View vProductInventories
	As
	Select top 1000
	ProductName as [Product]
	,InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vProducts as P
	JOIN vInventories as I
	On P.ProductID = I.ProductID;
	go

	select * from vProductInventories
	Order by [Product] asc, InventoryDate, Inventory;
	go


	--Alter view vProductInventories
	--As
	--Select Top 1000
	--ProductName as [Product]
	--,InventoryDate
	--,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	--Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	--cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	--,I.[Count] as [Inventory] 
	--From vProducts as P
	--JOIN vInventories as I
	--On P.ProductID = I.ProductID;
	--go

	--Select [Product], [Date], [Inventory] from vProductInventories
	--Order by [Product] asc, InventoryDate, Inventory;
	--go


-- Check that it works: Select * From vProductInventories;
--go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vCategoryInventories', 'V') IS NOT NULL
	Drop View vCategoryInventories;
	go

	Create or Alter View vCategoryInventories
	As
	Select top 1000
	CategoryName as Category
	,ProductName as [Product]
	,InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vCategories as C

	JOIN vProducts As P
	On C.CategoryID = P.CategoryID
	JOIN vInventories as I
	On P.ProductID = I.ProductID;
	go

	--Alter view vProductInventories
	--As
	--Select Top 100 percent
	--CategoryName as Category
	--,ProductName as [Product]
	--,InventoryDate
	--,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	--Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	--cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	--,I.[Count] as [Inventory] 
	--From vCategories as C
	--JOIN vProducts As P
	--On C.CategoryID = P.CategoryID
	--JOIN vInventories as I
	--On P.ProductID = I.ProductID;
	--go

	Select * from vCategoryInventories
	Order by [Product], InventoryDate;
	go

-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.


Print 'Q6, jump to line 842'

/*
	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviouMonthCounts', 'V') IS NOT NULL
	Drop View vProductInventoriesWithPreviouMonthCounts;
	go

	Create View vProductInventoriesWithPreviouMonthCounts
	As
	Select
	ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory]
	
	From vCategories as C

	JOIN vProducts As P
	On C.CategoryID = P.CategoryID
	JOIN vInventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Alter view vProductInventoriesWithPreviouMonthCounts
	As
	Select Top 100 percent
	CategoryName as Category
	,ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vCategories as C

	JOIN vProducts As P
	On C.CategoryID = P.CategoryID
	JOIN vInventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Select Category, [Product], [Date], [Inventory] from vProductInventoriesWithPreviouMonthCounts
	Order by [Product], InventoryDate;
	go

trying to figure out previous month as KPI 

	   	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviouMonthCounts', 'V') IS NOT NULL
	Drop View vProductInventoriesWithPreviouMonthCounts;
	go

	Create View vProductInventoriesWithPreviouMonthCounts
	As
	Select
	ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory]
	
	From vCategories as C

	JOIN vProducts As P
	On C.CategoryID = P.CategoryID
	JOIN Inventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Alter view vProductInventoriesWithPreviouMonthCounts
	As
	Select Top 100 percent
	ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	From vCategories as C

	JOIN vProducts As P
	On C.CategoryID = P.CategoryID
	JOIN Inventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Select [Product], [Date], [Inventory] from vProductInventoriesWithPreviouMonthCounts
	Order by [Product], InventoryDate;
	go

made KPI column, fixing inventory counts

		   	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviouMonthCounts', 'V') IS NOT NULL
	Drop View vProductInventoriesWithPreviouMonthCounts;
	go

	Create View vProductInventoriesWithPreviouMonthCounts
	As
	Select
	ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory]
	,I.[Count] as LastMonthKPI
	
	From vProducts as P

	JOIN Inventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Alter view vProductInventoriesWithPreviouMonthCounts
	As
	Select Top 100 percent
	ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,I.[Count] as [Inventory] 
	,I.[Count] as LastMonthKPI
	From vProducts as P

	JOIN Inventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Select [Product], [Date], [Inventory], LastMonthKPI from vProductInventoriesWithPreviouMonthCounts
	Order by [Product], InventoryDate;
	go

		   	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviouMonthCounts', 'V') IS NOT NULL
	Drop View vProductInventoriesWithPreviouMonthCounts;
	go

	Create View vProductInventoriesWithPreviouMonthCounts
	As
	Select
	ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,cast(I.[Count] as nvarchar(50)) as [Inventory]
	,I.[Count] as LastMonthKPI
	
	From vProducts as P

	JOIN vInventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Alter view vProductInventoriesWithPreviouMonthCounts
	As
	Select Top 100 percent
	ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,cast(I.[Count] as nvarchar(50)) as [Inventory]
	,I.[Count] as LastMonthKPI
	From vProducts as P

	JOIN vInventories as I
	On P.ProductID = I.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Select [Product], [Date], [Inventory], LastMonthKPI from vProductInventoriesWithPreviouMonthCounts
	Order by [Product], InventoryDate;
	go

			   	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviouMonthCounts', 'V') IS NOT NULL
	Drop View vProductInventoriesWithPreviouMonthCounts;
	go

	Create View vProductInventoriesWithPreviouMonthCounts
	As
	Select
	P.ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,cast(I.[Count] as nvarchar(50)) as [Inventory]
	,I.[Count] as LastMonthKPI
	
	From vProducts as VP

	JOIN Inventories as I
	On VP.ProductID = I.ProductID
	Join Products as P
	On P.ProductID = VP.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Alter view vProductInventoriesWithPreviouMonthCounts
	As
	Select Top 100 percent
	P.ProductName as [Product]
	,V.InventoryDate
	,DateName(Month, Cast(I.InventoryDate as date))+ ' ' +
	Cast(DatePart(Day, Cast(I.InventoryDate as date)) as varchar(2)) + ', ' +
	cast(datepart(year, Cast(I.InventoryDate as date)) as varchar(4)) as [Date]
	,cast(I.[Count] as nvarchar(50)) as [Inventory]
	,I.[Count] as LastMonthKPI
	From vProducts as VP

	JOIN Inventories as I
	On VP.ProductID = I.ProductID
	Join Products as P
	On P.ProductID = VP.ProductID
	Join vProductInventories as V
	On V.InventoryDate = I.InventoryDate;
	go

	Select vProductInventoriesWithPreviouMonthCounts.[Product], vProductInventoriesWithPreviouMonthCounts.LastMonthKPI) + ' ' + 
	concat(Select InventoryDate, [Count] from Inventories)
	Order by ProductID, InventoryDate;
	go */



/*
	USE Assignment07DB_Croberts;
	GO

	IF OBJECT_ID('vProductInventoriesWithPreviousMonthCounts', 'V') IS NOT NULL
		DROP VIEW vProductInventoriesWithPreviousMonthCounts;
	GO

	Create OR Alter view vProductInventoriesWithPreviousMonthCounts
	AS
	--Select * from vProductInventories
	SELECT top 100000
    Product
    ,InventoryDate
    ,DATENAME(MONTH, InventoryDate) + ' ' +
     CAST(DATEPART(DAY, InventoryDate) AS varchar(2)) + ', ' +
     CAST(DATEPART(YEAR, InventoryDate) AS varchar(4)) AS [Date]
    ,[Inventory]
    --,IsNull([Inventory], 0) as LastMonthKPI
	, iif( previousMonthCount
	
	FROM vProductInventories

	--JOIN vInventories as I
	--	ON P.ProductID = I.ProductID
	--LEFT JOIN vInventories as PM              -- previous month
	--	ON PM.ProductID = I.ProductID
	--AND PM.InventoryDate = DATEADD(MONTH, -1, I.InventoryDate)
	--GO

	--SELECT [Product], [Date], [Inventory], LastMonthKPI
	--FROM vProductInventoriesWithPreviousMonthCounts
	ORDER BY Product, InventoryDate;
	GO

	Select * from vProductInventoriesWithPreviousMonthCounts
 Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
*/


	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviousMonthCounts', 'V') IS NOT NULL
		Drop View vProductInventoriesWithPreviousMonthCounts;
	go

	Create OR Alter View vProductInventoriesWithPreviousMonthCounts
	As
	With Base As
	(
		Select
			Product
			,InventoryDate
		,DateName(Month, Cast(InventoryDate as date))+ ' ' +
		Cast(DatePart(Day, Cast(InventoryDate as date)) as varchar(2)) + ', ' +
		cast(datepart(year, Cast(InventoryDate as date)) as varchar(4)) as [Date]
			,Inventory
			,LAG(Inventory) Over (
				Partition By Product
				Order By InventoryDate
			) As PrevInventory
		from vProductInventories
	)
	Select
		Product
		,InventoryDate
		,[Date]
		,Inventory
		,IIF(PrevInventory IS NULL, 0, PrevInventory) AS LastMonthInventory
	from Base;
	go

	Select * from vProductInventoriesWithPreviousMonthCounts;
	go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Verify that the results are ordered by the Product and Date.

print 'Q7, Jump down to line 1029'

--Try 1

/*

	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviousMonthCountsWithKPIs', 'V') is not null
		Drop View vProductInventoriesWithPreviousMonthCountsWithKPIs;
	go

	Create OR Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs
	As
	With Base As
	(
		Select
			Product
			,InventoryDate
		,DateName(Month, Cast(InventoryDate as date))+ ' ' +
		Cast(DatePart(Day, Cast(InventoryDate as date)) as varchar(2)) + ', ' +
		cast(datepart(year, Cast(InventoryDate as date)) as varchar(4)) as [Date]
			,Inventory
			,LAG(Inventory) Over (
				Partition By Product
				Order By InventoryDate
			) As PrevInventory
		from vProductInventories
	)
	
	Select
		Product
		,InventoryDate
		,[Date]
		,Inventory
		,PrevInventory As [Last Month Inventory]

		,IIF(PrevInventory is Null, '0'
			,IIF(Inventory > PrevInventory, 1,
				IIF(Inventory = PrevInventory, 0, -1))) AS [Inventory KPI]
		From Base;
		go

	Select * from vProductInventoriesWithPreviousMonthCountsWithKPIs
	Order By [Product], InventoryDate;
	go


	

Try 2	
Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviousMonthCountsWithKPIs', 'V') is not null
		Drop View vProductInventoriesWithPreviousMonthCountsWithKPIs;
	go

	Create OR Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs
	As
	With Base As
	(
		Select
			Product
			,InventoryDate
		,DateName(Month, Cast(InventoryDate as date))+ ' ' +
		Cast(DatePart(Day, Cast(InventoryDate as date)) as varchar(2)) + ', ' +
		cast(datepart(year, Cast(InventoryDate as date)) as varchar(4)) as [Date]
			,Inventory
			,LAG(Inventory) Over (
				Partition By Product
				Order By InventoryDate
			) As PrevInventory
		from vProductInventories
	)
	
	Select
		Product
		,InventoryDate
		,[Date]
		,Inventory
		, Cast(IIF(PrevInventory is Null, 'N/a',
		Cast(PrevInventory as Varchar(3))
			As Varchar(3) As [Last Month Inventory]

		,IIF(PrevInventory is Null, '0'
			,IIF(Inventory > PrevInventory, 1,
				IIF(Inventory = PrevInventory, 0, -1))) AS [Inventory KPI]
		From Base;
		go

	Select * from vProductInventoriesWithPreviousMonthCountsWithKPIs
	Order By [Product], InventoryDate;
	go


Try 3
	Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviousMonthCountsWithKPIs', 'V') is not null
		Drop View vProductInventoriesWithPreviousMonthCountsWithKPIs;
	go

	Create OR Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs
	As
	With Base As
	(
		Select
			Product
			,InventoryDate
		,DateName(Month, Cast(InventoryDate as date))+ ' ' +
		Cast(DatePart(Day, Cast(InventoryDate as date)) as varchar(2)) + ', ' +
		cast(datepart(year, Cast(InventoryDate as date)) as varchar(4)) as [Date]
			,Inventory
			,LAG(Inventory) Over (
				Partition By Product
				Order By InventoryDate
			) As [Past Inventory]
		from vProductInventories
	)
	
	Select
		Product
		,InventoryDate
		,[Date]
		,Inventory
		,[Past Inventory]
		go

	IIF([Past Inventory] is Null, null
		,IIF(Inventory > [Past Inventory], 1
			,IIF(Inventory = [Past Inventory], 0, -1))) As [Inventory KPI]
		From Base;
		go

	Select * from vProductInventoriesWithPreviousMonthCountsWithKPIs
	Order By Product, InventoryDate;
	Go
	*/

	--try five million and 4

		Use Assignment07DB_Croberts;
	go

	IF OBJECT_ID('vProductInventoriesWithPreviousMonthCountsWithKPIs', 'V') is not null
		Drop View vProductInventoriesWithPreviousMonthCountsWithKPIs;
	go

	Create OR Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs
	As
	With Base As
	(
		Select
			Product
			,InventoryDate
		,DateName(Month, Cast(InventoryDate as date))+ ' ' +
		Cast(DatePart(Day, Cast(InventoryDate as date)) as varchar(2)) + ', ' +
		cast(datepart(year, Cast(InventoryDate as date)) as varchar(4)) as [Date]
			,Inventory
			,LAG(Inventory) Over (
				Partition By Product
				Order By InventoryDate
			) As PrevInventory
		from vProductInventories
	)
	
	Select
		Product
		,InventoryDate
		,[Date]
		,Inventory
		,
		--PrevInventory As [Last Month Inventory]

		IIF(PrevInventory is Null, 'N/A'
			
			,Cast(PrevInventory as varchar(10))) as [Last Month Inventory],
			
		IIF (PrevInventory is null, '0',
			Cast(
				IIF(Inventory > PrevInventory, 1
					,IIF(Inventory = PrevInventory, 0, -1)
			) as Varchar(3))) as [Inventory KPI]
		From Base;
		go

	Select * from vProductInventoriesWithPreviousMonthCountsWithKPIs
	Order By [Product], InventoryDate;
	go


-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Verify that the results are ordered by the Product and Date.

print 'Q8, go down to line 1128'


--create function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs
--Returns @UDF_KPIs table
--as
--	Return(
--		Select [InventoryDate] as date)
--				[Product] as varchar(60))
--				 [Inventory] as int
--				  [Last Month Inventory] as int
--					[Inventory KPI] as int
--go

--USE Assignment07DB_Croberts;
--GO

--IF OBJECT_ID('dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs', 'IF') IS NOT NULL
--    DROP FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs;
--GO

--CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs()
--RETURNS TABLE
--AS
--RETURN
--(
--    SELECT
--        Product,
--        InventoryDate,
--        Inventory AS InventoryCount,
--        [Inventory KPI] AS PreviousMonthKPI
--    FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
--    WHERE [Inventory KPI] IN (1, 0, -1) 
--);
--GO


USE Assignment07DB_Croberts;
GO

IF OBJECT_ID('dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs
(
    @KPI int   -- <-- professor expects this
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        Product,
        InventoryDate,
        Inventory AS InventoryCount,
        [Inventory KPI] AS PreviousMonthKPI
    FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
    WHERE 
        TRY_CAST([Inventory KPI] AS int) = @KPI
);
GO

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/