# revu-docs

REVU 서비스의 정적 문서 페이지 모음입니다.

## 사이트

- **URL**: https://revu.copy-money.com
- **호스팅**: WSL2 + Nginx + Let's Encrypt

## 페이지 목록

| 경로 | 파일 | 설명 |
|------|------|------|
| `/` | `docs/index.html` | 이메일 인증 완료 페이지 |
| `/pricing` | `docs/pricing.html` | 요금제 안내 |
| `/privacy` | `docs/privacy.html` | 개인정보처리방침 |
| `/terms` | `docs/terms.html` | 이용약관 |

## 서버 설정

- **Nginx 설정**: `/etc/nginx/sites-available/revu.copy-money.com`
- **SSL 인증서**: `/etc/letsencrypt/live/revu.copy-money.com/` (Let's Encrypt, 자동 갱신)
- **Document Root**: `/home/seung/sg/revu-docs/docs`

## 스크립트

| 파일 | 설명 |
|------|------|
| `scripts/setup-nginx.sh` | Nginx + SSL 초기 설정 (WSL에서 실행) |
| `scripts/wsl-port-forward.sh` | WSL2 포트포워딩 추가/제거/상태 확인 |
| `scripts/wsl2-portforward.ps1` | Windows 포트포워딩 자동 업데이트 |
| `scripts/register-portforward-task.ps1` | Windows 로그인 시 자동 포트포워딩 등록 (PowerShell 관리자) |

## 문제 해결

[trouble-shooting.md](./trouble-shooting.md) 참고
