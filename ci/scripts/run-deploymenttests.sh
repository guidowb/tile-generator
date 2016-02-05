#!/bin/sh -e

TILE_DIR="$( cd "$1" && pwd )"
POOL_DIR="$( cd "$2" && pwd )"

MY_DIR="$( cd "$( dirname "$0" )" && pwd )"
REPO_DIR="$( cd "${MY_DIR}/../.." && pwd )"
BASE_DIR="$( cd "${REPO_DIR}/.." && pwd )"
TEST_DIR="$( cd "${REPO_DIR}/ci/deployment-tests" && pwd )"

TILE_FILE=`cd "${TILE_DIR}"; ls *.pivotal`
if [ -z "${TILE_FILE}" ]; then
	echo "No files matching ${TILE_DIR}/*.pivotal"
	ls -lR "${TILE_DIR}"
	exit 1
fi

PRODUCT=`echo "${TILE_FILE}" | sed "s/-[^-]*$//"`
VERSION=`echo "${TILE_FILE}" | sed "s/.*-//" | sed "s/\.pivotal\$//"`

cd "${POOL_DIR}"

echo "Available products:"
python "${TEST_DIR}/pcf" products
echo

echo "Uploading ${TILE_FILE}"
python "${TEST_DIR}/pcf" import "${TILE_DIR}/${TILE_FILE}"
echo

echo "Available products:"
python "${TEST_DIR}/pcf" products
python "${TEST_DIR}/pcf" is-available "${PRODUCT}" "${VERSION}"
echo

echo "Installing product ${PRODUCT} version ${VERSION}"
python "${TEST_DIR}/pcf" install "${PRODUCT}" "${VERSION}"
echo

echo "Available products:"
python "${TEST_DIR}/pcf" products
python "${TEST_DIR}/pcf" is-installed "${PRODUCT}" "${VERSION}"
echo

echo "Configuring product ${PRODUCT}"
python "${TEST_DIR}/pcf" configure "${PRODUCT}" "${REPO_DIR}/sample/missing-properties.yml"
echo

echo "Applying Changes"
python "${TEST_DIR}/pcf" apply-changes
echo
