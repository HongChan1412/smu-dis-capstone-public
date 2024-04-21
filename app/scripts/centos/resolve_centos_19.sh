#!/bin/bash

#<<19>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "19. Finger 서비스 비활성화 "
echo "-------------------------------------------------------------------------"

# Finger 서비스 비활성화 작업 시작
echo "Finger 서비스 비활성화 작업을 시작합니다."

# Finger 서비스가 설치되어 있는지 확인
if test -f /etc/xinetd.d/finger; then
    # Finger 서비스가 설치되어 있고 활성화 되어 있는지 확인
    if [ "$(grep 'disable' /etc/xinetd.d/finger | awk '{print $3}')" = "no" ]; then
        # Finger 서비스가 활성화 되어 있으므로, 비활성화 처리
        echo "Finger 서비스가 설치되어 있고, 활성화 되어 있습니다. 비활성화를 진행합니다."
        sed -i 's/disable[ ]*=[ ]*no/disable = yes/g' /etc/xinetd.d/finger
        # xinetd 서비스 재시작
        systemctl restart xinetd
        echo "Finger 서비스가 비활성화 되었습니다."
    else
        # Finger 서비스가 이미 비활성화 되어 있음
        echo "Finger 서비스가 설치되어 있으나 이미 비활성화 되어 있습니다."
    fi
else
    # Finger 서비스가 설치되어 있지 않음
    echo "Finger 서비스가 설치되어 있지 않습니다."
fi

echo 

