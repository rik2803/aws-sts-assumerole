# assumerole: A bash script to easily assume AWS roles using Temporary Security Credentials and MFA

## Pre-requisites

The script uses `jq` to parse the JSON configuration file `~/.assumerole`

## Usage

```
$ . ./assumerole 
Select from these available accounts:
cust1-prod-read cust1-staging-power
Account:   cust1-prod-read
MFA token: 331956
export AWS_ACCESS_KEY_ID=ASIAXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=7O801XXXXXXXXXXXXXXXXXahoLwdz8KLtRCc1Bvh
export AWS_SESSION_TOKEN=FQoDYXdXXXXXX...XXXX//
```

When sourcing the scipt using `source` or `. ./assumerole`, the environment variables are set
by the script, no need to copy/paste the output.

The user has to enter 2 values:
* The account: this is a account string defined in the configuration file `~/.assumerole`
* MFA token: the current value of the MFA token used as multi factor device

## The configuration file `~/.assumerole`

This is an example configuration file:

```
{
  "assume_roles": {
    "logical_name_for_stsAssumeRole": {
      "aws_profile": "aws_profile_to_use",
      "aws_account": "account_number_of_account_where_to_assume_the_role",
      "aws_mfa_arn": "arn_of_user_mfa_devoce",
      "aws_role": "name_of_role_to_assume"
    },
    "mycompany-prod-read": {
      "aws_profile": "mycompany-bastion",
      "aws_account": "123456789012",
      "aws_mfa_arn": "arn:aws:iam::210987654321:mfa/myuser",
      "aws_role": "read"
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
