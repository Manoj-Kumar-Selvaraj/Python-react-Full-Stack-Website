#!/usr/bin/bash

# Prompt user for input values
read -p "Enter AWS Region: " AWS_REGION
read -p "Enter Key Pair Name: " KEY_NAME
read -p "Enter VPC Name: " VPC_NAME
read -p "Enter VPC CIDR Block (e.g., 10.0.0.0/16): " CIDR_BLOCK
read -p "Enter Number of Public Subnets: " NO_OF_PUBLIC_SUBNETS
read -p "Enter Number of Private Subnets: " NO_OF_PRIVATE_SUBNETS
read -p "Enter Public Route Table Name: " PUBLIC_ROUTE_TABLE_NAME
read -p "Enter Private Route Table Name: " PRIVATE_ROUTE_TABLE_NAME
read -p "Enter Internet Gateway Name: " IGW_NAME

# Validate NO_OF_PUBLIC_SUBNETS and NO_OF_PRIVATE_SUBNETS as numeric values
if ! [[ "$NO_OF_PUBLIC_SUBNETS" =~ ^[0-9]+$ ]] || ! [[ "$NO_OF_PRIVATE_SUBNETS" =~ ^[0-9]+$ ]]; then
    echo "Error: Number of subnets must be numeric values."
    exit 1
fi

# Get the list of existing key pairs
Key_pair_List=$(aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output text --region "$AWS_REGION")

# Check if the key pair exists
if ! grep -wq "$KEY_NAME" <<< "$Key_pair_List"; then
    aws ec2 create-key-pair --key-name "$KEY_NAME" --key-type rsa --query 'KeyMaterial' --output text --region "$AWS_REGION" > "$KEY_NAME.pem"
    chmod 400 "$KEY_NAME.pem"
    echo "$KEY_NAME is Created and saved as $KEY_NAME.pem"
else
    echo "$KEY_NAME already exists"
fi

# Check if the VPC exists
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" \
    --query "Vpcs[0].VpcId" --output text --region "$AWS_REGION" 2>vpc_error.log)

if [[ -z "$VPC_ID" || "$VPC_ID" == "None" ]]; then
    VPC_ID=$(aws ec2 create-vpc --cidr-block "$CIDR_BLOCK" \
        --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
        --query "Vpc.VpcId" --output text --region "$AWS_REGION")
    echo "VPC $VPC_NAME created with ID $VPC_ID"
else
    echo "VPC $VPC_NAME already exists with ID $VPC_ID"
fi

# Function to check CIDR block conflicts
check_cidr_conflict() {
    local NEW_CIDR="$1"
    local EXISTING_CIDRS=($(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
        --query "Subnets[*].CidrBlock" --output text --region "$AWS_REGION"))
    
    for EXISTING_CIDR in "${EXISTING_CIDRS[@]}"; do
        if [[ "$NEW_CIDR" == "$EXISTING_CIDR" ]]; then
            return 1  # Conflict found
        fi
    done
    return 0  # No conflict
}

# Function to check if a subnet name already exists
check_subnet_name_exists() {
    local SUBNET_NAME="$1"
    local EXISTING_SUBNET_NAMES=($(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
        --query "Subnets[*].Tags[?Key=='Name'].Value" --output text --region "$AWS_REGION"))
    
    for EXISTING_NAME in "${EXISTING_SUBNET_NAMES[@]}"; do
        if [[ "$SUBNET_NAME" == "$EXISTING_NAME" ]]; then
            return 1  # Subnet name exists
        fi
    done
    return 0  # Subnet name does not exist
}

# Function to count existing subnets in a route table
count_existing_subnets() {
    local ROUTE_TABLE_ID="$1"
    local COUNT=$(aws ec2 describe-route-tables --route-table-ids "$ROUTE_TABLE_ID" \
        --query "RouteTables[0].Associations[?SubnetId].SubnetId | length(@)" --output text --region "$AWS_REGION")
    echo "$COUNT"
}

