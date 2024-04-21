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
