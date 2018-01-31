CREATE TABLE Carrier
(
    ID INT NOT NULL AUTO_INCREMENT,
    CarrierName VARCHAR(64),
    CONSTRAINT Carrier_CarrierID_CarrierName_pk PRIMARY KEY (ID, CarrierName)
);

CREATE TABLE Device_Type
(
    `Device Model` VARCHAR(255) NOT NULL,
    `Device Name` VARCHAR(255),
    `Device type` VARCHAR(32),
    CarrierID INT,

    CONSTRAINT Device_Type_Model_Name_Type PRIMARY KEY (`Device Model`, `Device Name`, `Device type`, CarrierID),
    CONSTRAINT CarrierID___fk FOREIGN KEY (CarrierID) REFERENCES Carrier (ID)
);

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
    CONSTRAINT Device_RegistrationID_pk PRIMARY KEY (RegistrationID),
    CONSTRAINT `Device_Device_Type_Device Model_fk` FOREIGN KEY (DeviceModel) REFERENCES Device_Type (`Device Model`),
    UNIQUE(ID)
);

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

CREATE TABLE IF NOT EXISTS RegistrationSource(
  regSourceId INTEGER PRIMARY KEY,
  regSourceName VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS CustomerAccount(
  customerID INTEGER,
  registrationDate DATE,
  numRegistrations INTEGER,
  registeredAt INTEGER,

  PRIMARY KEY (customerID, registrationDate),
  FOREIGN KEY (customerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceId)
);

CREATE TABLE IF NOT EXISTS DeviceRegistration(
  deviceRegistrationID INTEGER,
  registeredAt INTEGER,
  registrationDate DATE,

  PRIMARY KEY (deviceRegistrationID),
  FOREIGN KEY (deviceRegistrationID) REFERENCES Device(RegistrationID),
  FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceId)
);

#Star model for Customer
CREATE TABLE Customer
(
    CustomerId VARCHAR(32) NOT NULL,
    Permission CHAR(1),
    Tier VARCHAR(32),
    NumRegistrations INT,
    CONSTRAINT Customer_CustomerID_pk PRIMARY KEY (CustomerId)
);
CREATE TABLE Gender
(
    Gender CHAR(1),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_Gender_pk PRIMARY KEY (CustomerId, Gender),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IncomeLevel
(
    IncomeLevel VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_IncomeLevel_pk PRIMARY KEY (CustomerId, IncomeLevel),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE Language
(
    Language CHAR(3),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_Language_pk PRIMARY KEY (CustomerId, Language),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE Zip
(
    Zip INT,
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_Zip_pk PRIMARY KEY (CustomerId, Zip),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE State
(
    State VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_State_pk PRIMARY KEY (CustomerId, State),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

CREATE TABLE SubjectLine
(
    SubjectLine VARCHAR(255),
    EmailID INTEGER(32) NOT NULL,
    CONSTRAINT SubjectLine_pk PRIMARY KEY (SubjectLine,EmailID),
    CONSTRAINT EmailID_fk FOREIGN KEY (EmailID) REFERENCES Email(id)
);

CREATE TABLE Audience
(
    Audience VARCHAR(255),
    EmailID INTEGER(32) NOT NULL,
    CONSTRAINT audience_pk PRIMARY KEY (Audience,EmailID),
    CONSTRAINT EmailID_fk FOREIGN KEY (EmailID) REFERENCES Email(id)
);