* README_EN.txt
* 2025.09.04
* contools--recent-lists

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. CATALOG CONTENT DESCRIPTION
5. EXTERNALS
6. USAGE
6.1. Generate config files
6.2. Edit generated config files
6.3. Run cleanup scripts
7. LIST FORMATS
8. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Recent list scripts to:
* Cleanup application recent lists or MRU (most recently used) files and items
  in applications.

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The MIT license (see included text file "license.txt" or
https://en.wikipedia.org/wiki/MIT_License)

-------------------------------------------------------------------------------
3. REPOSITORIES
-------------------------------------------------------------------------------
Primary:
  * https://github.com/andry81/contools--recent-lists/branches
    https://github.com/andry81/contools--recent-lists.git
First mirror:
  * https://sf.net/p/contools/contools--recent-lists/ci/master/tree
    https://git.code.sf.net/p/contools/contools--recent-lists
Second mirror:
  * https://gitlab.com/andry81/contools-recent-lists/-/branches
    https://gitlab.com/andry81/contools-recent-lists.git

-------------------------------------------------------------------------------
4. CATALOG CONTENT DESCRIPTION
-------------------------------------------------------------------------------

<root>
 |
 +- /`.log`
 |    #
 |    # Log files directory, where does store all log files from all scripts
 |    # including all nested projects.
 |
 +- /`_config`
 |    #
 |    # Directory with input configuration files.
 |
 +- /`_out`
 |  | #
 |  | # Output directory for all files.
 |  |
 |  +- /`config`
 |     | #
 |     | # Output directory for all configuration files.
 |     |
 |     +- /`contools--recent-lists`
 |        | #
 |        | # Output directory for the scripts configuration files.
 |        |
 |        +- /`lists`
 |        |  |
 |        |  +- `*.lst`, `*.ini`
 |        |      #
 |        |      # Recent list configuration files.
 |        |
 |        +- `config.0.vars`
 |            #
 |            # Scripts environment variables.
 |
 +- `/scripts/*.bat`
     #
     # Scripts.

-------------------------------------------------------------------------------
5. EXTERNALS
-------------------------------------------------------------------------------
See details in `README_EN.txt` in `externals` project:

https://github.com/andry81/externals

-------------------------------------------------------------------------------
6. USAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1. Generate config files
-------------------------------------------------------------------------------

Run:

  >
  __init__/__init__.bat

-------------------------------------------------------------------------------
6.2. Edit generated config files
-------------------------------------------------------------------------------

lists/*.lst
lists/*.ini
config.0.vars

-------------------------------------------------------------------------------
6.3. Run cleanup scripts
-------------------------------------------------------------------------------

To cleanup particular application recent list:

  >
  scripts/cleanup_*.bat

To cleanup all recent lists:

  >
  scripts/_cleanup_all.bat

-------------------------------------------------------------------------------
7. LIST FORMATS
-------------------------------------------------------------------------------

<Storage>|...

1. reg|<CleanupMode>|...

1.1. reg|*|<RegKeyPath>

  Cleanup entire key path

1.2. reg|.|<RegKeyPath>|<RegKeyType>|<RegKeyName>

  Cleanup a single key path with exact key name match.

1.3. reg|n|<RegKeyPath>[\*]|<RegKeyType>|<RegKeyName>[*]

  Cleanup multiple keys with path and name globbing pattern match.

  CAUTION:
    `n` pattern won't work if a value of the `<RegKeyName>` is too long.

  CAUTION:
    `<RegKeyName>` must be without whitespaces.

1.3.1 ...|<RegKeyPath>\*|<RegKeyType>|<RegKeyName>

  Cleanup multiple key paths with exact name match from key path recursively.

1.3.2 ...|<RegKeyPath>|<RegKeyType>|<RegKeyName>*

  Cleanup multiple key names with inexact name match by single key path.

1.3.3 ...|<RegKeyPath>\*|<RegKeyType>|<RegKeyName>*

  Cleanup multiple key names with inexact name match from key path recursively.

1.4. reg|m|<NestLevel>|<CleanupSubmode>|...

  Cleanup multiple keys with subkey path regex match (`findstr.exe`).

  NOTE:
    Currently only <NestLevel>=1 is supported.

1.4.1 ...|*|1|<RegKeyPathPrefix>|<RegSubkeyRegexMatch>|<RegKeyPathSuffix>

  Cleanup entire key path using match pattern:
    <RegKeyPathPrefix>\<RegSubkeyRegexMatch>\<RegKeyPathSuffix>

  NOTE:
    If `<RegKeyPathSuffix>` is `.`, then treated as empty.

  Example:
    reg|m|*|1|HKEY_USERS|S-[0-9].*[0-9]|Software\MyApp\RecentList

  Resulted path pattern:
    HKEY_USERS\S-[0-9].*[0-9]\Software\MyApp\RecentList

1.4.2 ...|.|1|<RegKeyPathPrefix>|<RegSubkeyRegexMatch>|<RegKeyPathSuffix>|<RegKeyType>|<RegKeyName>

  Cleanup multiple key paths with exact key name and type match.

  NOTE:
    If `<RegKeyPathSuffix>` is `.`, then treated as empty.

  Example:
    reg|m|.|1|HKEY_USERS|S-[0-9].*[0-9]|Software\MyApp|REG_SZ|History

  Resulted path pattern and key type:
    HKEY_USERS\S-[0-9].*[0-9]\Software\MyApp\History, REG_SZ

1.4.3 ...|n|1|<RegKeyPathPrefix>|<RegSubkeyRegexMatch>|<RegKeyPathSuffix>[\*]|<RegKeyType>|<RegKeyName>[*]

  Cleanup multiple key paths with path and name globbing pattern match.

  NOTE:
    If `<RegKeyPathSuffix>` is `.`, then treated as empty.

  Example:
    reg|m|n|1|HKEY_USERS|S-[0-9].*[0-9]|Software\MyApp\*|REG_SZ|History*

  Resulted path pattern and key type:
    HKEY_USERS\S-[0-9].*[0-9]\Software\MyApp\*\History*, REG_SZ

2. file|<Format>|...

2.1. file|ini|<CleanupMode>|...

2.1.1. file|ini|*|<FileExpandPath>|<IniSectionList>

  Cleanup multiple ini file sections in the expanded file path.

3. cmd|<Command>|...

3.1. cmd|rmdir|<DirExpandPath>|<Arguments>

  Remove a directory.


CAUTION:
  To apply all variables expansion in `<*ExpandPath>` a cleanup script must run
  from respective session or process which has that environment variable.
  For example, `%COMMANDER_INI%` variable exists only under the
  `Total Commander` session.

-------------------------------------------------------------------------------
8. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
