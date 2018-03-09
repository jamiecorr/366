
#Query 2
INSERT INTO AccountRegistrationReport SELECT count(distinct CustomerID),Permission,S2.State,MONTH(RegistrationDate),Year(RegistrationDate) FROM Customer JOIN RegistrationSource S ON Customer.RegisteredAt = S.regSourceID JOIN State S2 ON Customer.StateID = S2.id GROUP BY S2.State,Permission,MONTH(RegistrationDate),Year(RegistrationDate);
#Query 3
INSERT INTO DeviceRegistrationReport SELECT count(DISTINCT DR.deviceRegistrationID), C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate),Year(DR.RegistrationDate) FROM Device d JOIN DeviceRegistration DR ON d.RegistrationID = DR.deviceRegistrationID JOIN Device_Type Type ON d.DeviceModel = Type.DeviceModel JOIN Carrier C ON Type.CarrierID = C.ID GROUP BY C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate),Year(DR.RegistrationDate);