# Function to create subnets
create_subnets() {
    local SUBNET_TYPE=$1
    local NO_OF_SUBNETS=$2
    local ROUTE_TABLE_ID=$3
    local SUBNET_IDS=()

    # Count existing subnets in the route table
    local EXISTING_SUBNETS=$(count_existing_subnets "$ROUTE_TABLE_ID")
    local SUBNETS_TO_CREATE=$((NO_OF_SUBNETS - EXISTING_SUBNETS))

    if [[ "$SUBNETS_TO_CREATE" -le 0 ]]; then
        echo "No new $SUBNET_TYPE subnets to create. Already have $EXISTING_SUBNETS subnets."
        return
    fi

    echo "Creating $SUBNETS_TO_CREATE new $SUBNET_TYPE subnets..."

    for ((i = 1; i <= SUBNETS_TO_CREATE; i++)); do
        while true; do
            read -p "Enter CIDR block for $SUBNET_TYPE subnet $i: " SUBNET_CIDR
            if check_cidr_conflict "$SUBNET_CIDR"; then
                break
            else
                echo "Error: CIDR block $SUBNET_CIDR conflicts with an existing subnet. Please enter a different CIDR block."
            fi
        done

        SUBNET_NAME="$SUBNET_TYPE-subnet-$((EXISTING_SUBNETS + i))"
        if ! check_subnet_name_exists "$SUBNET_NAME"; then
            echo "Error: Subnet name $SUBNET_NAME already exists. Please choose a different name."
            continue
        fi

        SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$SUBNET_CIDR" \
            --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$SUBNET_NAME}]" \
            --query "Subnet.SubnetId" --output text --region "$AWS_REGION")
        
        if [[ -z "$SUBNET_ID" || "$SUBNET_ID" == "None" ]]; then
            echo "Error: Failed to create subnet $SUBNET_NAME."
            exit 1
        fi

        if [[ "$SUBNET_TYPE" == "public" ]]; then
            aws ec2 modify-subnet-attribute --subnet-id "$SUBNET_ID" --map-public-ip-on-launch
        fi

        echo "$SUBNET_TYPE Subnet $SUBNET_NAME created with ID $SUBNET_ID"
        SUBNET_IDS+=("$SUBNET_ID")
    done

    for SUBNET_ID in "${SUBNET_IDS[@]}"; do
        aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID" --subnet-id "$SUBNET_ID" --region "$AWS_REGION"
        echo "Associated $SUBNET_TYPE Subnet $SUBNET_ID with $SUBNET_TYPE Route Table"
    done
}

# Check for Route Table Duplicates
RouteTablePublicId=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=$PUBLIC_ROUTE_TABLE_NAME" \
    "Name=vpc-id,Values=$VPC_ID" \
    --query "RouteTables[0].RouteTableId" \
    --output text --region "$AWS_REGION")

if [[ -z "$RouteTablePublicId" || "$RouteTablePublicId" == "None" ]]; then                        
    # Create Public Route Table
    PUBLIC_RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" \
        --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$PUBLIC_ROUTE_TABLE_NAME}]" \
        --query "RouteTable.RouteTableId" --output text --region "$AWS_REGION")
    echo "Public Route Table created with ID $PUBLIC_RT_ID"
else
    PUBLIC_RT_ID="$RouteTablePublicId"
    echo "Route Table name: $PUBLIC_ROUTE_TABLE_NAME, id:$PUBLIC_RT_ID already in place."
fi

RouteTablePrivateId=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=$PRIVATE_ROUTE_TABLE_NAME" \
    "Name=vpc-id,Values=$VPC_ID" \
    --query "RouteTables[0].RouteTableId" --output text --region "$AWS_REGION")

if [[ -z "$RouteTablePrivateId" || "$RouteTablePrivateId" == "None" ]]; then 
    PRIVATE_RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" \
        --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$PRIVATE_ROUTE_TABLE_NAME}]" \
        --query "RouteTable.RouteTableId" --output text --region "$AWS_REGION")
    echo "Private Route Table created with ID $PRIVATE_RT_ID"
else
    PRIVATE_RT_ID="$RouteTablePrivateId"
    echo "Route Table name: $PRIVATE_ROUTE_TABLE_NAME, id:$PRIVATE_RT_ID already in place."
