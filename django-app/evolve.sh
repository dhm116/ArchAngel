#!/bin/bash
./manage.py syncdb
./manage.py evolve --hint --execute