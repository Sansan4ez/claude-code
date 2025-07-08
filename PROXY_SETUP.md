# Настройка Proxy в DevContainer

## Безопасная настройка без коммита паролей в git

### Вариант 1: Переменные окружения хоста (рекомендуется)

Установите переменные на хост-машине:

```bash
# Linux/macOS
export PROXY_SERVER="http://username:password@proxy.company.com:8080"
export HTTP_PROXY="$PROXY_SERVER"
export HTTPS_PROXY="$PROXY_SERVER"
export NO_PROXY="localhost,127.0.0.1,.local,.company.com"

# Добавить в ~/.bashrc или ~/.zshrc для постоянства
echo 'export PROXY_SERVER="http://username:password@proxy.company.com:8080"' >> ~/.bashrc
```

```powershell
# Windows PowerShell
$env:PROXY_SERVER = "http://username:password@proxy.company.com:8080"
$env:HTTP_PROXY = $env:PROXY_SERVER
$env:HTTPS_PROXY = $env:PROXY_SERVER
$env:NO_PROXY = "localhost,127.0.0.1,.local,.company.com"
```

### Вариант 2: Локальный .env файл

1. Создайте файл `.env` в корне проекта (он исключен из git):

```bash
PROXY_SERVER=http://username:password@proxy.company.com:8080
HTTP_PROXY=http://username:password@proxy.company.com:8080
HTTPS_PROXY=http://username:password@proxy.company.com:8080
NO_PROXY=localhost,127.0.0.1,.local,.company.com
```

2. Загрузите переменные:

```bash
source .env
```

## Использование в контейнере

После настройки переменных доступны команды:

```bash
# Загрузите переменные
source .env
# Добавить в ~/.zshrc для постоянства
echo 'source /workspace/.devcontainer/proxy-aliases.sh' >> ~/.zshrc
# Перезагрузить конфигурацию
source ~/.zshrc

# Доступные команды:
proxy-config    # ✅ Показать конфигурацию
proxy-on        # ✅ Включить proxy
proxy-off       # ✅ Отключить proxy
proxy-toggle    # ✅ Переключить proxy
proxy-status    # ✅ Показать переменные
proxy-test      # ✅ Тестировать соединение
proxy-reload    # ✅ Перезагрузить .env
no-proxy <cmd>  # ✅ Выполнить команду без proxy
```
