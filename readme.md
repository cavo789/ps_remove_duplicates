![Banner](images/banner.png)

# Remove duplicates

> Powershell script that will compare two folders and will removes duplicated files in the second folder. At the end, the second folder will only contains new or modified files.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [License](#license)

## Install

Make a right-click on the hyperlink to [remove_duplicates.ps1](https://raw.githubusercontent.com/cavo789/ps_remove_duplicates/master/remove_duplicates.ps1) and select `save the target of the link as` so you can save the file on your hard disk.

## Usage

Start a DOS prompt and start the script by running `powershell .\remove_duplicates.ps1` 

You'll be prompted for some parameters:

* the `source` folder (the master folder)
* the `compared with` folder (from where duplicates files should be removed)
* does WinMerge be started after the cleaning or not? (0=false/1=true)

Please read the explanations displayed on screen and press "yes" then <kbd>Enter</kbd> key to start the script.

Files in the `compared with` folder already present in the `source` (with an exact match) will be removed from the `compared with` folder.

At the end, the `compared with` folder will contains only:

* files not present in the `source` folder
* files present in the `source` folder but different

### Tips

You can also directly start the script like this: `powershell .\remove_duplicates.ps1 -SourceFolder c:\christophe\docs -ComparedWith c:\temp\docs -StartWinMerge 0`.

If you want to run WinMerge once the cleaning is doen: `powershell .\remove_duplicates.ps1 -SourceFolder c:\christophe\docs -ComparedWith c:\temp\docs -StartWinMerge 1`.

If WinMerge isn't yet install on your machine, please download and install from here: [https://sourceforge.net/projects/winmerge/](https://sourceforge.net/projects/winmerge/).

## License

[MIT](LICENSE)
