--*************************************************************************--
-- Title: Assignment06
-- Author: Croberts
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2025-11-16,CJ Roberts,Created File
--**************************************************************************--
Begin Try
	Use master; --I changed this so my tables were in the right place.
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Croberts')
	 Begin 
	  Alter Database [Assignment06DB_Croberts] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Croberts;
	 End
	Create Database Assignment06DB_Croberts;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Croberts;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNION
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNION
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--products, inventories, employees, categories tables
-->in order: Categories, Products, Employees, Inventories
--Create
	--View NAMEDVIEW
	--As
		--Select top 100 percent
		--columns, aliases on the right [example: CategoryNAme, ProductName, UnitPrice]
		--from database.dbo.table (if alias, add here)
		--join DB.dbo.table as DBTable1
		--on T1.TableID = T2.TableID
		--other joins continue here
		--now can: order by CategoryNAme, ProductName, UnitPrice

-- select each column

--vCurrentCategories -- order of tables also matters

--vCurrentEmployees -- order of tables also matters
--select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID

--vCurrentProducts
--select ProductID, ProductName, CategoryID, UnitPrice -- remember to grab in order

--vCurrentInventory
--select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]


	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vCategories', 'V') IS NOT NULL
	Drop View vCategories;
	go

	Create View vCategories
	As
	Select
		CategoryID
		,CategoryName as Category
		From Categories;
	go

	Select * From vCategories;
	go

	--Products

		Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vProducts', 'V') IS NOT NULL
	Drop View vProducts;
	go

	Create View vProducts
	As
	Select
		ProductID
		,ProductName as [Product]
		,CategoryID
		,UnitPrice
		From Products;
	go

	Select * From vProducts;
	go


	--Inventories

	
		Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vInventories', 'V') IS NOT NULL
	Drop View vInventories;
	go

	Create View vInventories
	As
	Select
		InventoryID
		,InventoryDate as [Date]
		,EmployeeID
		,ProductID
		,inventories.[Count]
		From Inventories;
	go

	Select * From vInventories;
	go

	--Employees

		Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vEmployees', 'V') IS NOT NULL
	Drop View vEmployees;
	go

	Create View vEmployees
	As
	Select
		M.EmployeeFirstName
		,M.EmployeeLastName
		,M.EmployeeID
		,M.ManagerID
		From Employees As M
		JOIN Employees AS E
		On E.EmployeeID = M.ManagerID;
	go

	Select * From vEmployees;
	go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--create view vPublic
--all the things you can see
--from database.dbo.table
--deny select on tableToProtect to public;
--grant select on vPublicTableToProtect;


--Private view

		Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vPrivateEmployees', 'V') IS NOT NULL
	Drop View vPrivateEmployees;
	go

	Create View vPrivateEmployees
	As
	Select
		EmployeeFirstName
		,EmployeeLastName
		,EmployeeID
		,ManagerID
		From Employees
	go

--Public view

		Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vPublicEmployees', 'V') IS NOT NULL
	Drop View vPublicEmployees;
	go

	Create View vPublicEmployees
	As
	Select
		EmployeeFirstName
		,EmployeeLastName
		From Employees
	go

	Deny Select on Employees to Public;
	Grant Select on vPublicEmployees to Public;

	Select * From vPublicEmployees;
	Select * From vPrivateEmployees;
	go



-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--USE Assignment06DB_Croberts;
--GO

--	Create View dbo.vCompanyProductInfo
--	As
--	Select
--	C.CategoryName as Category
--	,P.ProductName as [Product]
--	,P.UnitPrice as [Price]
--	From Products as P
--	Join Categories as C
--	On C.CategoryID = P.CategoryID
--	go

--	Select *
--	From dbo.vCompanyProductInfo
--	Order by Category, [Product];

	Use Assignment06DB_Croberts;
	--Use master; --testing if tables are in master or my database, figuring out how to use my database and not break the tables or view.
	go

	--Select top 5 * from Assignment06DB_Croberts.dbo.Products


	IF OBJECT_ID('vCompanyProductInfo', 'V') IS NOT NULL
	Drop View vCompanyProductInfo;
	go

	Create View vCompanyProductInfo
	As
	Select
		C.CategoryName AS Category,
		P.ProductName  AS [Product],
		P.UnitPrice    AS [Price]
	From Products   AS P
	JOIN Categories AS C
		On C.CategoryID = P.CategoryID;
	go

	Alter view vCompanyProductInfo
	As
	Select Top 100
		C.CategoryName AS Category,
		P.ProductName  AS [Product],
		P.UnitPrice    AS [Price]
	From Products   AS P
	JOIN Categories AS C
		On C.CategoryID = P.CategoryID
	go

		Select * from vCompanyProductInfo
		Order By Category, [Product], [Price];

