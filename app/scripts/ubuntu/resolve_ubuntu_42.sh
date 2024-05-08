#!/bin/bash
#42번 조치
apt_upgrade(){
        # 사용자에게 업그레이드 진행 여부를 묻습니다.
        echo -n "업그레이드를 진행하시겠습니까? [y/n]: "
        read answer

        # 사용자 응답을 소문자로 변환합니다.
        answer=$(echo $answer | tr '[:upper:]' '[:lower:]')

        if [ "$answer" == "y" ]; then
                echo "업그레이드를 시작합니다..."
                sudo apt-get upgrade
                echo "시스템을 재시작합니다...."
                sudo reboot
        elif [ "$answer" == "n" ]; then
                echo "업그레이드를 취소했습니다."
        else
                echo "잘못된 입력입니다. 'y' 또는 'n'을 입력해주세요."
        fi
}

apt_upgrade
