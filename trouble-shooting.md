# Troubleshooting

## revu.copy-money.com 서버 설정 가이드

WSL2 환경에서 Nginx + Let's Encrypt로 서브도메인을 설정하는 과정의 트러블슈팅 기록입니다.

---

## 환경

- **OS**: WSL2 (Ubuntu) on Windows
- **Web Server**: Nginx 1.18.0
- **SSL**: Let's Encrypt (certbot)
- **포트포워딩**: Windows netsh → WSL2 → Nginx

---

## 발생했던 문제들

### 1. certbot이 nginx 설정을 자동으로 업데이트하지 못함

**증상**: certbot 실행 후 `Could not install certificate` 오류

**원인**: `sites-enabled`에 심볼릭 링크가 없어 certbot이 nginx 서버 블록을 찾지 못함

**해결**: 인증서를 발급 후 nginx 설정에 수동으로 SSL 블록 추가
```nginx
ssl_certificate /etc/letsencrypt/live/revu.copy-money.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/revu.copy-money.com/privkey.pem;
include /etc/letsencrypt/options-ssl-nginx.conf;
ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
```

---

### 2. revu.copy-money.com 요청이 copy-money.com으로 라우팅됨

**증상**: nginx 로그에서 `host: revu.copy-money.com`인데 `server: copy-money.com`으로 처리됨

**원인**: `sites-enabled`에 `revu.copy-money.com` 심볼릭 링크가 없어 nginx가 서버 블록을 인식하지 못함

**해결**:
```bash
cd /etc/nginx/sites-enabled
sudo ln -sf ../sites-available/revu.copy-money.com .
sudo systemctl restart nginx
```

---

### 3. 긴 경로 복사-붙여넣기 시 줄바꿈 문제

**증상**: `sudo ln -sf /etc/nginx/sites-available/revu.copy-money.com /etc/nginx/sites-enabled/revu.copy-money.com` 명령이 터미널에서 잘림

**해결**: `cd`로 이동 후 상대경로 사용
```bash
cd /etc/nginx/sites-enabled
sudo ln -sf ../sites-available/revu.copy-money.com .
```

---

### 4. Nginx 403 Forbidden (Document Root 접근 불가)

**증상**: SSL 설정 후 모든 요청에서 404 반환

**원인**: `/home/seung/` 디렉토리 권한이 `750`이라 www-data(nginx)가 접근 불가

**해결**:
```bash
chmod o+x /home/seung
```

---

## Nginx 설정 파일

```nginx
# /etc/nginx/sites-available/revu.copy-money.com

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
}
```

---

## WSL2 포트포워딩

WSL2 IP는 재시작마다 변경되므로 포트포워딩을 다시 설정해야 할 수 있음:

```bash
~/wsl-port-forward.sh add
```

**공유기 포트포워딩**: 외부 80, 443 → Windows PC 내부 IP (192.168.55.103)

**Windows → WSL**: `netsh portproxy` 로 80, 443 → WSL IP 포워딩
