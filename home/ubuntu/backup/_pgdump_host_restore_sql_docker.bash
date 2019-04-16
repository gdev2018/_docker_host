#!/bin/bash
# 
# 2018-01-08 - Initial
# 2019-04-15 - change 4 docker
#

clear

echo "------------------------------------------------------------"
echo "Easy Restore Postgresql database (sql format)"
echo "Livesey Inc., 2018-01-08"
echo "------------------------------------------------------------"
echo "The File for restore must be here - /home/ubuntu/"
echo "Filename for restore must be: pg_dump_DBNAME.sql,"
echo "	where DBNAME - real database name"
echo "	pg_dump_drupal8.sql"
echo "	pg_dump_user_tables.sql - for user+comments only"
echo "------------------------------------------------------------"

print_msg() {
    echo "`date '+%Y/%m/%d %H:%M:%S'` $1"
}

#HOST=54.93.205.16
HOST=52.59.34.33
PATH4RESTORE='/var/lib/postgresql/data/'


read -p "Input DBNAME for restore (1-drupal8, 2-plabor, 3-drupal8(user+comments only): " DATABASE_TARGET 

	 FILE4RESTORE="pg_dump_$DATABASE_TARGET.sql"
	 
if [ "$DATABASE_TARGET" == "1" ]; then
     DATABASE_TARGET='drupal8'
	 FILE4RESTORE='pg_dump_drupal8.sql'
fi
if [ "$DATABASE_TARGET" == "2" ]; then
     DATABASE_TARGET='plabor'
	 FILE4RESTORE='pg_dump_plabor.sql'
fi
if [ "$DATABASE_TARGET" == "3" ]; then
     DATABASE_TARGET='drupal8'
	 FILE4RESTORE='pg_dump_user_tables.sql'
fi

# add path for docker volume
PATHFILE4RESTORE="$PATH4RESTORE$FILE4RESTORE"

#@todo/done set real check exist file by bash
if [ -e $PATHFILE4RESTORE ]
then

	print_msg "COMMENT_05: HOST=$HOST"
	print_msg "COMMENT_10: DATABASE_TARGET=$DATABASE_TARGET"
	print_msg "COMMENT_20: FILE4RESTORE=$FILE4RESTORE"
	print_msg "COMMENT_25: PATHFILE4RESTORE=$PATHFILE4RESTORE"
	print_msg "COMMENT_30: START"

	#goto root
	cd

	#@todo/done set real drop/create DB by bash
	if [ "$FILE4RESTORE" != "pg_dump_user_tables.sql" ]; then
	
		read -p "password for username=postgres: " PGPASSWORD_ADMIN
	
		# 2) удалим базу
		PSQL_COMMAND="DROP DATABASE $DATABASE_TARGET;"
		print_msg "$PSQL_COMMAND waiting..."
		PGPASSWORD=$PGPASSWORD_ADMIN psql  --dbname=postgres --host="$HOST" --port=5432 --username=postgres --command="$PSQL_COMMAND"

		# 3) создадим базу
		print_msg "createdb $DATABASE_TARGET waiting..."
		PGPASSWORD=$PGPASSWORD_ADMIN createdb --username=postgres --encoding=UTF8 --owner=user8 $DATABASE_TARGET
	fi

	read -p "password for username=user8: " PGPASSWORD_INPUT 
	
	#импорт базы (положить в папку /home/ubuntu/ или ту папаку откуда запускался psql)
	# тут именно в двойных кавычках, в одинарных не подставляет значение переменной
	PSQL_COMMAND="\i $PATHFILE4RESTORE"
	print_msg "$PSQL_COMMAND waiting..."
								#psql -d %DATABASE_TARGET% -U user8 --command=%PSQL_COMMAND%
	PGPASSWORD=$PGPASSWORD_INPUT psql $DATABASE_TARGET --host="$HOST" --port=5432 --username=user8 --command="$PSQL_COMMAND"
	
else
	print_msg "COMMENT_05: HOST=$HOST"
	print_msg "COMMENT_10: DATABASE_TARGET=$DATABASE_TARGET"
	print_msg "COMMENT_20: FILE4RESTORE=$FILE4RESTORE"
	print_msg "COMMENT_30: ERROR. No file for restore - $PATHFILE4RESTORE"
fi

print_msg "COMMENT_40: FINISH"