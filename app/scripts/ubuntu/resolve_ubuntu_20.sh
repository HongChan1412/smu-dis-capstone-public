#!/bin/bash
#20번 조치
update_anonymous_enable() {
    local config_file="/etc/vsftpd.conf"

    # anonymous_enable=YES인지 확인
    if grep -qE "^anonymous_enable=YES$" "$config_file"; then
        # anonymous_enable=YES를 anonymous_enable=NO로 변경
        sudo sed -i 's/^anonymous_enable=YES$/anonymous_enable=NO/' "$config_file"
        echo "anonymous_enable을(를) NO로 변경했습니다."
    else
        echo "anonymous_enable이(가) 이미 NO이거나 설정이 존재하지 않습니다."
    fi
}

update_anonymous_enable
