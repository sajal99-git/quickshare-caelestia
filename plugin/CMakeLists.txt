cmake_minimum_required(VERSION 3.19)
project(qs-quickshare LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Network DBus)
find_package(Protobuf REQUIRED)
find_package(OpenSSL REQUIRED)
qt_standard_project_setup()

protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS
    src/proto/device_to_device_messages.proto
    src/proto/offline_wire_formats.proto
    src/proto/securegcm.proto
    src/proto/securemessage.proto
    src/proto/ukey.proto
    src/proto/wire_format.proto
)
set_source_files_properties(${PROTO_SRCS} ${PROTO_HDRS} PROPERTIES SKIP_AUTOMOC ON SKIP_AUTOGEN ON)

qt_add_qml_module(qsquickshare
    URI QSExt.QuickShare
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/QSExt/QuickShare
    SOURCES
        src/QuickShareDiscovery.cpp src/QuickShareDiscovery.hpp
        src/QuickShareCrypto.cpp src/QuickShareCrypto.hpp
        src/QuickShareConnection.cpp src/QuickShareConnection.hpp
        src/quickshare_service.cpp src/quickshare_service.hpp
        ${PROTO_SRCS}
)
target_include_directories(qsquickshare PRIVATE src ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(qsquickshare PRIVATE
    Qt6::Core Qt6::Qml Qt6::Network Qt6::DBus
    protobuf::libprotobuf OpenSSL::Crypto OpenSSL::SSL)
