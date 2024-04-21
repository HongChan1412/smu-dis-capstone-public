#!/bin/bash
#10
INETD_FILE="/etc/inetd.conf"
XINETD_FILE="/etc/xinetd.conf"

fix_inetd_file(){
        if [ "$(stat -c '%U' $INETD_FILE)" != "root" ]; then
                sudo chown root:root $INETD_FILE
                echo "변경: /etc/inetd.conf 파일의 소유자를 root로 변경했습니다."
        fi

        if  [ "$(stat -c '%a' $INETD_FILE)" != "600" ]; then
                sudo chmod 600 $INETD_FILE
                echo "변경: /etc/inetd.conf 파일의 파일 권한을 600로 변경"
        fi
}

fix_xinetd_file(){
        if [ "$(stat -c '%U' $XINETD_FILE)" != "root" ]; then
                sudo chown root:root $XINETD_FILE
                echo "변경: /etc/xinetd.conf 파일의 소유자를 root로 변경했습니다."
        fi

        if [ "$(stat -c '%a' $XINETD_FILE)" != "600" ]; then
                sudo chmod 600 $XINETD_FILE
                echo "변경: /etc/xinetd.conf 파일의 파일 권한을 600로 변경"
        fi
}

fix_inetd_file
fix_xinetd_file
