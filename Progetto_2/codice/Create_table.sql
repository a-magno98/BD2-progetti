
CREATE TABLE Branch
(
	branchID	INTEGER PRIMARY KEY,
	bblance 	INTEGER
);

CREATE TABLE Account
(
	numbers	INTEGER PRIMARY KEY,
	branch		INTEGER,
	FOREIGN KEY(branch) REFERENCES Branch(branchID)
			    ON DELETE RESTRICT
			    ON UPDATE CASCADE,
	balance		INTEGER
);