#!/bin/bash

echo
echo "-------------------------------------------------------------------------"
echo "1. root 계정 원격 접속 제한 "
echo "-------------------------------------------------------------------------"

# sshd_config 파일 경로
SSHD_CONFIG="/etc/ssh/sshd_config"

# PermitRootLogin이 no로 설정되어 있는지 확인
if grep -q "^PermitRootLogin no" $SSHD_CONFIG; then
    # no를 yes로 변경
    sudo sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' $SSHD_CONFIG
    echo "PermitRootLogin이 yes로 변경되었습니다."
    # SSH 서비스 재시작
    sudo systemctl restart sshd.service
    echo "SSH 서비스가 재시작되었습니다."
else
    echo "PermitRootLogin이 이미 yes로 설정되어 있거나, 설정이 주석 처리되어 있습니다."
fi
echo
echo "-------------------------------------------------------------------------"
echo "5. root 홈, 패스 디렉터리 권한 및 패스 설정 "
echo "-------------------------------------------------------------------------"


# root 홈 디렉터리 권한 변경
sudo chmod 755 /root

echo "root 홈 디렉터리 권한을 755로 변경하였습니다. "

# 변경된 권한 확인
ls -ld /root
echo

echo
echo "-------------------------------------------------------------------------"
echo "6. 파일 및 디렉터리 소유자 설정 "
echo "-------------------------------------------------------------------------"

# 시스템 전체에서 소유자나 그룹이 없는 파일 또는 디렉터리를 찾음
echo "소유자나 그룹이 없는 파일 또는 디렉터리를 찾고 있습니다..."

# 임시 사용자 및 그룹 생성
sudo useradd tempuser
sudo groupadd tempgroup

# 임시 파일 및 디렉터리 생성 및 소유자 변경
sudo touch tempfile
sudo mkdir tempdir
sudo chown tempuser:tempgroup tempfile
sudo chown tempuser:tempgroup tempdir

# 사용자 및 그룹 삭제
sudo userdel tempuser
sudo groupdel tempgroup

echo "임시 사용자 및 그룹을 생성하고 삭제하는 과정이 완료되었습니다."

echo
echo
echo "-------------------------------------------------------------------------"
echo "10. /etc/(x)inetd.conf 파일 소유자 및 권한 설정"
echo "-------------------------------------------------------------------------"

XINETD_DIR="/etc/xinetd.d"
TEST_SERVICE_FILE="$XINETD_DIR/test_service"

# xinetd 설치 확인 및 설치
if ! rpm -q xinetd &>/dev/null; then
    echo "xinetd 설치가 완료되었습니다."
fi

# /etc/xinetd.d 폴더의 존재 확인
if [ ! -d "$XINETD_DIR" ]; then
    echo "$XINETD_DIR 폴더가 존재하지 않습니다. 생성합니다..."
    sudo mkdir "$XINETD_DIR"
fi

# /etc/xinetd.d 내에 취약한 권한 설정을 가진 파일이 있는지 확인
vulnerable_file_found=false

