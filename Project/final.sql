-- CREATING THE DATABASE
DROP DATABASE medical_system_assistant;
CREATE DATABASE medical_system_assistant;
\c medical_system_assistant

-- CREATING THE TABLES
CREATE TABLE DrugStore (Drug_id serial NOT NULL, Drug_name varchar(30) UNIQUE NOT NULL, cost Integer NOT NULL CHECK (cost > 0), PRIMARY KEY (Drug_id)); 
CREATE TABLE Nurse (N_id serial NOT NULL, Name varchar(30) NOT NULL, shift varchar(20) NOT NULL, CONSTRAINT check_shift check (shift in ('Morning', 'Afternoon', 'Evening', 'Night')), PRIMARY KEY (N_id));
CREATE TABLE Test (Test_id serial NOT NULL, Test_name varchar(30) NOT NULL, cost Integer NOT NULL check (cost > 0), PRIMARY KEY (Test_id));
create table Operations(op_id serial not null, op_name varchar(50) unique not null, cost int not null check (cost > 0), equipments varchar(50) [], primary key (op_id));
create table Patient(p_id serial not null, name varchar(50) not null, age int not null check (age > 0), symptoms varchar(50) [], sex varchar(10) not null, constraint check_sex check (sex in ('Male', 'Female', 'Intersex')), primary key (p_id));
create table Department(dept_id serial not null, dept_name varchar(50) unique not null, budget int check (budget > 0), hod Integer, primary key (dept_id));
CREATE TABLE Prescription(pres_id serial NOT NULL, Test_id Integer, Op_id Integer, Drug_id Integer, PRIMARY KEY (pres_id), FOREIGN KEY (Test_id) REFERENCES Test(Test_id), FOREIGN KEY (Op_id) REFERENCES Operations(Op_id), FOREIGN KEY (Drug_id) REFERENCES DrugStore(Drug_id));
CREATE TABLE Doctor(Dr_id serial NOT NULL, Name varchar(30) NOT NULL, Age Integer NOT NULL check (age > 18), Salary Integer NOT NULL check (Salary >= 0), YearsOfExp Integer NOT NULL check (YearsOfExp >= 0), PRIMARY KEY(Dr_id));
ALTER TABLE Department ADD CONSTRAINT FK_DOC FOREIGN KEY (hod) REFERENCES Doctor(Dr_id);
-- \dt
-- DONE WITH TABLES CREATION 

-- NOW CREATING THE RELATIONS 
CREATE TABLE Buys(P_id Integer NOT NULL, Pres_id Integer NOT NULL, Drug_id Integer NOT NULL, PRIMARY KEY(P_id, Pres_id, Drug_id), FOREIGN KEY (P_id) REFERENCES Patient(P_id), FOREIGN KEY (Pres_id) REFERENCES Prescription(Pres_id), FOREIGN KEY (Drug_id) REFERENCES DrugStore(Drug_id));
CREATE TABLE Takes(Test_id Integer NOT NULL, P_id Integer NOT NULL, Pres_id Integer NOT NULL, DateOfTest date default (current_date) not null, PRIMARY KEY(Test_id, P_id, Pres_id), FOREIGN KEY (Test_id) REFERENCES Test(Test_id), FOREIGN KEY (P_id) REFERENCES Patient(P_id), FOREIGN KEY (Pres_id) REFERENCES Prescription(Pres_id));
CREATE TABLE Prescribes(P_id Integer NOT NULL, Dr_id Integer NOT NULL, Pres_id Integer NOT NULL, PRIMARY KEY(P_id, Dr_id, Pres_id), FOREIGN KEY (P_id) REFERENCES Patient(P_id), FOREIGN KEY (Dr_id) REFERENCES Doctor(Dr_id), FOREIGN KEY (Pres_id) REFERENCES Prescription(Pres_id));
CREATE TABLE ReportTo(N_id Integer NOT NULL, Dr_id Integer NOT NULL, PRIMARY KEY(N_id, Dr_id), FOREIGN KEY (N_id) REFERENCES Nurse(N_id), FOREIGN KEY (Dr_id) REFERENCES Doctor(Dr_id));
create table BelongsTo (Dr_id Integer Not null, Dept_id Integer Not null, Foreign Key(Dr_id) references Doctor(Dr_id), Foreign Key(Dept_id) references Department(Dept_id), Primary Key(Dr_id, Dept_id));
create table isOf (Op_id Integer Not null, Dept_id Integer Not null, Foreign Key(Op_id) references Operations(Op_id), Foreign Key(Dept_id) references Department(Dept_id), Primary Key(Op_id, Dept_id));    
create table TakesAppoints(P_id Integer Not null, Dr_id Integer Not null, DateOfApp date not null, Foreign Key(P_id) references Patient(P_id), Foreign Key(Dr_id) references Doctor(Dr_id), Primary Key(P_id, Dr_id));
create table OT (Pres_id Integer Not null, P_id Integer Not null, Op_id Integer Not null, DateOfOp date not null, RoomNumber Integer not null check (RoomNumber >= 1 and RoomNumber <= 50), Foreign Key(Pres_id) references Prescription(Pres_id), Foreign Key(P_id) references Patient(P_id), Foreign Key(Op_id) references Operations(Op_id), Unique (DateOfOp, RoomNumber), Primary Key(Pres_id, P_id, Op_id));

