{
    "containerDefinitions": [
        {
            "portMappings": [
                {
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "containerPort": 8080
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "secretOptions": [],
                "options": {
                    "awslogs-group": "services/${cluster}/${service_name}",
                    "awslogs-region": "${aws_region}",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "cpu": ${cpu},
            "memory": ${memory},
            "image": "${aws_account}.dkr.ecr.${aws_region}.amazonaws.com/example/${service_name}:${image_tag}",
            "name": "${service_name}",
            "environment": [
                ${environment_variables}
            ],
            "secrets": [
                {
                    "name": "DD_API_KEY",
                    "valueFrom": "/config/application/datadog/apikey"
                }
            ],
            "ulimits": [
                {
                    "name": "nofile",
                    "softLimit": 65535,
                    "hardLimit": 65535
                }
            ]
        },
        {
            "cpu": 0,
            "memory": 256,
            "image": "datadog/agent:latest",
            "name": "datadog-agent",
            "environment": [
                {
                    "name": "ECS_FARGATE",
                    "value": "true"
                },
                {
                    "name": "DD_PROCESS_AGENT_ENABLED",
                    "value": "true"
                },
                {
                    "name": "DD_LOGS_INJECTION",
                    "value": "true"
                }
            ],
            "secrets": [
                {
                    "name": "DD_API_KEY",
                    "valueFrom": "/config/application/datadog/apikey"
                }
            ],
            "ulimits": [
                {
                    "name": "nofile",
                    "softLimit": 65535,
                    "hardLimit": 65535
                }
            ]
        }
    ],
    "runtimePlatform": {
        "operatingSystemFamily": "LINUX",
        "cpuArchitecture": "${cpu_architecture}"
    },
    "executionRoleArn": "arn:aws:iam::${aws_account}:role/${service_name}-ecsexecution",
    "taskRoleArn": "arn:aws:iam::${aws_account}:role/${service_name}-ecsrole",
    "memory": "${memory}",
    "cpu": "${cpu}",
    "family": "${service_name}-${aws_environment}",
    "networkMode": "awsvpc",
    "requiresCompatibilities": [
        "FARGATE"
    ]
}
