CREATE TABLE CP_Account LIKE cpe366_readonly.CP_Account;
INSERT CP_Account SELECT * FROM cpe366_readonly.CP_Account;

CREATE TABLE CP_Device LIKE cpe366_readonly.CP_Device;
INSERT CP_Device SELECT * FROM cpe366_readonly.CP_Device;

CREATE TABLE CP_Device_Model LIKE cpe366_readonly.CP_Device_Model;
INSERT CP_Device_Model SELECT * FROM cpe366_readonly.CP_Device_Model;

CREATE TABLE CP_Email_Final LIKE cpe366_readonly.CP_Email_Final;
INSERT CP_Email_Final SELECT * FROM cpe366_readonly.CP_Email_Final;


#Inserting into Customer
INSERT INTO Gender(id,Gender) VALUES(-1,'N');
INSERT INTO Gender(id,Gender) VALUES(1,'M');
INSERT INTO Gender(id,Gender) VALUES(2,'F');


INSERT INTO IncomeLevel(id,IncomeLevel) VALUES(-1,"Unknown");
INSERT INTO IncomeLevel(IncomeLevel) SELECT distinct IncomeLevel FROM `CP_Account`;
INSERT INTO Language(Language) SELECT distinct Language FROM `CP_Account`;
INSERT INTO Language(id,Language) VALUES(-1,"N/A");
INSERT INTO Zip(Zip) SELECT distinct ZIP FROM `CP_Account`;
INSERT INTO Zip(id,Zip) VALUES(-1,-1);
INSERT INTO State(State) SELECT distinct State FROM `CP_Account`;
INSERT INTO State(id,State) VALUES(-1,"Unknown");


# Fills RegistrationSource
INSERT INTO RegistrationSource (regSourceId, regSourceName)
SELECT DISTINCT RegSourceID as sourceID, RegSourceName as sourceName
FROM CP_Account
UNION
SELECT DISTINCT SourceID as sourceID, SourceName as sourceName
FROM CP_Device
ORDER BY sourceID;

ALTER TABLE Device ADD COLUMN PurchaseDate DATE;
ALTER TABLE Device ADD COLUMN PurchaseStoreName VARCHAR(64);
ALTER TABLE Device ADD COLUMN PurchaseStoreCity VARCHAR(64);
ALTER TABLE Device ADD COLUMN PurchaseStoreState CHAR(3);
ALTER TABLE Device ADD COLUMN CustomerID VARCHAR(32);
ALTER TABLE Device ADD COLUMN Ecomm CHAR(1);

ALTER TABLE Purchase ADD COLUMN PurchaseStoreName VARCHAR(64);
ALTER TABLE Purchase ADD COLUMN PurchaseStoreCity VARCHAR(64);
ALTER TABLE Purchase ADD COLUMN PurchaseStoreState CHAR(3);

#Inserts all possible carriers into carrier table, plus a dummy -1 value
INSERT INTO Carrier(CarrierName) (SELECT distinct Carrier from CP_Device_Model);
INSERT INTO Carrier(ID,CarrierName) VALUES(-1,"No Carrier Information Found");

#Moves CP_Device_Model to the new table Device_Type
UPDATE CP_Device_Model JOIN Carrier ON CarrierName = Carrier SET Carrier = ID;
INSERT INTO Device_Type (SELECT distinct * FROM CP_Device_Model);

#Due to the presence of device models from sales records not in the device models table we must pull device
#models from device as well
INSERT INTO Device_Type (SELECT distinct `DeviceModel`,"","",-1 FROM CP_Device);

#Insert into device all the devices from CP_Device, properly converting date fields to be of DATE type
INSERT INTO Device(CustomerID,DeviceModel,SerialNumber,PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm,RegistrationDate,RegistrationID)
  SELECT distinct CustomerID,DeviceModel,SerialNumber,STR_TO_DATE(CP_Device.PurchaseDate,'%m/%d/%Y'),PurchaseStoreName, PurchaseStoreState,PurchaseStoreCity, Ecomm,
     STR_TO_DATE(CP_Device.RegistrationDate,'%m/%d/%Y'), RegistrationID FROM CP_Device;

ALTER TABLE Device ADD COLUMN PurchaseID INTEGER;
ALTER TABLE Device ADD FOREIGN KEY (PurchaseID) REFERENCES Purchase(id);

INSERT INTO Customer(CustomerID,Permission,Tier,RegistrationDate,RegisteredAt,NumRegistrations,GenderID,IncomeLevelID,LanguageID,ZipID,StateID)
  SELECT r.CustomerId,r.Permission,r.CustomerTier,STR_TO_DATE(r.RegDate,'%m/%d/%Y') as regDate,r.RegSourceID,0,-1,-1,-1,-1,-1 FROM `CP_Account` r group by CustomerId;
