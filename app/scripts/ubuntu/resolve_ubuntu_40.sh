#!/bin/bash
#40번 조치 코드
# PHP.ini 설정 업데이트 함수
updatePHPIni() {
    local phpIni="/etc/php.ini"
    local postMaxSize="post_max_size = 5000000"

    # /etc/php.ini에서 post_max_size 검색
    if ! grep -q "^post_max_size" "$phpIni"; then
        # 설정이 없으면 추가
        echo "$postMaxSize" >> "$phpIni"
        echo "Added $postMaxSize to $phpIni."
    else
        echo "post_max_size already set in $phpIni."
    fi
}
# Apache2 설정 업데이트 함수
updateApacheConf() {
    local apacheConf="/etc/apache2/apache2.conf"
    local limitRequestBody="LimitRequestBody 5000000"

    # /etc/apache2/apache2.conf에서 LimitRequestBody 검색
    if ! grep -q "^LimitRequestBody" "$apacheConf"; then
        # 설정이 없으면 추가
        echo "$limitRequestBody" >> "$apacheConf"
        echo "Added $limitRequestBody to $apacheConf."
    else
        echo "LimitRequestBody already set in $apacheConf."
    fi
}

updatePHPIni
updateApacheConf
