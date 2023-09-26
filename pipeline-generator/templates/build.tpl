build-${service_name_full}:
  stage: build
  script:
    - |
      cd ${service_name_full}
      mkdir -p graal && cp -R ../graal/* graal/
      AWS_DEFAULT_REGION=us-west-2 ./mvnw -B -Dmaven\.test\.skip=true package
  artifacts:
    untracked: true
    paths:
      - ${service_name_full}/target/*.jar
    expire_in: 4 hours
  dependencies:
    - test-${service_name_full}
  rules:
    - if: '${service_name_variable} == "true" && $BUILD_TYPE == "service"'
      when: always
    - if: '$FULL_DEPLOY == "true"'
      when: always
    - if: '${service_name_variable} == "true"'
      when: always
    - if: '($BUILD_TYPE == "image" || $BUILD_TYPE == "promote" || $BUILD_TYPE == "promote_tag")'
      allow_failure: false
      changes:
        - micronaut-shared/pom.xml
        - pom.xml
        - "${service_name_full}/**/*"


coverage-report-${service_name_full}:
  stage: build
  allow_failure: true
  image: registry.gitlab.com/haynes/jacoco2cobertura:1.0.7
  script:
    - cd ${service_name_full}

    # convert report from jacoco to cobertura, using relative project path
    - |
      if test -f "target/site/jacoco/jacoco.xml"; then
        python /opt/cover2cover.py target/site/jacoco/jacoco.xml $CI_PROJECT_DIR/src/main/java/ > target/site/cobertura.xml
      fi
  needs: ["test-${service_name_full}"]
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: ${service_name_full}/target/site/cobertura.xml
  rules:
    - if: '${service_name_variable} == "true" && ($BUILD_TYPE == "service" && $CI_COMMIT_REF_NAME == "develop")'
      when: always
    - if: '$FULL_DEPLOY == "true"'
      when: never
    - if: '$BUILD_TYPE == "image" || $BUILD_TYPE == "branch"'
      changes:
        - micronaut-shared/pom.xml
        - pom.xml
        - "${service_name_full}/**/*"
