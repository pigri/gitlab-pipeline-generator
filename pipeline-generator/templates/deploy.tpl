.ecs_image-${service_name_full}:
  image: "registry.gitlab.com/gitlab-org/cloud-deploy/aws-ecs:latest"

.deploy_to_ecs-${service_name_full}:
  extends: .ecs_image-${service_name_full}
  dependencies: []
  variables:
    CI_AWS_ECS_CLUSTER: ${cluster}
    CI_AWS_ECS_SERVICE: ${service_name}
    CI_AWS_ECS_TASK_DEFINITION_FILE: ${service_name_full}/ci/task_definition.json
  before_script:
    - source ci/setup-env.sh
    - source ci/assume-role.sh
  script:
    - ecs update-task-definition


deploy-${service_name_full}-development:
  stage: deploy
  script:
    - bash ci/deploy.sh deploy ${service_name_full}
  dependencies:
    - image-${service_name_full}
    - task-definition-${service_name_full}
  rules:
    - if: '$FULL_DEPLOY == "true" && ($BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME == "develop")'
      when: always
    - if: '${service_name_variable} == "true" && ($BUILD_TYPE == "service" && $CI_COMMIT_REF_NAME == "develop")'
      when: always
    - if: '$BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME == "develop"'
      changes:
        - "aws/**/*"
        - pom.xml
        - micronaut-shared/pom.xml
        - "${service_name_full}/**/*"

# deploy-${service_name_full}-development:
#   stage: deploy
#   extends: .deploy_to_ecs-${service_name_full}
#   dependencies:
#     - image-${service_name_full}
#     - task-definition-${service_name_full}
#   rules:
#     - if: '$AUTO_DEVOPS_PLATFORM_TARGET != "FARGATE"'
#       when: never
#     - if: '$CI_KUBERNETES_ACTIVE'
#       when: never
#     - if : '$FULL_DEPLOY == "true" && ($BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME == "develop")'
#       when: always
#     - if: '$BUILD_TYPE == "image"'
#       when: always
#     - if: '$FULL_DEPLOY == "true"'
#       when: always
#     - if: "'${service_name_variable} == "true"'"
#       when: always
#     - if: '$BUILD_TYPE == "image"'
#       changes:
#         - micronaut-shared/pom.xml
#         - "${service_name_full}/**/*"


deploy-${service_name_full}-staging:
  stage: deploy
  extends: .deploy_to_ecs-${service_name_full}
  dependencies:
    - image-${service_name_full}
    - task-definition-${service_name_full}
  rules:
    - if: '$AUTO_DEVOPS_PLATFORM_TARGET != "FARGATE"'
      when: never
    - if: '$CI_KUBERNETES_ACTIVE'
      when: never
    - if: '$FULL_DEPLOY == "true" && ($BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME == "main")'
      when: always
    - if: '${service_name_variable} == "true" && ($BUILD_TYPE == "service" && $CI_COMMIT_REF_NAME == "main")'
      when: always
    - if: '$BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME == "main"'
      changes:
        - pom.xml
        - micronaut-shared/pom.xml
        - "${service_name_full}/**/*"


deploy-${service_name_full}-sandbox:
  stage: deploy
  extends: .deploy_to_ecs-${service_name_full}
  dependencies:
    - image-${service_name_full}
    - task-definition-${service_name_full}
  rules:
    - if: '$AUTO_DEVOPS_PLATFORM_TARGET != "FARGATE"'
      when: never
    - if: '$CI_KUBERNETES_ACTIVE'
      when: never
    - if: '${service_name_variable} == "true" && ($BUILD_TYPE == "service" && $CI_COMMIT_REF_NAME =~ /sandbox-v.*/)'
      when: always
    - if : '$FULL_DEPLOY == "true" && ($BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME =~ /sandbox-v.*/)'
      when: always
    - if: '$BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME =~ /sandbox-v.*/'
      changes:
        - pom.xml
        - micronaut-shared/pom.xml
        - "${service_name_full}/**/*"

deploy-${service_name_full}-production:
  stage: deploy
  extends: .deploy_to_ecs-${service_name_full}
  dependencies:
    - image-${service_name_full}
    - task-definition-${service_name_full}
  rules:
    - if: '$AUTO_DEVOPS_PLATFORM_TARGET != "FARGATE"'
      when: never
    - if: "$CI_KUBERNETES_ACTIVE"
      when: never
    - if: '${service_name_variable} == "true" && ($BUILD_TYPE == "service" && $CI_COMMIT_REF_NAME =~ /prod-v.*/)'
      when: always
    - if: '$FULL_DEPLOY == "true" && ($BUILD_TYPE == "promote" || $BUILD_TYPE == "promote_tag")'
      when: always
    - if: '$BUILD_TYPE == "promote" || $BUILD_TYPE == "promote_tag"'
      changes:
        - pom.xml
        - micronaut-shared/pom.xml
        - "${service_name_full}/**/*"
