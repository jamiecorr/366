#Query 2
SELECT  count(distinct CustomerID) as 'Distinct number of registrees',S2.State as 'State',Permission,MONTH(RegistrationDate) as 'Month',Year(RegistrationDate) as 'Year' FROM Customer JOIN RegistrationSource S ON Customer.RegisteredAt = S.regSourceID JOIN State S2 ON Customer.StateID = S2.id GROUP BY S2.State,Permission,MONTH(RegistrationDate),Year(RegistrationDate);
#Query 3
SELECT C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate) as 'Date',Year(DR.RegistrationDate) as 'Year',count(DISTINCT DR.deviceRegistrationID) as 'Distinct device purchases' FROM Device d JOIN DeviceRegistration DR ON d.RegistrationID = DR.deviceRegistrationID JOIN Device_Type Type ON d.DeviceModel = Type.DeviceModel JOIN Carrier C ON Type.CarrierID = C.ID GROUP BY C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate),Year(DR.RegistrationDate);

