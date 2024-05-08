#!/bin/bash
# 백업 파일 경로
BACKUP_FILE="/etc/pam.d/common-auth.bak"
#3
# 계정 잠금 임계값 설정 함수
set_account_lock_threshold() {
    # 계정 잠금 임계값이 설정되어 있는지 확인
    if grep -q 'pam_tally2.so' /etc/pam.d/common-auth; then
        echo "계정 잠금 임계값이 설정되어 있습니다."
    else
        echo "취약: 계정 잠금 임계값이 설정되어 있지 않습니다."

        # 변경 전 사항을 백업 파일에 저장
        sudo cp /etc/pam.d/common-auth "$BACKUP_FILE"

        # 계정 잠금 설정 추가
        echo "auth required pam_tally2.so deny=5 unlock_time=600" | sudo tee -a /etc/pam.d/common-auth > /dev/null
        echo "안전: 계정 잠금 임계값을 설정했습니다."
    fi
}

set_account_lock_threshold
