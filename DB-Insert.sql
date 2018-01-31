#Inserts all possible carriers into carrier table, plus a dummy -1 value
INSERT INTO Carrier(CarrierName) (SELECT distinct Carrier from CP_Device_Model);
INSERT INTO Carrier(ID,CarrierName) VALUES(-1,"No Carrier Information Found");

#Moves CP_Device_Model to the new table Device_Type
UPDATE CP_Device_Model JOIN Carrier ON CarrierName = Carrier SET Carrier = ID;
INSERT INTO Device_Type (SELECT distinct * FROM CP_Device_Model);

#Removes old table
DROP TABLE CP_Device_Model;

#Due to the presence of device models from sales records not in the device models table we must pull device
#models from device as well
INSERT INTO Device_Type (SELECT distinct `DeviceModel`,"","",-1 FROM CP_Device);

#Insert into device all the devices from CP_Device, properly converting date fields to be of DATE type
INSERT INTO Device (SELECT distinct CP_Device.CustomerID,CP_Device.SourceID,CP_Device.SourceName,CP_Device.DeviceModel,CP_Device.SerialNumber,STR_TO_DATE(CP_Device.PurchaseDate,'%m/%d/%Y'),
                      PurchaseStoreName, CP_Device.PurchaseStoreState,PurchaseStoreCity, Ecomm, STR_TO_DATE(CP_Device.RegistrationDate,'%m/%d/%Y') , NumberOfRegistrations, RegistrationID FROM CP_Device);

INSERT INTO Purchase (SELECT distinct null,PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm FROM Device);

ALTER TABLE Device ADD COLUMN PurchaseID INTEGER;
ALTER TABLE Device ADD FOREIGN KEY (PurchaseID) REFERENCES Purchase(id);

UPDATE Device d JOIN Purchase p ON p.PurchaseDate = d.PurchaseDate AND p.PurchaseStoreCity = d.PurchaseStoreCity
                                          AND p.PurchaseStoreState = d.PurchaseStoreState AND p.PurchaseStoreName = d.PurchaseStoreName
                                          AND p.Ecomm = d.Ecomm SET d.PurchaseID = p.id;

ALTER TABLE Device DROP COLUMN PurchaseDate;
ALTER TABLE Device DROP COLUMN PurchaseStoreName;
ALTER TABLE Device DROP COLUMN PurchaseStoreCity;
ALTER TABLE Device DROP COLUMN PurchaseStoreState;
ALTER TABLE Device DROP COLUMN Ecomm;


