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

CREATE TABLE IF NOT EXISTS Gender
(   id INT AUTO_INCREMENT,
    Gender CHAR(1) NOT NULL,
    PRIMARY KEY (Gender),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS IncomeLevel
(   id INT AUTO_INCREMENT,
    IncomeLevel VARCHAR(32) NOT NULL,
    PRIMARY KEY (IncomeLevel),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS Language
(   id INT AUTO_INCREMENT,
    Language CHAR(3) NOT NULL,
    PRIMARY KEY (Language),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS Zip
(   id INT AUTO_INCREMENT,
    Zip INT,
    PRIMARY KEY (Zip),
    UNIQUE(id)
);

CREATE TABLE IF NOT EXISTS State
(   id INT AUTO_INCREMENT,
    State VARCHAR(127) NOT NULL,
    PRIMARY KEY (State),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS Customer
(
    CustomerID VARCHAR(32) NOT NULL,
    Permission CHAR(1),
    Tier VARCHAR(32),
    RegistrationDate DATE,
    NumRegistrations INT,
    RegisteredAt INT,
    GenderID INT,
    IncomeLevelID INT,
    LanguageID INT,
    ZipID INT,
    StateID INT,
    PRIMARY KEY (CustomerID),
    FOREIGN KEY (GenderID) REFERENCES Gender(id),
    FOREIGN KEY (IncomeLevelID) REFERENCES IncomeLevel(id),
    FOREIGN KEY (LanguageID) REFERENCES Language(id),
    FOREIGN KEY (ZipID) REFERENCES Zip(id),
    FOREIGN KEY (StateID) REFERENCES State(id),
    FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceID)
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
    Version varchar(255),
    EmailCampaignID INT,
    SubjectLineID int,
    AudienceID int,
    PRIMARY KEY (Version, EmailCampaignID,SubjectLineID,AudienceID),
    FOREIGN KEY (EmailCampaignID) REFERENCES EmailCampaign (id),
    FOREIGN KEY (SubjectLineID) REFERENCES SubjectLine(id),
    FOREIGN KEY (AudienceID) REFERENCES Audience(id)
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
   emailAddressID INT,
   EmailVersion varchar(255),
   EmailCampaignID INT,
   SubjectLineID int,
   AudienceID int,
   PRIMARY KEY (EmailVersion,EmailCampaignID,SubjectLineID,AudienceID, emailAddressID),
   FOREIGN KEY (emailAddressID) REFERENCES EmailAddress(emailAddressID),
   FOREIGN KEY (EmailVersion) REFERENCES Email(Version),
   CONSTRAINT a FOREIGN KEY (SubjectLineID) REFERENCES EmailCampaign(id),
   CONSTRAINT b FOREIGN KEY (EmailCampaignID) REFERENCES SubjectLine(id),
   CONSTRAINT c FOREIGN KEY (AudienceID) REFERENCES Audience(id)

);

CREATE TABLE IF NOT EXISTS Link
(
   LinkID INT AUTO_INCREMENT,
   LinkName VARCHAR(255),
   LinkURL VARCHAR(255),
   EmailVersion varchar(255),
   EmailCampaignID INT,
   SubjectLineID int,
   AudienceID int,
   PRIMARY KEY (LinkID),
   UNIQUE KEY (LinkID, LinkName, LinkURL, EmailVersion,EmailCampaignID,SubjectLineID,AudienceID),
   FOREIGN KEY (EmailVersion) REFERENCES Email(Version)
);


CREATE TABLE IF NOT EXISTS EmailEvent(
   eventID INT AUTO_INCREMENT,
   eventType varchar(32),
   eventDate DATETIME,
   EmailVersion varchar(255),
   EmailCampaignID INT,
   SubjectLineID int,
   AudienceID int,   emailAddressID INT,
   linkID INT,
   PRIMARY KEY (eventID),
   UNIQUE KEY (eventType, eventDate, EmailVersion,EmailCampaignID,SubjectLineID,AudienceID, emailAddressID),
   CONSTRAINT d FOREIGN KEY (EmailVersion,EmailCampaignID,SubjectLineID,AudienceID) REFERENCES EmailSentTo(EmailVersion,EmailCampaignID,SubjectLineID,AudienceID),
   FOREIGN KEY (emailAddressID) REFERENCES EmailSentTo(emailAddressID),
   FOREIGN KEY (linkID) REFERENCES Link(LinkID)
);
