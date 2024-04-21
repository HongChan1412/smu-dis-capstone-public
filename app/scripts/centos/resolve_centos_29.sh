#!/bin/bash

#<<29>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "29. tftp, talk 서비스 비활성화 "
echo "-------------------------------------------------------------------------"

# tftp, talk 서비스 비활성화 작업 시작
echo "tftp, talk 서비스 비활성화 작업을 시작합니다."

# /etc/xinetd.d/tftp 파일이 존재하는지 확인
if [ -f /etc/xinetd.d/tftp ]; then
    # 'disable = no'를 'disable = yes'로 변경. 공백 문자에 대해 더 유연하게 처리
    sudo sed -i 's/disable[[:space:]]*=[[:space:]]*no/disable = yes/' /etc/xinetd.d/tftp
    echo "TFTP 서비스가 비활성화되었습니다."
    # xinetd 서비스 재시작
    sudo systemctl restart xinetd
    echo "Xinetd 서비스가 재시작되었습니다."
else
    echo "/etc/xinetd.d/tftp 파일을 찾을 수 없습니다. TFTP 서비스가 설치되어 있는지 확인해주세요."
fi

# talk 서비스 비활성화 절차
if test -f /etc/xinetd.d/talk; then
    # talk 서비스가 활성화 되어 있는지 확인
    TK=$(grep 'disable' /etc/xinetd.d/talk | grep 'no')
    if [ -n "$TK" ]; then
        # talk 서비스가 활성화 되어 있으므로, 비활성화 처리
        echo "talk 서비스가 활성화 되어 있습니다. 비활성화를 진행합니다."
        sed -i 's/disable[ ]*=[ ]*no/disable = yes/g' /etc/xinetd.d/talk
        # xinetd 서비스 재시작
        systemctl restart xinetd
        echo "talk 서비스가 비활성화 되었습니다."
    else
        # talk 서비스가 이미 비활성화 되어 있음
        echo "talk 서비스가 이미 비활성화 되어 있습니다."
    fi
else
    # talk 서비스가 설치되어 있지 않음
    echo "talk 서비스가 설치되어 있지 않습니다."
fi

echo 
