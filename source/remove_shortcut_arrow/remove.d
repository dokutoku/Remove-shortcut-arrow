/**
 * Windowsのショートカットの矢印を消すためのやつ。
 *
 * Author: $(LINK2 https://twitter.com/dokutoku3, dokutoku)
 * License: $(LINK2 https://creativecommons.org/publicdomain/zero/1.0/, CC0 1.0 Universal)
 */
module remove_shortcut_arrow.remove;


version (Windows):

version (NON_WINREG) {
} else {
	version = IS_WINREG;
}

private static import core.sys.windows.basetsd;
private static import core.sys.windows.winbase;
private static import core.sys.windows.windef;
private static import core.sys.windows.winerror;
private static import core.sys.windows.winnt;
private static import remove_shortcut_arrow.command;
private static import remove_shortcut_arrow.no_arrow;
private static import remove_shortcut_arrow.path;
private static import remove_shortcut_arrow.registory;

/**
 * プログラムのディレクトリを作成する
 */
nothrow @nogc
private bool create_direcotry(const core.sys.windows.winnt.LPCWSTR program_path)

	do
	{
		core.sys.windows.windef.BOOL result = core.sys.windows.winbase.CreateDirectoryW(program_path, null);

		return (result == core.sys.windows.windef.TRUE) || (core.sys.windows.winbase.GetLastError() == core.sys.windows.winerror.ERROR_ALREADY_EXISTS);
	}

/**
 * no-arrow.icoをファイルに書き出す
 *
 * Params:
 *      output_path = no-arrow.icoの絶対パス
 */
nothrow @nogc
private bool write_no_arrow_ico(const core.sys.windows.winnt.LPCWSTR output_path)

	do
	{
		core.sys.windows.basetsd.HANDLE hFile = core.sys.windows.winbase.CreateFileW(output_path, core.sys.windows.winnt.GENERIC_WRITE, core.sys.windows.winnt.FILE_SHARE_WRITE, null, core.sys.windows.winbase.CREATE_ALWAYS, core.sys.windows.winnt.FILE_ATTRIBUTE_NORMAL, null);

		if (hFile == core.sys.windows.winbase.INVALID_HANDLE_VALUE) {
			return false;
		}

		scope (exit) {
			core.sys.windows.winbase.CloseHandle(hFile);
		}

		/* Windows7以降ではnullを渡せないので、適当なポインターを渡す*/
		core.sys.windows.windef.DWORD temp = void;

		core.sys.windows.windef.BOOL result = core.sys.windows.winbase.WriteFile(hFile, &(remove_shortcut_arrow.no_arrow.ico_binary[0]), remove_shortcut_arrow.no_arrow.ico_binary.length, &temp, null);

		return result == core.sys.windows.windef.TRUE;
	}

/**
 * ショートカットアイコンを削除する。
 */
version (IS_WINREG)
extern (C)
nothrow @nogc
public bool remove_windows_shortcut_arrow()

	do
	{
		remove_shortcut_arrow.path.program_path_buffer buffer = void;

		return ((remove_shortcut_arrow.path.get_program_path(buffer)) && (.create_direcotry(&(buffer.program_path[0]))) && (.write_no_arrow_ico(&(buffer.ico_path[0]))) && (remove_shortcut_arrow.registory.add_registory(&(buffer.ico_path[0]))) && ((remove_shortcut_arrow.command.exec_clear_icon_cache()) || (true))) ? (true) : (false);
	}

/**
 * REGコマンドを利用して、レジストリにアイコンファイルを登録する。
 */
extern (C)
nothrow @nogc
public bool exec_remove_windows_shortcut_arrow_command(const core.sys.windows.winnt.LPCWSTR ico_path)

	do
	{
		//Unicode版はバッファに入れなければならない
		wchar[remove_shortcut_arrow.command.REG_ADD_COMMAND_BUFFER_LENGTH] command_buffer = void;

		if (!remove_shortcut_arrow.command.copy_remove_windows_shortcut_arrow_command(command_buffer.ptr, command_buffer.length, ico_path)) {
			return false;
		}

		return remove_shortcut_arrow.command.exec_system32_command(&(command_buffer[0]));
	}

/**
 * REGコマンドを利用して、ショートカットアイコンを削除する。
 */
extern (C)
nothrow @nogc
public bool reg_remove_windows_shortcut_arrow()

	do
	{
		remove_shortcut_arrow.path.program_path_buffer buffer = void;

		return ((remove_shortcut_arrow.path.get_program_path(buffer)) && (.create_direcotry(&(buffer.program_path[0]))) && (.write_no_arrow_ico(&(buffer.ico_path[0]))) && (.exec_remove_windows_shortcut_arrow_command(&(buffer.ico_path[0]))) && ((remove_shortcut_arrow.command.exec_clear_icon_cache()) || (true))) ? (true) : (false);
	}

version (REMOVE_SHORTCUT_ARROW)
extern (Windows)
nothrow @nogc
int WinMain(core.sys.windows.windef.HINSTANCE hInstance, core.sys.windows.windef.HINSTANCE hPrevInstance, core.sys.windows.winnt.LPSTR pCmdLine, int nCmdShow)

	do
	{
		version (IS_WINREG) {
			return (.remove_windows_shortcut_arrow()) ? (0) : (1);
		} else {
			return (.reg_remove_windows_shortcut_arrow()) ? (0) : (1);
		}
	}
