DROP TABLE IF EXISTS cpe366.CP_Account;
DROP TABLE IF EXISTS cpe366.CP_Device;
DROP TABLE IF EXISTS cpe366.CP_Device_Model;
DROP TABLE IF EXISTS cpe366.CP_Email_Final;
DROP TABLE IF EXISTS cpe366.Device;
DROP TABLE IF EXISTS cpe366.Device_Type;
DROP TABLE IF EXISTS cpe366.Carrier;

CREATE TABLE cpe366.CP_Account LIKE cpe366_readonly.CP_Account;
INSERT cpe366.CP_Account SELECT * FROM cpe366_readonly.CP_Account;

CREATE TABLE cpe366.CP_Device LIKE cpe366_readonly.CP_Device;
INSERT cpe366.CP_Device SELECT * FROM cpe366_readonly.CP_Device;

CREATE TABLE cpe366.CP_Device_Model LIKE cpe366_readonly.CP_Device_Model;
INSERT cpe366.CP_Device_Model SELECT * FROM cpe366_readonly.CP_Device_Model;

CREATE TABLE cpe366.CP_Email_Final LIKE cpe366_readonly.CP_Email_Final;
INSERT cpe366.CP_Email_Final SELECT * FROM cpe366_readonly.CP_Email_Final;
