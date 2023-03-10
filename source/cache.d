/**
 * アイコンキャッシュをクリアする
 *
 * Author: $(LINK2 https://twitter.com/dokutoku3, dokutoku)
 * License: $(LINK2 https://creativecommons.org/publicdomain/zero/1.0/, CC0 1.0 Universal)
 */
module remove_shortcut_arrow.cache;


version (Windows):

private static import core.sys.windows.winbase;
private static import core.sys.windows.windef;
private static import core.sys.windows.winnt;
private static import remove_shortcut_arrow.command;
private static import remove_shortcut_arrow.path;

private enum pre_local_setting = "\\Local Settings\0"w;

private enum pre_application_data = "\\Application Data\0"w;

private enum pre_iconcachedb = "\\IconCache.db\0"w;

private enum iconcache_path_buffer_length = 1024 + "\0".length;

/**
 * 効果不明
 */
extern (C)
nothrow @nogc
public bool remove_current_user_iconcache()

	do
	{
		enum pre_str_length = (.pre_local_setting.length - "\0".length) + (.pre_application_data.length - "\0".length) + (.pre_iconcachedb.length - "\0".length);

		wchar[.iconcache_path_buffer_length] userprofile_path = void;

		if (core.sys.windows.winbase.GetEnvironmentVariableW(&("UserProfile\0"w[0]), &(userprofile_path[0]), cast(core.sys.windows.windef.DWORD)(userprofile_path.length - pre_str_length - remove_shortcut_arrow.path.windows_extra_path_prefix_str_length)) <= 0) {
			return false;
		}

		int length = core.sys.windows.winbase.lstrlenW(&(userprofile_path[0]));

		if (length <= 0) {
			return false;
		}

		if (userprofile_path[length - 1] == '\\') {
			return false;
		}

		wchar[.iconcache_path_buffer_length] iconcache_path1 = void;

		if (length > (core.sys.windows.windef.MAX_PATH - pre_str_length - "\0".length)) {
			iconcache_path1 = remove_shortcut_arrow.path.windows_extra_path_prefix;
		} else {
			iconcache_path1[0] = '\0';
		}

		core.sys.windows.winbase.lstrcatW(&(iconcache_path1[0]), &(userprofile_path[0]));
		core.sys.windows.winbase.lstrcatW(&(iconcache_path1[0]), &(.pre_local_setting[0]));

		version (none) {
			wchar[.iconcache_path_buffer_length] iconcache_path2 = iconcache_path1;
		}

		core.sys.windows.winbase.lstrcatW(&(iconcache_path1[0]), &(.pre_application_data[0]));
		core.sys.windows.winbase.lstrcatW(&(iconcache_path1[0]), &(.pre_iconcachedb[0]));

		if (core.sys.windows.winbase.DeleteFileW(&(iconcache_path1[0])) == 0) {
			version (none) {
				/*
				 * 削除に失敗した場合は、%UserProfile%\Application Data\IconCache.dbを探索する
				 *
				 * See_Also:
				 *      https://www.inasoft.org/webhelp/sdfr4/HLP000100.html
				 */
				core.sys.windows.winbase.lstrcatW(&(iconcache_path2[0]), &(.pre_application_data[0]));
				core.sys.windows.winbase.lstrcatW(&(iconcache_path2[0]), &(.pre_iconcachedb[0]));

				if (core.sys.windows.winbase.DeleteFileW(&(iconcache_path2[0])) == 0) {
					return false;
				}
			} else {
				return false;
			}
		}

		return true;
	}

version (CLEAR_ICON_CACHE)
extern (Windows)
nothrow @nogc
int WinMain(core.sys.windows.windef.HINSTANCE hInstance, core.sys.windows.windef.HINSTANCE hPrevInstance, core.sys.windows.winnt.LPSTR pCmdLine, int nCmdShow)

	do
	{
		return (remove_shortcut_arrow.command.exec_clear_icon_cache()) ? (0) : (1);
	}
