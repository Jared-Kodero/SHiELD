#!/usr/bin/env bash
set -euo pipefail




mkdir -p ../SHiELD_backup


cp site/environment.gnu.sh ../SHiELD_backup/
cp oscar_build.sh ../SHiELD_backup/



if ! git remote | grep -q upstream; then
    git remote add upstream https://github.com/NOAA-GFDL/SHiELD_build.git
fi



git fetch upstream
git checkout main
git reset --hard upstream/main
git push origin main --force

cp ../SHiELD_backup/environment.gnu.sh site/
cp ../SHiELD_backup/oscar_build.sh .


git add oscar_build.sh
git commit -m "Sync oscar_build.sh with upstream changes"
git push origin main

rm -rf ../SHiELD_backup


./CHECKOUT_code
git submodule update --init mkmf

AFFINITY_FILE="../SHiELD_SRC/FMS/affinity/affinity.c"

if grep -q "static pid_t gettid(void)" "$AFFINITY_FILE"; then
    sed -i.bak 's/static pid_t gettid(void)/pid_t gettid(void)/' "$AFFINITY_FILE"
    echo "Modification complete."
else
    echo "Pattern not found. Skipping."
fi

echo "Starting SHiELD build..."
cd Build
./COMPILE 64bit gnu pic

echo "Build completed successfully."