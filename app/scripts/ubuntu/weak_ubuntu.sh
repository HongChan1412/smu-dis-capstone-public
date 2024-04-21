#취약코드
#!/bin/bash
#=====================1번 취약=================

remove_account_lock_threshold() {
    # 계정 잠금 임계값이 설정되어 있는지 확인
    if grep -q 'pam_tally2.so' /etc/pam.d/common-auth; then
        echo "계정 잠금 임계값 설정이 발견되었습니다. 설정을 삭제합니다."
        
        # 설정된 계정 잠금 임계값 삭제
        sudo sed -i '/pam_tally2.so/d' /etc/pam.d/common-auth
        echo "계정 잠금 임계값 설정이 삭제되었습니다."
    else
        echo "계정 잠금 임계값 설정이 없습니다."
    fi
}
change_permit_root_login_to_yes() {
    # SSH 설정 파일 경로
    local sshd_config="/etc/ssh/sshd_config"

    # SSH 설정 파일에서 PermitRootLogin 줄을 찾아서 yes로 변경
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' $sshd_config
    # SSH 서비스를 재시작
    sudo systemctl restart ssh
}

#=====================4번 취약=================
change_group_owner_to_shadow() {
    local filename="/etc/shadow"
    sudo chown :shadow "$filename"
    if [ $? -eq 0 ]; then
        echo "그룹 소유자를 shadow로 변경했습니다: $filename"
    else
        echo "그룹 소유자 변경 실패"
    fi
}
change_permission_and_owner() {
    # /etc/passwd와 /etc/shadow의 권한을 766으로 변경
    sudo chmod 766 /etc/passwd /etc/shadow

    # /etc/passwd와 /etc/shadow의 소유자를 captest로 변경
    sudo chown captest:captest /etc/passwd /etc/shadow

    echo "/etc/passwd와 /etc/shadow의 권한이 766으로 변경되었으며, 소유자가 captest로 설정되었습니다."
}
#=====================5번 취약=================

change_root_permission() {
    # 기대되는 권한
    local expected_permission="600"
    # 현재 root 디렉터리의 권한
    local root_permission=$(stat -c "%A" /root)

    # 현재 권한이 기대되는 권한과 다른 경우에만 변경
    if [ "$root_permission" != "$expected_permission" ]; then
        sudo chmod $expected_permission /root
        echo "root 디렉터리 권한이 변경되었습니다."
    else
        echo "root 디렉터리 권한이 이미 안전한 상태입니다."
    fi
}
#=====================9번 취약=================
HOSTS_FILE="/etc/hosts"

# /etc/hosts 파일의 소유자와 파일 권한을 검사하고 수정하는 함수
check_and_fix_hosts_file() {
    # /etc/hosts 파일의 소유자가 root가 아닌 경우, 소유자를 root로 변경합니다.
    if [ "$(stat -c '%U' $HOSTS_FILE)" != "captest" ]; then
        sudo chown captest:captest $HOSTS_FILE
        echo "변경: /etc/hosts 파일의 소유자를 root로 변경했습니다."
    fi

    # /etc/hosts 파일의 파일 권한이 644가 아닌 경우, 권한을 644로 변경합니다.
    if [ "$(stat -c '%a' $HOSTS_FILE)" != "644" ]; then
        sudo chmod 644 $HOSTS_FILE
        echo "변경: /etc/hosts 파일의 파일 권한을 644로 변경했습니다."
    fi
}

#=====================10번 취약=================
INETD_FILE="/etc/inetd.conf"
XINETD_FILE="/etc/xinetd.conf"

fix_inetd_file(){
    if [ "$(stat -c '%U' $INETD_FILE)" != "captest" ]; then
        sudo chown captest:captest $INETD_FILE
        echo "변경: /etc/inetd.conf 파일의 소유자를 captest로 변경했습니다."
    fi

    if  [ "$(stat -c '%a' $INETD_FILE)" != "644" ]; then
        sudo chmod 644 $INETD_FILE
        echo "변경: /etc/inetd.conf 파일의 파일 권한을 644로 변경했습니다."
    fi
}

fix_xinetd_file(){
    if [ "$(stat -c '%U' $XINETD_FILE)" != "captest" ]; then
        sudo chown captest:captest $XINETD_FILE
        echo "변경: /etc/xinetd.conf 파일의 소유자를 captest로 변경했습니다."
    fi

    if [ "$(stat -c '%a' $XINETD_FILE)" != "644" ]; then
        sudo chmod 644 $XINETD_FILE
        echo "변경: /etc/xinetd.conf 파일의 파일 권한을 644로 변경했습니다."
    fi
}

#=====================12번 취약=================
SERVICE_FILE="/etc/services"

