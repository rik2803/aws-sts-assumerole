# `assumerole`: A bash script to easily assume AWS roles using Temporary Security Credentials and MFA

The script uses the standard AWS credentials file `~/.aws/credentials` and it's own configuration file `~/.assumerole` to assume a role on an account (defined in `~/.assumerole`), using the AWS profile in `~/.aws/credentials` referred to by
the `aws_profile` property in `~/.assumerole`.

Credentials are cached in `~/.assumerole.d/cache`. When assuming a role using `assumerole`,
and the cache exists, the cache is used and the validity of the cache is checked.

If the cache is valid, it is used. If the cache is not valid, the cache entry is cleared,
and the user is asked to enter the MFA code.

An example to illustrate this.

The AWS credentials file `~/.aws/credentials` contains:

```$xslt
[acme-bastion]
aws_access_key_id = AKIAXXXXXXXXXXXXXXXX
aws_secret_access_key = bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
region = eu-central-1
```

The `~/.assumerole` file contains this:

```$xslt
{
  "assume_roles": {
    "acme-sandbox-read": {
      "aws_profile": "acme-bastion",
      "aws_account": "123456789012",
      "aws_mfa_arn": "arn:aws:iam::210987654321:mfa/rtytgat",
      "aws_role": "read",
      "environment": [
        {
          "name": "MYVAR1",
          "value": "MYVALUE1"
        },
        {
          "name": "MYVAR2",
          "value": "MYVALUE2"
        }
      ]
    },
    ...
}
```

And running the command:

```$xslt
$ /usr/local/bin/assumerole
Select from these available accounts:
... 
acme-sandbox-read
acme-otheraccount-read
...

Account:   acme-sandbox-read
MFA token: 123456
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
export AWS_SESSION_TOKEN=aaaaaaa/a/very/long/string/aaaaaaaaaa
```

Does the following:

* use the AWS profile `acme-bastion`
* if the user has permissions to assume the role `read` on account `123456789012` ...
* ... temporary credentials are requested for that account
* extract the relevant properties from the returned JSON file
* sets the environment variables
* and also prints the `export` commands to `stdout` for the user to copy/paste
* sets the environment variables if any are defined in the configuration
  for that profile
* loads the SSH key, if one is defined for the selected profile
* start a new shell

In the new shell, the permissions linked to the role that is being assumed is available for
the `aws` CLI.

Exiting the shell will unset the credential environment variables.

## Pre-requisites

* The script uses `jq` to parse the JSON configuration file `~/.assumerole`
* The AWS CLI, see [here](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) on how to install this

## Usage

```
$ assumerole [profile [mfatoken]]
```

```
$ assumerole 
Select from these available accounts:
cust1-prod-read cust1-staging-power
Account:   cust1-prod-read
MFA token: 331956
export AWS_ACCESS_KEY_ID=ASIAXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=7O801XXXXXXXXXXXXXXXXXahoLwdz8KLtRCc1Bvh
export AWS_SESSION_TOKEN=FQoDYXdXXXXXX...XXXX//
```

During its execution, `assumerole` starts a new shell (`${SHELL}`). The environment
variables that build the credentials are set before starting the shell.

The user has to enter 2 values (either on the commandline or interactively):

* The account: this is a account string defined in the configuration file `~/.assumerole`
* MFA token: the current value of the MFA token used as multi factor device

## Commandline completion

Bash commandline completion was introduced in version v0.1.1 and can be used to complete
account names.

### `bash` commandline completion

For command completion to work, add these lines to your `~/.bash_profile` file:

```bash
# Bash completion for assumerole
_assumerole_accounts=$(assumerole accountlist)
complete -W "${_assumerole_accounts}" 'assumerole'
```

You need to star a new shell (or source the `~/.bash_profile` file) before command completion will be avialable.

### `zsh` commandline completion

Create the file `~/.oh-my-zsh/completions/_assumerole` with this content:

```
#compdef assumerole

function _assumerole {
  _describe -t 'assumerole' $(/usr/local/bin/assumerole accountlist)
}
```

Add these lines to your `~/.zshrc` file:

```
### Commandline completion
autoload -U compinit
compinit

source /usr/local/bin/aws_zsh_completer.sh
```

## Environment Variables

### `AWS_STS_DURATION_SECONDS`

Set this envvar to the number of seconds you wish the temporary credentials to be valid.

Mind though, the assumed role should be configured to allow at least the requested session
duration. If the role's session duration is less than what you specify here, the
`assumerole` operation will fail.

To increase the role's maximume CLI/API session duration, use the AWS Console or this CLI
command:

```
aws iam update-role -–role-name name-of-the-role -–max-session-duration 14400
```

### `${ASSUMEROLE_COMMAND}`

When this environment variable is set and the `assumerole` command is executed, it will not start
a new shell, but run the command in the environmnet variable instead, returning to the current
shell after the command finishes.

This can be used to loop over different accounts and have the same command run against those
accounts.

### Custom profile environment variables

When required, custom environment variables can be defined in the configuration
file. When that profile is activated, the environment variables are set before
the new shell is spawned.

