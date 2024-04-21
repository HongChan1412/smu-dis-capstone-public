#!/bin/bash
#22
CRONA_FILE="/etc/cron.allow"
CROND_FILE="/etc/cron.deny"

fix_crona_file() {
    if [ "$(stat -c '%U' $CRONA_FILE)" != "root" ]; then
        sudo chown root:root $CRONA_FILE
        echo "변경: /etc/cron.allow 파일의 소유자를 root로 변경했습니다."
    fi

    if [ "$(stat -c '%a' $CRONA_FILE)" != "600" ]; then
        sudo chmod 600 $CRONA_FILE
        echo "변경: /etc/cron.allow 파일의 파일 권한을 600으로 변경했습니다."
    else
        if [ "$(stat -c '%a' $CRONA_FILE)" != "644" ]; then
            sudo chmod 644 $CRONA_FILE
            echo "변경: /etc/cron.allow 파일의 파일 권한을 644로 변경했습니다."
        fi
    fi
}

fix_crond_file() {
    if [ "$(stat -c '%U' $CROND_FILE)" != "root" ]; then
        sudo chown root:root $CROND_FILE
        echo "변경: /etc/cron.deny 파일의 소유자를 root로 변경했습니다."
    fi

    if [ "$(stat -c '%a' $CROND_FILE)" != "600" ]; then
        sudo chmod 600 $CROND_FILE
        echo "변경: /etc/cron.deny 파일의 파일 권한을 600으로 변경했습니다."
    else
        if [ "$(stat -c '%a' $CROND_FILE)" != "644" ]; then
            sudo chmod 644 $CROND_FILE
            echo "변경: /etc/cron.deny 파일의 파일 권한을 644로 변경했습니다."
        fi
    fi
}

fix_crona_file
fix_crond_file