for file in $XINETD_DIR/*; do
    if [ -f "$file" ]; then
        # 파일 권한이 -rwxrwxrwx가 아니거나, 소유자가 root가 아닌 경우 취약한 것으로 간주
        if [ "$perms" != "-rwxrwxrwx" ] || [ "$owner" != "root" ]; then
            echo "$file 의 권한을 -rwxrwxrwx로 변경합니다."
            sudo chmod 777 "$file"
            vulnerable_file_found=true
        fi
    fi
done

# 취약한 권한 설정을 가진 파일이 없으면, 테스트 서비스 파일을 생성
if [ "$vulnerable_file_found" = false ]; then
    echo "취약한 파일이 없으므로, 테스트 서비스 파일을 생성합니다..."
    echo "service test_service
{
    disable     = no
    socket_type = stream
    protocol    = tcp
    wait        = no
    user        = nobody
    server      = /usr/sbin/test_service
}" | sudo tee "$TEST_SERVICE_FILE" > /dev/null

    echo "$TEST_SERVICE_FILE 의 권한을 -rwxrwxrwx로 변경합니다."
    sudo chmod 777 "$TEST_SERVICE_FILE"
fi

echo "작업이 완료되었습니다."
echo
echo
echo "-------------------------------------------------------------------------"
echo "12. /etc/services 파일 소유자 및 권한 설정 "
echo "-------------------------------------------------------------------------"
SERVICES_FILE="/etc/services"

# /etc/services 파일의 권한을 777로 변경
echo "$SERVICES_FILE 파일의 권한을 변경합니다."
sudo chmod 777 $SERVICES_FILE

# 변경된 권한 확인
ls -l $SERVICES_FILE
echo
echo
echo "-------------------------------------------------------------------------"
echo "17. /root/.rhosts, hosts.equiv 사용 금지 "
echo "-------------------------------------------------------------------------"

# root 사용자로 실행되고 있는지 확인
if [ "$(id -u)" -ne 0 ]; then
    echo "이 스크립트는 root 권한으로 실행되어야 합니다."
fi

# .rhosts 파일 생성 및 취약하게 만들기
if [ ! -f /root/.rhosts ]; then
    echo "/root/.rhosts을(를) 생성하고 취약하게 만듭니다..."
    touch /root/.rhosts
    echo "+ +" > /root/.rhosts
    chmod 600 /root/.rhosts # 변경됨: 666에서 600으로, 더 안전한 권한 설정
else
    echo "/root/.rhosts 파일이 이미 존재합니다."
fi

# hosts.equiv 파일 생성 및 취약하게 만들기
if [ ! -f /root/hosts.equiv ]; then
    echo "/root/hosts.equiv을(를) 생성하고 취약하게 만듭니다..."
    touch /root/hosts.equiv
    echo "+ +" > /root/hosts.equiv
    chmod 600 /root/hosts.equiv # 변경됨: 666에서 600으로, 더 안전한 권한 설정
else
    echo "/root/hosts.equiv 파일이 이미 존재합니다."
fi

echo
echo "-------------------------------------------------------------------------"
echo "19. Finger 서비스 비활성화 "
echo "-------------------------------------------------------------------------"

# Finger 서비스 설치
echo "Finger 서비스를 설치합니다..."
sudo yum update -y
sudo yum install finger xinetd -y

# Finger 서비스를 위한 xinetd 설정 파일 확인
sudo sed -i 's/disable\s*=\s*yes/disable = no/g' /etc/xinetd.d/finger
sudo systemctl restart xinetd
netstat -tuln | grep :79

# xinetd 재시작하여 변경사항 적용
sudo systemctl restart xinetd
echo "Finger 서비스가 활성화되었습니다."

echo
echo
echo "-------------------------------------------------------------------------"
echo "22. cron 파일 소유자 및 권한 설정 "
echo "-------------------------------------------------------------------------"

# cron 파일 위치. 여기서는 예시로 /etc/cron.deny을 사용합니다.
CRON_FILE="/etc/cron.deny"

# cron 파일의 소유자 및 권한 확인
echo "현재 $CRON_FILE 파일의 소유자 및 권한:"
ls -l $CRON_FILE

# cron 파일의 권한을 644로 변경
echo "권한을 755로 변경합니다."
sudo chmod 755 $CRON_FILE

# 변경 후 권한 확인
echo "변경된 $CRON_FILE 파일의 소유자 및 권한:"
ls -l $CRON_FILE

echo
echo
echo "-------------------------------------------------------------------------"
echo "29. tftp, talk 서비스 비활성화"
echo "-------------------------------------------------------------------------"


# xinetd 설치
echo "xinetd 설치 중..."
sudo yum install -y xinetd

# tftp, talk, talk-server 설치
echo "tftp, talk 및 talk-server 설치 중..."
sudo yum install -y tftp-server talk talk-server

# tftp 설정 수정
echo "tftp 서비스 활성화 중..."
sudo sed -i '/disable/s/yes/no/' /etc/xinetd.d/tftp

# talk 설정 수정
echo "talk 서비스 활성화 중..."
sudo sed -i '/disable/s/yes/no/' /etc/xinetd.d/talk

# ntalk 설정 수정
echo "ntalk 서비스 활성화 중..."
sudo sed -i '/disable/s/yes/no/' /etc/xinetd.d/ntalk

# xinetd 재시작 및 활성화
echo "xinetd 서비스 재시작 및 부팅 시 활성화 중..."
sudo systemctl restart xinetd
sudo systemctl enable xinetd

echo "서비스 활성화 완료!"


echo
echo "-------------------------------------------------------------------------"
echo "32. 일반사용자의 Sendmail 실행 금지"
echo "-------------------------------------------------------------------------"

# Sendmail 설치 여부 확인
if rpm -q sendmail &> /dev/null; then
    # Sendmail 설치가 확인됨
    SENDMAIL_CF="/etc/mail/sendmail.cf"
    if grep -q "O PrivacyOptions=.*restrictqrun" $SENDMAIL_CF; then
        # restrictqrun 옵션이 PrivacyOptions에 있는 경우 제거
        sudo sed -i '/^O PrivacyOptions/ s/,restrictqrun//' $SENDMAIL_CF
        echo "Sendmail 설정을 업데이트하여 일반 사용자가 실행할 수 있도록 했습니다."
        # Sendmail 서비스 재시작
        sudo systemctl restart sendmail
    else
        echo "Sendmail 설정이 이미 일반 사용자가 실행할 수 있게 설정되어 있습니다."
    fi
else
    # Sendmail 설치가 안됨
    echo "Sendmail이 설치되어 있지 않습니다."
fi

echo
echo
echo "-------------------------------------------------------------------------"
echo "35, 36, 40, 41. Apache"
echo "-------------------------------------------------------------------------"

# Apache 설치
echo "Apache를 설치합니다..."
sudo yum update -y
sudo yum install httpd -y

# 디렉터리 리스팅 활성화
# 기본적으로 Apache의 설정 파일에서 Options 지시어에 Indexes 옵션을 추가합니다.
echo "Apache 디렉터리 리스팅을 활성화합니다..."
#APACHE_CONF="/etc/httpd/conf/httpd.conf"
#sudo sed -i '/<Directory \/var\/www\/html>/,/<\/Directory>/ s/Options None/Options Indexes/' /etc/httpd/conf/httpd.conf
#sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/Options None/Options Indexes/' /etc/httpd/conf/httpd.conf

# Apache 웹 프로세스의 사용자 및 그룹을 root로 설정
# 보안상의 이유로 이 설정은 권장되지 않습니다. Apache를 root로 실행하는 것은 매우 위험할 수 있습니
다.
# 아래의 설정은 예시일 뿐 실제 환경에서는 사용하지 않는 것이 좋습니다.
echo "Apache 웹 프로세스의 사용자와 그룹을 root로 설정합니다..."
APACHE_ENVVARS="/etc/httpd/conf/httpd.conf"
sudo sed -i 's/User apache/User root/' $APACHE_ENVVARS
sudo sed -i 's/Group apache/Group root/' $APACHE_ENVVARS

# 41
sudo sed -i 's|DocumentRoot "/var/www/my_new_site"|DocumentRoot "/var/www/html"|' /etc/httpd/conf/httpd.conf
sudo sed -i 's|<Directory "/var/www/my_new_site">|<Directory "/var/www/html">|' /etc/httpd/conf/httpd.conf

echo "디렉터리 리스팅 설정 시작"
# 35
# Apache 설정 파일 경로 설정
APACHE_CONF="/etc/httpd/conf/httpd.conf"

# 디렉터리 리스팅 활성화
if grep -q "Options" $APACHE_CONF && ! grep -q "Options.*Indexes" $APACHE_CONF; then
    # Options 지시어에 Indexes 옵션이 없는 경우 추가 (Options 뒤에 오는 모든 내용 포함)
    sudo sed -i '/Options/ s/$/ Indexes/' $APACHE_CONF
    echo "Apache 디렉터리 리스팅을 활성화했습니다."
else
    echo "Apache 디렉터리 리스팅이 이미 활성화되어 있거나, 적절한 Options 지시어를 찾을 수 없습니다."
fi

# 40

# Apache 설정에서 파일 다운로드 제한을 매우 큰 값으로 설정
sudo sed -i 's/^\(LimitRequestBody \).*/\1104857600/' /etc/httpd/conf/httpd.conf

# PHP 설정에서 파일 업로드 제한을 매우 큰 값으로 설정
sudo sed -i 's/^\(post_max_size = \).*/\11024M/' /etc/php.ini
sudo sed -i 's/^\(upload_max_filesize = \).*/\11024M/' /etc/php.ini

echo "Apache 서버와 PHP의 파일 업로드 및 다운로드 용량을 넘기기 완료"

# Apache 재시작
echo "설정 변경을 적용하기 위해 Apache를 재시작합니다..."
sudo systemctl restart httpd
echo "Apache 설정 변경이 완료되었습니다."

echo

