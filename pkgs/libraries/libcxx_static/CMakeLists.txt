cmake_minimum_required(VERSION 3.2)
project(c++_static)

include(bundle_static_library.cmake)

find_library(LIBCXX_LIBRARY NAMES c++ cxx REQUIRED)
find_library(LIBCXXABI_LIBRARY NAMES c++abi REQUIRED)

add_library(libc++ STATIC IMPORTED GLOBAL)
set_target_properties(libc++ PROPERTIES IMPORTED_LOCATION ${LIBCXX_LIBRARY})

add_library(libc++abi STATIC IMPORTED GLOBAL)
set_target_properties(libc++abi PROPERTIES IMPORTED_LOCATION ${LIBCXXABI_LIBRARY})

add_library(libc++_unbundled STATIC dummy.cpp)
target_link_libraries(libc++_unbundled libc++)
target_link_libraries(libc++_unbundled libc++abi)

bundle_static_library(libc++_unbundled c++_static)