-- \dt


/*
	
	ORDER OF INSERTION in relations
	1. Takes Appointment
	2. Prescribes 
	3. Buys, Takes, Operation

	CONSTRAINTS -> BUYS
					1. If drug in pres
					2. If patient has pres

				-> TAKES
					1. if patient has pres
					2. pres has test_id

				-> OP
					1. if patient has pres
					2. pres has op_id



*/

/*
	
	check prescribes to make sure appointment bw

*/

create or replace function check_doc_for_pres(p_id1 int, dr_id1 int)
returns VARCHAR(5)
language plpgsql
as
$$
begin
	if dr_id1 IN (Select dr_id from TakesAppoints WHERE p_id = p_id1)
	then
		return 'True';
	else 
		return 'False';
	end if;
end;
$$;

ALTER TABLE Prescribes ADD CONSTRAINT check_doc_pres check (check_doc_for_pres(p_id, dr_id) = 'True');

/*
	Function for checking if patient has a prescription -> COMMON FOR TAKES, OT, BUYS
*/

create or replace function check_p_in_pres(p_id1 int, pres_id1 int)
returns VARCHAR(5)
language plpgsql
as
$$
begin
	if pres_id1 IN (Select pres_id from Prescribes WHERE p_id = p_id1)
	then
		return 'True';
	else 
		return 'False';
	end if;
end;
$$;



/*
	Constraint for buys check_drug_for_buys -> For every entry in Buys, the drug_id should be present in the prescription of pres_id
						if patient has pres
*/

create or replace function check_drug_for_buys(pres_id1 int, drug_id1 int)
returns VARCHAR(5)
language plpgsql
as
$$
begin
	if drug_id1 = (Select drug_id from Prescription WHERE pres_id = pres_id1)
	then
		return 'True';
	else 
		return 'False';
	end if;
end;
$$;

ALTER TABLE Buys ADD CONSTRAINT check_drug_buy check (check_drug_for_buys(pres_id, drug_id) = 'True');

ALTER TABLE Buys ADD CONSTRAINT check_pres_buy check (check_p_in_pres(p_id, pres_id) = 'True');

/*
	Constraint for takes check_test_for_takes -> For every entry in Takes, the test_id should be present in the prescription of pres_id
						if patient has pres
*/


create or replace function check_test_for_takes(pres_id1 int, test_id1 int)
returns VARCHAR(5)
language plpgsql
as
$$
begin
	if test_id1 = (Select test_id from Prescription WHERE pres_id = pres_id1)
	then
		return 'True';
	else 
		return 'False';
	end if;
end;
$$;

ALTER TABLE Takes ADD CONSTRAINT check_test_takes check (check_test_for_takes(pres_id, test_id) = 'True');

ALTER TABLE Takes ADD CONSTRAINT check_pres_takes check (check_p_in_pres(p_id, pres_id) = 'True');

