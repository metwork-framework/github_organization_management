#!/bin/bash

/bin/echo "docker size before clean " `/bin/du -sh /var/lib/docker`
/bin/echo y | /bin/docker system prune
/bin/echo "docker size after clean " `/bin/du -sh /var/lib/docker`
