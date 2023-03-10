/**
 * ICOファイルに関する共通処理
 *
 * Author: $(LINK2 https://twitter.com/dokutoku3, dokutoku)
 * License: $(LINK2 https://creativecommons.org/publicdomain/zero/1.0/, CC0 1.0 Universal)
 */
module remove_shortcut_arrow.registory;


version (NON_WINREG) {
} else {
	version = IS_WINREG;
}

version (Windows) {
	version (IS_WINREG) {
		pragma(lib, "advapi32");

		private static import core.sys.windows.w32api;
		private static import core.sys.windows.winbase;
		private static import core.sys.windows.windef;
		private static import core.sys.windows.winerror;
		private static import core.sys.windows.winnt;
		private static import core.sys.windows.winreg;

		static assert(core.sys.windows.w32api._WIN32_WINNT >= 0x502);

		/**
		 * WindowsレジストリのHKEY
		 */
		public enum windows_shortcut_arrow_hKey = core.sys.windows.winreg.HKEY_LOCAL_MACHINE;

		/**
		 * Windowsレジストリのキーのタイプ
		 */
		public enum windows_shortcut_arrow_dwType = core.sys.windows.winreg.REG_EXPAND_SZ;
	}
}

/**
 * Windowsレジストリのサブキーの名前
 */
public enum windows_shortcut_arrow_SubKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Icons\0"w;

/**
 * Windowsレジストリの値の名前
 */
public enum windows_shortcut_arrow_ValueName = "29\0"w;

/**
 * レジストリにICOファイルのPATHを登録する。
 */
version (Windows)
version (IS_WINREG)
extern (C)
nothrow @nogc
public bool add_registory(const core.sys.windows.winnt.LPCWSTR ico_path)

	do
	{
		core.sys.windows.windef.HKEY hkResult = void;

		core.sys.windows.windef.DWORD cbData = cast(core.sys.windows.windef.DWORD)(core.sys.windows.winbase.lstrlenW(ico_path) * wchar.sizeof);

		if (cbData < 1) {
			return false;
		}

		core.sys.windows.windef.LONG result = core.sys.windows.winreg.RegCreateKeyExW(.windows_shortcut_arrow_hKey, &(.windows_shortcut_arrow_SubKey[0]), 0, null, core.sys.windows.winnt.REG_OPTION_NON_VOLATILE, core.sys.windows.winnt.KEY_SET_VALUE | core.sys.windows.winnt.KEY_WOW64_64KEY, null, &hkResult, null);

		if (result != core.sys.windows.winerror.ERROR_SUCCESS) {
			return false;
		}

		if (core.sys.windows.winreg.RegSetValueExW(hkResult, &(.windows_shortcut_arrow_ValueName[0]), 0, .windows_shortcut_arrow_dwType, cast(const (core.sys.windows.windef.BYTE)*)(ico_path), cbData) != core.sys.windows.winerror.ERROR_SUCCESS) {
			core.sys.windows.winreg.RegCloseKey(hkResult);

			return false;
		}

		return core.sys.windows.winreg.RegCloseKey(hkResult) == core.sys.windows.winerror.ERROR_SUCCESS;
	}

/**
 * レジストリの特定の値を削除する
 */
version (Windows)
version (IS_WINREG)
extern (C)
nothrow @nogc
public bool delete_registory()

	do
	{
		core.sys.windows.windef.HKEY hkResult = void;

		core.sys.windows.windef.LONG result = core.sys.windows.winreg.RegOpenKeyExW(.windows_shortcut_arrow_hKey, &(.windows_shortcut_arrow_SubKey[0]), 0, core.sys.windows.winnt.KEY_SET_VALUE | core.sys.windows.winnt.KEY_WOW64_64KEY, &hkResult);

		if (result != core.sys.windows.winerror.ERROR_SUCCESS) {
			return false;
		}

		if (core.sys.windows.winreg.RegDeleteValueW(hkResult, &(.windows_shortcut_arrow_ValueName[0])) != core.sys.windows.winerror.ERROR_SUCCESS) {
			core.sys.windows.winreg.RegCloseKey(hkResult);

			return false;
		}

		return core.sys.windows.winreg.RegCloseKey(hkResult) == core.sys.windows.winerror.ERROR_SUCCESS;
	}
