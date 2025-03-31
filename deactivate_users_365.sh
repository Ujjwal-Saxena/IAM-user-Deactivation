#!/bin/bash

# Set the threshold in days
THRESHOLD_DAYS=365

# Get the current date in seconds since epoch
CURRENT_DATE=$(date +%s)

# Get all IAM users
USERS=$(aws iam list-users --query 'Users[*].UserName' --output text)

for USER in $USERS; do
    echo "Checking user: $USER"
    
    # Get the last activity date
    LAST_ACTIVITY=$(aws iam get-user --user-name "$USER" --query 'User.PasswordLastUsed' --output text 2>/dev/null)
    
    # Convert last activity to seconds since epoch
    if [[ "$LAST_ACTIVITY" != "None" ]]; then
        LAST_ACTIVITY_EPOCH=$(date -d "$LAST_ACTIVITY" +%s)
    else
        LAST_ACTIVITY_EPOCH=0
    fi
    
    # Get the access keys for the user
    ACCESS_KEYS=$(aws iam list-access-keys --user-name "$USER" --query 'AccessKeyMetadata[*].AccessKeyId' --output text)
    OLD_ACCESS_KEY_FOUND=false

    for KEY in $ACCESS_KEYS; do
        LAST_USED_DATE=$(aws iam get-access-key-last-used --access-key-id "$KEY" --query 'AccessKeyLastUsed.LastUsedDate' --output text 2>/dev/null)
        
        if [[ "$LAST_USED_DATE" != "None" ]]; then
            LAST_USED_EPOCH=$(date -d "$LAST_USED_DATE" +%s)
        else
            LAST_USED_EPOCH=0
        fi
        
        # Calculate the difference in days
        LAST_USED_DIFF=$(( (CURRENT_DATE - LAST_USED_EPOCH) / 86400 ))
        
        if [[ "$LAST_USED_DIFF" -gt "$THRESHOLD_DAYS" ]]; then
            echo "Disabling access key: $KEY"
            aws iam update-access-key --access-key-id "$KEY" --status Inactive --user-name "$USER"
            OLD_ACCESS_KEY_FOUND=true
        fi
    done
    
    # Check if both conditions met
    LAST_ACTIVITY_DIFF=$(( (CURRENT_DATE - LAST_ACTIVITY_EPOCH) / 86400 ))
    
    if [[ "$LAST_ACTIVITY_DIFF" -gt "$THRESHOLD_DAYS" && "$OLD_ACCESS_KEY_FOUND" = true ]]; then
        echo "Disabling console access for user: $USER"
        aws iam delete-login-profile --user-name "$USER" 2>/dev/null
    fi

done
