DROP TABLE IF EXISTS Company cascade;
DROP TABLE IF EXISTS "User" cascade;
DROP TABLE IF EXISTS location cascade;
DROP TABLE IF EXISTS Deposit_transaction cascade;
DROP TABLE IF EXISTS Investment_transaction cascade;
DROP TABLE IF EXISTS Portfolio_action cascade;
DROP TABLE IF EXISTS deposit_trans cascade;
DROP TABLE IF EXISTS Owns cascade;
DROP TABLE IF EXISTS Prefers cascade;
DROP TABLE IF EXISTS Customer cascade;
DROP TABLE IF EXISTS Administrator cascade;
DROP TABLE IF EXISTS MutualFund cascade;
DROP TABLE IF EXISTS Closing_price cascade;

-- Location_id to location
-- MF's company_id now can not be null
-- prefer's percentage fix
-- location's postcode fix ???
-- each FK now has its own ON DELETE CASCADE
-- trigger granularity changed to "statement" level
-- remove NULL from prefer's percentage fix

CREATE TABLE "User" (
  login VARCHAR(20),
  address VARCHAR(30),
  password VARCHAR(20),
  email VARCHAR(30),
  name VARCHAR(30),
  PRIMARY KEY (login)
);

CREATE TABLE Customer (
  login VARCHAR(20),
  balance BIGINT,
  PRIMARY KEY (login),
  FOREIGN KEY (login) REFERENCES "User" (login) ON DELETE CASCADE
);

CREATE TABLE Administrator (
  login VARCHAR(20),
  PRIMARY KEY (login),
  FOREIGN KEY (login) REFERENCES "User" (login) ON DELETE CASCADE
);

CREATE TABLE Company (
  company_id VARCHAR(10),
  name VARCHAR(20),
  CEO_fname VARCHAR(20),
  CEO_lname VARCHAR(20),
  PRIMARY KEY (company_id)
);

CREATE TABLE Location (
  location VARCHAR(10),
  company_id VARCHAR(10),
  city VARCHAR(20),
  postcode INT CHECK (postcode < 10000 and postcode > 999),
  state VARCHAR(3) DEFAULT 'NSW',
  CHECK ( state IN ('NSW', 'VIC', 'SA', 'QLD', 'WA', 'NT', 'ACT', 'TAS')),
  PRIMARY KEY (location, company_id), -- LECTURE 3 PAGE 42
  FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE CASCADE
);

CREATE TABLE MutualFund (
  symbol VARCHAR(10),
  company_id VARCHAR(10) NOT NULL,
  c_date DATE NOT NULL,
  t_num_shares BIGINT,
  description VARCHAR(50),
  name VARCHAR(20),
  category VARCHAR(20),
  PRIMARY KEY (symbol),
  FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE CASCADE
);

CREATE TABLE Closing_price (
  p_date DATE NOT NULL,
  symbol VARCHAR(10),
  price FLOAT,
  PRIMARY KEY (p_date, symbol),
  FOREIGN KEY (symbol) REFERENCES MutualFund(symbol) ON DELETE CASCADE
);

CREATE TABLE Deposit_transaction (
  trans_id VARCHAR(20) CHECK (trans_id like 'D%'),
  PRIMARY KEY (trans_id)
);

CREATE TABLE Investment_transaction (
  trans_id VARCHAR(20) CHECK (trans_id like 'I%'),
  PRIMARY KEY (trans_id)
);

CREATE TABLE deposit_trans (
  trans_id VARCHAR(20),
  login VARCHAR(20),
  t_date DATE NOT NULL,
  amount FLOAT,
  PRIMARY KEY (trans_id, login),
  FOREIGN KEY (login) REFERENCES "User" (login) ON DELETE CASCADE, 
  FOREIGN KEY (trans_id) REFERENCES Deposit_transaction (trans_id) ON DELETE CASCADE
);

CREATE TABLE Portfolio_action (
  trans_id VARCHAR(20),
  symbol VARCHAR(10),
  login VARCHAR(20),
  t_date DATE NOT NULL,
  action VARCHAR CHECK (action = 'buy' OR action = 'sell'),
  price FLOAT,
  num_shares INT,
  amount FLOAT,
  PRIMARY KEY (trans_id, symbol, login),
  FOREIGN KEY (symbol) REFERENCES MutualFund (symbol) ON DELETE CASCADE,
  FOREIGN KEY (login) REFERENCES "User" (login) ON DELETE CASCADE,
  FOREIGN KEY (trans_id) REFERENCES Investment_transaction (trans_id) ON DELETE CASCADE
);

CREATE TABLE Owns (
  symbol VARCHAR(10),
  login VARCHAR(20),
  shares INT,
  PRIMARY KEY (symbol, login),
  FOREIGN KEY (symbol) REFERENCES MutualFund (symbol) ON DELETE CASCADE,
  FOREIGN KEY (login) REFERENCES "User" (login) ON DELETE CASCADE
);

CREATE TABLE Prefers (
  symbol VARCHAR(10),
  login VARCHAR(20),
  percentage FLOAT CHECK (percentage > 0 AND percentage <= 1),
  PRIMARY KEY (symbol, login),
  FOREIGN KEY (symbol) REFERENCES MutualFund (symbol) ON DELETE CASCADE,
  FOREIGN KEY (login) REFERENCES "User" (login) ON DELETE CASCADE
);

--CREATE TRIGGER
CREATE OR REPLACE FUNCTION amount_update()
  RETURNS trigger AS
$$
BEGIN
  UPDATE Portfolio_action SET amount = num_shares * price;
  RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER t
  AFTER INSERT OR UPDATE OF Price, num_shares
  ON Portfolio_action
  FOR EACH STATEMENT
  EXECUTE PROCEDURE amount_update();


--INSERT STATEMENTS
INSERT INTO Company VALUES (1, 'thiscompany', 'Green', 'Newtown');
INSERT INTO location VALUES (307088592, '1', 'Newtown', 3432);

INSERT INTO MutualFund VALUES (5, '1', '2019-3-4', 9300, 'here', 'fund1', 'cate1');
INSERT INTO Closing_price VALUES ('2009-4-3', '5', 4000.0);

INSERT INTO "User" VALUES ('JohnWick', 'Newtown', 'pwd', 'mail', 'Wick');
INSERT INTO Customer VALUES ('JohnWick', 5000);
INSERT INTO Administrator VALUES ('JohnWick');

INSERT INTO deposit_transaction values ('D111');
INSERT INTO Investment_transaction values ('I222');

INSERT INTO Portfolio_action VALUES ('I222', 5, 'JohnWick', '1999-3-5', 'buy', 5, 10);
INSERT INTO deposit_trans VALUES ('D111', 'JohnWick', '1344-6-7', 599);
INSERT INTO Owns VALUES (5, 'JohnWick', 10);
INSERT INTO Prefers VALUES (5, 'JohnWick', 0.4);
