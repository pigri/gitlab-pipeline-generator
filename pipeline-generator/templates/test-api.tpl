test-${service_name_full}:
  stage: test-api
  coverage: '/([0-9]{1,3}.[0-9]*).%.covered/'
  script:
    - echo "Service name = ${service_name_full} and module type = ${module_type}"
    - cd ${service_name_full}
    - AWS_DEFAULT_REGION=us-west-2 ./mvnw -U -B install
    - |
      if [[ "$CI_COMMIT_REF_NAME" =~ /sandbox-v.*/ || "$BUILD_TYPE" == "promote_tag" ]]; then
          echo "Sandbox and production env Jacoco is not running!"
      else
          if test -f "target/jacoco-ut/jacoco.csv"; then
              if hash awk 2>/dev/null; then
                  awk -F"," '{ instructions += $4 + $5; covered += $5 } END { print covered, "/", instructions, " instructions covered"; print 100*covered/instructions, "% covered" }' target/jacoco-ut/jacoco.csv
              fi
          fi
      fi
  artifacts:
    reports:
      junit:
        - ${service_name_full}/target/surefire-reports/TEST-*.xml
  rules:
    - if: '"${module_type}" != "api"'
      when: never
    - if: '"${module_type}" == "api"'
      changes:
        - ${service_name_full}/**/*
        - .gitlab-ci.yml
        - pom.xml
    - if: '$BUILD_TYPE == "service"'
      when: never
    - if: '$FULL_DEPLOY == "true"'
      when: never
    - if: '${service_name_variable} == "true" && ("${module_type}" == "api" && $CI_COMMIT_REF_NAME == "develop")'
      when: always