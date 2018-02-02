CREATE TABLE IF NOT EXISTS Carrier
(
    ID INT NOT NULL AUTO_INCREMENT,
    CarrierName VARCHAR(64),
    PRIMARY KEY (ID, CarrierName)
);

CREATE TABLE IF NOT EXISTS Device_Type
(
    DeviceModel VARCHAR(255) NOT NULL,
    DeviceName VARCHAR(255),
    Devicetype VARCHAR(32),
    CarrierID INTEGER,

    PRIMARY KEY (DeviceModel, DeviceName, DeviceType, CarrierID),
    FOREIGN KEY (CarrierID) REFERENCES Carrier(ID)
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
    NumberOfRegistrations INTEGER,
    RegistrationID VARCHAR(64) NOT NULL,
    PRIMARY KEY (RegistrationID),
    FOREIGN KEY (DeviceModel) REFERENCES Device_Type (DeviceModel),
    UNIQUE(ID)
);

#Star model for Customer
CREATE TABLE IF NOT EXISTS Customer
(
    CustomerId VARCHAR(32) NOT NULL,
    Permission CHAR(1),
    Tier VARCHAR(32),
    NumRegistrations INTEGER,
    PRIMARY KEY (CustomerId)
);
CREATE TABLE IF NOT EXISTS Gender
(
    Gender CHAR(1),
    CustomerId VARCHAR(32) NOT NULL,
    PRIMARY KEY (CustomerId, Gender),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS IncomeLevel
(
    IncomeLevel VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    PRIMARY KEY (CustomerId, IncomeLevel),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS Language
(
    Language CHAR(3),
    CustomerId VARCHAR(32) NOT NULL,
    PRIMARY KEY (CustomerId, Language),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS Zip
(
    Zip INTEGER,
    CustomerId VARCHAR(32) NOT NULL,
    PRIMARY KEY (CustomerId, Zip),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IF NOT EXISTS State
(
    State VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    PRIMARY KEY (CustomerId, State),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
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
    FOREIGN KEY (DeviceRegistrationId) REFERENCES Device(RegistrationID),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    PRIMARY KEY (PurchaseDate, PurchaseStoreName, PurchaseStoreState, PurchaseStoreCity, Ecomm)
);

CREATE TABLE IF NOT EXISTS RegistrationSource(
  regSourceId INTEGER PRIMARY KEY,
  regSourceName VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS CustomerAccount(
  customerID VARCHAR(32),
  registrationDate DATE,
  numRegistrations INTEGER,
  registeredAt INTEGER,

  PRIMARY KEY (customerID, registrationDate),
  FOREIGN KEY (customerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceId)
);

CREATE TABLE IF NOT EXISTS DeviceRegistration(
  deviceRegistrationID VARCHAR(64),
  registeredAt INTEGER,
  registrationDate DATE,

  PRIMARY KEY (deviceRegistrationID),
  FOREIGN KEY (deviceRegistrationID) REFERENCES Device(RegistrationID),
  FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceId)
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
    Version INTEGER,
    EmailCampaignID INTEGER,
    PRIMARY KEY (Version, EmailCampaignID),
    FOREIGN KEY (EmailCampaignID) REFERENCES EmailCampaign (id),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS SubjectLine
(
    SubjectLine VARCHAR(255),
    EmailID INTEGER(32) NOT NULL,
    PRIMARY KEY (SubjectLine,EmailID),
    FOREIGN KEY (EmailID) REFERENCES Email(id)
);

CREATE TABLE IF NOT EXISTS Audience
(
    Audience VARCHAR(255),
    EmailID INTEGER(32) NOT NULL,
    PRIMARY KEY (Audience,EmailID),
    FOREIGN KEY (EmailID) REFERENCES Email(id)
);



CREATE TABLE IF NOT EXISTS Domain
(  
    DomainName VARCHAR(64),
    PRIMARY KEY (DomainName)
);

CREATE TABLE IF NOT EXISTS EmailAddress
(
    EmailAddressId INTEGER(32) NOT NULL,
	CustomerId VARCHAR(32) NOT NULL,
    Domain VARCHAR(64),
    PRIMARY KEY (EmailAddressId),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    FOREIGN KEY (Domain) REFERENCES Domain(DomainName)
);

CREATE TABLE IF NOT EXISTS EmailSentTo(
  emailID INTEGER,
  emailAddressId INTEGER,

  PRIMARY KEY (emailID, emailAddressId),
  FOREIGN KEY (emailAddressId) REFERENCES EmailAddress(emailAddressId),
  FOREIGN KEY (emailId) REFERENCES Email(id)
);

CREATE TABLE IF NOT EXISTS EmailEvent(
  eventID INTEGER AUTO_INCREMENT,
  eventType INTEGER,
  eventDate DATETIME,
  emailID INTEGER,
  emailAddressId INTEGER,

  PRIMARY KEY (eventID),
  UNIQUE KEY (eventType, eventDate, emailID, emailAddressId),
  FOREIGN KEY (emailID) REFERENCES EmailSentTo(emailID),
  FOREIGN KEY (emailAddressId) REFERENCES EmailSentTo(emailAddressId)
);

CREATE TABLE IF NOT EXISTS Link
(
	LinkName VARCHAR(255),
	LinkURL VARCHAR(255),
	EventId INTEGER,
	PRIMARY KEY (LinkName, LinkURL),
	FOREIGN KEY (EventId) REFERENCES EmailEvent(EventId)
);
