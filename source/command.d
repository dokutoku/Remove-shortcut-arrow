/**
 * コマンドに関連した処理
 *
 * Author: $(LINK2 https://twitter.com/dokutoku3, dokutoku)
 * License: $(LINK2 https://creativecommons.org/publicdomain/zero/1.0/, CC0 1.0 Universal)
 */
module remove_shortcut_arrow.command;


version (Windows) {
	private static import core.sys.windows.winbase;
	private static import core.sys.windows.windef;
	private static import core.sys.windows.winnt;

	extern (Windows)
	nothrow @nogc
	core.sys.windows.windef.BOOL Wow64DisableWow64FsRedirection(core.sys.windows.winnt.PVOID*);

	extern (Windows)
	nothrow @nogc
	core.sys.windows.windef.BOOL Wow64RevertWow64FsRedirection(core.sys.windows.winnt.PVOID);
}

private static import remove_shortcut_arrow.path;

/**
 * PATHを除いたレジストリの追加コマンド。
 */
public enum REG_PRE_ADD_COMMAND = "reg.exe add \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Icons\" /f /v 29 /t REG_EXPAND_SZ /reg:64 /d \0"w;

/**
 * レジストリから削除するコマンド
 */
public enum REG_DELETE_COMMAND = "reg.exe delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Icons\" /f /v 29 /reg:64\0"w;

version (Windows) {
	static assert(core.sys.windows.windef.MAX_PATH == 260);
}

public enum REG_ADD_COMMAND_BUFFER_LENGTH = .REG_PRE_ADD_COMMAND.length + ("\"\"".length * 2) + 260 + remove_shortcut_arrow.path.PATH_LIMIT;
public enum REG_DELETE_COMMAND_BUFFER_LENGTH = .REG_DELETE_COMMAND.length + "\"\"".length + 260;

/**
 * 実行マシン上で有効な、ショートカット矢印を削除するためのコマンドをバッファにコピーする。
 *
 * Params:
 *      command_buffer = コマンドのバッファ
 *      buffer_size = コマンドのバッファサイズ
 *      ico_path = icoファイルの絶対パス
 */
version (Windows)
extern (C)
nothrow @nogc
public bool copy_remove_windows_shortcut_arrow_command(scope wchar* command_buffer, size_t buffer_size, const core.sys.windows.winnt.LPCWSTR ico_path)

	do
	{
		if (command_buffer == null) {
			return false;
		}

		if (buffer_size < .REG_ADD_COMMAND_BUFFER_LENGTH) {
			if (buffer_size != 0) {
				command_buffer[0] = '\0';
			}

			return false;
		}

		if (ico_path == null) {
			return false;
		}

		if (core.sys.windows.winbase.lstrlenW(ico_path) >= remove_shortcut_arrow.path.PATH_LIMIT) {
			return false;
		}

		wchar[core.sys.windows.windef.MAX_PATH] system_directory = void;

		command_buffer[0] = '"';
		command_buffer[1] = '\0';

		if (remove_shortcut_arrow.path.get_system32_path(system_directory) == 0) {
			return false;
		}

		core.sys.windows.winbase.lstrcatW(command_buffer, &(system_directory[0]));
		core.sys.windows.winbase.lstrcatW(command_buffer, &("\\System32\0"w[0]));

		version (none) {
			// reg:64オプションを削除しない場合(Vistaでは動作しない)

			static assert(.REG_PRE_ADD_COMMAND[0 .. 8] == "reg.exe "w);
			static assert(.REG_PRE_ADD_COMMAND[($ - " /d \0"w.length) .. $] == " /d \0"w);
			enum TEMP = "\\reg.exe\" "w ~ .REG_PRE_ADD_COMMAND[8 .. ($ - " \0"w.length)] ~ " \"" ~ "\0";
		} else {
			// reg:64オプションを削除する場合

			static assert(.REG_PRE_ADD_COMMAND[0 .. 8] == "reg.exe "w);
			static assert(.REG_PRE_ADD_COMMAND[($ - " /reg:64 /d \0"w.length) .. $] == " /reg:64 /d \0"w);
			enum TEMP = "\\reg.exe\" "w ~ .REG_PRE_ADD_COMMAND[8 .. ($ - " /reg:64 /d \0"w.length)] ~ " /d \"" ~ "\0";
		}

		core.sys.windows.winbase.lstrcatW(command_buffer, &(TEMP[0]));
		core.sys.windows.winbase.lstrcatW(command_buffer, &(ico_path[0]));
		int length = core.sys.windows.winbase.lstrlenW(command_buffer);
		command_buffer[length] = '"';
		command_buffer[length + 1] = '\0';

		return true;
	}

/**
 * 実行マシン上で有効な、削除したショートカット矢印を元に戻すためのコマンドをバッファにコピーする。
 *
 * Params:
 *      command_buffer = コマンドのバッファ
 *      buffer_size = コマンドのバッファサイズ
 */
