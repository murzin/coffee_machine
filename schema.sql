-- sqlite 3
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE coffee_machine (mch_id integer primary key autoincrement, mch_name text not null, mch_caffein_mg_per_cup integer not null);
CREATE TABLE consumption (usr_id integer not null, mch_id integer not null, ts datetime not null, foreign key (usr_id) references user(usr_id) on delete restrict on update cascade, foreign key (mch_id) references coffee_machine(mch_id) on delete restrict on update cascade);
CREATE TABLE user (usr_id integer primary key autoincrement, usr_login text not null, usr_email text not null, usr_password not null);
DELETE FROM sqlite_sequence;
CREATE UNIQUE INDEX usr_login_index_uniq on user(usr_login);
CREATE UNIQUE INDEX usr_email_index_uniq on user(usr_email);
COMMIT;
PRAGMA foreign_keys=ON;

