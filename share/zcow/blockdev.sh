#!/usr/bin/env bash

function blockdev_get_size()
{
	local dev="$1"

	blockdev --getsize64 "$dev"
}

function blockdev_get_sector_size()
{
	local dev="$1"

	blockdev --getsz "$dev"
}
