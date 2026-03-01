#!/bin/bash
# revu.copy-money.com Nginx + SSL 설정 스크립트
set -euo pipefail

DOMAIN="revu.copy-money.com"
DOC_ROOT="/home/seung/sg/revu-docs/docs"
CONF_FILE="/etc/nginx/sites-available/${DOMAIN}"

echo "=== [1/5] Document root 권한 설정 ==="
chmod o+x /home/seung

echo "=== [2/5] Nginx 설정 파일 생성 ==="
sudo tee "${CONF_FILE}" > /dev/null <<'EOF'
server {
    listen 80;
    server_name revu.copy-money.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name revu.copy-money.com;
    root /home/seung/sg/revu-docs/docs;
    index index.html;

    ssl_certificate /etc/letsencrypt/live/revu.copy-money.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/revu.copy-money.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        try_files $uri $uri.html $uri/ =404;
    }

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_min_length 256;

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location ~ /\. {
        deny all;
    }
}
EOF

echo "=== [3/5] Sites-enabled 심볼릭 링크 ==="
cd /etc/nginx/sites-enabled
sudo ln -sf "../sites-available/${DOMAIN}" .

echo "=== [4/5] SSL 인증서 발급 (certbot) ==="
sudo certbot certonly --nginx -d "${DOMAIN}"

echo "=== [5/5] Nginx 테스트 & 재시작 ==="
sudo nginx -t && sudo systemctl restart nginx

echo ""
echo "========================================"
echo " 완료! https://${DOMAIN} 접속 확인"
echo "========================================"
