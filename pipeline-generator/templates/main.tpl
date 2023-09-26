stages:
  - triggers
  - install-parent-pom
  - test-base
  - deploy-base
  - test-api
  - publish-api
  - test
  - build
  - compile
  - deploy

variables:
    FULL_DEPLOY: "${full_deploy}"
    LOG_CONTAINERS: "${log_containers}"
    MODULE_TYPE: "${module_type}"
    %{ for service in services ~}${service}: "true"
    %{ endfor ~}
%{ if length(services) > 0 }SPECIFIC_SERVICE_DEPLOY: "true"%{ endif }
workflow:
  rules:
    - if: '$MODULE_TYPE == "api"'
      when: always
    - if: '$SPECIFIC_SERVICE_DEPLOY == "true"'
      when: always
      variables:
        BUILD_TYPE: service
    - if: '$CI_COMMIT_REF_NAME == "develop"'
      when: always
      variables:
        BUILD_TYPE: image
    - if: '$CI_COMMIT_REF_NAME == "main"'
      when: always
      variables:
        BUILD_TYPE: image
    - if: '$CI_COMMIT_REF_NAME =~ /sandbox-v.*/'
      when: always
      variables:
        BUILD_TYPE: image
    - if: "$CI_COMMIT_REF_NAME =~ /prod-v.*/"
      when: always
      variables:
        BUILD_TYPE: promote_tag
    - if: "$CI_COMMIT_REF_NAME != 'develop' || $CI_COMMIT_REF_NAME =~ /sandbox-v.*/ || $CI_COMMIT_REF_NAME =~ /prod-v.*/ || $CI_COMMIT_REF_NAME != 'main'"
      when: always
      variables:
        BUILD_TYPE: branch

include:
  - project: 'mangopay/cicd-templates'
    ref: ${pipeline_branch}
    file: 'v2-test/main/main.yml'
  - project: 'mangopay/cicd-templates'
    ref: ${pipeline_branch}
    file: 'v2-test/parent-pom/parent-pom.yml'
  - project: 'mangopay/cicd-templates'
    ref: ${pipeline_branch}
    file: 'v2-test/base/base.yml'
  - project: 'mangopay/cicd-templates'
    ref: ${pipeline_branch}
    file: 'v2-test/functional-test/functional-test.yml'
  - project: 'mangopay/cicd-templates'
    ref: ${pipeline_branch}
    file: 'v2-test/custom-triggers/graphql.yml'
