#!/bin/bash
#29
# tftp 서비스를 비활성화하는 함수
disable_tftp_service() {
    # xinetd를 사용하여 tftp 서비스를 관리하는 경우
    if systemctl is-active --quiet xinetd; then
        sudo systemctl stop xinetd
        sudo systemctl disable xinetd
    fi

    # systemd를 사용하여 tftpd-hpa 서비스를 관리하는 경우
    if systemctl is-active --quiet tftpd-hpa; then
        sudo systemctl stop tftpd-hpa
        sudo systemctl disable tftpd-hpa
    fi

    # tftpd-hpa 패키지가 설치되어 있는 경우 제거
    if dpkg-query -l tftpd-hpa > /dev/null 2>&1; then
        sudo apt remove tftpd-hpa -y
    fi
}

disable_tftp_service
