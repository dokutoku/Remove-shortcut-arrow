/**
 * 消した矢印を元に戻す。
 *
 * Author: $(LINK2 https://twitter.com/dokutoku3, dokutoku)
 * License: $(LINK2 https://creativecommons.org/publicdomain/zero/1.0/, CC0 1.0 Universal)
 */
module remove_shortcut_arrow.restore;


version (Windows):

version (NON_WINREG) {
} else {
	version = IS_WINREG;
}

private static import core.sys.windows.winbase;
private static import core.sys.windows.windef;
private static import core.sys.windows.winnt;
private static import remove_shortcut_arrow.command;
private static import remove_shortcut_arrow.path;
private static import remove_shortcut_arrow.registory;

/**
 * プログラムのディレクトリからファイルを削除する。
 */
nothrow @nogc
private bool delete_files(const core.sys.windows.winnt.LPCWSTR ico_path, const core.sys.windows.winnt.LPCWSTR program_path)

	do
	{
		if (core.sys.windows.winbase.DeleteFileW(ico_path) == core.sys.windows.windef.FALSE) {
			return false;
		}

		return core.sys.windows.winbase.RemoveDirectoryW(program_path) != core.sys.windows.windef.FALSE;
	}

/**
 * 削除したショートカットアイコンを元に戻す。
 */
version (IS_WINREG)
extern (C)
nothrow @nogc
public bool restore_windows_shortcut_arrow()

	do
	{
		bool result1 = remove_shortcut_arrow.registory.delete_registory();

		remove_shortcut_arrow.path.program_path_buffer buffer = void;

		bool result2 = remove_shortcut_arrow.path.get_program_path(buffer);

		if (result2) {
			result2 = .delete_files(&(buffer.ico_path[0]), &(buffer.program_path[0]));
		}

		return (result1) && (result2);
	}

/**
 * REGコマンドを利用して、レジストリの特定の値を削除する
 */
extern (C)
nothrow @nogc
public bool exec_restore_windows_shortcut_arrow_command()

	do
	{
		//Unicode版はバッファに入れなければならない
		wchar[remove_shortcut_arrow.command.REG_DELETE_COMMAND_BUFFER_LENGTH] command_buffer = void;

		if (!remove_shortcut_arrow.command.copy_restore_windows_shortcut_arrow_command(&(command_buffer[0]), command_buffer.length)) {
			return false;
		}

		return remove_shortcut_arrow.command.exec_system32_command(&(command_buffer[0]));
	}

/**
 * REGコマンドを利用して、削除したショートカットアイコンを元に戻す。
 */
extern (C)
nothrow @nogc
public bool reg_restore_windows_shortcut_arrow()

	do
	{
		bool result1 = .exec_restore_windows_shortcut_arrow_command();

		remove_shortcut_arrow.path.program_path_buffer buffer = void;

		bool result2 = remove_shortcut_arrow.path.get_program_path(buffer);

		if (result2) {
			result2 = .delete_files(&(buffer.ico_path[0]), &(buffer.program_path[0]));
		}

		return (result1) && (result2);
	}

version (RESTORE_SHORTCUT_ARROW)
extern (Windows)
nothrow @nogc
int WinMain(core.sys.windows.windef.HINSTANCE hInstance, core.sys.windows.windef.HINSTANCE hPrevInstance, core.sys.windows.winnt.LPSTR pCmdLine, int nCmdShow)

	do
	{
		version (IS_WINREG) {
			return (.restore_windows_shortcut_arrow()) ? (0) : (1);
		} else {
			return (.reg_restore_windows_shortcut_arrow()) ? (0) : (1);
		}
	}
