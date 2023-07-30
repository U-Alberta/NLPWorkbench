#! /bin/sh
set -e # exit on error

COMMAND=$1
SERVICE=$2

if [ -z "$COMMAND" ]; then
    echo "usage: $0 <command> <service>"
    echo "commands: build, test, build-test, cleanup, cleanup-all, coverage"
    echo "service: optional, a service defined in docker-compose.dev.yml"
    exit 1
fi

set -x
if [ -z "$CI_COMMIT_SHORT_SHA" ]; then
    # local testing
    CI_COMMIT_SHORT_SHA="local"
    CI_JOB_NAME=$SERVICE
    COVERAGE_FOLDER="/tmp/coverages_`whoami`"
    mkdir -p $COVERAGE_FOLDER
    chmod 777 $COVERAGE_FOLDER
else
    # CI testing
    # because of docker socket binding, we are mounting
    # a path OF THE HOST into the container.
    # On the host, /home/shared/coverages is mounted to /home/shared/coverages of the gitlab runner executor container
    # This is configured in gitlab-runner/config.toml
    COVERAGE_FOLDER="/data/local/workbench-data/coverages"
fi
export COVERAGE_FOLDER

# name docker images differently for each commit and each service to avoid collision
CI_PROJ_PREFIX="Workbench-CI"
CI_PROJ_PREFIX=$(echo "${CI_PROJ_PREFIX}" | tr '[:upper:]' '[:lower:]')
COMMIT_PROJ="${CI_PROJ_PREFIX}-${CI_COMMIT_SHORT_SHA}"
COMMIT_PROJ=$(echo "${COMMIT_PROJ}" | tr '[:upper:]' '[:lower:]')
PROJ="${COMMIT_PROJ}-${SERVICE}"
# docker compose project name can only have lower case letters
PROJ=$(echo "${PROJ}" | tr '[:upper:]' '[:lower:]')
IMAGE="${PROJ}_${SERVICE}"

# patch docker-compose.dev.yml to mount coverage folder and set build target
if [ ! -z $SERVICE ]; then
    mkdir -p ${COVERAGE_FOLDER}/${SERVICE}/
    docker build -t patch_compose -f build/Dockerfile.patching .
    docker run --rm -i patch_compose $SERVICE < docker-compose.dev.yml > docker-compose.testing.yml
fi

case $COMMAND in
    "build")
        docker compose -f docker-compose.testing.yml --profile non-gpu --profile gpu -p $PROJ build $SERVICE
        ;;
    "test") 
        docker compose -f docker-compose.testing.yml --profile non-gpu --profile gpu -p $PROJ up --build --abort-on-container-exit --always-recreate-deps --attach-dependencies --renew-anon-volumes $SERVICE
        mv ${COVERAGE_FOLDER}/${SERVICE}/.coverage ${CI_JOB_NAME}.coverage
        ;;
    "build-test")
        echo "build-test"
        $0 build $SERVICE
        $0 test $SERVICE
        ;;
    "cleanup")
        echo "cleanup"
        docker compose -f docker-compose.testing.yml --profile non-gpu --profile gpu -p $PROJ down -v || true
        docker rmi -f $(docker images --filter=reference="${PROJ}_*" -q) || true
        docker network rm $(docker network ls --filter=name="${PROJ}_*" -q) || true
        docker volume prune -f || true
        ;;
    "cleanup-all")
        echo "cleanup-all"
        docker stop $(docker ps --filter="name=${COMMIT_PROJ}-*" -q) || true
        docker rmi -f $(docker images --filter=reference="${COMMIT_PROJ}-*" -q) || true
        docker network rm $(docker network ls --filter=name="${COMMIT_PROJ}-*" -q) || true
        docker volume prune -f || true
        ;;
    "cleanup-ci")
        echo "cleanup-ci"
        docker stop $(docker ps --filter="name=${CI_PROJ_PREFIX}-*" -q) || true
        docker rmi -f $(docker images --filter=reference="${CI_PROJ_PREFIX}-*" -q) || true
        docker network rm $(docker network ls --filter=name="${CI_PROJ_PREFIX}-*" -q) || true
        docker volume prune -f || true
        ;;
    "cleanup-on-failure")
        if [ $CI_JOB_STATUS == 'success' ]; then
            echo 'job succeeded. no cleanup needed'
        else
            docker network prune -f || true
            $0 cleanup-all
        fi
        ;;
    "coverage")
        coverage combine *.coverage
        coverage report --precision=2
        ;;
esac
