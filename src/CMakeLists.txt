cmake_minimum_required(VERSION 3.10)
project(hello_world)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SOCI_LIBRARY /usr/local/lib/soci/libsoci_core.so)
set(SOCI_POSTGRESQL_LIBRARY /usr/local/lib/soci/libsoci_postgresql.so)
set(SOCI_INCLUDE_DIR /usr/local/include)

set(CLICKHOUSE_CPP_LIBRARY /usr/local/lib/libclickhouse-cpp-lib.so)
#set(CLICKHOUSE_CPP_INCLUDE /usr/local/include)

# Найти SOCI
find_library(SOCI_LIBRARY NAMES soci_core)
find_library(SOCI_POSTGRESQL_LIBRARY NAMES soci_postgresql)
find_path(SOCI_INCLUDE_DIR soci/soci.h)

# Найти clickhouse-cpp
find_library(CLICKHOUSE_CPP_LIBRARY NAMES clickhouse_cpp)
#find_path(CLICKHOUSE_CPP_INCLUDE clickhouse)

# Найти PostgreSQL
find_package(PostgreSQL REQUIRED)

add_executable(main main.cpp)

# Линковка с библиотеками
target_include_directories(main PRIVATE ${SOCI_INCLUDE_DIR} ${PostgreSQL_INCLUDE_DIRS})
target_link_libraries(main PRIVATE ${SOCI_LIBRARY} ${SOCI_POSTGRESQL_LIBRARY} ${PostgreSQL_LIBRARIES} ${CLICKHOUSE_CPP_LIBRARY})

