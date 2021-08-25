#!/bin/bash

#*****************************************************************************************************************
#Author : M.Sudhakaran
#Purpose : To log the file update in log file output.txt and file_modify_log.txt  ( This should be run in the container )
#execution : ./filemodifyalert.sh
#*****************************************************************************************************************

oldmd5=`md5sum test`
while true
do
    sleep 2
    newmd5=`md5sum test`

    if [ "${oldmd5}" != "${newmd5}" ]
    then
        echo " file has been changed `date` "
        echo " file has been changed `date` " > output.txt
        echo " file has been changed `date` " >> file_modified_log.txt
        oldmd5=$newmd5
    fi

done

