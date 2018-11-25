#!/bin/bash
git checkout mainnet && git fetch && git reset --hard origin/mainnet && git clean -dxf
