#!/bin/bash

#<<22>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "22. cron 파일 소유자 및 권한 설정 "
echo "-------------------------------------------------------------------------"

# /etc/cron.deny 파일의 경로 지정
CRON_DENY_FILE="/etc/cron.deny"

# /etc/cron.deny 파일이 존재하는지 확인
if [ -f "$CRON_DENY_FILE" ]; then
    # 파일 소유자가 root가 아닌지 확인
    if [ "$(stat -c '%U' $CRON_DENY_FILE)" != "root" ]; then
        echo "cron.deny 파일의 소유자를 root로 변경합니다."
        sudo chown root:root $CRON_DENY_FILE
    else
        echo "cron.deny 파일의 소유자는 이미 root입니다."
    fi
    
    # 파일 권한을 -rw-------로 변경
    echo "cron.deny 파일의 권한을 -rw------- (600)으로 변경합니다."
    sudo chmod 600 $CRON_DENY_FILE
    
    echo "cron.deny 파일의 소유자 및 권한 변경이 완료되었습니다."
else
    echo "/etc/cron.deny 파일이 존재하지 않습니다."
fi

echo 

