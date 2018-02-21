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
INSERT INTO Email(Version,EmailCampaignID,SubjectLineID,AudienceID) SELECT distinct r.EmailVersion,c.id,s.id,a.id FROM CP_Email_Final r JOIN EmailCampaign c ON r.EmailCampaignName = c.CampaignName AND STR_TO_DATE(r.Fulldate,'%m/%d/%Y') = c.DeploymentDate
  JOIN Audience a ON r.AudienceSegment = a.Audience JOIN SubjectLine s ON s.SubjectLine = r.SubjectLineCode;

# Fills Domain with domain names from CP_Account
INSERT INTO Domain (DomainName)
SELECT DISTINCT DomainName FROM CP_Account;

# Fills EmailAddress with info from the CP_Account table
INSERT INTO EmailAddress (EmailAddressID, CustomerID, Domain)
SELECT distinct EmailID, CustomerID, DomainName
FROM CP_Account;

INSERT INTO DeviceRegistration(deviceRegistrationID,registeredAt,registrationDate) SELECT RegistrationID,SourceID,STR_TO_DATE(RegistrationDate,'%m/%d/%Y') FROM CP_Device;

#TODO BROKEN BELOW

# Fills EmailSentTo table using Email and EmailAddress
ALTER TABLE EmailSentTo MODIFY EmailCampaignID varchar(255);
ALTER TABLE EmailSentTo MODIFY SubjectLineID varchar(255);
ALTER TABLE EmailSentTo MODIFY AudienceID varchar(255);

INSERT INTO EmailSentTo (EmailVersion,emailAddressID,EmailCampaignID,SubjectLineID,AudienceID)
    SELECT distinct EmailVersion,f.EmailID,f.EmailCampaignName,f.SubjectLineCode,f.AudienceSegment FROM CP_Email_Final f where f.EmailID in (SELECT EmailAddressID FROM EmailAddress);

UPDATE EmailSentTo e JOIN EmailCampaign c ON e.EmailCampaignID = c.CampaignName SET e.EmailCampaignID = c.id;

SELECT * FROM EmailSentTo e JOIN EmailCampaign c ON e.EmailCampaignID = c.CampaignName;
#Fills Link
#INSERT INTO Link(EmailID,LinkName,LinkURL)  SELECT Email.id,CP_Email_Final.HyperlinkName, CP_Email_Final.EmailURL
#FROM Email
#   JOIN EmailCampaign ON Email.EmailCampaignID = EmailCampaign.id
#   JOIN CP_Email_Final ON CP_Email_Final.EmailCampaignName = EmailCampaign.CampaignName
#                   AND CP_Email_Final.EmailVersion = Email.Version
#                   AND EmailCampaign.DeploymentDate = STR_TO_DATE(CP_Email_Final.EmailEventDateTime, '%m/%d/%y');
insert into Link (LinkName, LinkURL, EmailCampaignID, SubjectLineID, AudienceID)
select distinct HyperlinkName, EmailURL, 1, 1, 1 from CP_Email_Final;

INSERT INTO EmailEvent (eventType, eventDate, emailID, emailAddressID, linkID)
SELECT EmailEventType, STR_TO_DATE(EmailEventDateTime, '%m/%d/%y %h:%i %p'),
        e.id, ef.EmailID, l.LinkID
FROM Email e
JOIN EmailCampaign ec ON e.EmailCampaignID = ec.id
JOIN CP_Email_Final ef ON ef.EmailCampaignName = ec.CampaignName
                    AND ef.EmailVersion = e.Version
JOIN Link l ON l.EmailID = e.id
WHERE l.LinkURL = ef.EmailURL
AND l.LinkName = ef.HyperlinkName;
