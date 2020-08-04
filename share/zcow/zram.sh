#!/usr/bin/env bash

function zram_info()
{
	local dev="$1"

	zramctl "$dev"
}

function zram_create()
{
	local size="$1"

	zramctl -f -s "$size"
}

function zram_destroy() {
	local dev="$1"

	zramctl -r "$dev"
}
