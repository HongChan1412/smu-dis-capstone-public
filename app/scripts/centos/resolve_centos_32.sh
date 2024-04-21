#!/bin/bash

#<<32>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "32. 일반사용자의 Sendmail 실행 금지 "
echo "-------------------------------------------------------------------------"
# Sendmail 설치 여부 확인
if rpm -q sendmail &> /dev/null; then
    # Sendmail 설치가 확인됨
    SENDMAIL_CF="/etc/mail/sendmail.cf"
    if grep -q "O PrivacyOptions" $SENDMAIL_CF && ! grep -q "O PrivacyOptions=.*restrictqrun" $SENDMAIL_CF; then
        # restrictqrun 옵션이 PrivacyOptions에 없는 경우 추가
        sudo sed -i '/^O PrivacyOptions/ s/$/,restrictqrun/' $SENDMAIL_CF
        echo "Sendmail 설정을 업데이트하여 일반 사용자가 실행할 수 없도록 했습니다."
        # Sendmail 서비스 재시작
        sudo systemctl restart sendmail
    else
        echo "Sendmail이 이미 안전하게 설정되어 있습니다."
    fi
else
    # Sendmail 설치가 안됨
    echo "Sendmail이 설치되어 있지 않습니다."
fi

echo 

