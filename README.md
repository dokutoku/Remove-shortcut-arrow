# Remove shortcut arrow

Clear the standard arrows on Windows shortcuts.

To remove arrows from Windows shortcuts, you must edit certain registry entries.
However, many methods presented on the Internet do not remove the arrows or cause the arrows to turn black.

This application creates an ICO file optimized to remove the arrows from shortcut icons and registers the path to that file in the registry.

You must have administrator privileges to run the application.

## Usage

1. Double-click on remove-shortcut-arrow.exe in the bin directory
2. If you get a Windows Smart Screen warning, go to "More Info" -> "Run anyway" and allow it to run
3. If asked to do so with administrative privileges, select "Yes"
4. Once executed, log out and log in again and the arrow will disappear.

If you want to restore the arrow, run restore-shortcut-arrow.exe and do the same.

## About Errors

This application does not display any messages at all for the following reasons

1. reduce program dependencies so that it can be run in as many different environments and situations as possible
2. to reduce program size
3. as long as you have sufficient permissions, execution usually does not fail.

If you want to know if the execution is successful or not, enter the following command via the command prompt

```cmd
start /wait remove-shortcut-arrow32.exe
echo %ERRORLEVEL%
```

If you see 0, it has completed successfully.

## Report a bug

If you encounter an error and would like us to correct the symptom, please report the error on the [dedicated bug report page](https://gitlab.com/dokutoku/remove-shortcut-arrow/-/issues).

When reporting, please remember to complete the following fields.

- OS version (including whether it is 32-bit or 64-bit)
- Whether or not the system is running with administrator privileges
- Detailed error description

## License

The license is [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) and freely available to everyone.
