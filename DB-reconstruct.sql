#Recreating CP_Account
SELECT c.CustomerID, ea.EmailAddressID AS EmailID, c.RegisteredAt AS RegSourceID, r.regSourceName, ZipID AS Zip, StateID AS State, GenderID AS Gender, IncomeLevelID AS IncomeLevel, c.Permission, LanguageID AS Language, c.RegistrationDate AS RegDate, DomainName, c.Tier AS CustomerTier
FROM Customer c
JOIN EmailAddress ea ON ea.CustomerID = c.CustomerID
JOIN Domain d ON ea.DomainID = d.DomainID;
JOIN RegistrationSource r ON c.RegisteredAt = r.regSourceID
JOIN Zip z ON z.id = c.ZipID
JOIN State s ON s.id = c.StateID
JOIN Gender g ON g.id = c.GenderID
JOIN IncomeLevel i ON i.id = c.IncomeLevelID
JOIN Language l ON l.id = c.LanguageID;

# Recreates CP_Email_Final 
select E2.emailAddressID, EA.Audience, ec.CampaignName, EV.Version,
    ES.SubjectLine, ec.DeploymentDate, E3.eventType, E3.eventDate, L2.LinkName,
    L2.LinkURL
from Email e
join EmailCampaign ec on e.EmailCampaignID = ec.id
left join (select EA.EmailID, A.Audience FROM EmailAudience EA
join Audience A ON EA.AudienceID = A.id) as EA on EA.EmailID = e.id
left join (select EV.EmailID, V.Version from EmailVersion EV
join Version V ON EV.VersionID = V.id) as EV on EV.EmailID = e.id
left join (select S.EmailID, L.SubjectLine from EmailSubject S
join SubjectLine L ON S.SubjectLineID = L.id) as ES on ES.EmailID = e.id
left join Link L2 ON e.id = L2.EmailID
join EmailSentTo E2 ON e.id = E2.EmailID
left join EmailEvent E3 ON E2.emailAddressID = E3.emailAddressID and E2.EmailID = E3.EmailID;

#Recreating CP_Device_Model
SELECT distinct D.DeviceModel,DeviceName,Devicetype,CarrierName FROM Device JOIN Device_Type D ON Device.DeviceModel = D.DeviceModel JOIN Carrier C ON D.CarrierID = C.ID;

SELECT * FROM cpe366_readonly.CP_Device_Model;

#Recreating CP_Device
SELECt P.CustomerID,regSourceID, S.regSourceName, DeviceModel,SerialNumber,PurchaseDate,PurchaseStoreName,
  PurchaseStoreState,PurchaseStoreCity,Ecomm,NumRegistrations,RegistrationID
  FROM Customer JOIN Purchase P ON Customer.CustomerID = P.CustomerID JOIN PurchaseLocation L ON P.PurchaseLocationID = L.id
  JOIN Device D ON P.id = D.PurchaseID JOIN RegistrationSource S ON Customer.RegisteredAt = S.regSourceID;

SELECt count(*) FROM cpe366_readonly.CP_Device
