#!/bin/bash
# WSL2 포트 포워딩 자동화 스크립트
# Windows의 netsh를 사용하여 호스트 -> WSL2 포트 포워딩 설정

set -euo pipefail

# ======== 설정 ========
PORTS=(80 443)
# ======================

WSL_IP=$(hostname -I | awk '{print $1}')

if [ -z "$WSL_IP" ]; then
    echo "[ERROR] WSL IP를 가져올 수 없습니다."
    exit 1
fi

echo "WSL IP: $WSL_IP"
echo "포워딩 포트: ${PORTS[*]}"
echo ""

show_status() {
    echo "=== 현재 포트 프록시 상태 ==="
    netsh.exe interface portproxy show v4tov4 2>/dev/null | sed 's/\r$//'
    echo ""
}

add_forwarding() {
    echo "=== 포트 포워딩 추가 ==="
    for PORT in "${PORTS[@]}"; do
        echo "  [+] 0.0.0.0:${PORT} -> ${WSL_IP}:${PORT}"
        netsh.exe interface portproxy add v4tov4 \
            listenport="$PORT" listenaddress=0.0.0.0 \
            connectport="$PORT" connectaddress="$WSL_IP" 2>/dev/null
    done
    echo ""

    echo "=== 방화벽 규칙 추가 ==="
    PORTS_STR=$(IFS=,; echo "${PORTS[*]}")
    powershell.exe -Command "
        Remove-NetFirewallRule -DisplayName 'WSL2 Port Forward' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'WSL2 Port Forward' -Direction Inbound -Action Allow -Protocol TCP -LocalPort ${PORTS_STR}
    " 2>/dev/null
    echo "  [+] 방화벽 인바운드 규칙 추가 완료 (TCP: ${PORTS_STR})"
    echo ""
}

remove_forwarding() {
    echo "=== 포트 포워딩 제거 ==="
    for PORT in "${PORTS[@]}"; do
        echo "  [-] 0.0.0.0:${PORT}"
        netsh.exe interface portproxy delete v4tov4 \
            listenport="$PORT" listenaddress=0.0.0.0 2>/dev/null || true
    done
    powershell.exe -Command "
        Remove-NetFirewallRule -DisplayName 'WSL2 Port Forward' -ErrorAction SilentlyContinue
    " 2>/dev/null
    echo "  [-] 방화벽 규칙 제거 완료"
    echo ""
}

usage() {
    echo "사용법: $0 {add|remove|status}"
    echo ""
    echo "  add     포트 포워딩 추가"
    echo "  remove  포트 포워딩 제거"
    echo "  status  현재 상태 확인"
}

case "${1:-add}" in
    add)    add_forwarding; show_status ;;
    remove) remove_forwarding; show_status ;;
    status) show_status ;;
    *)      usage ;;
esac