check_and_fix_services_file() {
    # /etc/services 파일의 소유자가 users가 아닌 경우, 소유자를 users로 변경합니다.
    if [ "$(stat -c '%U' $SERVICE_FILE)" != "captest" ]; then
        sudo chown captest:captest $SERVICE_FILE
        echo "변경: /etc/services 파일의 소유자를 captest로 변경했습니다."
    fi

    # /etc/services 파일의 파일 권한이 600이 아닌 경우, 권한을 600으로 변경합니다.
    if [ "$(stat -c '%a' $SERVICE_FILE)" != "600" ]; then
        sudo chmod 600 $SERVICE_FILE
        echo "변경: /etc/services 파일의 파일 권한을 600으로 변경했습니다."
    fi
}

#=====================22번 취약=================
CRONA_FILE="/etc/cron.allow"
CROND_FILE="/etc/cron.deny"

fix_crona_file() {
    # /etc/cron.allow 파일의 소유자가 users가 아닌 경우, 소유자를 users로 변경합니다.
    if [ "$(stat -c '%U' $CRONA_FILE)" != "captest" ]; then
        sudo chown captest:captest $CRONA_FILE
        echo "변경: /etc/cron.allow 파일의 소유자를 captest로 변경했습니다."
    fi

    # /etc/cron.allow 파일의 파일 권한이 600이나 644인 경우, 권한을 400으로 변경합니다.
    current_perms=$(stat -c '%a' $CRONA_FILE)
    if [ "$current_perms" = "600" ] || [ "$current_perms" = "644" ]; then
        sudo chmod 400 $CRONA_FILE
        echo "변경: /etc/cron.allow 파일의 파일 권한을 400으로 변경했습니다."
    fi
}

fix_crond_file() {
    # /etc/cron.deny 파일의 소유자가 users가 아닌 경우, 소유자를 users로 변경합니다.
    if [ "$(stat -c '%U' $CROND_FILE)" != "captest" ]; then
        sudo chown captest:captest $CROND_FILE
        echo "변경: /etc/cron.deny 파일의 소유자를 captest로 변경했습니다."
    fi

    # /etc/cron.deny 파일의 파일 권한이 600이나 644인 경우, 권한을 400으로 변경합니다.
    current_perms=$(stat -c '%a' $CROND_FILE)
    if [ "$current_perms" = "600" ] || [ "$current_perms" = "644" ]; then
        sudo chmod 400 $CROND_FILE
        echo "변경: /etc/cron.deny 파일의 파일 권한을 400으로 변경했습니다."
    fi
}
#=====================29번 취약=================
enable_tftp_service() {
    # tftpd-hpa 패키지가 설치되어 있지 않은 경우 설치
    if ! dpkg-query -l tftpd-hpa > /dev/null 2>&1; then
        sudo apt update
        sudo apt install tftpd-hpa -y
    fi

    # systemd를 사용하여 tftpd-hpa 서비스를 관리하는 경우
    if ! systemctl is-active --quiet tftpd-hpa; then
        sudo systemctl start tftpd-hpa
        sudo systemctl enable tftpd-hpa
    fi

    # xinetd를 사용하는 경우, xinetd가 설치되어 있고 tftp 서비스를 위해 구성되어 있는지 확인해야 합니다.
    # 여기서는 xinetd의 활성화만 다룹니다. xinetd를 통한 tftp 서비스 구성은 시스템 설정에 따라 달라질 수 있습니다.
    if ! systemctl is-active --quiet xinetd; then
        sudo systemctl start xinetd
        sudo systemctl enable xinetd
    fi
}

#=====================30번 취약=================
removeSendmailOptions() {
    # Sendmail 설치 여부 확인
    if dpkg -s sendmail &> /dev/null; then
        # Sendmail 설치가 확인됨
        local SENDMAIL_CF="/etc/mail/sendmail.cf"
        # 제거해야 할 옵션들을 나열
        local REMOVE_OPTIONS=("authwarnings" "novrfy" "noexpn" "restrictqrun")

        # 현재 PrivacyOptions 검사
        local CURRENT_OPTIONS=$(grep "^O PrivacyOptions" $SENDMAIL_CF | awk -F= '{print $2}')
        
        # 제거해야 할 옵션이 현재 설정에 있는지 확인하고, 있으면 제거
        for option in "${REMOVE_OPTIONS[@]}"; do
            if echo "$CURRENT_OPTIONS" | tr ',' '\n' | grep -q "$option"; then
                # 옵션 제거
                CURRENT_OPTIONS=$(echo "$CURRENT_OPTIONS" | tr ',' '\n' | grep -v "$option" | paste -sd, -)
            fi
        done

        # 수정된 옵션을 설정 파일에 적용
        sudo sed -i "/^O PrivacyOptions/c\O PrivacyOptions=$CURRENT_OPTIONS" $SENDMAIL_CF
        echo "지정된 옵션들(authwarnings, novrfy, noexpn, restrictqrun)이 Sendmail 설정에서 제거되었습니다."
        # Sendmail 서비스 재시작
        sudo systemctl restart sendmail
    else
        # Sendmail 설치가 안됨
        echo "Sendmail이 설치되어 있지 않습니다."
    fi
}