fi 

# Create Internet Gateway if it does not exist
IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=$IGW_NAME" \
    --query "InternetGateways[0].InternetGatewayId" --output text --region "$AWS_REGION" 2>igw_error.log)

if [[ -z "$IGW_ID" || "$IGW_ID" == "None" ]]; then
    IGW_ID=$(aws ec2 create-internet-gateway \
        --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$IGW_NAME}]" \
        --query "InternetGateway.InternetGatewayId" --output text --region "$AWS_REGION")
    aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
    echo "Internet Gateway $IGW_NAME created and attached to VPC $VPC_NAME"
else
    echo "Internet Gateway $IGW_NAME already exists with ID $IGW_ID"
fi

# Add Internet Access Route to Public Route Table
aws ec2 create-route --route-table-id "$PUBLIC_RT_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" --region "$AWS_REGION"
echo "Internet access enabled in Public Route Table"

# Create Public and Private Subnets
create_subnets "public" "$NO_OF_PUBLIC_SUBNETS" "$PUBLIC_RT_ID"
create_subnets "private" "$NO_OF_PRIVATE_SUBNETS" "$PRIVATE_RT_ID"

# Check For Security Group
read -p "ENTER SECURITY GROUP NAME: " SG_NAME
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" \
             "Name=tag:Name,Values=$SG_NAME" \
    --query "SecurityGroups[0].GroupId" --output text --region "$AWS_REGION" 2>Sg-error.log )

# Create a Security Group
if [ "$SG_ID" == "None" ]; then
    aws ec2 create-security-group --group-name "$SG_NAME" --vpc-id "$VPC_ID" --description "FactoryOutletBackendSg" --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=FactoryOutletBackendSg}]"
    read -p "ENTER SUBNET PROTOCOL TYPE(tcp, udp, icmp, or all) " sg_protocol
    read -p "ENTER CIDR " sg_cidr
    read -p "ENTER PORT NO " sg_port
    # Allow SSH (Port 22) - Restrict to your IP for security
    aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol "$sg_protocol" --port $sg_port --cidr "sg_cidr"


else
    echo "$SG_NAME: $SG_ID, Already Present, Do you want to Update it?"
    read -p "PRESS(Y/N) " SG_Flag
    if [[ "$SG_Flag" == "y" || "$SG_Flag" == "Y" ]]; then
        read -p "ENTER SUBNET PROTOCOL TYPE(tcp, udp, icmp, or all) " sg_protocol
        read -p "ENTER CIDR " sg_cidr
        read -p "ENTER PORT NO " sg_port
        aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol "$sg_protocol" --port $sg_port --cidr "sg_cidr"
    else
        echo "Operation Completed"

    fi
fi

# Check if Flow Log is Present?

FlowLog_Id=$(aws ec2 describe-flow-logs \
    --filter "Name=resource-id,Values=$VPC_ID" \
             "Name=tag:Name,Values=$FlowLogName" \
    --query "FlowLogs[0].FlowLogId" \
    --output text 2>FlowLog.Log)

if [ -z "$FlowLog_Id" ]; then
    echo "No Flow Log found for VPC: $VPC_ID with Name: $FlowLogName"
    echo "Creating Flow Log..."

    FlowLog_Id=$(aws ec2 create-flow-logs \
        --resource-type VPC \
        --resource-ids $VPC_ID \
        --traffic-type ALL \
        --log-destination-type cloud-watch-logs \
        --log-group-name "/aws/vpc-flow-logs/$FlowLogName" \
        --deliver-logs-permission-arn "arn:aws:iam::<AWS_ACCOUNT_ID>:role/VPCFlowLogsRole" \
        --query "FlowLogIds[0]" \
        --output text 2>>FlowLog.Log)

    if [ -z "$FlowLog_Id" ]; then
        echo "Failed to create Flow Log. Check FlowLog.Log for details."
    else
        echo "Flow Log created successfully! FlowLog ID: $FlowLog_Id"
    fi
else
    echo "Flow Log already exists: $FlowLog_Id"
fi