#!/usr/bin/env bash

function error() { echo "error: $1" >&2; }
function fail()
{
	error "$1"
	exit -1
}
