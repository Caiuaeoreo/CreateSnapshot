#!/bin/bash

while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
                -id)
                instance_id="$2"
                shift
                shift
                ;;
                *)
                shift
                ;;
        esac
done

if [ -z "$instance_id" ]; then
        echo "Por favor, forneça um ID de EC2 usando a flag -id."
        exit 1
fi

read -p "Digite a região da EC2 desejada: " region
read -p "Digite o ticket para tag no snapshot: " ticket
read -p "Digite a descrição desejada para o snapshot: " description

instance_name=$(aws ec2 describe-instances --region "$region" --instance-ids "$instance_id" --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" --output text)

if [ -z "$instance_name" ]; then
        echo "EC2 não encontrada nesta região ou não existe"
        exit 1
fi

volume_ids=$(aws ec2 describe-volumes --region "$region" --filter "Name=attachment.instance-id,Values=$instance_id" --query "Volumes[*].VolumeId" --output text)

if [ -z "$volume_ids" ]; then
        echo "Nenhum volume encontrado para a ec2 $instance_name."
        exit 1
fi

for volume_id in $volume_ids; do
        aws ec2 create-snapshot --region "$region" --volume-id "$volume-id" --description "$description" --tag-specifications "ResourceType=snapshot,Tag=[{Key=Ticket,Value=$ticket},{Key=Name,Value=$instance_name}]"
        echo "Snapshot do volume $volume_id da EC2 $instance_name criado com sucesso"
done