version (Windows)
extern (C)
nothrow @nogc
public bool copy_restore_windows_shortcut_arrow_command(scope wchar* command_buffer, size_t buffer_size)

	do
	{
		if (command_buffer == null) {
			return false;
		}

		if (buffer_size < .REG_DELETE_COMMAND_BUFFER_LENGTH) {
			if (buffer_size != 0) {
				command_buffer[0] = '\0';
			}

			return false;
		}

		wchar[core.sys.windows.windef.MAX_PATH] system_directory = void;

		command_buffer[0] = '"';
		command_buffer[1] = '\0';

		if (remove_shortcut_arrow.path.get_system32_path(system_directory) == 0) {
			return false;
		}

		core.sys.windows.winbase.lstrcatW(command_buffer, &(system_directory[0]));
		core.sys.windows.winbase.lstrcatW(command_buffer, &("\\System32\0"w[0]));

		version (none) {
			// reg:64オプションを削除しない場合(Vistaでは動作しない)

			static assert(.REG_DELETE_COMMAND[0 .. 8] == "reg.exe "w);
			static assert(.REG_DELETE_COMMAND[$ - 1] == '\0');
			enum TEMP = "\\reg.exe\" "w ~ .REG_DELETE_COMMAND[8 .. $];
		} else {
			// reg:64オプションを削除する場合

			static assert(.REG_DELETE_COMMAND[0 .. 8] == "reg.exe "w);
			static assert(.REG_DELETE_COMMAND[($ - " /reg:64\0"w.length) .. $] == " /reg:64\0"w);
			enum TEMP = "\\reg.exe\" "w ~ .REG_DELETE_COMMAND[8 .. ($ - " /reg:64\0"w.length)] ~ "\0";
		}

		core.sys.windows.winbase.lstrcatW(command_buffer, &(TEMP[0]));

		return true;
	}

version (Windows)
nothrow @nogc
package bool exec_system32_command(core.sys.windows.winnt.LPWSTR command_buffer, bool disable_redirection = true)

	do
	{
		core.sys.windows.winbase.STARTUPINFOW temp =
		{
			cb: core.sys.windows.winbase.STARTUPINFOW.sizeof,
		};

		core.sys.windows.winbase.PROCESS_INFORMATION process_info;
		core.sys.windows.winnt.PVOID old_value = core.sys.windows.windef.NULL;
		core.sys.windows.windef.BOOL redirection_result = void;

		if (disable_redirection) {
			redirection_result = .Wow64DisableWow64FsRedirection(&old_value);
		}

		scope (exit) {
			if (disable_redirection) {
				if (redirection_result != core.sys.windows.windef.FALSE) {
					.Wow64RevertWow64FsRedirection(old_value);
				}
			}
		}

		core.sys.windows.windef.BOOL result = core.sys.windows.winbase.CreateProcessW(null, command_buffer, null, null, core.sys.windows.windef.FALSE, core.sys.windows.winbase.CREATE_NO_WINDOW, null, null, &temp, &process_info);

		if (result == core.sys.windows.windef.FALSE) {
			return false;
		}

		scope (exit) {
			core.sys.windows.winbase.CloseHandle(process_info.hProcess);
			core.sys.windows.winbase.CloseHandle(process_info.hThread);
		}

		core.sys.windows.windef.DWORD exit_code = 1;

		return (core.sys.windows.winbase.WaitForSingleObject(process_info.hProcess, core.sys.windows.winbase.INFINITE) != core.sys.windows.winbase.WAIT_FAILED) && (core.sys.windows.winbase.GetExitCodeProcess(process_info.hProcess, &exit_code) != core.sys.windows.windef.FALSE) && (exit_code == 0);
	}

/**
 * アイコンキャッシュをie4uinit.exeを利用してクリアする?
 *
 * ie4uinit.exeがあるかどうかやそのPATHなどはOSによって違うのでうまくいかないかもしれない
 */
version (Windows)
extern (C)
nothrow @nogc
public bool exec_clear_icon_cache()

	do
	{
		wchar[core.sys.windows.windef.MAX_PATH] system_directory = void;

		if (remove_shortcut_arrow.path.get_system32_path(system_directory) == 0) {
			return false;
		}

		//Unicode版はバッファに入れなければならない
		wchar[core.sys.windows.windef.MAX_PATH + "\"\"".length + " -ClearIconCache".length + "\0".length] command_buffer = void;
		command_buffer[0] = '"';
		command_buffer[1] = '\0';
		core.sys.windows.winbase.lstrcatW(&(command_buffer[0]), &(system_directory[0]));
		core.sys.windows.winbase.lstrcatW(&(command_buffer[0]), &("\\System32\0"w[0]));
		core.sys.windows.winbase.lstrcatW(&(command_buffer[0]), &("\\ie4uinit.exe\" -ClearIconCache\0"w[0]));

		int length = core.sys.windows.winbase.lstrlenW(&(command_buffer[0]));
		assert(length > 0);

		core.sys.windows.winnt.PVOID old_value = core.sys.windows.windef.NULL;
		core.sys.windows.windef.BOOL redirection_result = void;
		redirection_result = .Wow64DisableWow64FsRedirection(&old_value);

		scope (exit) {
			if (redirection_result != core.sys.windows.windef.FALSE) {
				.Wow64RevertWow64FsRedirection(old_value);
			}
		}

		bool result1 = .exec_system32_command(&(command_buffer[0]), false);
		length -= "ClearIconCache".length;

		command_buffer[length++] = 's';
		command_buffer[length++] = 'h';
		command_buffer[length++] = 'o';
		command_buffer[length++] = 'w';
		command_buffer[length] = '\0';

		return (result1) && (.exec_system32_command(&(command_buffer[0]), false));
	}
