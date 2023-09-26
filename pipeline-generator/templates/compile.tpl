image-${service_name_full}:
  stage: compile
  before_script:
    - source ci/setup-env.sh
    - aws ecr get-login-password  --region us-west-2 | docker login --username AWS --password-stdin $${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com
    - sh ci/deploy.sh existsonly ${service_name_full}
  script:
    - |
      cd ${service_name_full}
      mkdir -p graal && cp -R ../graal/* graal/
      docker run --rm --privileged $${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/qemu-user-static --reset -p yes
      source ../ci/assume-role.sh
      aws ecr get-login-password  --region $${AWS_BUILD_REGION} | docker login --username AWS --password-stdin $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com
      env DOCKER_CLI_EXPERIMENTAL=enabled docker buildx create --name wtbuilder --driver docker-container
      env DOCKER_CLI_EXPERIMENTAL=enabled docker buildx use wtbuilder
      env DOCKER_CLI_EXPERIMENTAL=enabled docker buildx ls
      env DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --platform linux/arm64 -f Dockerfile-release --build-arg image_type=$${DOCKER_IMAGE_TYPE} -t $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV}-arm64 --push .
      env DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --platform linux/amd64 -f Dockerfile-release --build-arg image_type=$${DOCKER_IMAGE_TYPE} -t $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV}-amd64 --push .
      docker manifest create $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV} $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV}-arm64 $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV}-amd64
      docker manifest push $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV}
      docker manifest create $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${CI_COMMIT_SHA} $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV}-arm64 $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${DEPLOYMENT_ENV}-amd64
      docker manifest push $${AWS_ACCOUNT}.dkr.ecr.$${AWS_BUILD_REGION}.amazonaws.com/${spec}/${service_name}:$${CI_COMMIT_SHA}
  dependencies:
    - build-${service_name_full}
  rules:
    - if: '${service_name_variable} == "true" && $BUILD_TYPE == "service"'
      when: always
    - if: '$FULL_DEPLOY == "true"'
      when: always
    - if: '($BUILD_TYPE == "image" || $BUILD_TYPE == "promote" || $BUILD_TYPE == "promote_tag")'
      changes:
        - pom.xml
        - micronaut-shared/pom.xml
        - "${service_name_full}/**/*"

task-definition-${service_name_full}:
  stage: compile
  image: registry.gitlab.com/gitlab-org/terraform-images/stable:latest
  before_script:
    - source ci/setup-env.sh
  script:
    - |
      export TF_VAR_image_tag=$${CI_COMMIT_SHA}
      git clone --depth=1 https://gitlab-ci-token:$${CI_JOB_TOKEN}@gitlab.com/mangopay/cicd-templates/
      cd cicd-templates/v2-test/task-definition
      terraform init
      terraform apply -auto-approve -var-file=$${CI_PROJECT_DIR}/${service_name_full}/ci/$${AWS_ENV}.tfvars -var=ci_project_dir=$${CI_PROJECT_DIR}
      cat $${CI_PROJECT_DIR}/${service_name_full}/ci/$${AWS_ENV}.tfvars | grep "cluster" | tr -d '[:space:]' | sed 's/cluster=//' > $${CI_PROJECT_DIR}/${service_name_full}/ci/cluster
  artifacts:
    untracked: true
    paths:
      - ${service_name_full}/ci/task_definition.json
      - ${service_name_full}/ci/cluster
    expire_in: 4 hours
  dependencies:
    - build-${service_name_full}
  rules:
    - if: '${service_name_variable} == "true" && ($BUILD_TYPE == "service" && $CI_COMMIT_REF_NAME != "develop")'
      when: always
    - if: '$FULL_DEPLOY == "true" && ($BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME =~ /sandbox-v.*/ || $BUILD_TYPE == "promote" || $BUILD_TYPE == "promote_tag" || $CI_COMMIT_REF_NAME == "main")'
      when: always
    - if: '($BUILD_TYPE == "image" && $CI_COMMIT_REF_NAME =~ /sandbox-v.*/ || $BUILD_TYPE == "promote" || $BUILD_TYPE == "promote_tag")'
      changes:
        - pom.xml
        - micronaut-shared/pom.xml
        - "${service_name_full}/**/*"
