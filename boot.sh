#!/bin/sh

cat > awslogs.conf <<EOF
[general]
state_file = /var/awslogs/state/agent-state
use_gzip_http_content_encoding = true
queue_size = 10

EOF

push_log() 
{
echo "Pushing config for log group [${2}] at location [${1}]"
cat >> awslogs.conf <<EOF
[${1}]
file = ${1}
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = ${2}

EOF
}

for item in "$@"
do 
	IFS=':'
	set $item
	push_log $1 $2
done

aws configure set plugins.cwlogs cwlogs
aws configure set default.region ${AWS_REGION:-eu-west-1}
aws logs push --config-file awslogs.conf