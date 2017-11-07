#!/bin/bash -e

# Push the 'conjur-policy-generator' image to the internal Docker registry
# Push stable images on master branch

cd "$(git rev-parse --show-toplevel)"

TAG="${1:-$(< VERSION)-$(git rev-parse --short HEAD)}"

SOURCE_IMAGE='conjur-policy-generator'
INTERNAL_IMAGE='registry.tld/cyberark/conjur-policy-generator'

function tag_and_push() {
    local image="$1"
    local tag="$2"
    local description="$3"

    echo "TAG = $tag, $description"

    docker tag "$SOURCE_IMAGE" "$image:$tag"
    docker push "$image:$tag"
}

tag_and_push $INTERNAL_IMAGE $TAG 'this branch'

if [[ "$BRANCH_NAME" == 'master' ]]; then
    latest_tag='latest'
    stable_tag="$(< VERSION)-stable"

    tag_and_push $INTERNAL_IMAGE $latest_tag 'latest image'
    tag_and_push $INTERNAL_IMAGE $stable_tag 'stable image'
fi
