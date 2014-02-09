msvm
====

msvm, or "**M**inecraft **S**erver **V**ersion **M**anager", is a BASH
script application for managing minecraft server versions. It allows
you to easily download and manage *official* versions (ie: versions
published by Mojang via their
[JSON API](http://s3.amazonaws.com/Minecraft.Download/versions/versions.json))


## Installation

Currently, the only documented way to install will be using `msvm-init`.
This prints the changes you will need to make for your shell profile in
order to use `msvm` in your terminal.

```bash
$ git clone git@github.com:dominicbarnes/msvm.git ~/.msvm
$ cd ~/.msvm
$ bin/msvm init
```

In the near future, there will be a more "permanent" installation
process that puts the scripts into `/usr/local`.


## Dependencies

 * `curl`
 * [`jq`](http://stedolan.github.io/jq/) (v1.3+)

**NOTE** Ubuntu only has jq *v1.2* in it's repositories, you'll need
to download a more recent binary and install it manually in order to
use msvm.


## Usage

To output the current version of msvm

    $ msvm version

To install the latest official release

    $ msvm get

To output the list of currently installed versions

    $ msvm ls
    
To output the path to the latest official release

    $ msvm path

Use `msvm help <command>` for further usage information.
