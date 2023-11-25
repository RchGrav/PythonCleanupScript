# Python Distribution Cleanup Script

This PowerShell script is designed to aggressively remove Python distributions from a Windows system, including standard Python, Anaconda, Miniconda, and Mambaforge. It's useful for users who need to completely uninstall Python environments from their system.

## Features

- Uninstalls Python distributions including standard Python, Anaconda, Miniconda, and Mambaforge.
- Removes related directories, environment variables, and registry entries.
- Offers options to selectively remove specific distributions.
- Backs up registry entries before removal for safety.
- Requires administrative privileges to execute.

## Usage

To use this script, clone the repository or download the script file. You can run the script with specific switches to target certain Python distributions or use the `-All` switch to remove all distributions.

```powershell
.\cleanup_script.ps1 [-All] [-StandardPython] [-Anaconda] [-Mambaforge] [-Help]
```

### Switches

- `-All`: Remove all Python distributions.
- `-StandardPython`: Remove standard Python distribution.
- `-Anaconda`: Remove Anaconda distribution.
- `-Mambaforge`: Remove Mambaforge distribution.
- `-Help`: Show help message and usage instructions.

## Example

To remove only the standard Python distribution:

```powershell
.\cleanup_script.ps1 -StandardPython
```

To remove all detected Python distributions:

```powershell
.\cleanup_script.ps1 -All
```

## Requirements

- Windows Operating System
- PowerShell 5.0 or higher

## Warning

This script makes significant changes to your system. It's recommended to back up important data before running it. Use this script at your own risk.

## Contributing

Contributions to improve the script are welcome. Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

