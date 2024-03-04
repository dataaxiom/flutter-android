FROM ubuntu:22.04

ARG VERSION=3.19.2

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && \
    apt-get install --no-install-recommends -y curl wget unzip xz-utils git openjdk-17-jdk-headless libglu1-mesa lib32stdc++6 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt

RUN mkdir -p /opt/android && cd /opt/android && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip && \
    mv cmdline-tools latest && \
    mkdir cmdline-tools && \
    mv latest cmdline-tools

ENV ANDROID_HOME /opt/android
ENV PATH "${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"

# accept the license agreements of the SDK components
RUN yes | sdkmanager --licenses

RUN sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"

ENV FLUTTER_FILE "flutter_linux_${IMAGE_VERSION_TAG}-stable.tar.xz"
ENV PATH "/opt/flutter/bin:${PATH}"

RUN cd /opt && \
    curl -s --output - https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${VERSION}-stable.tar.xz  | tar xJf - -C /opt

RUN git config --global --add safe.directory /opt/flutter && \
    flutter config --no-analytics && \
    flutter config --enable-android && \
    flutter config --no-enable-web && \
    flutter config --no-enable-linux-desktop && \
    flutter doctor --android-licenses && \
    flutter precache && \
    flutter doctor && \
    dart --disable-analytics

