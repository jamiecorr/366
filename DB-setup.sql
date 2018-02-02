CREATE TABLE IF NOT EXISTS Carrier
(
    ID INT NOT NULL AUTO_INCREMENT,
    CarrierName VARCHAR(64),
    CONSTRAINT Carrier_CarrierID_CarrierName_pk PRIMARY KEY (ID, CarrierName)
);

CREATE TABLE IF NOT EXISTS Device_Type
(
    DeviceModel VARCHAR(255) NOT NULL,
    DeviceName VARCHAR(255),
    Devicetype VARCHAR(32),
    CarrierID INT,

    CONSTRAINT Device_Type_Model_Name_Type PRIMARY KEY (`Device Model`, `Device Name`, `Device type`, CarrierID),
    CONSTRAINT CarrierID_fk FOREIGN KEY (CarrierID) REFERENCES Carrier (ID)
);

CREATE TABLE IF NOT EXISTS Device
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
    CONSTRAINT Device_pk PRIMARY KEY (RegistrationID),
    CONSTRAINT Device_Type_fk FOREIGN KEY (DeviceModel) REFERENCES Device_Type (`Device Model`),
    UNIQUE(ID)
);

CREATE TABLE IF NOT EXISTS Purchase
(
    PurchaseDate DATE,
    PurchaseStoreName VARCHAR(255),
    PurchaseStoreState CHAR(3),
    PurchaseStoreCity VARCHAR(255),
    Ecomm CHAR(1),
    DeviceRegistrationId VARCHAR(64) NOT NULL,
    CustomerID VARCHAR(32) NOT NULL,	
    CONSTRAINT Device_fk FOREIGN KEY (DeviceRegistrationId) REFERENCES Device(RegistrationID),
    CONSTRAINT Customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
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
CREATE TABLE IF NOT EXISTS Customer
(
    CustomerId VARCHAR(32) NOT NULL,
    Permission CHAR(1),
    Tier VARCHAR(32),
    NumRegistrations INT,
    CONSTRAINT Customer_pk PRIMARY KEY (CustomerId)
);
CREATE TABLE IF NOT EXISTS Gender
(
    Gender CHAR(1),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT Gender_pk PRIMARY KEY (CustomerId, Gender),
    CONSTRAINT Customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS IncomeLevel
(
    IncomeLevel VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT IncomeLevel_pk PRIMARY KEY (CustomerId, IncomeLevel),
    CONSTRAINT Customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS Language
(
    Language CHAR(3),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT Language_pk PRIMARY KEY (CustomerId, Language),
    CONSTRAINT Customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS Zip
(
    Zip INT,
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT Zip_pk PRIMARY KEY (CustomerId, Zip),
    CONSTRAINT Customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS State
(
    State VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT State_pk PRIMARY KEY (CustomerId, State),
    CONSTRAINT Customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

CREATE TABLE IF NOT EXISTS SubjectLine
(
    SubjectLine VARCHAR(255),
    EmailID INTEGER(32) NOT NULL,
    CONSTRAINT SubjectLine_pk PRIMARY KEY (SubjectLine,EmailID),
    CONSTRAINT Email_fk FOREIGN KEY (EmailID) REFERENCES Email(id)
);

CREATE TABLE IF NOT EXISTS Audience
(
    Audience VARCHAR(255),
    EmailID INTEGER(32) NOT NULL,
    CONSTRAINT audience_pk PRIMARY KEY (Audience,EmailID),
    CONSTRAINT Email_fk FOREIGN KEY (EmailID) REFERENCES Email(id)
);

CREATE TABLE IF NOT EXISTS EmailCampaign
(
    id INT AUTO_INCREMENT,
    CampaignName VARCHAR(255),
    DeploymentDate DATE,
    CONSTRAINT EmailCampaign_pk PRIMARY KEY (CampaignName, DeploymentDate),
    Unique(id)
);

CREATE TABLE IF NOT EXISTS Email
(
    id INT AUTO_INCREMENT,
    Version INT,
    EmailCampaignID INT,
    CONSTRAINT Email_pk PRIMARY KEY (Version, EmailCampaignID),
    CONSTRAINT EmailCampaign_fk FOREIGN KEY (EmailCampaignID) REFERENCES EmailCampaign (id),
    UNIQUE(id)
)

CREATE TABLE IF NOT EXISTS Domain
(  
    DomainName VARCHAR(64),
    CONSTRAINT Domain_pk PRIMARY KEY (DomainName)
);

CREATE TABLE IF NOT EXISTS EmailAddress
(
    EmailAddressId INTEGER(32) NOT NULL,
	CustomerId VARCHAR(32) NOT NULL,
    Domain VARCHAR(64),
    CONSTRAINT EmailAddress_pk PRIMARY KEY (EmailAddressId),
    CONSTRAINT Customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    CONSTRAINT Domain_fk FOREIGN KEY (Domain) REFERENCES Domain(DomainName)
);

CREATE TABLE IF NOT EXISTS EmailSentTo(
  emailID INTEGER,
  emailAddressId INTEGER,

  CONSTRAINT EmailSentTo_pk PRIMARY KEY (emailID, emailAddressId),
  CONSTRAINT FOREIGN KEY (emailAddressId) REFERENCES EmailAddress(emailAddressId),
  FOREIGN KEY (emailId) REFERENCES Email(id)
);

CREATE TABLE IF NOT EXISTS EmailEvent(
  eventID INTEGER AUTO_INCREMENT,
  eventType INTEGER,
  eventDate DATETIME,
  emailID INTEGER,
  emailAddressId INTEGER,

  CONSTRAINT EmailEvent_pk PRIMARY KEY (eventID),
  CONSTRAINT Event_Unique UNIQUE KEY (eventType, eventDate, emailID, emailAddressId),
  CONSTRAINT EmailSentTo_fk FOREIGN KEY (emailID) REFERENCES EmailSentTo(emailID),
  CONSTRAINT EmailAddress_Fk FOREIGN KEY (emailAddressId) REFERENCES EmailSentTo(emailAddressId)
);

CREATE TABLE IF NOT EXISTS Link
(
	LinkName VARCHAR(255),
	LinkURL VARCHAR(255),
	EventId INT,
	CONSTRAINT Link_pk PRIMARY KEY (LinkName, LinkURL),
	CONSTRAINT EventEvent_fk FOREIGN KEY (EventId) REFERENCES EmailEvent(EventId)
);
