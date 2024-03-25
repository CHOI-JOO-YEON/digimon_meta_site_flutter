# 베이스 이미지로 Ubuntu를 사용합니다.
FROM ubuntu:22.04

# 필요한 패키지를 설치합니다.
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    lib32stdc++6 \
    libglu1-mesa



# Flutter SDK를 다운로드하고 설치합니다.
#RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz
#RUN tar xf flutter_linux_3.16.9-stable.tar.xz
#ENV PATH="/flutter/bin:${PATH}"


RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
RUN tar xf flutter_linux_3.19.0-stable.tar.xz
ENV PATH="/flutter/bin:${PATH}"


RUN git config --global --add safe.directory /flutter
# Flutter 설치 경로를 출력합니다.
RUN echo $PATH

# Dart SDK 버전을 확인합니다.
RUN flutter --version

# 작업 디렉토리를 설정합니다.
WORKDIR /app

# 프로젝트의 pubspec.yaml 파일을 복사합니다.
COPY pubspec.yaml .

RUN flutter pub cache repair

# 프로젝트의 의존성을 가져옵니다.
RUN flutter pub get

# 프로젝트의 소스 코드를 복사합니다.
COPY . .

RUN flutter clean

# Flutter 웹 애플리케이션을 빌드합니다.
RUN flutter build web

# 컨테이너가 시작될 때 웹 서버를 실행합니다.
CMD ["sh", "-c", "flutter run --release -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=SERVER_URL=${SERVER_URL}"]