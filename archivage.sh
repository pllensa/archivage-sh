#!/usr/bin/env bash 

source archivage.var

# overwriting of the variables for now
# DEV workaround only
# LOCAL_BACKUP_DIR=/tmp/backups
# LOCAL_BACKUP_RET=/tmp/retention

for i in $(find $LOCAL_BACKUP_DIR -mtime +$RETENTION_DAYS -exec echo {} \;); 
  do
  mkdir -p $LOCAL_BACKUP_RET/$(date --iso)

  cp $i $LOCAL_BACKUP_RET/$(date --iso)/$i
  if [ -z $? ]; then
    echo "$i wasn't copied to $LOCAL_BACKUP_RET/$(date --iso), check it."
  fi
  if [ $(sha1 $i) -eq $(sha1 $LOCAL_BACKUP_RET/$(date --iso)/$i) ]; then
    rm $i
  fi

  for i in "{REMOTE_REPO_SET[@]}"; do
    ssh backup@i -e "mkdir $REMOTE_REPO_DIR/$(date --iso)"
    rsync $i backup@$i:$REMOTE_REPO_DIR/$(date --iso)/$i
  done
done
