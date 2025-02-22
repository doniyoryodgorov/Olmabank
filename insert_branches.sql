USE olmabank;
GO

SET IDENTITY_INSERT olmabank_core.Branches ON;
GO

INSERT INTO olmabank_core.Branches (BranchID, BranchName, Address, City, State, Country, ManagerID, ContactNumber) VALUES
(1, 'Tashkent Branch', 'Random Address 1', 'Tashkent', 'Tashkent', 'Uzbekistan', 1972, '+998947261783'),
(2, 'Samarkand Branch', 'Random Address 2', 'Samarkand', 'Samarkand', 'Uzbekistan', 857, '+998955418769'),
(3, 'Bukhara Branch', 'Random Address 3', 'Bukhara', 'Bukhara', 'Uzbekistan', 3451, '+998959755410'),
(4, 'Andijan Branch', 'Random Address 4', 'Andijan', 'Andijan', 'Uzbekistan', 4411, '+998952174970'),
(5, 'Fergana Branch', 'Random Address 5', 'Fergana', 'Fergana', 'Uzbekistan', 333, '+998954542990'),
(6, 'Namangan Branch', 'Random Address 6', 'Namangan', 'Namangan', 'Uzbekistan', 3987, '+998952128517'),
(7, 'Navoiy Branch', 'Random Address 7', 'Navoiy', 'Navoiy', 'Uzbekistan', 4815, '+998916584349'),
(8, 'Kashkadarya Branch', 'Random Address 8', 'Kashkadarya', 'Kashkadarya', 'Uzbekistan', 5004, '+998936360105'),
(9, 'Surkhandarya Branch', 'Random Address 9', 'Surkhandarya', 'Surkhandarya', 'Uzbekistan', 3392, '+998915009724'),
(10, 'Jizzakh Branch', 'Random Address 10', 'Jizzakh', 'Jizzakh', 'Uzbekistan', 3020, '+998907577747'),
(11, 'Sirdarya Branch', 'Random Address 11', 'Sirdarya', 'Sirdarya', 'Uzbekistan', 2234, '+998968316406'),
(12, 'Karakalpakstan Branch', 'Random Address 12', 'Karakalpakstan', 'Karakalpakstan', 'Uzbekistan', 5426, '+998989016770'),
(13, 'Khorezm Branch', 'Random Address 13', 'Khorezm', 'Khorezm', 'Uzbekistan', 874, '+998912353339'),
(14, 'Tashkent City Branch', 'Random Address 14', 'Tashkent', 'Tashkent', 'Uzbekistan', 2538, '+998906255280'),
(15, 'Samarkand City Branch', 'Random Address 15', 'Samarkand', 'Samarkand', 'Uzbekistan', 250, '+998927258445'),
(16, 'Bukhara City Branch', 'Random Address 16', 'Bukhara', 'Bukhara', 'Uzbekistan', 3113, '+998959134623'),
(17, 'Andijan City Branch', 'Random Address 17', 'Andijan', 'Andijan', 'Uzbekistan', 5071, '+998905166107'),
(18, 'Fergana City Branch', 'Random Address 18', 'Fergana', 'Fergana', 'Uzbekistan', 1396, '+998942545272'),
(19, 'Namangan City Branch', 'Random Address 19', 'Namangan', 'Namangan', 'Uzbekistan', 617, '+998938198226'),
(20, 'Navoiy City Branch', 'Random Address 20', 'Navoiy', 'Navoiy', 'Uzbekistan', 1194, '+998912742760'),
(21, 'Kashkadarya City Branch', 'Random Address 21', 'Kashkadarya', 'Kashkadarya', 'Uzbekistan', 4068, '+998914940497'),
(22, 'Surkhandarya City Branch', 'Random Address 22', 'Surkhandarya', 'Surkhandarya', 'Uzbekistan', 4901, '+998918734633'),
(23, 'Jizzakh City Branch', 'Random Address 23', 'Jizzakh', 'Jizzakh', 'Uzbekistan', 5568, '+998944000153'),
(24, 'Sirdarya City Branch', 'Random Address 24', 'Sirdarya', 'Sirdarya', 'Uzbekistan', 226, '+998914041308'),
(25, 'Head Office', 'Random Address 25', 'Tashkent', 'Tashkent', 'Uzbekistan', 212, '+998964219877');
GO

SET IDENTITY_INSERT olmabank_core.Branches OFF;
GO

