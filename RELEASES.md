# Release notes

## `0.1.5` (20190617)

* FEATURE: Set `${ASSUNMEROLE_COMMAND}` to run a command instead of starting
  a shell

## `0.1.4` (20181210)

* FIX: Rename ENV variable to ASSUMEROLE_ENV to avoif collision with
  user defined environment variables in the assumerole config file

## `0.1.3` (20181210)

* Credentials are cached and reloaded upon next invocation
* Extended `README.md`

## `0.1.2` (20181209)

* Set custom environment variables from `environment` list for your profiles
* Load a private key if `sshkey` is defined for a profile

## `0.1.1` (20181028)

* No more need to `source` the script because the script will start a new `bash`
  shell where the envirinment variables will be available because they are
  inherited from the parent shell where you started `assumerole`
* Command line completion for the account names, but this requires your
  `~/.bash_profile` to be changed. See `README.md` for details.
  
## `0.1.0` (First Release)

First version.
