#!/bin/bash
#4번 조치 new
# /etc/passwd 파일의 권한을 444로 변경하고, 소유자와 그룹을 root로 변경하는 함수
change_passwd_permissions_and_owner() {
    sudo chmod 444 /etc/passwd
    sudo chown root:root /etc/passwd

    if [ $? -eq 0 ]; then
        echo "/etc/passwd 파일의 권한이 444로 변경되었으며, 소유자와 그룹이 root로 설정되었습니다."
    else
        echo "/etc/passwd 파일 변경 실패"
    fi
}

# /etc/shadow 파일의 권한을 400으로 변경하고, 소유자와 그룹을 root로 변경하는 함수
change_shadow_permissions_and_owner() {
    sudo chmod 400 /etc/shadow
    sudo chown root:root /etc/shadow

    if [ $? -eq 0 ]; then
        echo "/etc/shadow 파일의 권한이 400으로 변경되었으며, 소유자와 그룹이 root로 설정되었습니다."
    else
        echo "/etc/shadow 파일 변경 실패"
    fi
}

main(){
	change_passwd_permissions_and_owner
	change_shadow_permissions_and_owner
}

main
