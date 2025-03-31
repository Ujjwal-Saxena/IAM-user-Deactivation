#!/bin/bash

# Set the threshold in days
THRESHOLD_DAYS=365

# Get the current date in seconds since epoch
CURRENT_DATE=$(date -u +%s)

# Get all IAM users
USERS=$(aws iam list-users --query 'Users[*].UserName' --output text)

for USER in $USERS; do
    echo "Checking user: $USER"
    
    # Get the last activity date
    LAST_ACTIVITY=$(aws iam get-user --user-name "$USER" --query 'User.PasswordLastUsed' --output text 2>/dev/null)
    
    # Convert last activity to seconds since epoch
    if [[ "$LAST_ACTIVITY" != "None" && "$LAST_ACTIVITY" != "null" ]]; then
        LAST_ACTIVITY_EPOCH=$(date -u -d "$LAST_ACTIVITY" +%s 2>/dev/null || date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_ACTIVITY" +%s 2>/dev/null)
    else
        LAST_ACTIVITY_EPOCH=0
    fi
    
    # Get the access keys for the user
    ACCESS_KEYS=$(aws iam list-access-keys --user-name "$USER" --query 'AccessKeyMetadata[*].AccessKeyId' --output text)
    OLD_ACCESS_KEY_FOUND=false
    LAST_DEACTIVATION_TIMESTAMP=0

    for KEY in $ACCESS_KEYS; do
        LAST_USED_DATE=$(aws iam get-access-key-last-used --access-key-id "$KEY" --query 'AccessKeyLastUsed.LastUsedDate' --output text 2>/dev/null)
        
        if [[ "$LAST_USED_DATE" != "None" && "$LAST_USED_DATE" != "null" ]]; then
            LAST_USED_EPOCH=$(date -u -d "$LAST_USED_DATE" +%s 2>/dev/null || date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_USED_DATE" +%s 2>/dev/null)
        else
            LAST_USED_EPOCH=0
        fi
        
        # Calculate the difference in days
        LAST_USED_DIFF=$(( (CURRENT_DATE - LAST_USED_EPOCH) / 86400 ))
        
        if [[ "$LAST_USED_DIFF" -gt "$THRESHOLD_DAYS" ]]; then
            echo "Disabling access key: $KEY"
            aws iam update-access-key --access-key-id "$KEY" --status Inactive --user-name "$USER"
            LAST_DEACTIVATION_TIMESTAMP=$CURRENT_DATE
            OLD_ACCESS_KEY_FOUND=true
        fi
    done
    
    # Check if both conditions met
    LAST_ACTIVITY_DIFF=$(( (CURRENT_DATE - LAST_ACTIVITY_EPOCH) / 86400 ))
    
    if [[ "$LAST_ACTIVITY_DIFF" -gt "$THRESHOLD_DAYS" && "$OLD_ACCESS_KEY_FOUND" = true ]]; then
        echo "Disabling console access for user: $USER"
        aws iam delete-login-profile --user-name "$USER" 2>/dev/null
        CONSOLE_DISABLE_TIMESTAMP=$CURRENT_DATE
    fi
    
    # If the access key was deactivated and console access was disabled over 365 days ago, delete the IAM user
    if [[ "$LAST_DEACTIVATION_TIMESTAMP" -ne 0 && "$CONSOLE_DISABLE_TIMESTAMP" -ne 0 ]]; then
        LAST_DEACTIVATION_DIFF=$(( (CURRENT_DATE - LAST_DEACTIVATION_TIMESTAMP) / 86400 ))
        CONSOLE_DISABLE_DIFF=$(( (CURRENT_DATE - CONSOLE_DISABLE_TIMESTAMP) / 86400 ))
        
        if [[ "$LAST_DEACTIVATION_DIFF" -gt "$THRESHOLD_DAYS" && "$CONSOLE_DISABLE_DIFF" -gt "$THRESHOLD_DAYS" ]]; then
            echo "Deleting IAM user: $USER"
            aws iam delete-user --user-name "$USER" 2>/dev/null
        fi
    fi

done
        
