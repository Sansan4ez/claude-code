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

2. Загрузите переменные перед запуском VS Code:

```bash
source .env && code .
```

## Использование в контейнере

После настройки переменных доступны команды:

```bash
# Проверить статус
proxy-status

# Включить прокси
proxy-on

# Отключить прокси
proxy-off

# Переключить состояние
proxy-toggle

# Тест соединения
proxy-test

# Запустить команду без прокси
no-proxy curl https://google.com
```

## Автозагрузка алиасов

Добавьте в ~/.zshrc:

```bash
echo 'source /workspace/.devcontainer/proxy-aliases.sh' >> ~/.zshrc
```
