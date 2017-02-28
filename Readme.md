# Unite-extra

**This project is deprecated, consider use [denite-extra](https://github.com/chemzqm/denite-extra) instead.**

Some extra unite sources that I made to make my life easier.

* **emoji.vim** for list and insert emoji.
* **command.vim** for list and insert command to command line, execute immediately
  if command doesn't need argument.
* **project.vim** for quickly locate a project and open a file inside.
* **node.vim** for works with *node_modules* of project contains current file.
* **git_status.vim** for works with git status

**Note:** `json_decode` is used, make sure `echo exists('json_decode')` is `1`.

## Install

Take [vim-plug](https://github.com/junegunn/vim-plug) for example:

    Plug chemzqm/unite-extra

If you just need individual source, you can use command:

    curl -fLo ~/.vim/autoload/unite/sources --create-dirs \
    https://raw.githubusercontent.com/chemzqm/unite-extra/master/utoload/unite/sources/emoji.vim

to download the `emoji.vim` into folder `.vim/autoload/unite/sources`

## Configure

* emoji, and node source have zero configuration.
* command source requires a json file names `~/.vim/command.json`, it contains
  an array of command configs, like this:
  ``` json
  [{
    "command": "Pretty",
    "description": "Pretty format current file",
    "args": 0
  }, {
    "command": "Update",
    "description": "Update vimrc in github",
    "args": 0
  }]
  ```
  where `command` is command name, `description` if the description hint, `args` is
  1 or 0, indicates whether this command need argument to run.

* project source requires a global variable that contains the folds of project
  roots to search for projects, for example:

    let g:project_folders = ['~/vim-dev', '~/.vim/bundle']

## Actions

* **Emoji** source has one action which insert selected emoji into current cursor position.

* **Command** source actions:

    *execute* (default action) for execute command with args set to 0, insert the command string
    to command line if args set to 1.

    *add* open the file command.json for add a command.

    *edit* open the file command.json at the line of selected command for edit.

* **Project** source has one action which open unite file_rec buffer for file
  choose.

* **Node** source actions:

    *open* (default action) open unite file_rec buffer for selected module.

    *main* open main file of the selected module

    *help* open readme.md file of the selected module

    *preview* preview the `package.json` file of selected module

    *browser* open the module project in your browser (need
    [vim-shell](https://github.com/xolox/vim-shell) if not working on macos)

## Notice

The original command source of unite have to be removed to make new
command.vim take replace, or you can just copy the file into directory
`~/.vim/autoload/unite/sources`

## License

MIT
