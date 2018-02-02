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

CREATE TABLE EmailCampaign
(
    id INT AUTO_INCREMENT,
    CampaignName VARCHAR(255),
    DeploymentDate DATE,
    CONSTRAINT EmailCampaign_pk PRIMARY KEY (CampaignName, DeploymentDate),
    Unique(id)
);

CREATE TABLE Email
(
    id INT AUTO_INCREMENT,
    Version INT,
    EmailCampaignID INT,
    CONSTRAINT Email_pk PRIMARY KEY (Version, EmailCampaignID),
    CONSTRAINT Email_EmailCampaign_id_fk FOREIGN KEY (EmailCampaignID) REFERENCES EmailCampaign (id),
    UNIQUE(id)
)

CREATE TABLE Domain
(  
    DomainName VARCHAR(64),
    CONSTRAINT DomainName_pk PRIMARY KEY (DomainName)
);

CREATE TABLE EmailAddress
(
    EmailAddressId INTEGER(32) NOT NULL,
	CustomerId VARCHAR(32) NOT NULL,
    Domain VARCHAR(64),
    CONSTRAINT EmailAddressId_pk PRIMARY KEY (EmailAddressId),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    CONSTRAINT Domain_fk FOREIGN KEY (Domain) REFERENCES Domain(DomainName)
);

CREATE TABLE EmailSentTo(
  emailID INTEGER,
  emailAddressId INTEGER,

  CONSTRAINT Email_Address_Pk PRIMARY KEY (emailID, emailAddressId),
  CONSTRAINT FOREIGN KEY (emailAddressId) REFERENCES EmailAddress(emailAddressId),
  FOREIGN KEY (emailId) REFERENCES Email(id)
);

CREATE TABLE EmailEvent(
  eventID INTEGER AUTO_INCREMENT,
  eventType INTEGER,
  eventDate DATETIME,
  emailID INTEGER,
  emailAddressId INTEGER,

  CONSTRAINT Event_Pk PRIMARY KEY (eventID),
  CONSTRAINT Event_Unique UNIQUE KEY (eventType, eventDate, emailID, emailAddressId),
  CONSTRAINT Email_Fk FOREIGN KEY (emailID) REFERENCES EmailSentTo(emailID),
  CONSTRAINT EmailAddress_Fk FOREIGN KEY (emailAddressId) REFERENCES EmailSentTo(emailAddressId)
);

CREATE TABLE Link
(
	LinkName VARCHAR(255),
	LinkURL VARCHAR(255),
	EventId INT
	CONSTRAINT Name_URL_pk PRIMARY KEY (LinkName, LinkURL)
	CONSTRAINT EventId_fk FOREIGN KEY (EventId) REFERENCES EmailEvent(EventId),
);

CREATE TABLE CustomerDevices
(
	CustomerId VARCHAR(32) NOT NULL,
	DeviceRegistrationId VARCHAR(64) NOT NULL,
	CONSTRAINT CustomerDevices_pk PRIMARY KEY (CustomerId, DeviceRegistrationId),
	CONSTRAINT DeviceId_fk FOREIGN KEY (DeviceRegistrationId) REFERENCES Device(RegistrationID),
	CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
