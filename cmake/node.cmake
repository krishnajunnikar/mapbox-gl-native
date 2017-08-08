# Load Node.js
include(cmake/NodeJS.cmake)
nodejs_init()

add_nodejs_module(mbgl-node
    platform/node/src/node_mapbox_gl_native.cpp
)

# NodeJS.cmake forces C++11.
# https://github.com/cjntaylor/node-cmake/issues/18
set_target_properties("mbgl-node" PROPERTIES CXX_STANDARD 14)

target_sources(mbgl-node
    PRIVATE platform/default/async_task.cpp
    PRIVATE platform/default/run_loop.cpp
    PRIVATE platform/default/timer.cpp
    PRIVATE platform/node/src/node_logging.hpp
    PRIVATE platform/node/src/node_logging.cpp
    PRIVATE platform/node/src/node_map.hpp
    PRIVATE platform/node/src/node_map.cpp
    PRIVATE platform/node/src/node_request.hpp
    PRIVATE platform/node/src/node_request.cpp
    PRIVATE platform/node/src/node_feature.hpp
    PRIVATE platform/node/src/node_feature.cpp
    PRIVATE platform/node/src/node_thread_pool.hpp
    PRIVATE platform/node/src/node_thread_pool.cpp
    PRIVATE platform/node/src/util/async_queue.hpp
)

target_compile_options(mbgl-node
    PRIVATE -fPIC
    PRIVATE -fvisibility-inlines-hidden
)

target_include_directories(mbgl-node
    PRIVATE include
    PRIVATE src
    PRIVATE platform/default
)

# Use node-provided uv.h
target_include_directories(mbgl-loop-uv PUBLIC ${NODEJS_INCLUDE_DIRS})

target_link_libraries(mbgl-node
    PRIVATE mbgl-core
)

target_add_mason_package(mbgl-node PRIVATE geojson)

add_custom_command(
    TARGET mbgl-node
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:mbgl-node> ${CMAKE_SOURCE_DIR}/lib/mapbox_gl_native.node
)

mbgl_platform_node()

create_source_groups(mbgl-node)

xcode_create_scheme(
    TARGET mbgl-node
)

xcode_create_scheme(
    TARGET mbgl-node
    TYPE node
    NAME "node tests"
    ARGS
        "`npm bin tape`/tape platform/node/test/js/**/*.test.js"
)

xcode_create_scheme(
    TARGET mbgl-node
    TYPE node
    NAME "node render tests"
    ARGS
        "platform/node/test/render.test.js"
    OPTIONAL_ARGS
        "group"
        "test"
)

xcode_create_scheme(
    TARGET mbgl-node
    TYPE node
    NAME "node query tests"
    ARGS
        "platform/node/test/query.test.js"
    OPTIONAL_ARGS
        "group"
        "test"
)

xcode_create_scheme(
    TARGET mbgl-node
    TYPE node
    NAME "node-benchmark"
    ARGS
        "platform/node/test/benchmark.js"
    OPTIONAL_ARGS
        "group"
        "test"
)
