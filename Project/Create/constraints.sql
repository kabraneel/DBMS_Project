ALTER TABLE Buys ADD CONSTRAINT check_drug_buy check (check_drug_for_buys(pres_id, drug_id) = 'True');

ALTER TABLE Buys ADD CONSTRAINT check_pres_buy check (check_p_in_pres(p_id, pres_id) = 'True');

ALTER TABLE Takes ADD CONSTRAINT check_test_takes check (check_test_for_takes(pres_id, test_id) = 'True');

ALTER TABLE Takes ADD CONSTRAINT check_pres_takes check (check_p_in_pres(p_id, pres_id) = 'True');

ALTER TABLE OT ADD CONSTRAINT check_op_ot check (check_op_for_ot(pres_id, op_id) = 'True');

ALTER TABLE OT ADD CONSTRAINT check_pres_takes check (check_p_in_pres(p_id, pres_id) = 'True');