/*

	Constraint for OT check_op_for_ot -> For every entry in OT, the op_id should be present in the prescription of pres_id
						if patient has pres

*/


create or replace function check_op_for_ot(pres_id1 int, op_id1 int)
returns VARCHAR(5)
language plpgsql
as
$$
begin
	if op_id1 = (Select op_id from Prescription WHERE pres_id = pres_id1)
	then
		return 'True';
	else 
		return 'False';
	end if;
end;
$$;

ALTER TABLE OT ADD CONSTRAINT check_op_ot check (check_op_for_ot(pres_id, op_id) = 'True');

ALTER TABLE OT ADD CONSTRAINT check_pres_takes check (check_p_in_pres(p_id, pres_id) = 'True');


\dt

-- Tables
INSERT INTO DrugStore(Drug_name, Cost) VALUES ('Dolo 650', 10), ('Crocin', 15);
INSERT INTO Test(Test_name, Cost) VALUES ('Platlet Count', 200), ('RBC Count', 150);
INSERT INTO Operations(Op_name, Cost, equipments) VALUES ('Heart Bypass', 200000, '{"Knife", "Gloves"}'), ('Lasik Surgery', 150000, '{"Black Glasses", "Lasers"}');
INSERT INTO Prescription(Test_id, Op_id, Drug_id) VALUES (1, 1, 2), (2, 1, 2);
insert into Patient(Name, Age, symptoms, sex) values ('Aman', 14, '{"Headache", "Nausea"}', 'Male'), ('Sheila', 25, '{"Fatigue", "Extreme Sweating", "Stroke"}', 'Female');
insert into Nurse(Name, Shift) values ('Vivian', 'Morning'), ('Shanti', 'Afternoon'), ('Florence', 'Evening'), ('Shyam', 'Night');
insert into Department(dept_name, budget) values ('General', 500000), ('Ophthalmology', 750000), ('Cardiology', 1500000);
insert into Doctor(Name, Age, Salary, YearsOfExp) values ('Drakeramory', 50000, 50, 25), ('Ryan', 25000, 27, 5), ('Vikram', 75000, 40, 15);

\dt 

-- Relations

/*
	
	ORDER OF INSERTION in relations
	1. Takes Appointment
	2. Prescribes 
	3. Buys, Takes, Operation

	CONSTRAINTS -> BUYS
					1. If drug in pres
					2. If patient has pres

				-> TAKES
					1. if patient has pres
					2. pres has test_id

				-> OP
					1. if patient has pres
					2. pres has op_id

*/


INSERT INTO ReportTo (N_id, Dr_id) VALUES (1,1), (2,2), (3,2), (4,2);
INSERT INTO BelongsTo (Dr_id, Dept_id) VALUES (1,1), (2,3), (3,2);
INSERT INTO isOf (Op_id, Dept_id) VALUES (1,3), (2,2);
INSERT INTO TakesAppoints(P_id, Dr_id, dateofapp) VALUES (1, 1, '2022-03-15'), (2, 2, '2022-03-15'),(2,1, '2022-03-16');
INSERT INTO PRESCRIBES(P_id, Pres_id, Dr_id) VALUES (1,1,1), (2,1,2), (2,2,1);
INSERT INTO BUYS(P_id, Pres_id, Drug_id) VALUES (1,1,2), (2,2,2);
INSERT INTO Takes(P_id, Pres_id, Test_id) VALUES (1,1,1), (2,1,1);
INSERT INTO OT(P_id, Pres_id, Op_id, dateofop, RoomNumber) VALUES (2, 1, 1, '2022-04-01', 13);

-- Creating ROLES

create role doctors login password 'doctors';
create role drug_store_admin login password 'drug_store_admin';
create role doctor_admin login password 'doctor_admin';
create role patient login password 'patient';
create role test_admin login password 'test_admin';
create role opd_admin login password 'opd_admin';
create role nurses login password 'nurses';
create role nurse_admin login password 'nurse_admin';
create role hospital_admin superuser login password 'hospital_admin';

-- Giving different permissions to roles on different tables

