#Inserting into Customer
INSERT INTO Gender(Gender) VALUES('m');
INSERT INTO Gender(Gender) VALUES('f');

INSERT INTO IncomeLevel(IncomeLevel) SELECT distinct IncomeLevel FROM `CP_Account`;
INSERT INTO Language(Language) SELECT distinct Language FROM `CP_Account`;
INSERT INTO Zip(Zip) SELECT distinct ZIP FROM `CP_Account`;
INSERT INTO State(State) SELECT distinct State FROM `CP_Account`;

INSERT INTO Customer(CustomerID,Permission,Tier,RegistrationDate,NumRegistrations,RegisteredAt,GenderID,IncomeLevelID,LanguageID,ZipID,StateID)
    SELECT distinct r.CustomerId,r.Permission,r.CustomerTier,r.RegDate,r.RegSourceID,a.`NumberOfRegistrations`,g.id,i.id,l.id,z.id,s.id FROM `CP_Account` r
        JOIN Gender g ON g.Gender = r.Gender
        JOIN IncomeLevel i ON i.IncomeLevel= r.IncomeLevel
        JOIN Language l ON l.Language = r.Language
        JOIN Zip z ON z.Zip = r.Zip
        JOIN State s ON s.State = r.State
        JOIN `CP_Device` a ON r.`customerID` = a.`CustomerID`

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

# Fills RegistrationSource
INSERT INTO RegistrationSource (regSourceId, regSourceName)
SELECT DISTINCT RegSourceID as sourceID, RegSourceName as sourceName
FROM CP_Account
UNION
SELECT DISTINCT SourceID as sourceID, SourceName as sourceName
FROM CP_Device
ORDER BY sourceID;

#Insert into device all the devices from CP_Device, properly converting date fields to be of DATE type
INSERT INTO Device(CustomerID,SourceID,SourceName,DeviceModel,SerialNumber,PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm,RegistrationDate,NumberOfRegistrations,RegistrationID)
  (SELECT distinct CustomerID,SourceID,SourceName,DeviceModel,SerialNumber,STR_TO_DATE(CP_Device.PurchaseDate,'%m/%d/%Y'),PurchaseStoreName, PurchaseStoreState,PurchaseStoreCity, Ecomm,
     STR_TO_DATE(CP_Device.RegistrationDate,'%m/%d/%Y') , NumberOfRegistrations, RegistrationID FROM CP_Device);
#TODO Customer MUST Exist before this row
INSERT INTO Purchase(PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm,DeviceRegistrationId,CustomerID) (SELECT PurchaseDate,PurchaseStoreName,PurchaseStoreState,PurchaseStoreCity,Ecomm,RegistrationID,CustomerID FROM Device);

ALTER TABLE Device ADD COLUMN PurchaseID INTEGER;
ALTER TABLE Device ADD FOREIGN KEY (PurchaseID) REFERENCES Purchase(id);

UPDATE Device d JOIN Purchase p ON p.PurchaseDate = d.PurchaseDate AND p.PurchaseStoreCity = d.PurchaseStoreCity
                                          AND p.PurchaseStoreState = d.PurchaseStoreState AND p.PurchaseStoreName = d.PurchaseStoreName
                                          AND p.Ecomm = d.Ecomm SET d.PurchaseID = p.id;

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

# Fills EmailAddress with info from the CP_Acoount table
INSERT INTO EmailAddress (EmailAddressID, CustomerID, Domain)
SELECT EmailID, CustomerID, DomainName
FROM CP_Account;

# Fills EmailSentTo table using Email and EmailAddress
INSERT INTO EmailSentTo (emailID, emailAddressID)
SELECT Email.id, CP_Email_Final.EmailID FROM Email
JOIN EmailCampaign ON Email.EmailCampaignID = EmailCampaign.id
JOIN CP_Email_Final ON CP_Email_Final.EmailCampaignName = EmailCampaign.CampaignName
                    AND CP_Email_Final.EmailVersion = Email.Version;
