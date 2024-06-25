#!/usr/bin/env bash

export MESSAGE="$1"
export REPO="$2"
export DESTINATION_BRANCH="main"
export FILE_TO_COMMIT="package.json"
VERSION=v$(cat package.json | jq -r .version)

export SHA=$( git rev-parse $DESTINATION_BRANCH:$FILE_TO_COMMIT )
export LAST_COMMIT_SHA=$(git rev-parse origin/$DESTINATION_BRANCH)
export CONTENT=$( base64 -i $FILE_TO_COMMIT )

echo "/repos/thomassloboda/$REPO/contents/$FILE_TO_COMMIT"

gh api --method PUT /repos/thomassloboda/$REPO/contents/$FILE_TO_COMMIT \
  --field message="$MESSAGE" \
  --field content="$CONTENT" \
  --field encoding="base64" \
  --field branch="$DESTINATION_BRANCH" \
  --field sha="$SHA"

echo "/repos/thomassloboda/$REPO/git/tags"
TAG_SHA=$(gh api -X POST /repos/thomassloboda/$REPO/git/tags -f tag="$VERSION" -f message="Tag for version $VERSION" -f object="$LAST_COMMIT_SHA" -f type='commit' | jq -r .sha)

echo "/repos/thomassloboda/$REPO/git/refs"
gh api -X POST /repos/thomassloboda/$REPO/git/refs -f ref="refs/tags/$VERSION" -f sha="$TAG_SHA"

echo "/repos/thomassloboda/$REPO/git/releases"
gh api -X POST /repos/thomassloboda/$REPO/releases -f tag_name="$VERSION" -f name="$VERSION" -f body="This is a release of version $VERSION"