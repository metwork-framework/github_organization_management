#!/usr/bin/env python3

import uuid

tmp = str(uuid.uuid4()).replace('-', '')
print(tmp[0:10])
