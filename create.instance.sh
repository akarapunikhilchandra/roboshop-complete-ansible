#!/bin/bash
NAMES=("web")
INSTANCE_TYPE=" "
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0c21f4afbf4430ceb
DOMAIN_NAME=joindevops.cloud
for i in "${NAMES[@]}"
do   
    if [[ $i == "mongodb" || $i == "mysql" ]] 
    then
        INSTANCE_TYPE="t3.micro"
    else
        INSTANCE_TYPE="t2.micro"
    fi 
    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z10334032ZMZZ509Q21DU --change-batch '
    
    {

            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 1,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done

#     aws route53 change-resource-record-sets --hosted-zone-id Z098285010FMU6PDV8O9P --change-batch '
#     {
#             "Changes": [{
#             "Action": "CREATE",
#                         "ResourceRecordSet": {
#                             "Name": "'$i.$DOMAIN_NAME'",
#                             "Type": "A",
#                             "TTL": 300,
#                             "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
#                         }}]
#     }
#     '
# done