test-${service_name_full}:
  stage: test
  coverage: '/([0-9]{1,3}.[0-9]*).%.covered/'
  script:
    - cd ${service_name_full}
    - mkdir -p graal && cp -R ../graal/* graal/
    - AWS_DEFAULT_REGION=us-west-2 ./mvnw -U -Dmicronaut.env.deduction=false -B verify
#    - AWS_DEFAULT_REGION=us-west-2 ./mvnw -Dmicronaut.env.deduction=false -B site
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
#    paths:
#      - ${service_name_full}/target/site/
  rules:
    - if: '${service_name_variable} == "true" && ($BUILD_TYPE == "service" && $CI_COMMIT_REF_NAME == "develop")'
      when: always
    - if: '$FULL_DEPLOY == "true"'
      when: never
    - if: '$BUILD_TYPE == "image" || $BUILD_TYPE == "branch"'
      changes:
        - pom.xml
        - micronaut-shared/pom.xml
        - "${service_name_full}/**/*"
