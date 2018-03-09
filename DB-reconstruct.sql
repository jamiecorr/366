#Recreating CP_Device_Model
SELECT distinct D.DeviceModel,DeviceName,Devicetype,CarrierName FROM Device JOIN Device_Type D ON Device.DeviceModel = D.DeviceModel JOIN Carrier C ON D.CarrierID = C.ID;

SELECT * FROM cpe366_readonly.CP_Device_Model;

#Recreating CP_Device
SELECt P.CustomerID,regSourceID, S.regSourceName, DeviceModel,SerialNumber,PurchaseDate,PurchaseStoreName,
  PurchaseStoreState,PurchaseStoreCity,Ecomm,NumRegistrations,RegistrationID
  FROM Customer JOIN Purchase P ON Customer.CustomerID = P.CustomerID JOIN PurchaseLocation L ON P.PurchaseLocationID = L.id
  JOIN Device D ON P.id = D.PurchaseID JOIN RegistrationSource S ON Customer.RegisteredAt = S.regSourceID;

SELECt count(*) FROM cpe366_readonly.CP_Device