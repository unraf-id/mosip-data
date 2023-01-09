#!/bin/sh
# Usage: ./download_md.sh [kubeconfig file]
# Default kubeconfig file is $HOME/.kube/config
if [ $# -ge 1 ]
  then
    export KUBECONFIG=$1
fi
read -p "Enter DB Schema name to Import: " user_db_schema
read -p "Enter Specific Tables to Import. if any (comma separated file name) : " user_tab_list

# This username is hardcoded in sql scripts
DB_PWD=$(kubectl get secret --namespace postgres postgres-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
DB_HOST=`kubectl get cm global -o json | jq .data.\"mosip-api-internal-host\" | tr -d '"'`
DB_PORT=5432
XLS=xlsx/$user_db_schema

while true; do
    read -p "WARNING: Data import from Database '$user_db_schema'. Are you sure?(Y/n) " yn
    if [ $yn == "Y" ]
      then
        echo Downloading ..
        cd lib
        python pgtoexcel.py $DB_HOST $DB_PWD ../$XLS $user_db_schema ${user_tab_list:-default} > output.log
        break
      else
        break
    fi
done

