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
    echo Ошибка: Python не найден. Установите Python 3.11.7 и добавьте его в PATH.
	echo Скачать можно тут:
	echo https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe
    goto :eof
	pause
)
:: Проверка наличия Ollama
where ollama >nul 2>&1
if %errorlevel% neq 0 (
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo Ошибка: Ollama не найден в PATH. Убедитесь, что оно установлено.
	echo Скачать можно тут:
	echo https://ollama.com/download/OllamaSetup.exe
    goto :eof
	pause
)
:: Проверка наличия Open-Webui
where open-webui >nul 2>&1
if %errorlevel% neq 0 (
    echo Open-Webui не найден. Пробуем поставить.
    pip install open-webui
)
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Запуск Ollama
start "ollama serve" /b cmd /c "ollama serve"
:: Ожидание запуска процесса ollama serve (можно добавить задержку или проверку)
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