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
    COVERAGE_FOLDER="/tmp/coverages"
    mkdir -p $COVERAGE_FOLDER
    chmod 777 $COVERAGE_FOLDER
else
    # CI testing
    # because of docker socket binding, we are mounting
    # a path OF THE HOST into the container.
    # On the host, /home/shared/coverages is mounted to /home/shared/coverages of the gitlab runner executor container
    # This is configured in gitlab-runner/config.toml
    COVERAGE_FOLDER="/home/shared/coverages"
fi
export COVERAGE_FOLDER

# name docker images differently for each commit to avoid collision
PROJ="Workbench-CI-${CI_COMMIT_SHORT_SHA}"
# docker compose project name can only have lower case letters
PROJ=$(echo "${PROJ}" | tr '[:upper:]' '[:lower:]')
IMAGE="${PROJ}_${SERVICE}"

# patch docker-compose.dev.yml to mount coverage folder and set build target
if [ ! -z $SERVICE ]; then
    docker build -t patch_compose -f build/Dockerfile.patching .
    docker run --rm -i patch_compose $SERVICE < docker-compose.dev.yml > docker-compose.testing.yml
fi

case $COMMAND in
    "build")
        docker compose -f docker-compose.testing.yml --profile non-gpu --profile gpu -p $PROJ build $SERVICE
        ;;
    "test") 
        docker compose -f docker-compose.testing.yml --profile non-gpu --profile gpu -p $PROJ up --abort-on-container-exit $SERVICE
        mv ${COVERAGE_FOLDER}/.coverage ${CI_JOB_NAME}.coverage
        ;;
    "build-test")
        echo "build-test"
        $0 build $SERVICE
        $0 test $SERVICE
        ;;
    "cleanup")
        echo "cleanup"
        # FIXME: dependent services are not stopped
        docker compose -f docker-compose.testing.yml --profile non-gpu --profile gpu -p $PROJ stop $SERVICE || true
        docker rmi -f $(docker images --filter=reference="${IMAGE}" -q) || true
        docker network rm $(docker network ls --filter=name="${PROJ}_*" -q) || true
        docker volume prune -f || true
        ;;
    "cleanup-all")
        echo "cleanup-all"
        docker compose -f docker-compose.testing.yml --profile non-gpu --profile gpu -p $PROJ down -v || true
        docker rmi -f $(docker images --filter=reference="${PROJ}_*" -q) || true
        docker network rm $(docker network ls --filter=name="${PROJ}_*" -q) || true
        docker volume prune -f || true
        ;;
    "coverage")
        coverage combine *.coverage
        coverage report --precision=2
        ;;
esac