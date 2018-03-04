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

UPDATE Device d JOIN Purchase p ON d.CustomerID = p.CustomerID AND p.DeviceRegistrationID = d.RegistrationID SET d.purchaseId = p.id;

ALTER TABLE Device DROP COLUMN PurchaseDate;
ALTER TABLE Device DROP COLUMN PurchaseStoreName;
ALTER TABLE Device DROP COLUMN PurchaseStoreCity;
ALTER TABLE Device DROP COLUMN PurchaseStoreState;
ALTER TABLE Device DROP COLUMN CustomerID;
ALTER TABLE Device DROP COLUMN Ecomm;

INSERT INTO EmailCampaign(CampaignName,DeploymentDate) (SELECT Distinct EmailCampaignName,STR_TO_DATE(Fulldate,'%m/%d/%Y') FROM CP_Email_Final);
INSERT INTO Audience(Audience) SELECT DISTINCT AudienceSegment FROM CP_Email_Final;
INSERT INTO SubjectLine(SubjectLine) SELECT DISTINCT SubjectLineCode FROM CP_Email_Final;

# TO DO: BROKEN BECAUSE OF NEW EMAIL STAR SCHEMA
INSERT INTO Email(Version,EmailCampaignID,SubjectLineID,AudienceID) SELECT distinct r.EmailVersion,c.id,s.id,a.id FROM CP_Email_Final r JOIN EmailCampaign c ON r.EmailCampaignName = c.CampaignName AND STR_TO_DATE(r.Fulldate,'%m/%d/%Y') = c.DeploymentDate
  JOIN Audience a ON r.AudienceSegment = a.Audience JOIN SubjectLine s ON s.SubjectLine = r.SubjectLineCode;

# Fills Domain with domain names from CP_Account
INSERT INTO Domain (DomainName)
SELECT DISTINCT DomainName FROM CP_Account;

# Fills EmailAddress with info from the CP_Account table
INSERT INTO EmailAddress (EmailAddressID, CustomerID, DomainID)
SELECT distinct c.EmailID, c.CustomerID, d.DomainID
FROM CP_Account c
JOIN Domain d ON c.DomainName = d.DomainName;

INSERT INTO DeviceRegistration(deviceRegistrationID,registeredAt,registrationDate) SELECT RegistrationID,SourceID,STR_TO_DATE(RegistrationDate,'%m/%d/%Y') FROM CP_Device;

#TODO BROKEN BELOW

# Fills EmailSentTo table using Email and EmailAddress

ALTER TABLE EmailSentTo DROP FOREIGN KEY a;
ALTER TABLE EmailSentTo DROP FOREIGN KEY b;
ALTER TABLE EmailSentTo DROP FOREIGN KEY c;

ALTER TABLE EmailSentTo DROP INDEX  a;
ALTER TABLE EmailSentTo DROP INDEX  b;
ALTER TABLE EmailSentTo DROP INDEX  c;

ALTER TABLE EmailEvent DROP FOREIGN KEY d;
ALTER TABLE EmailEvent DROP INDEX  d;


ALTER TABLE EmailSentTo MODIFY EmailCampaignID varchar(255);
ALTER TABLE EmailSentTo MODIFY SubjectLineID varchar(255);
ALTER TABLE EmailSentTo MODIFY AudienceID varchar(255);

INSERT INTO EmailSentTo (EmailVersion,emailAddressID,EmailCampaignID,SubjectLineID,AudienceID)
    SELECT distinct EmailVersion,f.EmailID,f.EmailCampaignName,f.SubjectLineCode,f.AudienceSegment FROM CP_Email_Final f where f.EmailID in (SELECT EmailAddressID FROM EmailAddress);

UPDATE EmailSentTo e JOIN SubjectLine c ON e.SubjectLineID = c.SubjectLine SET e.SubjectLineID = c.id;
ALTER TABLE EmailSentTo MODIFY SubjectLineID int(32);
ALTER TABLE EmailSentTo ADD FOREIGN KEY (SubjectLineID) REFERENCES SubjectLine(id);

