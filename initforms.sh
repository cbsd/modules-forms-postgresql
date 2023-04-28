#!/bin/sh
pgm="${0##*/}"		# Program basename
progdir="${0%/*}"	# Program directory
: ${REALPATH_CMD=$( which realpath )}
: ${SQLITE3_CMD=$( which sqlite3 )}
: ${RM_CMD=$( which rm )}
: ${MKDIR_CMD=$( which mkdir )}
: ${FORM_PATH="/opt/forms"}
: ${distdir="/usr/local/cbsd"}

MY_PATH="$( ${REALPATH_CMD} ${progdir} )"
HELPER="postgresql"

# MAIN
if [ -z "${workdir}" ]; then
	[ -z "${cbsd_workdir}" ] && . /etc/rc.conf
	[ -z "${cbsd_workdir}" ] && exit 0
	workdir="${cbsd_workdir}"
fi

set -e
. ${distdir}/cbsd.conf
. ${subrdir}/tools.subr
. ${subr}
set +e

FORM_PATH="${workdir}/formfile"

[ ! -d "${FORM_PATH}" ] && err 1 "No such ${FORM_PATH}"
[ -f "${FORM_PATH}/${HELPER}.sqlite" ] && ${RM_CMD} -f "${FORM_PATH}/${HELPER}.sqlite"

/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite ${distsharedir}/forms.schema forms
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite ${distsharedir}/forms.schema additional_cfg
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite ${distsharedir}/forms_system.schema system

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,1,'-Globals','Globals','Globals','PP','',1, 'maxlen=60', 'delimer', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,2,'postgres_ver','Postgresql version','2','13','',1, 'maxlen=5', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,3,'-Additional','Additional params','Additional params','','',1, 'maxlen=60', 'delimer', '', '' );

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,4,'bgwriter_delay','bgwriter_delay','500ms','500ms','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,5,'checkpoint_completion_target','checkpoint_completion_target','0.9','0.9','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,6,'commit_delay','commit_delay','10000','10000','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,7,'datestyle','datestyle','iso, mdy','iso, mdy','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,8,'effective_io_concurrency','effective_io_concurrency','2','2','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,9,'hot_standby','hot_standby','on','on','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,10,'listen_addresses','Listen options','127.0.0.1','127.0.0.1','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,11,'log_destination','log_destination','csvlog','csvlog','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,12,'log_filename','log_filename','postgresql-%Y-%m-%d-%H.log','postgresql-%Y-%m-%d-%H.log','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,13,'log_rotation_age','log_rotation_age','1h','1h','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,14,'log_timezone','log_timezone','UTC','UTC','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,15,'log_truncate_on_rotation','log_truncate_on_rotation','on','on','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,16,'maintenance_work_mem','maintenance_work_mem','128MB','128MB','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,17,'max_connections','max_connections','1-','10','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,18,'max_replication_slots','max_replication_slots','0','0','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,19,'max_wal_senders','max_wal_senders','5','5','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,20,'max_wal_size','max_wal_size','3GB','3GB','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,21,'max_worker_processes','max_worker_processes','8','8','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,22,'shared_buffers','shared_buffers','128MB','128MB','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,23,'synchronous_commit','synchronous_commit','off','off','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,24,'temp_buffers','temp_buffers','64MB','64MB','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,25,'timezone','timezone','UTC','UTC','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,26,'wal_compression','wal_compression','on','on','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,28,'wal_level','wal_level','hot_standby','hot_standby','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,29,'work_mem','work_mem','64MB','64MB','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,100,'','Desc','2','127.0.0.1','',1, 'maxlen=42', 'inputbox', '', '' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,200,'-Databases','Databases','Databases','-','',1, 'maxlen=60', 'delimer', '', 'databases' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,201,'databases','Add databases','201','','',0, 'maxlen=60', 'group_add', '', 'databases' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,300,'-Roles','Roles','Roles','-','',1, 'maxlen=60', 'delimer', '', 'roles' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,301,'roles','Add roles','301','','',0, 'maxlen=60', 'group_add', '', 'roles' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,400,'-DBGrant','DB GRANT','DB GRANT','-','',1, 'maxlen=60', 'delimer', '', 'database_grant' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,401,'database_grant','Add DB GRANT','401','','',0, 'maxlen=60', 'group_add', '', 'database_grant' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,500,'-HBARules','HBA Rules','HBA Rules','-','',1, 'maxlen=60', 'delimer', '', 'hba_rules' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', 1,501,'hba_rules','HBA Rules','501','','',0, 'maxlen=60', 'group_add', '', 'hba_rules' );
COMMIT;
EOF

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( 'postgresql', '201607', 'databases/postgresql13-server', 'postgresql' );
COMMIT;
EOF

# CREATE VIEW
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
CREATE VIEW FORM_VIEW AS SELECT * FROM forms UNION SELECT * FROM additional_cfg;
COMMIT;
EOF

# long description
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
PostgreSQL is a sophisticated Object-Relational DBMS, supporting \
almost all SQL constructs, including subselects, transactions, and \
user-defined types and functions. It is the most advanced open-source \
database available anywhere. Commercial Support is also available. \
\
The original Postgres code was the effort of many graduate students, \
undergraduate students, and staff programmers working under the direction of \
Professor Michael Stonebraker at the University of California, Berkeley. In \
1995, Andrew Yu and Jolly Chen took on the task of converting the DBMS query \
language to SQL and created a new database system which came to known as \
Postgres95. Many others contributed to the porting, testing, debugging and \
enhancement of the Postgres95 code. As the code improved, and 1995 faded into \
memory, PostgreSQL was born. \
\
PostgreSQL development is presently being performed by a team of Internet \
developers who are now responsible for all current and future development. The \
development team coordinator is Marc G. Fournier (scrappy@PostgreSQL.ORG). \
Support is available from the PostgreSQL developer/user community through the \
support mailing list (questions@PostgreSQL.ORG). \
\
PostgreSQL is free and the complete source is available. \
\
WWW: https://www.postgresql.org/ \
';
COMMIT;
EOF
