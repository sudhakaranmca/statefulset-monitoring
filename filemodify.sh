
#!/bin/bash
#*****************************************************************************************************************
#Author : M.Sudhakaran
#Purpose : To make the persistent volume data to be synced across the containers
#Hint : Before proceed - we need to add the Labels in deployment yaml file to get the pods using selector
#execution : ./filemodify.sh  app=ai type=statefulset    or   ./filemodify.sh  app=ai  
#*****************************************************************************************************************

set -x
updated_pod_list=""

#podlist=`kubectl get pods --selector app=ai --selector type=statefulset | awk '{print $1}' | sed '1d'`

file_notification()
{
    if [[ -n `kubectl exec $1 cat /tmp/output.txt | tail -n 1` ]]
    then
          echo " file has been updated on $1 "
          updated_pod=$1
          kubectl exec $1 cat /dev/null > /tmp/output.txt
          updated_pod_hash=`kubectl exec $1 md5sum /tmp/test`
   fi

   for pod in $podlist
   do
          if [ -f old ]; then
              rm ./old
          fi
     
          if [ -f new ]; then
              rm ./new
          fi
          
          if [ -f diff.txt ]; then
              rm ./diff.txt
          fi

          if [ -f new.txt ]; then
              rm ./new.txt
          fi

          non_update_pod_hash=`kubectl exec $pod md5sum /tmp/test`

          if [ "$1" != "$pod" -a "$updated_pod_hash" != "$non_update_pod_hash" ]
          then
               
               kubectl cp $pod:/tmp/test ./old
               kubectl cp $1:/tmp/test ./new
               grep -Fxvf old new > diff.txt  # used to find the exact difference between two files
               cat old diff.txt > new.txt
               #echo " updating $1 pod test file-----------"
               kubectl cp new.txt $pod:/tmp/test
          fi
   done
    
}

file_consistency_check()
{
     previous=""
     flag=0

     for pod in $podlist
     do
        present=`kubectl exec $pod md5sum /tmp/test`
        
        if [ -n "$previous" -a "$present" != "$previous" ]
        then
             flag=1
        fi
        
        previous=$present

     done
    
     if [ $flag -eq 1 ]
     then
         echo " Files across pods are not in consistent "
     else
         echo " Files across pods are in consistent state"
     fi
}

# SHELL SCRIPT ENTRY POINT 

echo " number of arguments passed in command line arguments is $# "

if [ $# -lt 1 ]
then
    echo " MINIMUM IT REQUIRES ONE ARGUMENTS - NEED TO PASS ONE OR TWO LABELS WITH VALUE TO GET THE PODS "
    exit 0
fi

if [ $# -eq 1 ]
then
     podlist=`kubectl get pods --selector $1 | awk '{print $1}' | sed '1d'`
elif [ $# -eq 2 ]
then
     podlist=`kubectl get pods --selector $1 --selector $2 | awk '{print $1}' | sed '1d'`
fi


for pod in $podlist
do
   #echo " pod name is $pod "
   file_notification $pod 
done

file_consistency_check
