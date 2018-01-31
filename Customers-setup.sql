#Star model for Customer
CREATE TABLE Customer
(
    CustomerId VARCHAR(32) NOT NULL,
    Permission CHAR(1),
    Tier VARCHAR(32),
    NumRegistrations INT,
    CONSTRAINT Customer_CustomerID_pk PRIMARY KEY (CustomerId)
);
CREATE TABLE Gender
(
    Gender CHAR(1),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_Gender_pk PRIMARY KEY (CustomerId, Gender),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE IncomeLevel
(
    IncomeLevel VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_IncomeLevel_pk PRIMARY KEY (CustomerId, IncomeLevel),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE Language
(
    Language CHAR(3),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_Language_pk PRIMARY KEY (CustomerId, Language),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE Zip
(
    Zip INT,
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_Zip_pk PRIMARY KEY (CustomerId, Zip),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE State
(
    State VARCHAR(32),
    CustomerId VARCHAR(32) NOT NULL,
    CONSTRAINT CustomerId_State_pk PRIMARY KEY (CustomerId, State),
    CONSTRAINT CustomerId_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

