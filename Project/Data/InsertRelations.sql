INSERT INTO ReportTo (N_id, Dr_id) VALUES (1,1), (2,2), (3,2), (4,2);
INSERT INTO BelongsTo (Dr_id, Dept_id) VALUES (1,1), (2,3), (3,2);
INSERT INTO isOf (Op_id, Dept_id) VALUES (1,3), (2,2);
INSERT INTO TakesAppoints(P_id, Dr_id, dateofapp) VALUES (1, 1, '2022-03-15'), (2, 2, '2022-03-15'),(2,1, '2022-03-16');
INSERT INTO PRESCRIBES(P_id, Pres_id, Dr_id) VALUES (1,1,1), (2,1,2), (2,2,1);
INSERT INTO BUYS(P_id, Pres_id, Drug_id) VALUES (1,1,2), (2,2,2);
INSERT INTO Takes(P_id, Pres_id, Test_id) VALUES (1,1,1), (2,1,1);
INSERT INTO OT(P_id, Pres_id, Op_id, dateofop, RoomNumber) VALUES (2, 1, 1, '2022-04-01', 13);
