create database stage ; 
create database dq_good;
create database transform;
create database trans; 
create database report; 
show databases ; 
drop database my_database ; 
drop database my_database cascade ; 
show databases ; 
create external table election_data ( State string, year int, pc_no int , pc_name string, pc_type string, cand_name string, cand_sex string, partyname string, Partyabbr string, total_vot_poll int, electors int) 
row format delimited fields terminated by ','
location '/user/hive/stage/election.db/election_table' ; 
dfs -ls /user/hive/stage/election.db/election_table;
;
dfs -ls /user/hive/stage/election.db/election_table ; 
dfs -ls /user/kalpesh;

dfs -cp Election_Dataset_v_3.0.csv /user/hive/stage/election.db/election_table/.; 
select * from election_data ; 
show databases ; 
use stage ; 
show tables ; 
use default ; 
show tables ; 
select * from election_data limit 10 ; 
desc election_data ; 
select * from election_data where year is null ; 
desc election_data ; 
select * from election_data where partyabbr is null ; 
show databases ; 
create table dq_good as select * from election_data where year is not null; 
drop table dq_good ; 
create table dq_good.election_data as select * from election_data where year is not null; 
use dq_good ;

show tables ; 
use dq_good ; 
desc election_data ; 
select distinct(state) from election_data ; 
select count(distinct(state)) from election_data ; 
select count(distinct(year)) from election_data ; 
select count(distinct(pc_type)) from election_data ; 
# create table statewise_election_data (year int, term int, area string, category string, name string, sex string, party string, party_id string, ukn int, voters int) PARTITIONED BY (state string) row format delimited fields terminated by ',' ; 
desc election_data ; 
create table trans.statewise_election_data (year int, pc_no int, pc_name string, pc_type string, cand_name string, cand_sex string, partyname string, partyabbr string, total_vot_poll int, electors int) PARTITIONED BY (state string) row format delimited fields terminated by ',' ; 
create table trans.yearwise_election_data (state string, pc_no int, pc_name string, pc_type string, cand_name string, cand_sex string, partyname string, partyabbr string, total_vot_poll int, electors int) PARTITIONED BY (year int) row format delimited fields terminated by ',' ; 
insert overwrite table statewise_election_data partition(state) 
select year, pc_no, pc_name, pc_type, cand_name, cand_sex, partyname, partyabb
;
insert overwrite table trans.statewise_election_data partition(state) 
select year, pc_no, pc_name, pc_type, cand_name, cand_sex, partyname, partyabbr, total_vot_poll, electors 
;
insert overwrite table trans.statewise_election_data partition(state) 
select year, pc_no, pc_name, pc_type, cand_name, cand_sex, partyname, partyabbr, total_vot_poll, electors, state 
from dq_good.election_data; 
set hive.exec.dynamic.partition.mode=nonstrict ;
;
insert overwrite table trans.statewise_election_data partition(state) 
select year, pc_no, pc_name, pc_type, cand_name, cand_sex, partyname, partyabbr, total_vot_poll, electors, state 
from dq_good.election_data; 
select count(distinct(year)) from trans.statewise_election_data ; 
select count(distinct(state)) from trans.statewise_election_data ; 
select count(1) from dq_good.election_data where cand_sex = 'M' ; 
select count(1) from trans.statewise_election_data where cand_sex = 'M' ; 
select count(1) from dq_good.election_data where cand_sex = 'M' and state = 'Goa' ; 
select count(1) from trans.statewise_election_data where cand_sex = 'M' and state = 'Goa' ; 
dfs -ls /user/hive/warehouse/
;
dfs -ls /user/hive/warehouse/trans.db/statewise_election_data
;
select count(1) from trans.statewise_election_data where cand_sex = 'F' and state = 'Goa' ; 
explain select count(1) from trans.statewise_election_data where cand_sex = 'F' and state = 'Goa' ; 
explain select count(1) from trans.statewise_election_data where state = 'Goa' and cand_sex = 'F' ; 
select count(1) from trans.statewise_election_data where state = 'Goa' and cand_sex = 'F' ; 
create table report.mfcandidates (state string, cand_sex string, count int); 
select count(cand_sex), state from trans.statewise_election_data group by state having cand_sex = 'M' ; 
select count(cand_sex), state from trans.statewise_election_data group by state ; 
select count(cand_sex), state from trans.statewise_election_data group by state where cand_sex = 'M' ; 
select count(cand_sex), state from trans.statewise_election_data group by state having cand_sex = 'M' ; 
select count(cand_sex), cand_sex , state from trans.statewise_election_data group by state having cand_sex = 'M' ; 
select count(cand_sex), cand_sex , state from trans.statewise_election_data group by state ; 
select count(cand_sex), cand_sex , state from trans.statewise_election_data group by state, cand_sex having cand_sex = 'M' ; 
select count(cand_sex), cand_sex , state from trans.statewise_election_data group by state, cand_sex ; 
select count(cand_sex), cand_sex, state from trans.statewise_election_data group by state, cand_sex having cand_sex ='M' ; 
select count(cand_sex), cand_sex, state from trans.statewise_election_data group by state, cand_sex having cand_sex ='M' or cand_sex = 'F' ; 
use reports ; 
show databases   
;
use report ; 
show tables ; 
drop table mfcandidates ; 
create table report.mfcandidates as select count(cand_sex), cand_sex, state from trans.statewise_election_data group by state, cand_sex having cand_sex ='M' or cand_sex = 'F' ; 
select * from report.mfcandidates ; 
use report; 
select * from report.mfcandidates where cand_sex = 'M' ; 
use trans ; 
show tables ; 
exit
;
