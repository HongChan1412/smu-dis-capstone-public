#!/bin/bash
#35번
modify_apache2_config() {
    # 설정 파일 및 백업 파일 경로 지정
    local apache_config_file="/etc/apache2/apache2.conf"
    local backup_file="/etc/apache2/apache2.conf.backup"

    # 백업 파일 생성
    if sudo cp "$apache_config_file" "$backup_file"; then
        echo "백업 파일 생성됨: $backup_file"
    else
        echo "백업 파일 생성 실패. 스크립트를 종료합니다."
        return 1
    fi

    # sed 명령어로 'Options Indexes'를 'Options -Indexes'로 변경
    sudo sed -i '/<Directory /,/Directory>/ s/Options Indexes/Options -Indexes/g' "$apache_config_file" && \
    echo "apache2.conf 파일이 수정되었습니다."

    # Apache 서버 재시작
    if sudo systemctl restart apache2; then
        echo "Apache 서버가 재시작되었습니다."
    else
        echo "Apache 서버 재시작 실패. 설정을 확인하세요."
        return 1
    fi
}

modify_apache2_config
