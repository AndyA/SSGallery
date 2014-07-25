#!/bin/bash

echo 'UPDATE ss_image SET seq = RAND()' | mysql -uroot ss

# vim:ts=2:sw=2:sts=2:et:ft=sh

