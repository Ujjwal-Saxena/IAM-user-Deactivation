# IAM-user-Deactivation

#### Multiple times, orgs end up having multiple IAM users being created with Access keys and having console access to multiple users in entire account for varieyt of purposes and sometimes even in adhoc requests. And, even if each individual IAM user is no more in the organization, their credentials still persists in the account, thereby exposing to security risk and threat.

#### This is security concern and is not recommended as best practice due to security risks of exposing the AWS Account resources to users who can have access to resoruces despite of not being aprt of the organization anymore.

#### To fix this, I have written a script that calculates the age of Access keys and validates for Console access for those IAM users who havent access the Account resources for more than 365 days. 
We can furher customise this duration accordingly by replacing it with the required value.

#### There are 2 scripts in this repository namely:
1) deactivate_users_365.sh
2) delete_users_365.sh
  
## Deactivate IAM users using Threshold

### The script "deactivate_users_365.sh" performs following actions:

1) Deactivate Access keys for IAM users whose "Access Key Last Used" and "Last Activity" is having value greater than 365 days.
2) Disable Console Access for IAM users whose "Access Key Last Used" and "Last Activity" is having value greater than 365 days.

------------------

## Delete IAM users using Threshold 

### The script "delete_user_365.sh" will perform similar actions with deletion activity for IAM users which were already in disable/deactivated state for more than 365 days. Script performs following actions:

1) Deactivate Access keys for IAM users whose "Access Key Last Used" and "Last Activity" is having value greater than 365 days.
2) Disable Console Access for IAM users whose "Access Key Last Used" and "Last Activity" is having value greater than 365 days.
3) Calculates the log deactivation timestamp and console disable timestamp for IAM users who were already disabled for more than 365 days
4) Perform deletion on those IAM users whos log deactivation and console disable timestamp value is more than 365 days. 

-------------------

## MAC Users:

Before running the script, ensure of running below command:
```
brew install coreutils

```

### Windows Users with WinSSL/ Ubuntu Based Users:

Ensure to omit the "IF" conditions in script to have single "[" brackets only instead of "[[" brackets.

-------------





