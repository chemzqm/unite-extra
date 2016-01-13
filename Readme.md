# Unite-extra

Some extra unite sources that I made to make my life easier.

* *emoji.vim* for list and insert emoji.
* *command.vim* for list and insert command to command line, execute immediately
  if command doesn't need argument.
* *project.vim* for quickly locate a project and open a file inside.
* *note.vim* for list and open note of [vim-notes](https://github.com/xolox/vim-notes)

## Install

[vim-plug](https://github.com/junegunn/vim-plug) is my recommended vim plugin manager,
you can install unite-extra like this:

    Plug chemzqm/unite-extra

You can want individual source, you can use:

    curl -fLo ~/.vim/autoload/unite/sources --create-dirs \
    https://raw.githubusercontent.com/chemzqm/unite-extra/master/utoload/unite/sources/emoji.vim

## Configure

* emoji source and note source have zero configuration.
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
  }}
  ```
  where `command` is command name, description if the description hint, args is
  1 or 0, indicates whether this command need argument to run.

* project source requires a global variable that contains the folds of project
  roots to search for projects, for example:

    let g:project_folders = ['~/vim-dev', '~/.vim/bundle']

## Notice

The original command source of unite have to remove to removed to make new
command.vim take replace, or you can just copy the file into directory
`~/.vim/autoload/unite/sources`

## License

MIT
