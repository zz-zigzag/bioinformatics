#!/bin/bash

. 0.0.env.sh

extract="SimpleFeature -D $diff"

SVfeature -D $diff -b sample_info.list
