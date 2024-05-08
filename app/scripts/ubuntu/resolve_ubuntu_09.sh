#!/bin/bash
#9
HOSTS_FILE="/etc/hosts"

# /etc/hosts 파일의 소유자와 파일 권한을 검사하고 수정하는 함수
check_and_fix_hosts_file() {
    # /etc/hosts 파일의 소유자가 root가 아닌 경우, 소유자를 root로 변경합니다.
    if [ "$(stat -c '%U' $HOSTS_FILE)" != "root" ]; then
        sudo chown root:root $HOSTS_FILE
        echo "변경: /etc/hosts 파일의 소유자를 root로 변경했습니다."
    fi

    # /etc/hosts 파일의 파일 권한이 644가 아닌 경우, 권한을 644로 변경합니다.
    if [ "$(stat -c '%a' $HOSTS_FILE)" != "600" ]; then
        sudo chmod 600 $HOSTS_FILE
        echo "변경: /etc/hosts 파일의 파일 권한을 600로 변경했습니다."
    fi
}

check_and_fix_hosts_file
