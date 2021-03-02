------------------------
/* splitwise user details */
------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`splitwise_users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `sp_user_name` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `email_id` VARCHAR(45) NOT NULL,
  `phone_number` INT NOT NULL,
  `is_active` VARCHAR(1) NULL,
  `created_date` DATETIME GENERATED ALWAYS AS () VIRTUAL,
  `modified_date` DATETIME GENERATED ALWAYS AS () VIRTUAL,
  UNIQUE INDEX `email_UNIQUE` (`email_id` ASC) VISIBLE,
  UNIQUE INDEX `phone_number_UNIQUE` (`phone_number` ASC) VISIBLE,
  INDEX `sp_username_IND` USING BTREE (`sp_user_name`) VISIBLE,
  PRIMARY KEY (`user_id`));

------------------------
/* splitwise group details */
------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`splitwise_groups` (
  `group_id` INT NOT NULL AUTO_INCREMENT,
  `group_name` VARCHAR(45) NOT NULL,
  `isgroup_active` VARCHAR(1) NOT NULL,
  `total_members` INT NULL,
  `created_on` DATETIME GENERATED ALWAYS AS () VIRTUAL,
  UNIQUE INDEX `group_name_UNIQUE` (`group_name` ASC) VISIBLE,
  PRIMARY KEY (`group_name`),
  UNIQUE INDEX `group_id_UNIQUE` (`group_id` ASC) INVISIBLE);
------------------------
/* splitwise user and group relationship */
------------------------
  CREATE TABLE IF NOT EXISTS `mydb`.`user_grop_relationship` (
  `group_name` VARCHAR(45) NOT NULL,
  `grp_user_name` VARCHAR(45) NOT NULL,
  `is_user_active_ingroup` VARCHAR(1) NULL,
  `user_addedon` DATETIME GENERATED ALWAYS AS () VIRTUAL,
  INDEX `fk_grp_name_idx` (`group_name` ASC) INVISIBLE,
  INDEX `fk_usr_group_name_idx` (`grp_user_name` ASC) VISIBLE,
  CONSTRAINT `fk_grp_name`
    FOREIGN KEY (`group_name`)
    REFERENCES `mydb`.`splitwise_groups` (`group_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_usr_group_name`
    FOREIGN KEY (`grp_user_name`)
    REFERENCES `mydb`.`splitwise_users` (`sp_user_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
------------------------
/* splitwise user amount spent details */
------------------------

