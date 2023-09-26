publish-${service_name_full}:
  stage: publish-api
  script:
    - echo "Service name = ${service_name_full} and module type = ${module_type}"
    - cd ${service_name_full}
    - AWS_DEFAULT_REGION=us-west-2 ./mvnw versions:set -DnewVersion=`echo -e "$CI_COMMIT_TAG" | sed -e "s/\.RELEASE//g"`
    - AWS_DEFAULT_REGION=us-west-2 ./mvnw -B deploy
  needs: ["test-${service_name_full}"]
  rules:
    - if: '"${module_type}" != "api"'
      when: never
    - if: '"${module_type}" == "api"'
      changes:
        - ${service_name_full}/**/*
        - .gitlab-ci.yml