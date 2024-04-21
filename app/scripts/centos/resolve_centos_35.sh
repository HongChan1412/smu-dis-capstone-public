#!/bin/bash

#<<35>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "35. Apache 디렉터리 리스팅 제거"
echo "-------------------------------------------------------------------------"

# Apache 설정 파일 경로
APACHE_CONF="/etc/httpd/conf/httpd.conf"

# 디렉터리 리스팅 옵션 제거
if grep -q "Options.*Indexes" $APACHE_CONF; then
    # Options 지시어에 Indexes 옵션이 포함되어 있으면, Indexes 옵션을 제거
    sudo sed -i 's/\(Options.*\)Indexes\(.*\)/\1 \2/' $APACHE_CONF
    sudo sed -i 's/\(Options.*\) \+/\1/' $APACHE_CONF # 중복된 공백 제거
    echo "Apache 디렉터리 리스팅 옵션(Indexes)을 제거했습니다."
else
    echo "Apache 디렉터리 리스팅 옵션이 이미 제거되었거나, 적절한 Options 지시어를 찾을 수 없습니다."
fi

# Apache 서비스 재시작
sudo systemctl restart httpd

echo "디렉터리 리스팅 설정이 수정되었습니다. Apache가 재시작되었습니다."

echo

