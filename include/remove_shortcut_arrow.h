#ifndef REMOVE_SHORTCUT_ARROW_H
#define REMOVE_SHORTCUT_ARROW_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef _WINDOWS_
#include <windef.h>

#ifndef NON_WINREG
#include <winreg.h>
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WINDOWS_
#ifndef NON_WINREG
#define windows_shortcut_arrow_hKey HKEY_LOCAL_MACHINE
#define windows_shortcut_arrow_dwType REG_EXPAND_SZ

bool add_registory(LPCWSTR ico_path);
bool delete_registory(void);

bool remove_windows_shortcut_arrow(void);
bool restore_windows_shortcut_arrow(void);
#endif

#define windows_shortcut_arrow_SubKey L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Icons"

#define windows_shortcut_arrow_ValueName L"29"

#define REG_PRE_ADD_COMMAND L"reg.exe add \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Icons\" /f /v 29 /t REG_EXPAND_SZ /reg:64 /d "
#define REG_ADD_COMMAND_BUFFER_LENGTH (133 + 1 + (2 * 2) + MAX_PATH + 1024)

#define REG_DELETE_COMMAND L"reg.exe delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Icons\" /f /v 29 /reg:64"
#define REG_DELETE_COMMAND_BUFFER_LENGTH (115 + 1 + 2 + MAX_PATH)

bool copy_remove_windows_shortcut_arrow_command(WCHAR* command_buffer, size_t buffer_size, LPCWSTR ico_path);
bool copy_restore_windows_shortcut_arrow_command(WCHAR* command_buffer, size_t buffer_size);

bool exec_remove_windows_shortcut_arrow_command(LPCWSTR ico_path);
bool exec_restore_windows_shortcut_arrow_command(void);

bool reg_remove_windows_shortcut_arrow(void);
bool reg_restore_windows_shortcut_arrow(void);

bool exec_clear_icon_cache(void);
#endif

size_t copy_windows_no_arrow_ico(uint8_t* output_buffer, size_t buffer_size);

#ifdef __cplusplus
}
#endif

#endif
