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
    id int AUTO_INCREMENT,
    CustomerID VARCHAR(32) NOT NULL,
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
    CONSTRAINT Device_CustomerID_RegistrationID_pk PRIMARY KEY (CustomerID, RegistrationID),
    CONSTRAINT `Device_Device_Type_Device Model_fk` FOREIGN KEY (DeviceModel) REFERENCES Device_Type (`Device Model`),
    UNIQUE(ID)
);


#Insert into device all the devices from CP_Device, properly converting date fields to be of DATE type
INSERT INTO Device (SELECT distinct CP_Device.CustomerID,CP_Device.SourceID,CP_Device.SourceName,CP_Device.DeviceModel,CP_Device.SerialNumber,STR_TO_DATE(CP_Device.PurchaseDate,'%m/%d/%Y'),
                      PurchaseStoreName, CP_Device.PurchaseStoreState,PurchaseStoreCity, Ecomm, STR_TO_DATE(CP_Device.RegistrationDate,'%m/%d/%Y') , NumberOfRegistrations, RegistrationID FROM CP_Device);

CREATE TABLE Purchase
(
    id INT AUTO_INCREMENT,
    PurchaseDate DATE,
    PurchaseStoreName VARCHAR(255),
    PurchaseStoreState CHAR(3),
    PurchaseStoreCity VARCHAR(255),
    Ecomm CHAR(1),
    Unique(id),
    CONSTRAINT Purchase_pk PRIMARY KEY (PurchaseDate, PurchaseStoreName, PurchaseStoreState, PurchaseStoreCity, Ecomm)
);
    INSERT INTO Purchase (SELECT distinct null,PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm FROM Device);

    SELECt * FROM Purchase;

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


