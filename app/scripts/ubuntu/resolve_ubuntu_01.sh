#!/bin/bash
#1번 조치

#1번 조치
# PermitRootLogin을 no로 변경하고 SSH 서비스를 재시작하는 함수
change_permit_root_login() {
    # SSH 설정 파일 경로
    local sshd_config="/etc/ssh/sshd_config"

    # SSH 설정 파일에서 PermitRootLogin 줄을 찾아서 no로 변경
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' $sshd_config
    # SSH 서비스를 재시작
    sudo service ssh restart
}


main(){
	set_account_lock_threshold
	set_account_lock_threshold
}

main
