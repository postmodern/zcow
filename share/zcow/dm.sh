#!/usr/bin/env bash

source "$zcow_share_dir/blockdev.sh"

function dm_list()
{
	dmsetup ls --target snapshot --exec basename
}

function dm_create_snapshot()
{
	local name="$1"
	local origin="$2"
	local snapshot="$3"
	local sector_size="$(blockdev_get_sector_size "$origin")"

	if [[ -z "$sector_size" ]]; then
		error "unable to get size of $origin"
		return 1
	fi

	local table="0 $sector_size snapshot $origin $snapshot N 8"

	dmsetup create "$name" --table "$table"
}

function dm_get_table()
{
	local name="$1"

	dmsetup table "$name"
}

function udev_lookup_blockdev()
{
	local major_minor="$1"
	local blockdev_sys_dir="/sys/dev/block/$major_minor"

	udevadm info -r -q name "$blockdev_sys_dir" 2>/dev/null
}

function dm_get_origin_device()
{
	local name="$1"
	local major_minor="$(dm_get_table "$name" | cut -d' ' -f4)"

	udev_lookup_blockdev "$major_minor"
}

function dm_get_cow_device()
{
	local name="$1"
	local major_minor="$(dm_get_table "$name" | cut -d' ' -f5)"

	udev_lookup_blockdev "$major_minor"
}

function dm_destroy()
{
	local name="$1"

	dmsetup remove "$name"
}
