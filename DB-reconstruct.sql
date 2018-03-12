#Recreating CP_Account
SELECT c.CustomerID, ea.EmailAddressID AS EmailID, c.RegisteredAt AS RegSourceID, r.regSourceName, ZipID AS Zip, StateID AS State, GenderID AS Gender, IncomeLevelID AS IncomeLevel, c.Permission, LanguageID AS Language, c.RegistrationDate AS RegDate, DomainName, c.Tier AS CustomerTier
FROM Customer c
JOIN EmailAddress ea ON ea.CustomerID = c.CustomerID
JOIN Domain d ON ea.DomainID = d.DomainID;
JOIN RegistrationSource r ON c.RegisteredAt = r.regSourceID
JOIN Zip z ON z.id = c.ZipID
JOIN State s ON s.id = c.StateID
JOIN Gender g ON g.id = c.GenderID
JOIN IncomeLevel i ON i.id = c.IncomeLevelID
JOIN Language l ON l.id = c.LanguageID;



#Recreating CP_Device_Model
SELECT distinct D.DeviceModel,DeviceName,Devicetype,CarrierName FROM Device JOIN Device_Type D ON Device.DeviceModel = D.DeviceModel JOIN Carrier C ON D.CarrierID = C.ID;

SELECT * FROM cpe366_readonly.CP_Device_Model;

#Recreating CP_Device
SELECt P.CustomerID,regSourceID, S.regSourceName, DeviceModel,SerialNumber,PurchaseDate,PurchaseStoreName,
  PurchaseStoreState,PurchaseStoreCity,Ecomm,NumRegistrations,RegistrationID
  FROM Customer JOIN Purchase P ON Customer.CustomerID = P.CustomerID JOIN PurchaseLocation L ON P.PurchaseLocationID = L.id
  JOIN Device D ON P.id = D.PurchaseID JOIN RegistrationSource S ON Customer.RegisteredAt = S.regSourceID;

SELECt count(*) FROM cpe366_readonly.CP_Device
