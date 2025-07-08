#!/bin/bash
# Proxy management aliases and functions

# Очищаем любые существующие aliases для предотвращения конфликтов
unalias proxy-off 2>/dev/null || true
unalias proxy-on 2>/dev/null || true
unalias proxy-toggle 2>/dev/null || true
unalias proxy-status 2>/dev/null || true

# Загрузка переменных из .env файла
load_env() {
    local env_file="/workspace/.env"
    if [ -f "$env_file" ]; then
        # Экспортируем переменные из .env
        export $(cat "$env_file" | grep -v '^#' | grep -v '^$' | xargs)
        echo "📁 Loaded environment variables from .env"
    else
        echo "⚠️  .env file not found at $env_file"
        return 1
    fi
}

# Проверка наличия переменных proxy
check_proxy_config() {
    # Сначала попробуем загрузить .env, если переменных нет
    if [ -z "$PROXY_SERVER" ] && [ -z "$HTTP_PROXY" ]; then
        echo "🔄 Attempting to load proxy config from .env..."
        load_env
    fi

    if [ -z "$PROXY_SERVER" ] && [ -z "$HTTP_PROXY" ]; then
        echo "⚠️  Proxy not configured. Set PROXY_SERVER or HTTP_PROXY environment variable"
        echo "   Example: export PROXY_SERVER='http://user:pass@proxy.company.com:8080'"
        echo "   Or create .env file with PROXY_SERVER=http://user:pass@proxy.company.com:8080"
        return 1
    fi
    return 0
}

# Функция для отключения proxy
proxy-off() {
    unset PROXY_SERVER HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY no_proxy
    echo "🔴 Proxy DISABLED"
}

# Умный алиас proxy-on с проверкой переменных
proxy-on() {
    if ! check_proxy_config; then
        return 1
    fi

    # Используем PROXY_SERVER или HTTP_PROXY
    local proxy_url="${PROXY_SERVER:-$HTTP_PROXY}"

    export HTTP_PROXY="$proxy_url"
    export HTTPS_PROXY="$proxy_url"
    export http_proxy="$proxy_url"
    export https_proxy="$proxy_url"
    export NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,.local}"
    export no_proxy="${no_proxy:-localhost,127.0.0.1,.local}"

    echo "🟢 Proxy ENABLED: $proxy_url"
}

# Показать статус proxy
proxy-status() {
    env | grep -i proxy
}

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
    if curl -I --connect-timeout 5 --max-time 10 https://api.myip.com 2>/dev/null >/dev/null; then
        echo "✅ Connection OK"
        curl --connect-timeout 5 --max-time 10 https://api.myip.com
        echo ""
        if [ -n "$HTTP_PROXY" ]; then
            echo "   Via proxy: $HTTP_PROXY"
        else
            echo "   Direct connection"
        fi
    else
        echo "❌ Connection FAILED"
    fi
}

# Запуск команды без proxy
no-proxy() {
    env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy "$@"
}

# Показать конфигурацию proxy
proxy-config() {
    echo "=== Proxy Configuration ==="
    echo "PROXY_SERVER: ${PROXY_SERVER:-not set}"
    echo "HTTP_PROXY: ${HTTP_PROXY:-not set}"
    echo "HTTPS_PROXY: ${HTTPS_PROXY:-not set}"
    echo "NO_PROXY: ${NO_PROXY:-not set}"
    echo ""
    echo "=== Current Status ==="
    if [ -n "$HTTP_PROXY" ]; then
        echo "🟢 Proxy is ENABLED: $HTTP_PROXY"
    else
        echo "🔴 Proxy is DISABLED"
    fi
}

# Принудительная загрузка .env
proxy-reload() {
    echo "🔄 Reloading proxy configuration from .env..."
    load_env
    proxy-config
}