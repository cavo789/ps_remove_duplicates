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

Mention the name of:

* the `source` folder
* the `compared with` folder

Please read the explanations displayed on screen and press "yes" then <kbd>Enter</kbd> key to start the script.

Files in the `compared with` folder already present in the `source` (with an exact match) will be removed from the `compared with` folder.

At the end, the `compared with` folder will contains only:

* files not present in the `source` folder
* files present in the `source` folder but different

### License

[MIT](LICENSE)
