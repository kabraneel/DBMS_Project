-- Tables
INSERT INTO DrugStore(Drug_name, Cost) VALUES ('Dolo 650', 10), ('Crocin', 15);
INSERT INTO Test(Test_name, Cost) VALUES ('Platlet Count', 200), ('RBC Count', 150);
INSERT INTO Operations(Op_name, Cost, equipments) VALUES ('Heart Bypass', 200000, '{"Knife", "Gloves"}'), ('Lasik Surgery', 150000, '{"Black Glasses", "Lasers"}');
INSERT INTO Prescription(Test_id, Op_id, Drug_id) VALUES (1, 1, 2), (2, 1, 2);
insert into Patient(Name, Age, symptoms, sex) values ('Aman', 14, '{"Headache", "Nausea"}', 'Male'), ('Sheila', 25, '{"Fatigue", "Extreme Sweating", "Stroke"}', 'Female');
insert into Nurse(Name, Shift) values ('Vivian', 'Morning'), ('Shanti', 'Afternoon'), ('Florence', 'Evening'), ('Shyam', 'Night');
insert into Department(dept_name, budget) values ('General', 500000), ('Ophthalmology', 750000), ('Cardiology', 1500000);
insert into Doctor(Name, Age, Salary, YearsOfExp) values ('Drakeramory', 50000, 50, 25), ('Ryan', 25000, 27, 5), ('Vikram', 75000, 40, 15);
