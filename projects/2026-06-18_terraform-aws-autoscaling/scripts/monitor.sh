#!/bin/bash
set -e

TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/..terraform" 2>/dev/null && pwd)" || TF_DIR="./terraform"

cd "$TF_DIR"
ASG_NAME=$(terraform output -raw asg_name 2>/dev/null) || exit 1
AWS_REGION="eu-west-1"

echo "📊 Auto Scaling Group Monitor"
echo "============================="
echo "ASG: $ASG_NAME"
echo ""

show_status() {
    echo "🔍 Current Status:"
    aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names "$ASG_NAME" \
        --region "$AWS_REGION" \
        --query 'AutoScalingGroups[0].[MinSize, MaxSize, DesiredCapacity, Instances[]]' \
        --output text | awk '{
            print "  Min: " $1 " | Max: " $2 " | Desired: " $3 " | Running: " NF-3
        }'

    echo ""
    echo "📈 Instances:"
    aws ec2 describe-instances \
        --filters "tag:aws:autoscaling:groupName=$ASG_NAME" \
        --region "$AWS_REGION" \
        --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PrivateIpAddress}' \
        --output table
}

show_status
echo ""
read -p "Enable live monitoring? (y/n): " -r LIVE
if [[ $LIVE =~ ^[Yy]$ ]]; then
    while true; do
        clear
        show_status
        sleep 10
    done
fi
