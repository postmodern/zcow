# zcow

Manages temporary [zram] backed COW (Copy On Write) devices. `zcow` uses
Device Mapper to combine a [zram] device and the origin device, such that
unchanged blocks are read from the origin device and written blocks are stored
in the [zram] device.

## Dependencies

* Linux
* `bash`
* `udevadm`
* `dmsetup`
* `zramctl`

## Synopsis

Create a zram device for `/dev/sda4`:

    $ zcow create /dev/sda4

Create a zcow device for `/dev/sda4`, but with the custom name
`foo`:

    $ zcow create /dev/sda4 foo

List all zcows:

    $ zcow
    vdc	/dev/vdc	/dev/zram0
    foo	/dev/vdc	/dev/zram1

Get info about the zcow named `foo`:

    $ zcow info foo
    Origin:	/dev/vdc
    COW:	/dev/zram1
    
    NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
    /dev/zram1 lzo-rle       100M   0B    0B    0B       8 

Remove the zcow named `foo`:

    $ zcow destroy foo

### systemd

Register a systemd unit that manages a zcow device for `/dev/sda4`:

    $ sudo systemctl enable zcow@/dev/sda4

## Install

    wget -O zcow-0.1.0.tar.gz https://github.com/postmodern/zcow/archive/v0.1.0.tar.gz
    tar -xzvf zcow-0.1.0.tar.gz
    cd zcow-0.1.0/
    sudo make install

### PGP

All releases are [PGP] signed for security. Instructions on how to import my
PGP key can be found on my [blog][1]. To verify that a release was not tampered
with:

    wget https://raw.github.com/postmodern/ruby-install/master/pkg/zcow-0.1.0.tar.gz.asc
    gpg --verify zcow-0.1.0.tar.gz.asc zcow-0.1.0.tar.gz

## Limitations

* Cannot work with loopback devices.
* Cannot mount zcow devices for some unknown reason:

      mount: /mnt: wrong fs type, bad option, bad superblock on /dev/mapper/zcow-test, missing codepage or helper program, or other error.

[zram]: https://www.kernel.org/doc/Documentation/blockdev/zram.txt

[PGP]: http://en.wikipedia.org/wiki/Pretty_Good_Privacy
[1]: http://postmodern.github.com/contact.html#pgp
