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
. ${subrdir}/forms.subr
set +e

FORM_PATH="${workdir}/formfile"

[ ! -d "${FORM_PATH}" ] && err 1 "No such ${FORM_PATH}"

###
groupname="rolesgroup"

err() {
	exitval=$1
	shift
	echo "$*"
	exit $exitval
}

add()
{
	local _custom_id=
	_custom_id=$( get_custom_id "roles_name" )

	if [ -r "${formfile}" ]; then
		${SQLITE3_CMD} ${formfile} << EOF
BEGIN TRANSACTION;
DROP TABLE IF EXISTS is_superuser_truefalse${_custom_id};
COMMIT;
EOF

		/usr/local/bin/cbsd ${miscdir}/updatesql ${formfile} ${distsharedir}/forms_yesno.schema is_superuser_truefalse${_custom_id}

		# Put boolean for use_sasl_yesno
		${SQLITE3_CMD} ${formfile} << EOF
BEGIN TRANSACTION;
INSERT INTO is_superuser_truefalse${_custom_id} ( text, order_id ) VALUES ( 'true', 1 );
INSERT INTO is_superuser_truefalse${_custom_id} ( text, order_id ) VALUES ( 'false', 0 );
COMMIT;
EOF

		${SQLITE3_CMD} ${formfile} <<EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'roles_name${_custom_id}','uniq database name, e.g: mydb','pguser${_custom_id}','pguser${_custom_id}','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'roles_password_hash${_custom_id}', 'password for user','password{_custom_id}', 'password${_custom_id}','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'roles_superuser${_custom_id}','Is superuser?','superuser${_custom_id}','superuser${_custom_id}','false',1, 'maxlen=60', 'dynamic', 'radio', 'is_superuser_truefalse${_custom_id}', '${groupname}' );
COMMIT;
EOF
	else
		/bin/cat <<EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,xattr,type,link,groupname ) VALUES ( 'forms', ${index},${order_id},'roles_name${_custom_id}','roles part ${_custom_id}','','','',1, 'maxlen=60', 'dynamic', 'inputbox', '', '${groupname}' );
COMMIT;
EOF
	fi
}


del()
{

	if [ -r "${formfile}" ]; then
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
