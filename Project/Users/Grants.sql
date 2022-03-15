grant INSERT on Prescription, Prescribes to doctors;
grant Select on Prescription, Prescribes, Test, Operations, DrugStore, Patient to doctors;
grant Select on Prescription, Prescribes, Doctor, Test, Operations, DrugStore, Patient to patient;	
grant all on DrugStore to drug_store_admin with grant option; 
grant all on Doctor, Department to doctor_admin with grant option; 
grant all on Test, Takes to test_admin with grant option; 
grant all on Operations, OT to opd_admin with grant option; 
grant Select on Patient, Prescription, Test, Operations to Nurses;
grant all on Nurse to nurse_admin with grant option;

grant execute on function medical_history to doctors;
grant execute on function patient_details to patient;
