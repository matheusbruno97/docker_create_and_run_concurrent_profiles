#!/bin/bash

email="${EMAIL}"
password="${PASSWORD}"
times=$((TIMES))
folderid="${FOLDERID}"

echo $email
echo $password
echo $times
echo $folderid

# Check if required environment variables are set
if [ -z "$email" ] || [ -z "$password" ]; then
    echo "Error: Both EMAIL and PASSWORD environment variables must be set."
    exit 1
fi

Xvfb DISPLAY=:1 -screen 0 1440x900x24 &

sleep 2

DISPLAY=:1 /opt/mlx/agent.bin --headless &

sleep 60

echo "Running main script now. Check /app/mlx-app for the launcher logs and for the automation script logs. They will be in that folder."

# cd /app/mlx-app

#nohup DISPLAY=:1 mlx > mlx.log 2>&1 &

response=$(curl --http1.1 --location 'https://api.multilogin.com/user/signin' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data '{
  "email": "'"$email"'",
  "password": "'"$password"'"
}')

if [[ $? -eq 0 ]]; then
    # Parse JSON response using jq and extract the token
    token=$(echo "$response" | jq -r '.data.token')
    response2=$(curl --http1.1 --location 'https://api.multilogin.com/profile/create' \
                    --header 'Content-Type: application/json' \
                    --header 'Accept: application/json' \
                    --header "Authorization: Bearer $token" \
                    --data '{
                    "name": "Created by Docker",
                    "browser_type": "mimic",
                    "os_type": "windows",
                    "automation": "selenium",
                    "folder_id": "'"$folderid"'",
                    "parameters": {
                        "flags": {
                        "navigator_masking": "mask",
                        "audio_masking": "natural",
                        "localization_masking": "mask",
                        "geolocation_popup": "allow",
                        "geolocation_masking": "mask",
                        "timezone_masking": "mask",
                        "graphics_noise": "natural",
                        "graphics_masking": "natural",
                        "webrtc_masking": "mask",
                        "fonts_masking": "natural",
                        "media_devices_masking": "natural",
                        "screen_masking": "mask",
                        "proxy_masking": "disabled",
                        "ports_masking": "mask"
                        },
                        "fingerprint": {},
                        "storage": {
                        "is_local": false
                        }
                    },
                    "times": '"$times"'
                    }')

    if [ $? -eq 0 ]; then
        # Parse the third response using jq and extract the "ids" array
        ids_array=($(echo "$response2" | jq -r '.data.ids[]'))
        if [ ${#ids_array[@]} -gt 0 ]; then
            # Loop through each ID and make the fourth API request
            for id in "${ids_array[@]}"; do
                sleep 10
                api_url="https://launcher.mlx.yt:45001/api/v1/profile/f/$folderid/p/$id/start/"
                fourth_response=$(curl --http1.1 --location "$api_url" \
                                        --header 'Content-Type: application/json' \
                                        --header 'Accept: application/json' \
                                        --header "Authorization: $token")

                error_code=$(echo "$fourth_response" | jq -r '.status.error_code')
                
                if [ "$error_code" == "INTERNAL_COMM_ERROR" ]; then
                    echo "Error: Internal communication error for ID $id. Waiting for 60 seconds before retrying..."
                    sleep 60
                    # Retry the request or perform other actions as needed
                    fourth_response=$(curl --http1.1 --location "$api_url" \
                                            --header 'Content-Type: application/json' \
                                            --header 'Accept: application/json' \
                                            --header "Authorization: $token")
                elif [ -z "$error_code" ] || [ "$error_code" == "null" ]; then
                    # Process the fourth response as needed when there is no error code
                    echo "Fourth API Response for ID $id: $fourth_response"
                else
                    echo "Error: Unexpected error_code '$error_code' for ID $id."
                    # Handle other error cases as needed
                fi
            done
        fi
    fi

    # python3 -u new-new-mlx-automation.py >> mlx-automation.log 2>&1

    # tail -f mlx-automation.log
fi
