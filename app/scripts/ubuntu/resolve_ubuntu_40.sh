#!/bin/bash

#<<40>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "40. Apache 파일 업로드 및 다운로드 제한"
echo "-------------------------------------------------------------------------"


# PHP 설정 파일 경로
PHP_INI=/etc/php.ini

# 업로드 최대 파일 크기를 5M 미만으로 설정 (예: 4M)
UPLOAD_MAX_FILESIZE="4M"
POST_MAX_SIZE="4M"

# php.ini에서 upload_max_filesize 설정 변경
if grep -q "^upload_max_filesize" $PHP_INI; then
    # 기존 설정이 존재한다면 수정
    sudo sed -i "s/^upload_max_filesize.*/upload_max_filesize = $UPLOAD_MAX_FILESIZE/" $PHP_INI
else
    # 존재하지 않는다면 추가
    echo "upload_max_filesize = $UPLOAD_MAX_FILESIZE" | sudo tee -a $PHP_INI
fi

# php.ini에서 post_max_size 설정 변경
if grep -q "^post_max_size" $PHP_INI; then
    # 기존 설정이 존재한다면 수정
    sudo sed -i "s/^post_max_size.*/post_max_size = $POST_MAX_SIZE/" $PHP_INI
else
    # 존재하지 않는다면 추가
    echo "post_max_size = $POST_MAX_SIZE" | sudo tee -a $PHP_INI
fi

# Apache 재시작하여 변경사항 적용
sudo systemctl restart apache2

echo "업로드 가능한 파일의 최대 용량을 $UPLOAD_MAX_FILESIZE 로 설정하였습니다."


# Apache 홈 디렉터리 설정. 실제 환경에 맞게 조정이 필요합니다.
APACHE_HOME="/etc/apache2"
HTTPD_CONF="$APACHE_HOME/apache2.conf"

# LimitRequestBody 값을 설정할 값 (5MB)
LIMIT_REQUEST_BODY_VALUE="5000000"

# httpd.conf 파일이 존재하는지 확인
if [ -f "$HTTPD_CONF" ]; then
    # httpd.conf에서 'LimitRequestBody' 설정이 이미 존재하는지 확인
    if grep -q "LimitRequestBody" $HTTPD_CONF; then
        echo "LimitRequestBody 설정이 이미 apache2.conf에 존재합니다."
        # 기존 설정을 5MB로 업데이트
        sudo sed -i "/LimitRequestBody/c\LimitRequestBody $LIMIT_REQUEST_BODY_VALUE" $HTTPD_CONF
        echo "기존 LimitRequestBody 설정을 $LIMIT_REQUEST_BODY_VALUE(5MB)로 업데이트 했습니다."
    else
        # LimitRequestBody 설정이 없으면, 전체 디렉터리에 대해 설정을 추가합니다.
        echo "<Directory />" | sudo tee -a $HTTPD_CONF > /dev/null
        echo "    LimitRequestBody $LIMIT_REQUEST_BODY_VALUE" | sudo tee -a $HTTPD_CONF > /dev/null
        echo "</Directory>" | sudo tee -a $HTTPD_CONF > /dev/null
        echo "LimitRequestBody 설정을 $LIMIT_REQUEST_BODY_VALUE(5MB)로 apache2.conf에 추가했습니다."
        sudo sed -i "/LimitRequestBody/c\LimitRequestBody $LIMIT_REQUEST_BODY_VALUE" $HTTPD_CONF
    fi
    # Apache 서비스 재시작
    sudo systemctl restart apache2
    echo "Apache 서비스를 재시작하여 변경사항을 적용했습니다."
else
    echo "apache2.conf 파일을 찾을 수 없습니다. Apache 홈 디렉터리를 확인해 주세요."
fi
