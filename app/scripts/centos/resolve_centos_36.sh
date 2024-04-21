#!/bin/bash

#<<36>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "36. Apache 웹 프로세스 권한 제한"
echo "-------------------------------------------------------------------------"

# Apache 설정 파일 경로 설정
APACHE_CONF="/etc/httpd/conf/httpd.conf"

# User, Group 지시어가 root로 설정된 경우 apache로 변경
if grep -qE "^User root" $APACHE_CONF; then
    sudo sed -i 's/^User root/User apache/' $APACHE_CONF
fi

if grep -qE "^Group root" $APACHE_CONF; then
    sudo sed -i 's/^Group root/Group apache/' $APACHE_CONF
fi

# Apache 서비스 재시작
sudo systemctl restart httpd

echo "Apache 웹 프로세스의 User, Group 권한이 apache로 변경되었습니다."
echo