UPDATE EmailSentTo e JOIN Audience c ON e.AudienceID = c.Audience SET e.AudienceID = c.id;
ALTER TABLE EmailSentTo MODIFY AudienceID int(32);
ALTER TABLE EmailSentTo ADD FOREIGN KEY (AudienceID) REFERENCES Audience(id);
#Todo fix foreign keys in EmailSentTo and EmailEvent
#UPDATE EmailSentTo e JOIN EmailCampaign c ON e.EmailCampaignID = c.CampaignName SET e.EmailCampaignID = c.id;
#Fills Link
ALTER TABLE Link MODIFY EmailCampaignID varchar(255);
ALTER TABLE Link MODIFY SubjectLineID varchar(255);
ALTER TABLE Link MODIFY AudienceID varchar(255);

ALTER TABLE EmailEvent MODIFY EmailCampaignID varchar(255);
ALTER TABLE EmailEvent MODIFY SubjectLineID varchar(255);
ALTER TABLE EmailEvent MODIFY AudienceID varchar(255);

insert into Link (LinkName, LinkURL, EmailVersion, EmailCampaignID, SubjectLineID, AudienceID)
select distinct HyperlinkName, EmailURL, EmailVersion, EmailCampaignName, SubjectLineCode, AudienceSegment from CP_Email_Final
where EmailID in (SELECT EmailAddressID FROM EmailAddress);

insert into EmailEvent (eventType, eventDate, EmailVersion, EmailCampaignID, SubjectLineID, AudienceID, emailAddressID, linkID)
select distinct EmailEventType,
  STR_TO_DATE(EmailEventDateTime, '%m/%d/%y %h:%i %p'),
  ef.EmailVersion, ef.EmailCampaignName,
  ef.SubjectLineCode, ef.AudienceSegment,
  EmailID, LinkID from CP_Email_Final ef
  join Link l on ef.HyperlinkName = l.LinkName
  and ef.EmailURL = l.LinkURL
  and ef.EmailVersion = l.EmailVersion
  and ef.EmailCampaignName = l.EmailCampaignID
  and ef.AudienceSegment = l.AudienceID
  and ef.SubjectLineCode = l.SubjectLineID
where EmailID in (SELECT EmailAddressID FROM EmailAddress);

UPDATE Link l JOIN EmailCampaign c ON l.EmailCampaignID = c.CampaignName SET l.EmailCampaignID = c.id;
UPDATE Link l JOIN SubjectLine s on l.SubjectLineID = s.SubjectLine SET l.SubjectLineID = s.id;
UPDATE Link l JOIN Audience a on l.AudienceID = a.Audience SET l.AudienceID = a.id;

UPDATE EmailEvent l JOIN EmailCampaign c ON l.EmailCampaignID = c.CampaignName SET l.EmailCampaignID = c.id;
UPDATE EmailEvent l JOIN SubjectLine s on l.SubjectLineID = s.SubjectLine SET l.SubjectLineID = s.id;
UPDATE EmailEvent l JOIN Audience a on l.AudienceID = a.Audience SET l.AudienceID = a.id;

ALTER TABLE Link MODIFY EmailCampaignID INTEGER;
ALTER TABLE Link MODIFY SubjectLineID INTEGER;
ALTER TABLE Link MODIFY AudienceID INTEGER;

ALTER TABLE EmailEvent MODIFY EmailCampaignID INTEGER;
ALTER TABLE EmailEvent MODIFY SubjectLineID INTEGER;
ALTER TABLE EmailEvent MODIFY AudienceID INTEGER;

ALTER TABLE Link ADD CONSTRAINT
FOREIGN KEY (EmailVersion)
REFERENCES Email(Version);

ALTER TABLE Link ADD CONSTRAINT
FOREIGN KEY (AudienceID)
REFERENCES Audience(id);

ALTER TABLE Link ADD CONSTRAINT
FOREIGN KEY (EmailCampaignID)
REFERENCES EmailCampaign(id);

ALTER TABLE Link ADD CONSTRAINT
FOREIGN KEY (SubjectLineID)
REFERENCES SubjectLine(id);

ALTER TABLE EmailEvent ADD CONSTRAINT FOREIGN KEY (EmailVersion) REFERENCES Email(Version);
ALTER TABLE EmailEvent ADD CONSTRAINT FOREIGN KEY (AudienceID) REFERENCES Audience(id);
ALTER TABLE EmailEvent ADD CONSTRAINT FOREIGN KEY (EmailCampaignID) REFERENCES EmailCampaign(id);
ALTER TABLE EmailEvent ADD CONSTRAINT FOREIGN KEY (SubjectLineID) REFERENCES SubjectLine(id);
