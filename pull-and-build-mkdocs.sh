#!/bin/sh

while true; do
	git pull origin main
  cd mkdocs && mkdocs build
	sleep 60
done
