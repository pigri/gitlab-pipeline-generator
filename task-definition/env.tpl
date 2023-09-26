{
    "name": "_JAVA_OPTIONS",
    "value": "-XX:MaxRAMPercentage=75 -XX:+UnlockExperimentalVMOptions"
},
{
    "name": "DD_AGENT_HOST",
    "value": "datadog.${aws_environment}.example.local"
},
{
    "name": "DD_INTAKE_PORT",
    "value": "10514"
},
{
    "name": "DD_AGENT_PORT",
    "value": "8126"
},
{
    "name": "DD_ENV",
    "value": "${aws_environment}"
},
{
    "name": "DD_INTAKE_HOST",
    "value": "intake.logs.datadoghq.com"
},
{
    "name": "DD_LOGS_INJECTION",
    "value": "true"
},
{
    "name": "DD_PROFILING_ENABLED",
    "value": "false"
},
{
    "name": "DD_SERVICE",
    "value": "${service_name}"
},
{
    "name": "DD_TRACE_SAMPLE_RATE",
    "value": "0.2"
},
{
    "name": "DATADOG_LOGGING_ENABLED",
    "value": "true"
},
{
    "name": "MICRONAUT_ENVIRONMENTS",
    "value": "${micronaut_environment}"
}
