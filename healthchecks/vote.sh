#!/bin/sh
if wget -q --spider http://127.0.0.1:5000/; then
  exit 0
else
  exit 1
fi