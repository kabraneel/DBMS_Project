CREATE TABLE DrugStore (Drug_id serial NOT NULL, Drug_name varchar(30) UNIQUE NOT NULL, cost Integer NOT NULL CHECK (cost > 0), PRIMARY KEY (Drug_id)); 
CREATE TABLE Nurse (N_id serial NOT NULL, Name varchar(30) NOT NULL, shift varchar(20) NOT NULL, CONSTRAINT check_shift check (shift in ('Morning', 'Afternoon', 'Evening', 'Night')), PRIMARY KEY (N_id));
CREATE TABLE Test (Test_id serial NOT NULL, Test_name varchar(30) NOT NULL, cost Integer NOT NULL check (cost > 0), PRIMARY KEY (Test_id));
create table Operations(op_id serial not null, op_name varchar(50) unique not null, cost int not null check (cost > 0), equipments varchar(50) [], primary key (op_id));
create table Patient(p_id serial not null, name varchar(50) not null, age int not null check (age > 0), symptoms varchar(50) [], sex varchar(10) not null, constraint check_sex check (sex in ('Male', 'Female', 'Intersex')), primary key (p_id));
create table Department(dept_id serial not null, dept_name varchar(50) unique not null, budget int check (budget > 0), hod Integer, primary key (dept_id));
CREATE TABLE Prescription(pres_id serial NOT NULL, Test_id Integer, Op_id Integer, Drug_id Integer, PRIMARY KEY (pres_id), FOREIGN KEY (Test_id) REFERENCES Test(Test_id), FOREIGN KEY (Op_id) REFERENCES Operations(Op_id), FOREIGN KEY (Drug_id) REFERENCES DrugStore(Drug_id));
CREATE TABLE Doctor(Dr_id serial NOT NULL, Name varchar(30) NOT NULL, Age Integer NOT NULL check (age > 18), Salary Integer NOT NULL check (Salary >= 0), YearsOfExp Integer NOT NULL check (YearsOfExp >= 0), PRIMARY KEY(Dr_id));
ALTER TABLE Department ADD CONSTRAINT FK_DOC FOREIGN KEY (hod) REFERENCES Doctor(Dr_id);
