#!/bin/bash

docker-compose -f docker-compose-orderer.yaml -f docker-compose-peer.yaml down

docker volume prune