#=====================37번 취약=================
update_allow_override_and_restart_apache() {
    # 원하는 AllowOverride 설정 값 정의
    local NEW_ALLOW_OVERRIDE="None"

    # Apache 설정 파일 경로 정의
    local APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"

    # /etc/apache2/apache2.conf 파일에서 첫 번째로 등장하는 AllowOverride 설정 값을 추출
    local GC=$(grep -m1 AllowOverride "$APACHE_CONFIG_FILE" | awk '{print $2}')

    # 현재 AllowOverride 설정 값이 원하는 값과 다른지 확인
    if [ "$GC" != "$NEW_ALLOW_OVERRIDE" ]; then
        # AllowOverride 설정이 원하는 값과 다른 경우, 원하는 값으로 변경
        sudo sed -i "/AllowOverride/ s/\(AllowOverride \).*/\1$NEW_ALLOW_OVERRIDE/" "$APACHE_CONFIG_FILE"
        
        echo "AllowOverride가 $NEW_ALLOW_OVERRIDE로 변경되었습니다."

        # Apache 서비스 재시작
        sudo systemctl restart apache2
        echo "Apache 서비스가 재시작되었습니다."
    else
        # 이미 원하는 설정값인 경우
        echo "AllowOverride는 이미 $NEW_ALLOW_OVERRIDE입니다."
    fi
}
#=====================39번 취약=================
enable_symlinks_apache() {
    # Apache 설정 파일 지정
    APACHE_CONF="/etc/apache2/apache2.conf"
    
    # Apache 설정 파일 백업
    sudo cp $APACHE_CONF "${APACHE_CONF}.bak"

    # Options 지시어가 있는지 확인하고, FollowSymLinks 옵션 추가
    if grep -q 'Options' $APACHE_CONF; then
        # FollowSymLinks가 이미 설정되어 있는지 확인
        if grep 'Options' $APACHE_CONF | grep -qv 'FollowSymLinks'; then
            # FollowSymLinks가 없는 경우, Options 지시어에 추가
            sudo sed -i '/Options/ s/$/ FollowSymLinks/' $APACHE_CONF
            echo "Apache 설정에 FollowSymLinks 옵션이 추가되었습니다."
        else
            echo "FollowSymLinks 옵션이 이미 설정되어 있습니다."
        fi
    else
        # Options 지시어가 없는 경우, 디렉토리 설정에 추가
        echo "Options 지시어가 발견되지 않았습니다. 설정 파일을 확인해주세요."
    fi

    # Apache 서비스 재시작
    sudo systemctl restart apache2
    echo "Apache 서비스를 재시작했습니다."
}

#=====================40번 취약=================
# 변수 설정
PHP_INI="/etc/php.ini"
APACHE_CONF="/etc/apache2/apache2.conf"  

# PHP의 post_max_size 설정을 완전히 제거하는 함수
remove_php_post_max_size() {
    PHP_INI="/etc/php.ini"
    cp $PHP_INI "$PHP_INI.bak"
    
    # post_max_size 설정을 완전히 제거합니다.
    sed -i '/post_max_size/d' $PHP_INI
    
    echo "PHP post_max_size 설정이 완전히 제거되었습니다."
}


# Apache의 LimitRequestBody 설정을 제거하는 함수
remove_apache_limit_request_body() {
    APACHE_CONF="/etc/apache2/apache2.conf"
    cp $APACHE_CONF "$APACHE_CONF.bak"
    
    # LimitRequestBody 설정을 완전히 제거합니다.
    sed -i '/LimitRequestBody/d' $APACHE_CONF
    
    echo "Apache LimitRequestBody 설정이 완전히 제거되었습니다."
}

#=====================41번 취약=================
set_document_root_to_var_www_html() {
    # Apache 설정 파일 경로 설정
    APACHE_CONF="/etc/apache2/apache2.conf"

    # DocumentRoot 설정 검사
    if grep -qE "^DocumentRoot" $APACHE_CONF; then
        # DocumentRoot 설정이 있는 경우, 해당 값을 /var/www/html로 변경
        sudo sed -i "s|^DocumentRoot.*|DocumentRoot /var/www/html|" $APACHE_CONF
        echo "DocumentRoot를 /var/www/html로 변경했습니다."
    else
        # DocumentRoot 설정이 없는 경우, 설정 추가
        echo "DocumentRoot /var/www/html" | sudo tee -a $APACHE_CONF > /dev/null
        echo "DocumentRoot 설정을 추가했습니다: /var/www/html"
    fi

    # Apache 서비스 재시작
    sudo systemctl restart apache2
}


main() {
remove_account_lock_threshold
change_permit_root_login_to_yes
#change_group_owner_to_shadow
change_permission_and_owner
change_root_permission
check_and_fix_hosts_file
fix_inetd_file
fix_xinetd_file
check_and_fix_services_file
fix_crona_file
fix_crond_file
enable_tftp_service
removeSendmailOptions
update_allow_override_and_restart_apache
enable_symlinks_apache
remove_php_post_max_size
remove_apache_limit_request_body
set_document_root_to_var_www_html
}

main
