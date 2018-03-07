#Query 1
SELECT c.CustomerID, e.EmailAddressID AS EmailID, c.RegisteredAt AS RegSourceID, r.regSourceName, ZipID AS Zip, StateID AS State, GenderID AS Gender, IncomeLevelID AS IncomeLevel, c.Permission, LanguageID AS Language, c.RegistrationDate AS RegDate, e.DomainID, c.Tier AS CustomerTier
FROM Customer c
JOIN Email e ON e.CustomerID = c.CustomerID
JOIN RegistrationSource r ON c.RegisteredAt = r.regSourceID
JOIN Zip z ON z.id = c.ZipID
JOIN State s ON s.id = c.StateID
JOIN Gender g ON g.id = c.GenderID
JOIN IncomeLevel i ON i.id = c.IncomeLevelID
JOIN Language l ON l.id = c.LanguageID;
#Query 2
SELECT  count(distinct CustomerID) as 'Distinct number of registrees',S2.State as 'State',Permission,MONTH(RegistrationDate) as 'Month',Year(RegistrationDate) as 'Year' FROM Customer JOIN RegistrationSource S ON Customer.RegisteredAt = S.regSourceID JOIN State S2 ON Customer.StateID = S2.id GROUP BY S2.State,Permission,MONTH(RegistrationDate),Year(RegistrationDate);
#Query 3
SELECT C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate) as 'Date',Year(DR.RegistrationDate) as 'Year',count(DISTINCT DR.deviceRegistrationID) as 'Distinct device purchases' FROM Device d JOIN DeviceRegistration DR ON d.RegistrationID = DR.deviceRegistrationID JOIN Device_Type Type ON d.DeviceModel = Type.DeviceModel JOIN Carrier C ON Type.CarrierID = C.ID GROUP BY C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate),Year(DR.RegistrationDate);

