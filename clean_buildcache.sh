#!/bin/bash

find /buildcache -type f -mtime +7 -exec rm -f {} \; >/dev/null 2>&1
chown -RL metworkpub:metworkpub /buildcache
chmod -R 755 /buildcache