--	Create View vCompanyProductInfo
--As
--	Select top 100
--	CategoryName
--	,ProductName
--	,UnitPrice
--	From Northwind.dbo.Products as P
--	Join Categories as C
--	On C.CategoryID = P.CategoryID
--	Order by CategoryName, ProductName;
--go

--	go
--	select * from vCompanyProductInfo Order by CategoryName, ProductName;




-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!


	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vCompanyProductInventory', 'V') IS NOT NULL
	Drop View vCompanyProductInventory;
	go

	Create View vCompanyProductInventory
	As
	Select
		P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory] 
	From Products   AS P
	JOIN Inventories AS I
		ON P.ProductID = I.ProductID;
	go

		Alter view vCompanyProductInventory
	As
	Select Top 100
		P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory] 
	From Products   AS P
	JOIN Inventories AS I
		ON P.ProductID = I.ProductID;
	go

	Select * From vCompanyProductInventory
	Order By [Product], [Date], Inventory;
	go



-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vEmployeeInventory', 'V') IS NOT NULL
	Drop View vEmployeeInventory;
	go

	Create View vEmployeeInventory
	As
	Select
		I.InventoryDate AS [Date]
		, concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee
	From Employees   AS E
	JOIN Inventories AS I
		ON I.EmployeeID = E.EmployeeID;
	go

		Alter view vEmployeeInventory
	As
	Select Top 100
		I.InventoryDate AS [Date]
		,concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee
	From Employees   AS E
	JOIN Inventories AS I
		ON I.EmployeeID = E.EmployeeID;
	go

	Select * From vEmployeeInventory
	Group by [Employee], [Date]
	Order By  [Employee], [Date];


-- Here are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--I don't see the Anne Dodsworth ones...



