#!/bin/sh

while true; do
	git pull origin main
	mkdocs build
	sleep 60
done
