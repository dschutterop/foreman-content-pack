#!/bin/bash
#
# __Requirements__
#
# In order for this hook to work you should have:
#
# Foreman running (duh)
# Foreman hooks installed (Foreman plugin)
# Graylog2 running with a GELF/HTTP input
# curl somewhere in your path
#
# __Summary__
#
# This foreman hook logs creation/modification
# actions of a host to graylog2 for administration
# purposes.
#
# Please set your graylog2 host and GELF HTTP port
# where the <logHost=graylog2.example.com>
# and logPort='12201' reside
#
# Parameters: $1 : Set by Foreman, the hook that
# is called (and then transformed
# into the $action variable)
# $2 : Set by Foreman, the hostname
# on which the action has
# taken place
#
# This foreman hook should be placed in
# ~foreman/config/hooks/host/managed and could be
# symbolically linked to the following events
# (directories):
# * after_build
# * before_provision
# * create
# * destroy
# * logToGraylog2.sh
# * update
#
# __What does it log?__
#
# This script logs the following fields to your
# graylog2 host:
#
# short_message (mandatory) information on the
# action that was performed by
# Foreman.
# host (mandatory)
# facility (mandatory)
# _foremanAction (content of the $1 variable)
# _foremanHost (content of the $2 variable)
# _foremanCount (Numeric field, easier to get
# statistics on Foreman actions)
#
# __Author__
# D. Schutterop
# daniel@schutterop.nl
# 2014
#
#
logHost='graylog2.example.com'
logPort='12201'
if [ -z $1 ]; then
	echo 'Foreman did not pass the first parameter'
else
	if [ -z $2 ]; then
		echo 'Foreman did not pass the second parameter'
	else
		hostname=`hostname -f`
		case $1 in
			'create') action='created'
			;;
			'update') action='updated'
			;;
			'destroy') action='destroyed'
			;;
			'after_build') action='put into build mode'
			;;
			'before_provision') action='installed, it is now finished and can now be provisioned'
			;;
			*) action='doing some incredible stuff I have not documented or implemented yet... Sorry'
			;;
		esac
		$(which curl) -XPOST http://$logHost:$logPort/gelf -p0 -d "{
			\"short_message\":\"Foreman: Host ${2} was just ${action}\",
			\"host\":\"${hostname}\",
			\"facility\":\"info\",
			\"_foremanAction\":\"${1}\",
			\"_foremanHost\":\"${2}\",
			\"_foremanCount\":1
		}"
	fi
fi
