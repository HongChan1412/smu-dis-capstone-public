#!/bin/bash
# 39번 심볼릭 링크 사용 해제 및 백업 파일 생성 스크립트
disable_symlinks_with_backup() {
    # Apache 설정 파일 지정
    APACHE_CONF="/etc/apache2/apache2.conf"

    # FollowSymLinks와 SymLinksIfOwnerMatch 옵션이 포함된 줄을 찾아
    # 해당 옵션을 제거하고, .bak 확장자를 가진 백업 파일을 생성합니다.
    sudo sed -i.bak 's/FollowSymLinks//g' $APACHE_CONF
    sudo sed -i.bak 's/SymLinksIfOwnerMatch//g' $APACHE_CONF

    echo "심볼릭 링크 사용이 해제되었으며, 백업 파일이 생성되었습니다."
}

disable_symlinks_with_backup
