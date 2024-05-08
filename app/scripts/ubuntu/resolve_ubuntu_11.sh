#!/bin/bash
#11번
check_and_update_file_permissions() {
    local file=$1

    # 파일이 존재하는지 확인
    if [ -f "$file" ]; then
        # 파일의 소유자 확인
        local owner=$(stat -c "%U" "$file")
        if [ "$owner" != "root" ]; then
            # 소유자를 root로 변경
            sudo chown root "$file"
            echo "$file의 소유자를 root로 변경했습니다."
        fi

        # 파일 권한 확인
        local permissions=$(stat -c "%a" "$file")
        if [ "$permissions" != "644" ]; then
            # 파일 권한을 -rw-r--r--로 변경
            sudo chmod 644 "$file"
            echo "$file의 권한을 -rw-r--r--로 변경했습니다."
        fi
    else
        echo "$file이(가) 존재하지 않습니다."
    fi
}

check_and_update_file_permissions "/etc/rsyslog.conf"
check_and_update_file_permissions "/etc/syslog.conf"
