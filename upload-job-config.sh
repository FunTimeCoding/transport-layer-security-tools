#!/bin/sh -e

~/src/jenkins-tools/bin/delete-job.sh transport-layer-security-tools || true
~/src/jenkins-tools/bin/put-job.sh transport-layer-security-tools job.xml
