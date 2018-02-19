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
    CarrierID INT,
    PRIMARY KEY (DeviceModel, DeviceName, DeviceType, CarrierID),
    FOREIGN KEY (CarrierID) REFERENCES Carrier(ID)
);

CREATE TABLE IF NOT EXISTS RegistrationSource(
    regSourceID INT PRIMARY KEY,
    regSourceName VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS Customer
(
    CustomerID VARCHAR(32) NOT NULL,
    Permission CHAR(1),
    Tier VARCHAR(32),
    RegistrationDate DATE,
    NumRegistrations INT,
    RegisteredAt INT,
    PRIMARY KEY (CustomerID),
    FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceID)
);

CREATE TABLE IF NOT EXISTS Gender
(
    Gender CHAR(1) NOT NULL,
    PRIMARY KEY (Gender)
);

CREATE TABLE IF NOT EXISTS IncomeLevel
(
    IncomeLevel VARCHAR(32) NOT NULL,
    PRIMARY KEY (IncomeLevel)
);

CREATE TABLE IF NOT EXISTS Language
(
    Language CHAR(3) NOT NULL,
    PRIMARY KEY (Language)
);

CREATE TABLE IF NOT EXISTS Zip
(
    Zip INT,
    PRIMARY KEY (Zip)
);

CREATE TABLE IF NOT EXISTS State
(
    State VARCHAR(32) NOT NULL,
    PRIMARY KEY (State)
);

CREATE TABLE IF NOT EXISTS Device
(
    id INT AUTO_INCREMENT,
    DeviceModel VARCHAR(255),
    SerialNumber VARCHAR(64),
    RegistrationDate DATE,
    RegistrationID VARCHAR(64) NOT NULL,
    CONSTRAINT Device_RegistrationID_pk PRIMARY KEY (RegistrationID),
    CONSTRAINT Device_Device_Type_DeviceModel_fk FOREIGN KEY (DeviceModel) REFERENCES Device_Type (DeviceModel),
    UNIQUE(ID)
);

CREATE TABLE IF NOT EXISTS Purchase
(
    id INT AUTO_INCREMENT NOT NULL,
    PurchaseDate DATE,
    PurchaseStoreName VARCHAR(255),
    PurchaseStoreState CHAR(3),
    PurchaseStoreCity VARCHAR(255),
    Ecomm CHAR(1),
    DeviceRegistrationID VARCHAR(64) NOT NULL,
    CustomerID VARCHAR(32) NOT NULL,
    FOREIGN KEY (DeviceRegistrationID) REFERENCES Device(RegistrationID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    PRIMARY KEY (CustomerID, DeviceRegistrationID),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS DeviceRegistration(
    deviceRegistrationID VARCHAR(64),
    registeredAt INT,
    registrationDate DATE,
    PRIMARY KEY (deviceRegistrationID),
    FOREIGN KEY (deviceRegistrationID) REFERENCES Device(RegistrationID),
    FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceID)
);

CREATE TABLE IF NOT EXISTS EmailCampaign
(
    id INT AUTO_INCREMENT,
    CampaignName VARCHAR(255),
    DeploymentDate DATE,
    CONSTRAINT EmailCampaign_pk PRIMARY KEY (CampaignName, DeploymentDate),
    Unique(id)
);

CREATE TABLE IF NOT EXISTS SubjectLine
(
    id INT AUTO_INCREMENT,
    SubjectLine VARCHAR(255),
    PRIMARY KEY (SubjectLine),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS Audience
(
    id INT AUTO_INCREMENT,
    Audience VARCHAR(255),
    PRIMARY KEY (Audience),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS Email
(
    id INT AUTO_INCREMENT,
    Version varchar(255),
    EmailCampaignID INT,
    SubjectLineID int,
    AudienceID int,
    PRIMARY KEY (Version, EmailCampaignID,SubjectLineID,AudienceID),
    FOREIGN KEY (EmailCampaignID) REFERENCES EmailCampaign (id),
    FOREIGN KEY (SubjectLineID) REFERENCES SubjectLine(id),
    FOREIGN KEY (AudienceID) REFERENCES Audience(id),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS Domain
(
    DomainName VARCHAR(64),
    PRIMARY KEY (DomainName)
);

CREATE TABLE IF NOT EXISTS EmailAddress
(
    EmailAddressID INT(32) NOT NULL,
    CustomerID VARCHAR(32) NOT NULL,
    Domain VARCHAR(64),
    PRIMARY KEY (EmailAddressID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (Domain) REFERENCES Domain(DomainName)
);

CREATE TABLE IF NOT EXISTS EmailSentTo(
   emailID INT,
   emailAddressID INT,
   PRIMARY KEY (emailID, emailAddressID),
   FOREIGN KEY (emailAddressID) REFERENCES EmailAddress(emailAddressID),
   FOREIGN KEY (emailID) REFERENCES Email(id)
);

CREATE TABLE IF NOT EXISTS Link
(
   LinkID INT AUTO_INCREMENT,
   LinkName VARCHAR(255),
   LinkURL VARCHAR(255),
   EmailID INT,
   PRIMARY KEY (LinkID),
   FOREIGN KEY (EmailID) REFERENCES Email(id),
   UNIQUE KEY (LinkID, LinkName, LinkURL, EmailID)
);

CREATE TABLE IF NOT EXISTS EmailEvent(
   eventID INT AUTO_INCREMENT,
   eventType varchar(32),
   eventDate DATETIME,
   emailID INT,
   emailAddressID INT,
   linkID INT,
   PRIMARY KEY (eventID),
   UNIQUE KEY (eventType, eventDate, emailID, emailAddressID),
   FOREIGN KEY (emailID) REFERENCES EmailSentTo(emailID),
   FOREIGN KEY (emailAddressID) REFERENCES EmailSentTo(emailAddressID),
   FOREIGN KEY (linkID) REFERENCES Link(LinkID)
);
