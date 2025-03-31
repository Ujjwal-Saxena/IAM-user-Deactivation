# IAM-user-Deactivation

#### Multiple times, orgs end up having multiple IAM users being created with Access keys and having console access to multiple users in entire account for varieyt of purposes and sometimes even in adhoc requests. And, even if each individual IAM user is no more in the organization, their credentials still persists in the account, thereby exposing to security risk and threat.

#### This is security concern and is not recommended as best practice due to security risks of exposing the AWS Account resources to users who can have access to resoruces despite of not being aprt of the organization anymore.

#### To fix this, I have written a script that calculates the age of Access keys and validates for Console access for those IAM users who havent access the Account resources for more than 365 days. 
We can furher customise this duration accordingly by replacing it with the required value.

### The script performs following actions:

1) Deactivate Access keys for IAM users whose "Access Key Last Used" and "Last Activity" is having value greater than 365 days.
2) Disable Console Access for IAM users whose "Access Key Last Used" and "Last Activity" is having value greater than 365 days.

-------------------

## MAC Users:

Before running the script, ensure of running below command:
```
brew install coreutils

```

### Windows Users with WinSSL/ Ubuntu Based Users:

Ensure to omit the "IF" conditions in script to have single "[" brackets only instead of "[[" brackets.

-------------





