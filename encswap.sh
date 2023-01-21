#!/bin/bash
set -e

. /etc/encswap.conf

run_swapon() {
    if [ -e /dev/mapper/encswapSwapFile ] ; then
        # This is unexpected and should not happen, because the swap should only be mounted
        # right before hibernation. We don't add the swap to /etc/fstab and do not try to
        # mount it in other circumstances. So if we got here, then something went wrong...
        # However, do not use swapoff because swapoff can potentially take a long time to
        # finish, and we do not want to unnecessarily delay the suspension request.
        echo "encswap: /dev/mapper/encswapSwapFile already mounted. Did not refresh key."
        return 1
    fi
    echo "encswap: Turning on swap"
    head -c "${swapkeyfilesize}" /dev/urandom | install -m 0600 /dev/stdin "${swapkeyfile}"
    cryptsetup open --type plain --cipher aes-xts-plain64:sha256 --key-file "${swapkeyfile}" "${swapdev}" encswapSwapFile ${swapdevopts}
    mkswap /dev/mapper/encswapSwapFile
    swapon /dev/mapper/encswapSwapFile
    echo "encswap: Finished turning on swap"
}

run_swapoff() {
    if [ ! -e /dev/mapper/encswapSwapFile ] ; then
        # Unexpectedly, the swap disappeared after resume...?
        echo "encswap: /dev/mapper/encswapSwapFile not found"
        return 0
    fi
    echo "encswap: Turning off swap"
    # shred is not reliable on SSD (i.e. file content can still be available).
    # However the location of the swapfile should be encrypted anyway, so the risk of a not 100% working shred is minimal.
    shred -n1 --remove "${swapkeyfile}"
    swapoff /dev/mapper/encswapSwapFile
    cryptsetup close encswapSwapFile
    echo "encswap: Finished turning off swap"
}

case "$1" in
    swapon)
        run_swapon
        ;;
    swapoff)
        run_swapoff
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
esac
