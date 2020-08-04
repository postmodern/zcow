#!/usr/bin/env bash

function zram_info()
{
	local dev="$1"

	modprobe zram && zramctl "$dev"
}

function zram_create()
{
	local size="$1"

	modprobe zram && zramctl -f -s "$size"
}

function zram_destroy() {
	local dev="$1"

	modprobe zram && zramctl -r "$dev"
}
