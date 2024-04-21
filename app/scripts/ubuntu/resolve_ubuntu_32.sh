#!/bin/bash
#32
updateSendmailSettings() {
    # Sendmail 설치 여부 확인
    if dpkg -s sendmail &> /dev/null; then
        # Sendmail 설치가 확인됨
        local SENDMAIL_CF="/etc/mail/sendmail.cf"
        # 기본적으로 필요한 옵션들을 나열
        local REQUIRED_OPTIONS=("authwarnings" "novrfy" "noexpn" "restrictqrun")
        local MISSING_OPTIONS=()

        # 현재 PrivacyOptions 검사
        local CURRENT_OPTIONS=$(grep "^O PrivacyOptions" $SENDMAIL_CF | awk -F= '{print $2}' | tr ',' '\n')

        # 필요한 옵션이 현재 설정에 있는지 확인하고, 없으면 MISSING_OPTIONS에 추가
        for option in "${REQUIRED_OPTIONS[@]}"; do
            echo "$CURRENT_OPTIONS" | grep -q "$option" || MISSING_OPTIONS+=("$option")
        done

        # 누락된 옵션이 있는 경우
        if [ ${#MISSING_OPTIONS[@]} -gt 0 ]; then
            # 누락된 옵션들을 쉼표로 구분된 문자열로 변환
            local MISSING_OPTIONS_STRING=$(IFS=, ; echo "${MISSING_OPTIONS[*]}")
            # Sendmail 설정 업데이트
            sudo sed -i "/^O PrivacyOptions/ s/$/,$MISSING_OPTIONS_STRING/" $SENDMAIL_CF
            echo "누락된 옵션들($MISSING_OPTIONS_STRING)을 Sendmail 설정에 추가하여 일반 사용자가 실행할 수 없도록 했습니다."
            # Sendmail 서비스 재시작
            sudo systemctl restart sendmail
        else
            echo "Sendmail이 이미 안전하게 설정되어 있습니다."
        fi
    else
        # Sendmail 설치가 안됨
        echo "Sendmail이 설치되어 있지 않습니다."
    fi
}

updateSendmailSettings
