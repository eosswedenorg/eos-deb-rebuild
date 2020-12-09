# EOS deb rebuild

This repository contains scripts used to rebuild debian packages created from [eosio](https://github.com/eosio/eos), [eosio.cdt](https://github.com/eosio/eosio.cdt) and related software to create different kinds of packages.

## Install/Uninstall

This project uses `make` to install files on a system.

You will also need to install [eos-deb-rebuild-info](https://github.com/eosswedenorg/eos-deb-rebuild-info) version `1.0.2` or greater.

run `sudo make install` and you should be able to execute the `eos-deb-rebuild` command after.

Run `sudo make uninstall` to remove.

## Package customization

The script can produce a veriety of customized packages

First there is package `type`:

* `standard` - Create a eosio package with updated/correct package info (some forks do not set their info correctly)

* `mv` - Create a eosio *multiversion* package (supports multiple versions to co-exists on a machine.)

* `cdt-mv` - Create a eosio.cdt *multiversion* package (supports multiple versions to co-exists on a machine.)

On top of this, it is possible to select a `flavor`. Flavors are basicly what type of chain of EOS to package for. (Alot of side-chains do not update their info in the original package)

A list of supported flavors can be found in [eos-deb-rebuild-info](https://github.com/eosswedenorg/eos-deb-rebuild-info)

run `eos-deb-rebuild` without any arguments to see what flags and arguments can be used.

## Usage

First. compile the source code and build the original packet provided by the official scripts. Consult the official documentation on how to do so.

Or you could get a hold of an offical .deb somehow. again consult the official documentation how to build/download a package.

You want to rebuild that package into a customized one. here is an example:

```sh
# Build/download a package somewhere on your system.
# For this example, lets say we built wax-1.8.4 (that is still named eosio)
$ ls | grep .deb
eosio_1.8.4-1-ubuntu-18.04_amd64.deb

# Repackage with update info (wax) first.
$ eos-deb-rebuild wax eosio_1.8.4-1-ubuntu-18.04_amd64.deb
...
dpkg-deb: building package 'wax' in 'wax_1.8.4-1-ubuntu-18.04_amd64.deb'

# Repackage as "wax" mutliversion also
~/wax-1.8.4 $ eos-deb-rebuild wax:mv eosio_1.8.4-1-ubuntu-18.04_amd64.deb
...
dpkg-deb: building package 'wax-mv-184' in 'wax-mv-184_1.8.4-1-ubuntu-18.04_amd64.deb'

# You now have 3 packages
~/wax-1.8.4 $ ls | grep .deb
eosio_1.8.4-1-ubuntu-18.04_amd64.deb
wax_1.8.4-1-ubuntu-18.04_amd64.deb
wax-mv-184_1.8.4-1-ubuntu-18.04_amd64.deb
```
## Author

Henrik Hautakoski - [henrik@eossweden.org](mailto:henrik@eossweden.org)
