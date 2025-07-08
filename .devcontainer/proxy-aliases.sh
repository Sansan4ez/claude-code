#!/bin/bash
# Proxy management aliases and functions

# Функция проверки доступности прокси настроек
check_proxy_config() {
    if [ -z "$PROXY_SERVER" ] && [ -z "$HTTP_PROXY" ]; then
        echo "⚠️  Proxy not configured. Set PROXY_SERVER or HTTP_PROXY environment variable"
        echo "   Example: export PROXY_SERVER='http://user:pass@proxy.company.com:8080'"
        return 1
    fi
    return 0
}

# Алиасы для управления proxy
alias proxy-off='unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY no_proxy && echo "🔴 Proxy DISABLED"'

# Умный алиас для включения прокси
proxy-on() {
    if ! check_proxy_config; then
        return 1
    fi

    local proxy_url="${PROXY_SERVER:-$HTTP_PROXY}"
    export HTTP_PROXY="$proxy_url"
    export HTTPS_PROXY="$proxy_url"
    export http_proxy="$proxy_url"
    export https_proxy="$proxy_url"
    export NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,.local}"
    export no_proxy="${NO_PROXY:-localhost,127.0.0.1,.local}"

    echo "🟢 Proxy ENABLED: $proxy_url"
}

alias proxy-status='env | grep -i proxy'

# Функция переключения
proxy-toggle() {
    if [ -n "$HTTP_PROXY" ]; then
        # Proxy включен - отключаем
        proxy-off
    else
        # Proxy отключен - включаем
        proxy-on
    fi
}

# Быстрый тест соединения
proxy-test() {
    echo "Testing connection..."
    curl -I --connect-timeout 5 --max-time 10 https://google.com 2>/dev/null && echo "✅ Connection OK" || echo "❌ Connection FAILED"
}

# Запуск команды без proxy
no-proxy() {
    env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy "$@"
}