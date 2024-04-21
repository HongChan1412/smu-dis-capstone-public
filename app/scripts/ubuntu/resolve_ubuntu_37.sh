#!/bin/bash
# 37번 apache 권한상승  함수 정의
update_auth_config() {
    # AllowOverride 설정 값을 추출
    GC=$(cat /etc/apache2/apache2.conf | grep AllowOverride | sed -n '1p' | awk '{print $2}')

    # GC가 AuthConfig가 아닌지 확인
    if [ "$GC" != "AuthConfig" ]; then
        # AllowOverride 설정이 AuthConfig가 아닌 경우, AuthConfig로 변경
        sudo sed -i '/AllowOverride/ s/\(AllowOverride \).*/\1AuthConfig/' /etc/apache2/apache2.conf

        echo "AllowOverride가 AuthConfig로 변경되었습니다."
    else
        # 이미 AuthConfig인 경우
        echo "AllowOverride는 이미 AuthConfig입니다."
    fi
}

update_auth_config