To define custom environment variables, add a list `environment` to the profile,
for example:

```yaml
{
  "assume_roles": {
    "acme-sandbox-read": {
       ...
       "environment": [
        {
          "name": "MYVAR1",
          "value": "MYVALUE1"
        },
        {
          "name": "MYVAR2",
          "value": "MYVALUE2"
        }
      ]
    },
    ...
}

```

## The configuration file `~/.assumerole`

This is an example configuration file:

```
{
  "assume_roles": {
    "logical_name_for_stsAssumeRole": {
      "aws_profile": "aws_profile_to_use",
      "aws_account": "account_number_of_account_where_to_assume_the_role",
      "aws_mfa_arn": "arn_of_user_mfa_devoce",
      "aws_role": "name_of_role_to_assume",
      "sshkey": "/full/path/to/private/key/for/this/profile"
    },
    "mycompany-prod-read": {
      "aws_profile": "mycompany-bastion",
      "aws_account": "123456789012",
      "aws_mfa_arn": "arn:aws:iam::210987654321:mfa/myuser",
      "aws_role": "read",
      "environment": [
        {
          "name": "MYVAR1",
          "value": "MYVALUE1"
        },
        {
          "name": "MYVAR2",
          "value": "MYVALUE2"
        }
      ]
    },
    ...
  }
}
```

### `logical_name_for_stsAssumeRole`

This is a description for the role that will be assumed. It typically contains the name of the
account where the role is going to be assumed, and the name of the role to be assumed. This
is a string that can be chosen freely.

### `aws_profile`

The `assumerole` script will set the environment variable `AWS_PROFILE` to this value. That
means that the AWS CLI configuration file `~/.aws/credentials` should contain a named profile
that matches this string.

### `aws-account`

The numeric account ID of the AWS account where a role is to be assumed.

### `aws_role`

The name of the role to assume on the remote account.

### `aws_mfa_arn`

The ARN of the MFA device of the user on the account that will assume the role. This can be
a _bastion_ account, where only user are defined, and groups that allow `sts::AssumeRole`
permissions for a selection of accounts.

### `environment`

A list of dicts with `name` and `value` keys, used to set custom environment in the
spawned shell.

### `sshkey`

Private key to load when activating the profile.

## Put the active credentials in your shell prompt

### `bash`

```
### Prompt
PROMPT_COMMAND="[[ -n \${AWS_ACCOUNT} ]] && export AWS_PROMPT=\" AWS:\${AWS_ACCOUNT}\" || export AWS_PROMPT=''"
PS1="\s-\v\$AWS_PROMPT $ "
```

### `zsh`

#### `POWERLEVEL9K`

```
### POWERLEVEL9K config
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( dir vcs  custom_aws_credentials)
POWERLEVEL9K_CUSTOM_AWS_CREDENTIALS="[[ -n \${AWS_ACCOUNT} ]] && echo AWS \${AWS_ACCOUNT}"
```

## Troubleshooting

### Check `aws_profile`

The `aws_profile` property in the `assumerole` configuration file shouls be a valid profile in
`~/.aws/credentials` with a valid and active access key.

If the value of the `aws_profile` property is, for example, `org-bastion`, the following command should
work and should not fail:

```bash
$ AWS_PROFILE=org-bastion aws sts get-caller-identity
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/you"
}
```

If the output does not resemble what you here, verify the validity of your access key or contact your
AWS support team. This message is what you get if your access key is invalid:

```bash
$ AWS_PROFILE=org-bastion aws sts get-caller-identity

An error occurred (SignatureDoesNotMatch) when calling the GetCallerIdentity operation: The request signature
we calculated does not match the signature you provided. Check your AWS Secret Access Key and signing method.
Consult the service documentation for details.
```

### Check the `assumerole` error

The `assumerole` error message is better thanit used to be in previous versione, and basically gives the same error
as `aws sts *` commands. For example:

```bash
$ assumerole ixor.vdl-tst-admin 188739
INFO: The profile ixor.vdl-tst-admin passed on the commandline is a valid profile.
INFO: Cache found for ixor.vdl-tst-admin, but credentials have expired and will be deleted.

An error occurred (SignatureDoesNotMatch) when calling the AssumeRole operation: The request signature we
calculated does not match the signature you provided. Check your AWS Secret Access Key and signing method.
Consult the service documentation for details.
```

Another possible error is this one:

```bash
$ assumerole assumerole_profile 384573
INFO: The profile assumerole_profile passed on the commandline is a valid profile.

An error occurred (AccessDenied) when calling the AssumeRole operation: User: arn:aws:iam::123456789012:user/you
is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::210987654321:role/admin
```

This can be caused by:

* The permission to assume the role has not been assigned to you, maybe you can have that taken care off by bying
  your AWS admin a _bak Duvel_.
* The value of `AWS_STS_DURATION_SECONDS` is higher than what is allowed for that role on the target 
  account. Unset `AWS_STS_DURATION_SECONDS` and try again. If it still does not work, remove the `max_session_duration`
  property from the profile in `~/.assumerole`. If that does not help either, contact the AWS support team in
  your organization.

