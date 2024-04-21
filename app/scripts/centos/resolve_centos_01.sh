#!/bin/bash 

#<<1>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "1. root 계정 원격 접속 제한 "
echo "-------------------------------------------------------------------------"

# sshd_config 파일 경로
#SSHD_CONFIG="/etc/ssh/sshd_config"

# PermitRootLogin이 no로 설정되어 있는지 확인
#if grep -qE "^PermitRootLogin\s+no" $SSHD_CONFIG; then
#    echo "PermitRootLogin이 이미 no로 설정되어 있습니다."
#else
    # PermitRootLogin 설정을 no로 변경
#    sudo sed -i 's/^PermitRootLogin\s\+yes/PermitRootLogin no/' $SSHD_CONFIG
#    echo "PermitRootLogin이 no로 변경되었습니다."
    # SSH 서비스 재시작
#    sudo systemctl restart sshd.service
#    echo "SSH 서비스가 재시작되었습니다."
#fi
