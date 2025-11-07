# Function to set ROS environment variables based on domain ID
set_robot_num() {
  # Mapping from ROS_DOMAIN_ID to ROBOT_IP
  # declare -A ROBOT_IPS=(
  #   [1]="128.135.202.20"
  #   [2]="128.135.202.21"
  #   [3]="128.135.202.82"
  #   [4]="128.135.202.84"
  #   [5]="128.135.202.193"
  #   [6]="128.135.202.203"
  #   [7]="128.135.202.208"
  #   [8]="128.135.202.231"
  #   [9]="128.135.202.238"
  #   [10]="128.135.202.239"
  #   [11]="128.135.202.241"
  #   [12]="128.135.202.243"
  #   [13]="128.135.202.6"
  # )
  declare -A ROBOT_IPS=(
    [1]="128.135.202.18"
    [2]="128.135.202.17"
    [3]="128.135.202.16"
    [4]="128.135.202.15"
    [5]="128.135.202.14"
    [6]="128.135.202.13"
    [7]="128.135.202.12"
    [8]="128.135.202.11"
    [9]="128.135.202.10"
    [10]="128.135.202.9"
    [11]="128.135.202.8"
    [12]="128.135.202.7"
    [13]="128.135.202.6"
  )

  local domain_id=$1

  if [[ -z "$domain_id" ]]; then
    echo "Usage: setros <ROS_DOMAIN_ID>"
    echo "Available IDs: ${!ROBOT_IPS[@]}"
    return 1
  fi

  if [[ -n "${ROBOT_IPS[$domain_id]}" ]]; then
    [ -t 0 ] && export ROS_SUPER_CLIENT=True || export ROS_SUPER_CLIENT=False
    export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
    export ROS_DOMAIN_ID=$domain_id
    export ROBOT_IP="${ROBOT_IPS[$domain_id]}"

    # Find the maximum index in the mapping
    local max_id
    max_id=$(printf "%s\n" "${!ROBOT_IPS[@]}" | sort -n | tail -1)

    # Build semicolon-separated list up to max_id
    local list=""
    for ((i=0; i<=max_id; i++)); do
      if [[ $i -eq $domain_id ]]; then
        list+="${ROBOT_IPS[$i]}:11811"
      fi
      if [[ $i -lt $max_id ]]; then
        list+=";"
      fi
    done

    export ROS_DISCOVERY_SERVER="$list"

    # Name of the script to generate
    OUTPUT_SCRIPT="$HOME/intro_robo_ws/src/intro_robo/intro_robo_utils/discovery_server_env_variables.sh"

    # Write commands into the file
    eval "cat > \"$OUTPUT_SCRIPT\" << EOF
[ -t 0 ] && export ROS_SUPER_CLIENT=True || export ROS_SUPER_CLIENT=False
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export ROS_DOMAIN_ID=$domain_id
export ROBOT_IP=\"${ROBOT_IPS[$domain_id]}\"
export ROS_DISCOVERY_SERVER=\"$list\"
EOF"

    echo "Created $OUTPUT_SCRIPT with:"
    echo -e "\tROS_DOMAIN_ID=$ROS_DOMAIN_ID"
    echo -e "\tROBOT_IP=\"$ROBOT_IP\""
    echo -e "\tROS_DISCOVERY_SERVER=\"$ROS_DISCOVERY_SERVER\""
  else
    echo "Error: ROS_DOMAIN_ID $domain_id not found in mapping."
    echo "Available IDs: ${!ROBOT_IPS[@]}"
    return 1
  fi
}
