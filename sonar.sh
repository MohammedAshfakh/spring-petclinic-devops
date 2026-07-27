#!/bin/bash

username=sonar
password=sonar
database=sonardb
network=sonarnet
image=sonarqube:26.7.0.124771-community
postgres=postgres:18


docker network create $network 2>/dev/null


sleep 5

docker run -d \
	--name postgres \
	--restart unless-stopped \
	--network $network \
	-e POSTGRES_USER=$username \
	-e POSTGRES_PASSWORD=$password \
	-e POSTGRES_DB=$database \
	$postgres

sleep 5 

docker pull $image


docker run -d \
	--name sonarqube \
	--network $network \
	--restart unless-stopped \
	-p 9000:9000 \
	-e SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/$database \
	-e SONAR_JDBC_USERNAME=$username \
	-e SONAR_JDBC_PASSWORD=$password \
	$image


echo "CREATED NETWORK, POSTGRESS DATABASE AND SONARQUBE, MAPPED WITH SAME NETWORK WHICH THEY CAN TALK INTERNALLY"
