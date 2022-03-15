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