#catch all customers not actually in the customer Table
INSERT INTO Customer(CustomerID) (SELECT distinct Device.CustomerID FROM Device WHERE NOT Device.CustomerID IN ( SELECT distinct CustomerID FROM Customer));

UPDATE Customer c JOIN (SELECT CustomerID,NumberOfRegistrations FROM CP_Device group BY  CustomerID) as z ON c.CustomerID = z.CustomerID SET c.NumRegistrations = z.NumberOfRegistrations;
UPDATE Customer c JOIN (SELECT * FROM CP_Account r group by CustomerId) as r ON c.CustomerID = r.customerId JOIN Gender G ON r.Gender = G.Gender SET c.GenderID = G.id;
UPDATE Customer c JOIN (SELECT * FROM CP_Account r group by CustomerId) as r ON c.CustomerID = r.customerId JOIN IncomeLevel G ON r.IncomeLevel = G.IncomeLevel SET c.IncomeLevelID = G.id;
UPDATE Customer c JOIN (SELECT * FROM CP_Account r group by CustomerId) as r ON c.CustomerID = r.customerId JOIN Language G ON r.Language = G.Language SET c.LanguageId = G.id;
UPDATE Customer c JOIN (SELECT * FROM CP_Account r group by CustomerId) as r ON c.CustomerID = r.customerId JOIN Zip G ON r.ZIP= G.Zip SET c.ZipID = G.id;
UPDATE Customer c JOIN (SELECT * FROM CP_Account r group by CustomerId) as r ON c.CustomerID = r.customerId JOIN State G ON r.State = G.State SET c.StateID = G.id;

INSERT INTO Purchase(PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm,DeviceRegistrationId,CustomerID) (SELECT PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm,RegistrationID,CustomerID FROM Device);

INSERT INTO PurchaseLocation(PurchaseStoreName,PurchaseStoreCity,PurchaseStoreState) (SELECT DISTINCT PurchaseStoreName,PurchaseStoreCity,PurchaseStoreState FROM Purchase);

UPDATE Purchase p JOIN PurchaseLocation l SET PurchaseLocationID = l.id WHERE p.PurchaseStoreName = l.PurchaseStoreName
                                                AND p.PurchaseStoreCity = l.PurchaseStoreCity
                                                AND l.PurchaseStoreState = p.PurchaseStoreState;

ALTER TABLE Purchase DROP PurchaseStoreState;
ALTER TABLE Purchase DROP PurchaseStoreName;
ALTER TABLE Purchase DROP PurchaseStoreCity;

UPDATE Device d JOIN Purchase p ON d.CustomerID = p.CustomerID AND p.DeviceRegistrationID = d.RegistrationID SET d.purchaseId = p.id;

ALTER TABLE Device DROP COLUMN PurchaseDate;
ALTER TABLE Device DROP COLUMN PurchaseStoreName;
ALTER TABLE Device DROP COLUMN PurchaseStoreCity;
ALTER TABLE Device DROP COLUMN PurchaseStoreState;
ALTER TABLE Device DROP COLUMN CustomerID;
ALTER TABLE Device DROP COLUMN Ecomm;

INSERT INTO EmailCampaign(CampaignName,DeploymentDate) 
(SELECT Distinct EmailCampaignName,STR_TO_DATE(Fulldate,'%m/%d/%Y') FROM CP_Email_Final);

INSERT INTO Audience (Audience)
SELECT DISTINCT AudienceSegment
FROM CP_Email_Final
WHERE AudienceSegment != '';

INSERT INTO SubjectLine (SubjectLine)
SELECT DISTINCT SubjectLineCode
FROM CP_Email_Final
WHERE CP_Email_Final.SubjectLineCode != '';

INSERT INTO Version (Version)
SELECT DISTINCT EmailVersion
FROM CP_Email_Final
WHERE CP_Email_Final.EmailVersion != '';

# Fills Domain with domain names from CP_Account
INSERT INTO Domain (DomainName)
SELECT DISTINCT DomainName FROM CP_Account;

# Fills EmailAddress with info from the CP_Account table
INSERT INTO EmailAddress (EmailAddressID, CustomerID, Domain)
SELECT distinct EmailID, CustomerID, DomainName
FROM CP_Account
UNION
SELECT distinct EmailID, NULL, NULL
FROM CP_Email_Final
WHERE EmailID NOT IN (SELECT DISTINCT EmailID FROM CP_Account);

INSERT INTO DeviceRegistration(deviceRegistrationID,registeredAt,registrationDate) SELECT RegistrationID,SourceID,STR_TO_DATE(RegistrationDate,'%m/%d/%Y') FROM CP_Device;
