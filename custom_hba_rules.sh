#!/bin/sh
pgm="${0##*/}"          # Program basename
progdir="${0%/*}"       # Program directory
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
. ${subrdir}/forms.subr
set +e

FORM_PATH="${workdir}/formfile"

[ ! -d "${FORM_PATH}" ] && err 1 "No such ${FORM_PATH}"

###
groupname="hba_rules"

err() {
	exitval=$1
	shift
	echo "$*"
	exit $exitval
}

add()
{
	local _custom_id=
	_custom_id=$( get_custom_id "hba_rules_type" )

	if [ -r "${formfile}" ]; then
		/usr/local/bin/cbsd ${miscdir}/updatesql ${formfile} ${distsharedir}/forms_yesno.schema purge_truefalse${index}

		${SQLITE3_CMD} ${formfile} <<EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'hba_rules_type${_custom_id}','type of connection, e.g: "host"','host','','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'hba_rules_address${_custom_id}','address for host type','0.0.0.0/0','0.0.0.0/0','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'hba_rules_database${_custom_id}','list of database name(s) to which this rule applies','','','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'hba_rules_user${_custom_id}','list of user and group name(s) to which this rule applies','','','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'hba_rules_auth_method${_custom_id}','authentication method, e.g: "password","trust","md5"..','password','password','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'hba_rules_order${_custom_id}','rule order, integer, eg: 00${_custom_id}','00${_custom_id}','00${_custom_id}','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
COMMIT;
EOF
	else
		/bin/cat <<EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'hba_rule${_custom_id}','hba_rule part ${_custom_id}','','','',1, 'maxlen=60', 'inputbox', '', '${groupname}' );
COMMIT;
EOF
	fi
}


del()
{

	if [ -r '${formfile}' ]; then
		${SQLITE3_CMD} ${formfile} <<EOF
BEGIN TRANSACTION;
DELETE FROM forms WHERE group_id = '${index}' AND groupname = '${groupname}';
COMMIT;
EOF
	else
		/bin/cat <<EOF
BEGIN TRANSACTION;
DELETE FROM forms WHERE group_id = '${index}' AND groupname = '${groupname}';
COMMIT;
EOF
	fi
}

usage()
{
	echo "$0 -a add/remove -i index"
}


get_index()
{
	local new_index

	[ ! -r "${formfile}" ] && err 1 "formfile not readable: ${formfile}"
	new_index=$( ${SQLITE3_CMD} ${formfile} "SELECT group_id FROM forms WHERE groupname = '${groupname}' ORDER BY group_id DESC LIMIT 1" )

	case "${action}" in
		add|create)
			index=$(( new_index + 1 ))
			;;
		del*|remove)
			index=$new_index
			;;
	esac

	[ "${index}" = "0" ] && index=1	# protect ADD custom button

}

while getopts "a:i:f:o:" opt; do
	case "$opt" in
		a) action="${OPTARG}" ;;
		i) index="${OPTARG}" ;;
		f) formfile="${OPTARG}" ;;
		o) order_id="${OPTARG}" ;;
	esac
	shift $(($OPTIND - 1))
done

[ -z "${action}" ] && usage
[ -z "${index}" ] && err 1 "${pgm}: empty index"
[ -z "${order_id}" ] && err 1 "${pgm}: empty order_id"

if [ ${index} -eq 1 ]; then
	err 1 "${pgm} error: index=0"
fi

case "${action}" in
	add|create)
		add
		;;
	del*|remove)
		del
		;;
	*)
		echo "Unknown action: must be 'add' or 'del'"
		;;
esac

exit 0
