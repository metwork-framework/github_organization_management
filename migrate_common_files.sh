#!/bin/bash

find common_files -type f -exec ./_migrate_common_files.sh {} \;
