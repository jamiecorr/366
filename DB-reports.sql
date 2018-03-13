#Report 1
# Create view to make actual query more manageable
create or replace view CombinedEmail as
select e.id, A2.CustomerID, ec.CampaignName, coalesce(EA.Audience, 0) as Audience,
    coalesce(EV.Version, 0) as Version, coalesce(ES.SubjectLine, 0) as Subject,
    ec.DeploymentDate, ee.EventType
from Email e
join EmailSentTo es on e.id = es.EmailID
join EmailAddress A2 ON es.emailAddressID = A2.EmailAddressID
join EmailCampaign ec on e.EmailCampaignID = ec.id
left join (select EA.EmailID, A.Audience FROM EmailAudience EA
join Audience A ON EA.AudienceID = A.id) as EA on EA.EmailID = e.id
left join (select EV.EmailID, V.Version from EmailVersion EV
join Version V ON EV.VersionID = V.id) as EV on EV.EmailID = e.id
left join (select S.EmailID, L.SubjectLine from EmailSubject S
join SubjectLine L ON S.SubjectLineID = L.id) as ES on ES.EmailID = e.id
join EmailEvent ee on ee.EmailID = e.id;

# Email query
insert into EmailCampaignPerformance
select ce1.CampaignName, ce1.Audience, ce1.Version, ce1.Subject, ce1.DeploymentDate,
  coalesce(emailSent-emailBounced, 0) as uniqueDelivered,
  uniqueOpened, uniqueClickers,
  if(emailBounced!=0,coalesce(uniqueOpened/coalesce(emailSent-emailBounced, 0), 0), 0) as openRate,
  if(uniqueOpened!=0,coalesce(uniqueClickers/uniqueOpened, 0), 0) as clickToOpen,
  if(coalesce(emailSent-emailBounced, 0) !=0,coalesce(uniqueClickers/coalesce(emailSent-emailBounced, 0), 0),0) as clickRate,
  if(uniqueClickers!=0,coalesce(emailUnsub/uniqueClickers, 0),0) as unsubRate
from
(select ce1.CampaignName, ce1.Audience, ce1.Version, ce1.Subject, ce1.DeploymentDate,
     count(distinct ce1.id) as emailSent
from CombinedEmail ce1
where ce1.EventType = 'Email Sent/Delivered'
group by ce1.CampaignName, ce1.Audience, ce1.Version, ce1.Subject, ce1.DeploymentDate)
as ce1 left join
(select ce1.CampaignName, ce1.Audience, ce1.Version, ce1.Subject, ce1.DeploymentDate,
     count(distinct ce1.id) as emailBounced
from CombinedEmail ce1
where ce1.EventType = 'Technical/Other bounce'
    or ce1.EventType = 'Block bounce'
    or ce1.EventType = 'Soft bounce'
    or ce1.EventType = 'Hard bounce'
    or ce1.EventType = 'Unknown bounce'
group by ce1.CampaignName, ce1.Audience, ce1.Version, ce1.Subject, ce1.DeploymentDate) as ce2
on ce1.CampaignName = ce2.CampaignName and ce1.Audience = ce2.Audience and ce1.Version=ce2.Version
    and ce1.Subject = ce2.Subject and ce1.DeploymentDate = ce2.DeploymentDate
left join
  (select ce.CampaignName, ce.Audience, ce.Version, ce.Subject, ce.DeploymentDate,
     count(*) as uniqueOpened
from CombinedEmail ce
where ce.EventType = 'Email Opened'
group by ce.CampaignName, ce.Audience, ce.Version, ce.Subject, ce.DeploymentDate) as ce3
on ce1.CampaignName = ce3.CampaignName and ce1.Audience = ce3.Audience and ce1.Version=ce3.Version
    and ce1.Subject = ce3.Subject and ce1.DeploymentDate = ce3.DeploymentDate
left join
  (select ce.CampaignName, ce.Audience, ce.Version, ce.Subject, ce.DeploymentDate,
     count(distinct ce.CustomerID) as uniqueClickers
from CombinedEmail ce
where ce.EventType = 'Email Opened'
group by ce.CampaignName, ce.Audience, ce.Version, ce.Subject, ce.DeploymentDate) as ce4
on ce1.CampaignName = ce4.CampaignName and ce1.Audience = ce4.Audience and ce1.Version=ce4.Version
    and ce1.Subject = ce4.Subject and ce1.DeploymentDate = ce4.DeploymentDate
left join
  (select ce1.CampaignName, ce1.Audience, ce1.Version, ce1.Subject, ce1.DeploymentDate,
     count(distinct ce1.id) as emailUnsub
from CombinedEmail ce1
where ce1.EventType = 'Unsubscribe'
group by ce1.CampaignName, ce1.Audience, ce1.Version, ce1.Subject, ce1.DeploymentDate) as ce6
on ce1.CampaignName = ce6.CampaignName and ce1.Audience = ce6.Audience and ce1.Version=ce6.Version
    and ce1.Subject = ce6.Subject and ce1.DeploymentDate = ce6.DeploymentDate;

# Drop view
drop view if exists CombinedEmail;

#Query 2
INSERT INTO AccountRegistrationReport 
SELECT count(distinct CustomerID),Permission,S2.State,MONTH(RegistrationDate),Year(RegistrationDate) 
FROM Customer 
JOIN RegistrationSource S ON Customer.RegisteredAt = S.regSourceID 
JOIN State S2 ON Customer.StateID = S2.id 
GROUP BY S2.State,Permission,MONTH(RegistrationDate),Year(RegistrationDate) 
ON DUPLICATE KEY UPDATE Permission = Permission;

#Query 3
INSERT INTO DeviceRegistrationReport 
SELECT count(DISTINCT DR.deviceRegistrationID), C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate),Year(DR.RegistrationDate) 
FROM Device d 
JOIN DeviceRegistration DR ON d.RegistrationID = DR.deviceRegistrationID 
JOIN Device_Type Type ON d.DeviceModel = Type.DeviceModel 
JOIN Carrier C ON Type.CarrierID = C.ID 
GROUP BY C.CarrierName,d.DeviceModel,MONTH(DR.RegistrationDate),Year(DR.RegistrationDate) 
ON DUPLICATE KEY UPDATE deviceModel = deviceModel;;
