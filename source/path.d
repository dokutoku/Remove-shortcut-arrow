/**
 * PATH取得の共通処理
 *
 * Author: $(LINK2 https://twitter.com/dokutoku3, dokutoku)
 * License: $(LINK2 https://creativecommons.org/publicdomain/zero/1.0/, CC0 1.0 Universal)
 */
module remove_shortcut_arrow.path;


version (Windows) {
	private static import core.sys.windows.winbase;
	private static import core.sys.windows.windef;
}

/**
 * プログラムディレクトリ名
 */
private enum program_name_path = "\\remove-shortcut-arrow\0";

/**
 * 出力icoファイルの相対PATH
 */
private enum end_ico_path = "\\no-arrow.ico\0";

/**
 * 事前に組み立てられる文字列の長さ
 */
private enum pre_str_length = (.program_name_path.length - "\0".length) + (.end_ico_path.length - "\0".length);

/**
 * WindowsのPATHに付与する謎の拡張表現
 */
package enum windows_extra_path_prefix = "\\\\?\\\0"w;

/**
 * windows_extra_path_prefixの文字列としての長さ
 */
package enum windows_extra_path_prefix_str_length = .windows_extra_path_prefix.length - "\0".length;

/**
 * REG_SZの最大長に制限する
 */
package enum PATH_LIMIT = 1024;

/**
 * 出力するICOファイルの各種PATHを格納するためのバッファ
 */
package struct program_path_buffer
{
	/**
	 * このプログラム用のディレクトリ
	 */
	wchar[.PATH_LIMIT] program_path = void;

	/**
	 * icoファイルのフルPATH
	 */
	wchar[.PATH_LIMIT] ico_path = void;
}

/**
 * 優先度順に環境変数から値を取得する。
 * 指定した環境変数が全部見つからなかったり、環境変数の値がおかしな値になっていたり、環境変数の値と事前に組み立てられる文字列の合計の長さがPATH_LIMITを超えていたりしない限り、この関数はまず失敗しない。
 *
 * Returns: 環境変数の値の長さ、0は失敗
 */
version (Windows)
nothrow @nogc
private int get_program_directory(ref wchar[.PATH_LIMIT] program_path)

	out(result)
	{
		if (result != 0) {
			assert(result < (program_path.length - .pre_str_length - .windows_extra_path_prefix_str_length - "\0".length));
		}
	}

	do
	{
		static foreach (variable; ["ProgramData\0"w, "ALLUSERSPROFILE\0"w, "ProgramFiles\0"w, "SystemDrive\0"w, "SystemRoot\0"w, "windir\0"w]) {
			if (core.sys.windows.winbase.GetEnvironmentVariableW(&(variable[0]), &(program_path[0]), cast(core.sys.windows.windef.DWORD)(program_path.length - .pre_str_length - .windows_extra_path_prefix_str_length)) > 0) {
				int length = core.sys.windows.winbase.lstrlenW(&(program_path[0]));

				if ((length > 0) && (program_path[length - 1] != '\\')) {
					return length;
				}
			}
		}

		program_path[0] = '\0';

		return 0;
	}

/**
 * 出力のためのicoファイルPATHを設定する。
 */
version (Windows)
nothrow @nogc
package bool get_program_path(ref .program_path_buffer buffer)

	do
	{
		{
			int length = .get_program_directory(buffer.program_path);

			if (length == 0) {
				return false;
			}

			if (length > (core.sys.windows.windef.MAX_PATH - .pre_str_length - "\0".length)) {
				buffer.ico_path = .windows_extra_path_prefix;
			} else {
				buffer.ico_path[0] = '\0';
			}
		}

		core.sys.windows.winbase.lstrcatW(&(buffer.ico_path[0]), &(buffer.program_path[0]));
		core.sys.windows.winbase.lstrcatW(&(buffer.ico_path[0]), .program_name_path);
		buffer.program_path = buffer.ico_path;
		core.sys.windows.winbase.lstrcatW(&(buffer.ico_path[0]), .end_ico_path);

		return true;
	}

/**
 * このライブラリ内で使うSystem32内のプログラム名の最大値
 */
private enum MAX_PROGRAM_NAME_LENGTH = "\"\\ie4uinit.exe\" -ClearIconCache".length;

/**
 * System32フォルダにあるsystem32の絶対パスを取得する。
 */
version (Windows)
nothrow @nogc
package int get_system32_path(ref wchar[core.sys.windows.windef.MAX_PATH] program_path)

	do
	{
		static foreach (variable; ["SystemRoot\0"w, "windir\0"w]) {
			if (core.sys.windows.winbase.GetEnvironmentVariableW(&(variable[0]), &(program_path[0]), cast(core.sys.windows.windef.DWORD)(program_path.length - "\\System32".length - .MAX_PROGRAM_NAME_LENGTH)) > 0) {
				int length = core.sys.windows.winbase.lstrlenW(&(program_path[0]));

				if ((length > 0) && (program_path[length - 1] != '\\')) {
					return length;
				}
			}
		}

		return 0;
	}
