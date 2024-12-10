@echo off
setlocal

cd "%~dp0"
:: Установка кодировки в UTF-8
chcp 65001
set OLLAMA_HOST=http://localhost:11434

echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Проверка зависимостей Python, Ollama, Open-Webui
:: Проверка наличия Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo Python не найден. Скачиваем и устанавливаем Python 3.11.7...
    powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe -OutFile python-3.11.7-amd64.exe"
    start /wait python-3.11.7-amd64.exe /quiet InstallAllUsers=1 PrependPath=1
    where python >nul 2>&1
    if %errorlevel% neq 0 (
	    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        echo Ошибка установки Python. Установите вручную: https://www.python.org/downloads/
        goto :eof
    )
)

:: Проверка наличия Ollama
where ollama >nul 2>&1
if %errorlevel% neq 0 (
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo Ollama не найден. Скачиваем и устанавливаем Ollama...
    powershell -Command "Invoke-WebRequest -Uri https://ollama.com/download/OllamaSetup.exe -OutFile OllamaSetup.exe"
    start /wait OllamaSetup.exe
    where ollama >nul 2>&1
    if %errorlevel% neq 0 (
	    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        echo Ошибка установки Ollama. Установите вручную: https://ollama.com/download/
        goto :eof
    )
)

:: Проверка наличия Open-WebUI
where open-webui >nul 2>&1
if %errorlevel% neq 0 (
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo Open-WebUI не найден. Пробуем установить...
    pip install open-webui
    if %errorlevel% neq 0 (
	    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        echo Ошибка установки Open-WebUI. Убедитесь, что pip установлен и работает.
        goto :eof
    )
)

echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Запуск Ollama
start "ollama serve" /b cmd /c "ollama serve"
:: Ожидание запуска ollama
timeout /t 7 >nul

echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Запуск Open-WebUI
start "open-webui" /b cmd /c open-webui serve ^> server.log

:: Ожидание готовности сервера (поиск строки в логах)
:wait_loop
timeout /t 1 >nul
findstr /m "Uvicorn running on http://0.0.0.0:8080" server.log && goto start_browser || goto wait_loop

:start_browser
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Открываем браузер
start http://localhost:8080

:: Поиск и закрытие всех процессов, содержащих 'ollama' и 'open-webui'
taskkill /fi "imagename eq *ollama*" /f >nul 2>&1
taskkill /fi "imagename eq *open-webui*" /f >nul 2>&1

endlocal

