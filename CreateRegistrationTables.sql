create table if not exists RegistrationSource(
  regSourceId INTEGER PRIMARY KEY,
  regSourceName VARCHAR(32)
);

create table if not exists CustomerAccount(
  customerID INTEGER,
  registrationDate DATE,
  numRegistrations INTEGER,
  registeredAt INTEGER,

  PRIMARY KEY (customerID, registrationDate),
  FOREIGN KEY (customerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceId)
);

create table if not exists DeviceRegistration(
  deviceRegistrationID INTEGER,
  registeredAt INTEGER,
  registrationDate DATE,

  PRIMARY KEY (deviceRegistrationID),
  FOREIGN KEY (deviceRegistrationID) REFERENCES Device(RegistrationID),
  FOREIGN KEY (registeredAt) REFERENCES RegistrationSource(regSourceId)
);