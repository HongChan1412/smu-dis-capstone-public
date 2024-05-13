#!/bin/bash
#41번 조치
# 41번 조치 DocumentRoot를 /root로 설정하는 함수
update_document_root() {
    local conf_file="/etc/apache2/apache2.conf"
    local new_root="/root"
    local found=$(grep -E '^DocumentRoot' $conf_file)

    if [ -z "$found" ]; then
        # DocumentRoot 설정이 없는 경우, 파일 끝에 추가
        echo "DocumentRoot $new_root" >> $conf_file
        echo "DocumentRoot가 추가되었습니다: $new_root"
    else
        # DocumentRoot 설정이 있는 경우, sed를 사용하여 변경
        sed -i "s|^DocumentRoot.*|DocumentRoot $new_root|" $conf_file
        echo "DocumentRoot가 업데이트되었습니다: $new_root"
    fi

    sudo systemctl restart apache2
}

update_document_root

#!/bin/bash

#<<41>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "41. Apache 웹 서비스 영역 분리 "
echo "-------------------------------------------------------------------------"

# Apache 홈 디렉터리 설정
APACHE_HOME="/etc/apache2"  # CentOS에서 Apache 홈 디렉터리의 기본 경로

# Apache 설정 파일 경로 설정
APACHE_CONF="$APACHE_HOME/apache2.conf"

# 새 DocumentRoot 경로 설정
NEW_DOCROOT="/var/www/my_new_site"

# 새 DocumentRoot 디렉터리 생성 (이미 존재하지 않는 경우)
if [ ! -d "$NEW_DOCROOT" ]; then
    echo "새 DocumentRoot 디렉터리를 생성합니다: $NEW_DOCROOT"
    sudo mkdir -p $NEW_DOCROOT
    # 새 디렉터리에 대한 적절한 소유권 및 권한 설정 (선택적)
    sudo chown apache:apache $NEW_DOCROOT
    sudo chmod 755 $NEW_DOCROOT
else
    echo "$NEW_DOCROOT 디렉터리가 이미 존재합니다."
fi

# DocumentRoot 변경
echo "DocumentRoot를 $NEW_DOCROOT로 변경합니다."
sudo sed -i "s|DocumentRoot .*|DocumentRoot \"$NEW_DOCROOT\"|g" $APACHE_CONF
sudo sed -i "s|<Directory .*|<Directory \"$NEW_DOCROOT\">|g" $APACHE_CONF
# Apache 서비스 재시작
echo "Apache 서비스를 재시작합니다."
sudo systemctl restart apache2

echo "Apache 설정 변경 완료."