CREATE TABLE IF NOT EXISTS `mydb`.`transaction_log` (
  `tr_id` INT NOT NULL AUTO_INCREMENT,
  `amount_spent_by` VARCHAR(45) NOT NULL,
  `amount_spent_for` VARCHAR(45) NOT NULL,
  `amount_spent` INT NOT NULL,
  `transaction_date` DATETIME GENERATED ALWAYS AS () VIRTUAL,
  `is_settlement_done` VARCHAR(1) NULL,
  `description` VARCHAR(45) NULL,
  PRIMARY KEY (`tr_id`),
  INDEX `fk_tr_grpname_idx` (`amount_spent_for` ASC) VISIBLE,
  INDEX `fk_tr_usrgrp_idx` (`amount_spent_by` ASC) VISIBLE,
  CONSTRAINT `fk_tr_grpname`
    FOREIGN KEY (`amount_spent_for`)
    REFERENCES `mydb`.`splitwise_groups` (`group_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tr_usrgrp`
    FOREIGN KEY (`amount_spent_by`)
    REFERENCES `mydb`.`splitwise_users` (`sp_user_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
	
------------------------
/* splitwise user amount settelment with other users*/
------------------------


CREATE TABLE IF NOT EXISTS `mydb`.`transaction_settlement` (
  `settlement_id` INT NOT NULL AUTO_INCREMENT,
  `from_user` VARCHAR(45) NULL,
  `to_user` VARCHAR(45) NULL,
  `amount_to_pay` INT NULL,
  `settlement_date` DATETIME NULL,
  `is_payment_settled` VARCHAR(1) NULL DEFAULT 'N',
  PRIMARY KEY (`settlement_id`),
  INDEX `fk_sl_user_topay_idx` (`to_user` ASC) VISIBLE,
  INDEX `fk_sl_user_frompay_idx` (`from_user` ASC) VISIBLE,
  CONSTRAINT `fk_sl_user_topay`
    FOREIGN KEY (`to_user`)
    REFERENCES `mydb`.`splitwise_users` (`sp_user_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sl_user_frompay`
    FOREIGN KEY (`from_user`)
    REFERENCES `mydb`.`splitwise_users` (`sp_user_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
	
------------------------
/* splitwise expenses split equally with other users  aross groups*/
------------------------

CREATE TABLE IF NOT EXISTS `mydb`.`expenses_log` (
  `payee_name` VARCHAR(45) NOT NULL,
  `drawee_name` VARCHAR(45) NOT NULL,
  `amount_to_pay` INT NOT NULL,
  `expenes_grp_name` VARCHAR(45) NULL,
  INDEX `fk_el_grp_name_idx` (`expenes_grp_name` ASC) VISIBLE,
  INDEX `fk_el_payee_name_idx` (`payee_name` ASC) VISIBLE,
  INDEX `fk_el_drawee_name_idx` (`drawee_name` ASC) VISIBLE,
  CONSTRAINT `fk_el_grp_name`
    FOREIGN KEY (`expenes_grp_name`)
    REFERENCES `mydb`.`splitwise_groups` (`group_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_el_payee_name`
    FOREIGN KEY (`payee_name`)
    REFERENCES `mydb`.`splitwise_users` (`sp_user_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_el_drawee_name`
    FOREIGN KEY (`drawee_name`)
    REFERENCES `mydb`.`splitwise_users` (`sp_user_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

/*procedure to insert users into splitwise users table*/
DELIMITER $$
CREATE PROCEDURE 'set_splitwise_users'(
IN sp_usr_name varchar(120),
IN sp_password varchar(20),
IN sp_email_id varchar(150),
IN sp_phone_no int(10),
OUT result bool)
DECLARE 
usr_chk INT;
BEGIN
select count(*) into usr_chk from splitwise_users where email_id=sp_email_id and phone_number=sp_phone_no;
if (usr_chk==0)
then
insert into splitwise_users values(sp_user_name,password,email_id,phone_number,is_active) values(sp_usr_name,sp_password,sp_email_id,sp_phone_no,'Y');
set result=true;
ELSE
set result=false;
END IF;
END $$ DELIMITER ;

/*procedure to UPDATE user DETAILS in splitwise users table*/

CREATE PROCEDURE 'update_splitwise_user_details'(
IN sp_usr_name varchar(120),
IN sp_password varchar(20),
IN sp_email_id varchar(150),
IN sp_phone_no int(10),
OUT result bool)
DECLARE 
usr_chk INT;
BEGIN
select count(*) into usr_chk from splitwise_users where email_id=sp_email_id and phone_number=sp_phone_no;
if (usr_chk==1)
then
update splitwise_users set sp_user_name=sp_usr_name,password=sp_password,email_id=sp_email_id,phone_number=sp_phone_no);
set result=true;
ELSE
set result=false;
END IF;
END $$ DELIMITER ;

/*procedure to check whether user is present or not by using email id and password*/

CREATE PROCEDURE 'update_splitwise_user_details'(
IN sp_password varchar(20),
IN sp_email_id varchar(150)
OUT result bool)
DECLARE 
usr_chk INT;
BEGIN
select count(*) into usr_chk from splitwise_users where email_id=sp_email_id and password=sp_password;
if (usr_chk==1)
then
set result=true;
ELSE
set result=false;
END IF;
END $$ DELIMITER ;

/*procedure to display list of splitwise users*/
DELIMITER $$
CREATE PROCEDURE 'get_splitwise_users'(
OUT sp_user_id int,
OUT sp_usr_name varchar(120)
)
BEGIN
SELECT user_id,sp_user_name into sp_user_id,sp_usr_name from splitwise_users;
END $$ DELIMITER ;

/*procedure to insert groups into splitwise group table*/

DELIMITER $$
CREATE PROCEDURE 'set_splitwise_groups'(
IN sp_grp_name varchar(45),
IN sp_password varchar(20),
IN sp_email_id varchar(150),
IN sp_phone_no int(10),
OUT result bool)
DECLARE 
usr_chk INT;
BEGIN
select count(*) into usr_chk from splitwise_users where email_id=sp_email_id and phone_number=sp_phone_no;
if (usr_chk==0)
then
insert into splitwise_users values(sp_user_name,password,email_id,phone_number,is_active) values(sp_usr_name,sp_password,sp_email_id,sp_phone_no,'Y');
set result=true;
ELSE
set result=false;
END IF;
END $$ DELIMITER ;


