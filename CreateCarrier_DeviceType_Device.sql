#Separates out Carrier from Device
CREATE TABLE Carrier
(
    ID INT NOT NULL AUTO_INCREMENT,
    CarrierName VARCHAR(64),
    CONSTRAINT Carrier_CarrierID_CarrierName_pk PRIMARY KEY (ID, CarrierName)
);

#Inserts all possible carriers into carrier table, plus a dummy -1 value
INSERT INTO Carrier(CarrierName) (SELECT distinct Carrier from CP_Device_Model);
INSERT INTO Carrier(ID,CarrierName) VALUES(-1,"No Carrier Information Found");


  CREATE TABLE Device_Type
(
    `Device Model` VARCHAR(255) NOT NULL,
    `Device Name` VARCHAR(255),
    `Device type` VARCHAR(32),
    CarrierID INT,

    CONSTRAINT Device_Type_Model_Name_Type PRIMARY KEY (`Device Model`, `Device Name`, `Device type`, CarrierID),
    CONSTRAINT CarrierID___fk FOREIGN KEY (CarrierID) REFERENCES Carrier (ID)
);

#Moves CP_DEvice_Model to the new table Device_Type
UPDATE CP_Device_Model JOIN Carrier ON CarrierName = Carrier SET Carrier = ID;

INSERT INTO Device_Type (SELECT distinct * FROM CP_Device_Model);
#Removes old table
DROP TABLE CP_Device_Model;

#Due to the presence of device models from sales records not in the device models table we must pull device
#models from device as well
INSERT INTO Device_Type (SELECT distinct `DeviceModel`,"","",-1 FROM CP_Device);

CREATE TABLE Device
(
    CustomerId VARCHAR(32) NOT NULL,
    SourceID VARCHAR(15),
    SourceName VARCHAR(64),
    DeviceModel VARCHAR(255),
    SerialNumber VARCHAR(64),
    PurchaseDate DATE,
    PurchaseStoreName VARCHAR(64),
    PurchaseStoreState CHAR(3),
    PurchaseStoreCity VARCHAR(64),
    Ecomm CHAR(1),
    RegistrationDate DATE,
    NumberOfRegistrations INT,
    RegistrationID VARCHAR(64) NOT NULL,
    CONSTRAINT Device_CustomerId_RegistrationID_pk PRIMARY KEY (CustomerId, RegistrationID),
    CONSTRAINT `Device_Device_Type_Device Model_fk` FOREIGN KEY (DeviceModel) REFERENCES Device_Type (`Device Model`)
);


#Insert into device all the devices from CP_Device, properly converting date fields to be of DATE type
INSERT INTO Device (SELECT distinct CP_Device.CustomerID,CP_Device.SourceID,CP_Device.SourceName,CP_Device.DeviceModel,CP_Device.SerialNumber,STR_TO_DATE(CP_Device.PurchaseDate,'%m/%d/%Y'),
                      PurchaseStoreName, CP_Device.PurchaseStoreState,PurchaseStoreCity, Ecomm, STR_TO_DATE(CP_Device.RegistrationDate,'%m/%d/%Y') , NumberOfRegistrations, RegistrationID FROM CP_Device);

