# User Directories

User directories are excluded from `git` tracking. They allow users to specify installation-specific settings without diverging from the primary `dotfiles` repository. This helps avoid merge conflicts, hotfixes, and other issues.

Subdirectories must follow the `*.user` naming scheme, otherwise they will be ignored completely.

## Installation

User directories are always *symlinked* to their install point, same as the regular installation process.

# Structure

For applications requiring user-specific configurations, a *base* file is included in the repository's dependency tree. 

The base file follows this naming scheme: `base.<section>.<application>.<extension>`. It is used to *include* or require other files that are not tracked by `git`. Note that `section` can be optional.

## Installation

The setup script recognizes these directories and treats them as user-only. For each *base file* in this folder, a copy is made in the same directory. These copies, called *active files*, are not tracked by `git` and can be freely edited by the user. Active files follow the same naming scheme as *base files*, replacing `base` with `active`.

When a move from a *base* file to an *active* file is made, any references to a base file is replaced with a reference to an active file.
