#!/bin/bash
#12
SERVICE_FILE="/etc/services"

# /etc/services 파일의 소유자와 파일 권한을 검사하고 수정하는 함수
check_and_fix_services_file() {
    # /etc/services 파일의 소유자가 root가 아닌 경우, 소유자를 root로 변경합니다.
    if [ "$(stat -c '%U' $SERVICE_FILE)" != "root" ]; then
        sudo chown root:root $SERVICE_FILE
        echo "변경: /etc/services 파일의 소유자를 root로 변경했습니다."
    fi

    # /etc/services 파일의 파일 권한이 644가 아닌 경우, 권한을 644로 변경합니다.
    if [ "$(stat -c '%a' $SERVICE_FILE)" != "644" ]; then
        sudo chmod 644 $SERVICE_FILE
        echo "변경: /etc/services 파일의 파일 권한을 644로 변경했습니다."
    fi
}

check_and_fix_services_file
