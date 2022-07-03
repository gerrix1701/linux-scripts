#!/bin/bash
###############################################################
# new_jekyll_post.sh
###############################################################
#
# Create new Jekyll post template
#
# 1. Please adjust settings below
# 2. run script (put new title in quotes):
#    $ ./new_jekyll_post.sh "My new post title"
#
###############################################################
#
# Version 0.1, 02/2022 Gerrit <gerrit@funzt.info>
# - initial release
#
###############################################################
#
#
###############################################################
## please set these variables according to your environment:
###############################################################
# path to your Jekyll "_posts" directory:
post_path=

# name of author (probably you ;-) )
author=""

# comments enabled? either "false" or "true"
comments=false

# post layout, depending on your theme, i.e. "single"
layout=single

# your blog's base url
url=
###############################################################


### no need to change anything below here ###

if [ -z "$1" ]; then
  echo "ERROR: missing title"
  echo "INFO: please run: $0 \"New blog title\""
  exit 1
fi

## variables
time=`date --rfc-3339=seconds`
d=`date +%d`
m=`date +%m`
y=`date +%Y`
slug=`echo $1 | sed -e 's/\ /-/g' | tr '[:upper:]' '[:lower:]'`
link=${url}/${y}/${m}/${slug}

## generate template
if [ ! -f ${post_path}/${y}-${m}-${d}-${slug}.markdown ]; then
  echo -e "---\nauthor: ${author}\ncomments: ${comments}\ndate: ${time}\nlayout: ${layout}\n\
link: ${link}\nslug: ${slug}\ntitle: $1\ncategories:\ntags:\n---" > ${post_path}/${y}-${m}-${d}-${slug}.markdown && echo "INFO: \"${y}-${m}-${d}-${slug}.markdown\" created."
else
  echo "ERROR: post already present, aborting."
fi

