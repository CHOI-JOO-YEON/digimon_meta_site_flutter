@echo off
echo === 모바일 웹 테스트 환경 시작 ===
echo.

rem 에뮬레이터 시작
echo 1. Android 에뮬레이터 시작 중...
start /b flutter emulators --launch Resizable_Experimental_API_34
echo 에뮬레이터 부팅을 기다리는 중...
timeout /t 10 /nobreak > nul

rem Flutter 웹 서버 시작
echo 2. Flutter 웹 서버 시작 중 (포트 50000)...
start "Flutter Web Server" cmd /c "flutter run -d web-server --web-hostname=0.0.0.0 --web-port=50000"

echo.
echo === 테스트 방법 ===
echo 1. 에뮬레이터가 완전히 부팅될 때까지 기다립니다.
echo 2. 에뮬레이터에서 Chrome 앱을 엽니다.
echo 3. 다음 URL로 접속합니다: http://10.0.2.2:50000
echo.
echo 접속이 안 될 경우, 호스트 IP로 시도해보세요: http://{호스트IP}:50000
echo.
echo 종료하려면 이 창과 Flutter 서버 창을 닫으세요.
echo. 