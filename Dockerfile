# ===================================================================================================
# Базовай образ первого этапа сборки
# ===================================================================================================
FROM alpine:3.21.3 AS builder

ARG SOCI_VERSION=4.1.0-rc1
ARG CLICKHOUSE_CPP_VERSION=2.5.1

# Устанавка необходимых пакетов для сборки C++ проекта
RUN apk add --no-cache --update \
    cmake \
    g++ \
    make \
    libpq-dev \
    postgresql-dev \
    zlib-dev \
    lz4-dev \
    openssl-dev \
    icu-data-full \
    abseil-cpp-dev

# Создание директории для сборки библиотек
WORKDIR /libs

# Загрузка и распаковка исходников драйвера SOCI
RUN wget https://github.com/SOCI/soci/archive/refs/tags/v${SOCI_VERSION}.tar.gz -O soci-${SOCI_VERSION}.tar.gz \
 && tar xzf soci-${SOCI_VERSION}.tar.gz

# Сборка SOCI
WORKDIR /libs/soci-${SOCI_VERSION}
RUN mkdir build
WORKDIR /libs/soci-${SOCI_VERSION}/build
RUN cmake .. \
    -DSOCI_TESTS=OFF \
    -DSOCI_EMPTY=OFF \
    -DSOCI_POSTGRESQL=ON \
    -DSOCI_MYSQL=OFF \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
 && make \
 && make install

# Загрузка и распаковка исходников драйвера clickhouse-cpp
WORKDIR /libs
RUN wget https://github.com/ClickHouse/clickhouse-cpp/archive/refs/tags/v${CLICKHOUSE_CPP_VERSION}.tar.gz -O clickhouse-cpp.tar.gz \
 && tar -xzf clickhouse-cpp.tar.gz

# Сборка clickhouse-cpp
WORKDIR /libs/clickhouse-cpp-${CLICKHOUSE_CPP_VERSION}
RUN mkdir build
WORKDIR /libs/clickhouse-cpp-${CLICKHOUSE_CPP_VERSION}/build
RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
 && make \
 && make install

# Создание рабочей директории
WORKDIR /src

# Копирование исходных файлов проекта
COPY src/. .

# Создание директории для сборки проекта
WORKDIR /src/build

# Сборка проекта
RUN cmake .. \
 && make

# ==================================================================================================
# Этап финального образа
# ==================================================================================================
FROM alpine:3.21.3 AS final

# Устанавка необходимых зависимостей для запуска приложения
RUN apk add --no-cache --update \
    libpq \
    libstdc++ \
    abseil-cpp

# Копирование исполняемого файла, собранного на первом этапе
COPY --from=builder /src/build/main /app/

# Копирование библиотек, собранных на первом этапе
COPY --from=builder /usr/local/lib/soci/libsoci_core.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/soci/libsoci_postgresql.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/libclickhouse-cpp-lib.so /usr/local/lib/
COPY --from=builder /usr/local/include/clickhouse /usr/local/include/clickhouse

# Устанавливаем точку входа для контейнера
ENTRYPOINT ["/app/main"]
