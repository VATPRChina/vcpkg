vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if ("docking-experimental" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ocornut/imgui
        REF "v${VERSION}-docking"
        SHA512 16aa9adc5e2a753a1c3a6fe121db6920755160f42793d8726fc6a69006f56b1316302820b9429671bce763fef6fc2b2dda0e09fbacdbf54cdd1680ec8a62165a 
        HEAD_REF docking
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ocornut/imgui
        REF "v${VERSION}"
        SHA512 5656fe355b90c9fdfbb425a26db0e7c62f8f8705f005d40950181d14a9dc05dbca66cf297ff903c510195a99f4408dbc50528103efcbc5970affb0dda9e52b25
        HEAD_REF master
    )
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/imgui-config.cmake.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
    allegro5-binding            IMGUI_BUILD_ALLEGRO5_BINDING
    android-binding             IMGUI_BUILD_ANDROID_BINDING
    dx9-binding                 IMGUI_BUILD_DX9_BINDING
    dx10-binding                IMGUI_BUILD_DX10_BINDING
    dx11-binding                IMGUI_BUILD_DX11_BINDING
    dx12-binding                IMGUI_BUILD_DX12_BINDING
    glfw-binding                IMGUI_BUILD_GLFW_BINDING
    glut-binding                IMGUI_BUILD_GLUT_BINDING
    metal-binding               IMGUI_BUILD_METAL_BINDING
    opengl2-binding             IMGUI_BUILD_OPENGL2_BINDING
    opengl3-binding             IMGUI_BUILD_OPENGL3_BINDING
    osx-binding                 IMGUI_BUILD_OSX_BINDING
    sdl3-binding                IMGUI_BUILD_SDL3_BINDING
    sdlgpu3-binding             IMGUI_BUILD_SDLGPU3_BINDING
    sdl3-renderer-binding       IMGUI_BUILD_SDL3_RENDERER_BINDING
    vulkan-binding              IMGUI_BUILD_VULKAN_BINDING
    win32-binding               IMGUI_BUILD_WIN32_BINDING
    freetype                    IMGUI_FREETYPE
    freetype-svg                IMGUI_FREETYPE_SVG
    wchar32                     IMGUI_USE_WCHAR32
    test-engine                 IMGUI_TEST_ENGINE
)

if ("libigl-imgui" IN_LIST FEATURES)
    vcpkg_download_distfile(
        IMGUI_FONTS_DROID_SANS_H
        URLS
            https://raw.githubusercontent.com/libigl/libigl-imgui/c3efb9b62780f55f9bba34561f79a3087e057fc0/imgui_fonts_droid_sans.h
        FILENAME "imgui_fonts_droid_sans.h"
        SHA512
            abe9250c9a5989e0a3f2285bbcc83696ff8e38c1f5657c358e6fe616ff792d3c6e5ff2fa23c2eeae7d7b307392e0dc798a95d14f6d10f8e9bfbd7768d36d8b31
    )

    file(INSTALL "${IMGUI_FONTS_DROID_SANS_H}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endif()

if ("test-engine" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH TEST_ENGINE_SOURCE_PATH
        REPO ocornut/imgui_test_engine
        REF "v${VERSION}"
        SHA512 44d6fd1c26c9c2cb3fcbd1560dba8e056f84dc170051dcb8db5d642945fb26475006a8166486f7f62e900a97d65f2f98d364ac06c121a57309b3229cc41556a4
        HEAD_REF master
    )

    file(REMOVE_RECURSE "${SOURCE_PATH}/test-engine")
    file(COPY "${TEST_ENGINE_SOURCE_PATH}/imgui_test_engine/" DESTINATION "${SOURCE_PATH}/test-engine")
    file(REMOVE_RECURSE "${SOURCE_PATH}/test-engine/thirdparty/stb")
    vcpkg_replace_string("${SOURCE_PATH}/test-engine/imgui_capture_tool.cpp" "//#define IMGUI_STB_IMAGE_WRITE_FILENAME \"my_folder/stb_image_write.h\"" "#define IMGUI_STB_IMAGE_WRITE_FILENAME <stb_image_write.h>\n#define STB_IMAGE_WRITE_STATIC")
    vcpkg_replace_string("${SOURCE_PATH}/imconfig.h" "#pragma once" "#pragma  once\n\n#include \"imgui_te_imconfig.h\"")
    vcpkg_replace_string("${SOURCE_PATH}/test-engine/imgui_te_imconfig.h" "#define IMGUI_TEST_ENGINE_ENABLE_COROUTINE_STDTHREAD_IMPL 0" "#define IMGUI_TEST_ENGINE_ENABLE_COROUTINE_STDTHREAD_IMPL 1")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_cmake_install()

if ("freetype" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imconfig.h" "//#define IMGUI_ENABLE_FREETYPE\n" "#define IMGUI_ENABLE_FREETYPE\n")
endif()
if ("freetype-svg" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imconfig.h" "//#define IMGUI_ENABLE_FREETYPE_PLUTOSVG" "#define IMGUI_ENABLE_FREETYPE_PLUTOSVG")
endif()
if ("wchar32" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imconfig.h" "//#define IMGUI_USE_WCHAR32" "#define IMGUI_USE_WCHAR32")
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

if ("test-engine" IN_LIST FEATURES)
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt" "${SOURCE_PATH}/test-engine/LICENSE.txt")
else()
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
endif()