grant INSERT on Prescription, Prescribes to doctors;
grant Select on Prescription, Prescribes, Test, Operations, DrugStore, Patient to doctors;
grant Select on Prescription, Prescribes, Doctor, Test, Operations, DrugStore, Patient to patient;	
grant all on DrugStore to drug_store_admin with grant option; 
grant all on Doctor, Department to doctor_admin with grant option; 
grant all on Test, Takes to test_admin with grant option; 
grant all on Operations, OT to opd_admin with grant option; 
grant Select on Patient, Prescription, Test, Operations to Nurses;
grant all on Nurse to nurse_admin with grant option;

-- Creating functions to view specific queries from specific tables

/*
Function medical_history:
				 -> takes Dr_id, P_id 
				 -> returns all the Prescriptions for that specific combination.
*/

create or replace function medical_history(dr_id1 int, p_id1 int)
returns table (Name varchar(50), 
			   Age Integer,
			   Test_Name varchar(30), 
			   Op_Name varchar(50), 
			   Drug_Name varchar(50))
language plpgsql
as
$$
begin
	return query (select Patient.name, Patient.age, Test.Test_name, Operations.Op_name, DrugStore.Drug_name from Prescription 
	join PRESCRIBES on Prescription.pres_id = Prescribes.pres_id
	join Test on Test.test_id = Prescription.test_id
	join  Operations on Operations.op_id = Prescription.op_id
	join DrugStore on DrugStore.drug_id = Prescription.drug_id
	join Patient on Patient.p_id = Prescribes.p_id
	WHERE dr_id1 = Prescribes.dr_id and p_id1 = Prescribes.p_id);
end;
$$;

grant execute on function medical_history to doctors;


/*
Function patient_details:
				 -> takes P_id 
				 -> returns all the Prescriptions for that specific patient.
*/

create or replace function patient_details(p_id1 int)
returns table (Name varchar(50), 
			   Age Integer,
			   Under_Doc varchar(30),
			   Test_Name varchar(30), 
			   Op_Name varchar(50), 
			   Drug_Name varchar(50))
language plpgsql
as
$$
begin
	return query (select Patient.name, Patient.age, Doctor.name, Test.Test_name, Operations.Op_name, DrugStore.Drug_name from Prescription 
	join PRESCRIBES on Prescription.pres_id = Prescribes.pres_id
	join Test on Test.test_id = Prescription.test_id
	join Operations on Operations.op_id = Prescription.op_id
	join DrugStore on DrugStore.drug_id = Prescription.drug_id
	join Patient on Patient.p_id = Prescribes.p_id
	join Doctor on Doctor.dr_id = Prescribes.dr_id
	WHERE p_id1 = Prescribes.p_id);
end;
$$;

grant execute on function patient_details to patient;


-- grant Select on Patient, Prescription, Prescribes, Test, Operations, DrugStore to Patient;

-- -- Creating one user for each patient

-- create role sheila login password 'sheila';
-- create role aman login password 'aman';

-- grant patient to sheila, aman;

-- ALTER TABLE patient enable row level security;
-- CREATE POLICY patient_access ON patient
-- FOR SELECT USING (name = current_user);

-- -- Now we create a function to get a view with all required information of patients


-- create or replace function patient_detail()
-- returns table (Name varchar(50), 
-- 			   Age Integer,
-- 			   Test_Name varchar(30), 
-- 			   Op_Name varchar(50), 
-- 			   Drug_Name varchar(50))
-- language sql
-- security invoker
-- as
-- $$
-- 	select Patient.name, Patient.age, Test.Test_name, Operations.Op_name, DrugStore.Drug_name from Prescription 
-- 	join PRESCRIBES on Prescription.pres_id = Prescribes.pres_id
-- 	join Test on Test.test_id = Prescription.test_id
-- 	join Operations on Operations.op_id = Prescription.op_id
-- 	join DrugStore on DrugStore.drug_id = Prescription.drug_id
-- 	join Patient on Patient.p_id = Prescribes.p_id;
-- $$;

-- -- creating a view from what the function returns

-- CREATE VIEW View_PD AS SELECT * FROM patient_detail();
-- GRANT SELECT ON View_PD TO patient;