-- Question 6 (10% pts): How can you create a view to show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!


	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vCategoryProductInventory', 'V') IS NOT NULL
	Drop View vCategoryProductInventory;
	go

	Create View vCategoryProductInventory
	As
	Select
		C.CategoryName As [Category]
		,P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory] 
	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	go

		Alter view vCategoryProductInventory
	As
	Select Top 100
		C.CategoryName As [Category]
		,P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory] 
	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	go

	Select * From vCategoryProductInventory
	Group By Category, [Product], [Date], Inventory
	Order By Category, [Product], [Date], Inventory;


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!


	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vCategoryProductInventory', 'V') IS NOT NULL
	Drop View vCategoryProductInventory;
	go

	Create View vCategoryProductInventory
	As
	Select
		C.CategoryName As [Category]
		,P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory] 
		,concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee

	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	Join Employees as E
		On E.EmployeeID = I.EmployeeID
	go

		Alter view vCategoryProductInventory
	As
	Select Top 100
		C.CategoryName As [Category]
		,P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory] 
		,concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee
	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	Join Employees as E
		On E.EmployeeID = I.EmployeeID
	go

	Select * From vCategoryProductInventory
	Group By Category, [Product], [Date],  Inventory, [Employee]
	Order By Category, [Product], [Date],  Inventory, [Employee];


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 


	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vChaiChangInventory', 'V') IS NOT NULL
	Drop View vChaiChangInventory;
	go

	Create View vChaiChangInventory
	As
	Select
		C.CategoryName As [Category]
		,P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory]
		,concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee
	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	Join Employees as E
		On E.EmployeeID = I.EmployeeID
	go

		Alter view vChaiChangInventory
	As
	Select Top 100
		C.CategoryName As [Category]
		,P.ProductName  AS [Product]
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory]
		,concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee
	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	Join Employees as E
		On E.EmployeeID = I.EmployeeID
	Where ProductName in ('Chang', 'Chai')
	go

	Select * From vChaiChangInventory
	Group By Category, [Product], [Date], [Employee], Inventory
	Order By Category, [Product], [Date], [Employee], Inventory;


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

	--previous attempt:
	--	Create View vEmployeesByManager
	--	As
	--Select
		--M.EmployeeFirstName
		--,M.EmployeeLastName
		--,M.EmployeeID
		--,M.ManagerID
		--From Employees As M
		--JOIN Employees AS E
		--On E.EmployeeID = M.ManagerID;


	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vEmployeesByManager', 'V') IS NOT NULL
	Drop View vEmployeesByManager;
	go

	Create View vEmployeesByManager
	As
	
	Select
	concat(m.EmployeeFirstName, ' ',m.EmployeeLastName) as Manager,
	concat(e.EmployeeFirstName, ' ',e.EmployeeLastName) as Employee --e.ManagerID (to confirm manager is correct)
	from Employees as e
	inner Join Employees as m
	on e.ManagerID = m.EmployeeID;
	go

	Alter view vEmployeesByManager
	As
	Select Top 100
	concat(m.EmployeeFirstName, ' ',m.EmployeeLastName) as Manager,
	concat(e.EmployeeFirstName, ' ',e.EmployeeLastName) as Employee --e.ManagerID (to confirm manager is correct)
	from Employees as e
	inner Join Employees as m
	on e.ManagerID = m.EmployeeID;
		go

	Select * From vEmployeesByManager
	Order by Manager, Employee;
	go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

	--Use Assignment06DB_Croberts;
	--go

	--IF OBJECT_ID('vInventoriesByProductsByCategoriesByEmployees', 'V') IS NOT NULL
	--Drop View vInventoriesByProductsByCategoriesByEmployees;
	--go

	--Create View vInventoriesByProductsByCategoriesByEmployees
	--As
	--	Select
	--	CategoryID
	--	,CategoryName as Category
	--From Categories as c
	--	,ProductID
	--	,ProductName as [Product]
	--	,CategoryID
	--	,UnitPrice
	--From Products as p
	--	,i.InventoryID
	--	,i.InventoryDate as [Date]
	--	,i.EmployeeID
	--	,i.ProductID
	--	,i.inventories.[Count]
	--From Inventories as i
	--	concat(m.EmployeeFirstName, ' ',m.EmployeeLastName) as Manager,
	--	concat(e.EmployeeFirstName, ' ',e.EmployeeLastName) as Employee
	--from Employees as e
	--inner Join Employees as m
	--on e.ManagerID = m.EmployeeID
	--join on i.EmployeeID = e.EmployeeID
	--Join on P.CategoryID = C.CategoryID
	--go

	--Alter view vInventoriesByProductsByCategoriesByEmployees
	--As
	--Select Top 100
	--	CategoryID
	--	,CategoryName as Category
	--From Categories as c
	--	,ProductID
	--	,ProductName as [Product]
	--	,CategoryID
	--	,UnitPrice
	--From Products as p
	--	,i.InventoryID
	--	,i.InventoryDate as [Date]
	--	,i.EmployeeID
	--	,i.ProductID
	--	,i.inventories.[Count]
	--From Inventories as i
	--	concat(m.EmployeeFirstName, ' ',m.EmployeeLastName) as Manager,
	--	concat(e.EmployeeFirstName, ' ',e.EmployeeLastName) as Employee
	--from Employees as e
	--inner Join Employees as m
	--on e.ManagerID = m.EmployeeID
	--join on i.EmployeeID = e.EmployeeID
	--Join on P.CategoryID = C.CategoryID
	--	go

	--Select * From vInventoriesByProductsByCategoriesByEmployees
	--Order by Category, [Product], InventoryID, Employee;
	--go

	
	Use Assignment06DB_Croberts;
	go

	IF OBJECT_ID('vInventoriesByProductsByCategoriesByEmployees', 'V') IS NOT NULL
	Drop View vInventoriesByProductsByCategoriesByEmployees;
	go

	Create View vInventoriesByProductsByCategoriesByEmployees
	As
	Select
		C.CategoryID
		,C.CategoryName As [Category]
		, P.ProductID
		,P.ProductName  AS [Product]
		, P.UnitPrice
		,I.InventoryID
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory]
		,I.EmployeeID
		,concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee
		,concat(m.EmployeeFirstName, ' ', m.EmployeeLastName) as Manager
	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	Join Employees as E
		On E.EmployeeID = I.EmployeeID
	Join Employees as M
		on M.ManagerID = E.EmployeeID;
	go


	Alter view vInventoriesByProductsByCategoriesByEmployees
	As
	Select Top 100
		C.CategoryID
		,C.CategoryName As [Category]
		, P.ProductID
		,P.ProductName  AS [Product]
		, P.UnitPrice
		,I.InventoryID
		,I.InventoryDate AS [Date]
		,I.[Count] As [Inventory]
		,I.EmployeeID
		,concat(E.EmployeeFirstName, ' ', E.EmployeeLastName) as Employee
		,concat(m.EmployeeFirstName, ' ', m.EmployeeLastName) as Manager
	From Products   AS P
	JOIN Inventories AS I
		On P.ProductID = I.ProductID
	JOIN Categories As C
		On C.CategoryID = P.CategoryID
	Join Employees as E
		On E.EmployeeID = I.EmployeeID
	Join Employees as M
		on M.ManagerID = E.EmployeeID
		Order by Category, [Product], InventoryID, Employee;
	go
	
	Select * From vInventoriesByProductsByCategoriesByEmployees
	go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/