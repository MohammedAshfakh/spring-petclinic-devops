#!/bin/bash

./dependencies.sh
./install-docker.sh
./sonar.sh
./Jenkins.sh
echo "Installed Docker and some dependencies. created a Jenkins, sonarqube containers with Jenkins volume and Postgres for persistance volumes"
