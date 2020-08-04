#!/usr/bin/env bash

zcow_share_dir="${0%/*}/../share/zcow"
zcow_version="0.1.0"
zcow_prefix="zcow"

source "$zcow_share_dir/util.sh"
source "$zcow_share_dir/blockdev.sh"
source "$zcow_share_dir/dm.sh"
source "$zcow_share_dir/zram.sh"

function zcow_path()
{
	local name="$1"

	echo -n "/dev/mapper/${zcow_prefix}-${name}"
}

function zcow_list()
{
	local snapshot
	local name
	local origin_device
	local cow_device

	for dev in $(dm_list); do
		if [[ "$dev" == "${zcow_prefix}-"* ]]; then
			snapshot="$dev"
			name="${snapshot#${zcow_prefix}-}"
			origin_device="$(dm_get_origin_device "$snapshot")"
			cow_device="$(dm_get_cow_device "$snapshot")"

			echo -e "${name}\t${origin_device}\t${cow_device}"
		fi
	done
}

function zcow_info()
{
	local name="$1"
	local snapshot="$(zcow_path "$name")"

	if [[ ! -b "$snapshot" ]]; then
		error "snapshot $snapshot does not exist"
		return 1
	fi

	local origin_device="$(dm_get_origin_device "$snapshot")"
	local cow_device="$(dm_get_cow_device "$snapshot")"

	cat <<EOF
Origin:	$origin_device
COW:	$cow_device
EOF

	echo
	zram_info "$cow_device"
}

function zcow_create()
{
	local device="$1"
	local name="$2"
	local snapshot="$(zcow_path "$name")"

	if [[ -b "$snapshot" ]]; then
		error "snapshot $snapshot already exists"
		return 1
	fi

	local device_size="$(blockdev_get_size "$device")"

	if [[ -z "$device_size" ]]; then
		error "unable to get size of $device"
		return 1
	fi

	local zram_device="$(zram_create "$device_size")"

	if [[ -z "$zram_device" ]]; then
		error "failed to create zram device of size $device_size"
		return 1
	fi

	dm_create_snapshot "${snapshot##*/}" "$device" "$zram_device" || {
		error "failed to create snapshot $snapshot device for $device"

		zram_destroy "$zram_device"
		return 1
	}
}

function zcow_remove()
{
	local name="$1"
	local snapshot="$(zcow_path "$name")"

	if [[ ! -b "$snapshot" ]]; then
		error "snapshot $snapshot does not exist"
		return 1
	fi

	local zram_device="$(dm_get_cow_device "$snapshot")"

	if [[ -z "$zram_device" ]]; then
		error "failed to query zram COW device for $snapshot"
		return 1
	fi

	dm_destroy "$snapshot" || {
		error "failed to remove snapshot $snapshot"
		return 1
	}

	zram_destroy "$zram_device" || {
		error "failed to remove zram device $zram_device"
		return 1
	}
}
