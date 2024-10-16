# Dash Core file system

* banlist.dat: stores the IPs/Subnets of banned nodes
* blocks/blk000??.dat: block data (custom, 128 MiB per file)
* blocks/rev000??.dat; block undo data (custom)
* blocks/index/*; block index (LevelDB)
* chainstate/*; block chain state database (LevelDB)
* stakecubecoin.conf: contains configuration settings for sccd or scc-qt
* sccd.pid: stores the process id of sccd while running
* database/*: BDB database environment; only used for wallet; moved to wallets/ directory on new installs since 0.16.0
* db.log: wallet database log file; moved to wallets/ directory on new installs since 0.16.0
* debug.log: contains debug information and general logging generated by sccd or scc-qt
* evodb/*: special txes and quorums database
* fee_estimates.dat: stores statistics used to estimate minimum transaction fees and priorities required for confirmation
* governance.dat: stores data for governance objects
* indexes/txindex/*: optional transaction index database (LevelDB); since 0.17.0
* llmq/*: quorum signatures database
* mempool.dat: dump of the mempool's transactions
* mncache.dat: stores data for masternode list
* netfulfilled.dat: stores data about recently made network requests
* peers.dat: peer IP address database (custom format)
* wallet.dat: personal wallet (BDB) with keys and transactions; moved to wallets/ directory on new installs since 0.16.0
* wallets/database/*: BDB database environment; used for wallets since 0.16.0
* wallets/db.log: wallet database log file; since 0.16.0
* wallets/wallet.dat: personal wallet (BDB) with keys and transactions; since 0.16.0
* .cookie: session RPC authentication cookie (written at start when cookie authentication is used, deleted on shutdown)
* onion_v3_private_key: cached Tor hidden service private key for `-listenonion`
* guisettings.ini.bak: backup of former GUI settings after `-resetguisettings` is used

- [Data directory location](#data-directory-location)

- [Data directory layout](#data-directory-layout)

- [Multi-wallet environment](#multi-wallet-environment)

- [GUI settings](#gui-settings)

- [Legacy subdirectories and files](#legacy-subdirectories-and-files)

- [Notes](#notes)

## Data directory location

The data directory is the default location where the Dash Core files are stored.

1. The default data directory paths for supported platforms are:

Platform | Data directory path
---------|--------------------
Linux    | `$HOME/.dashcore/`
macOS    | `$HOME/Library/Application Support/Dashcore/`
Windows  | `%APPDATA%\Dashcore\` <sup>[\[1\]](#note1)</sup>

2. The non-default data directory path can be specified by `-datadir` option.

3. All content of the data directory, except for `dash.conf` file, is chain-specific. This means the actual data directory paths for non-mainnet cases differ:

Chain option        | Data directory path
--------------------|--------------------
no option (mainnet) | *path_to_datadir*`/`
`-testnet`          | *path_to_datadir*`/testnet3/`
`-regtest`          | *path_to_datadir*`/regtest/`

## Data directory layout

Subdirectory       | File(s)               | Description
-------------------|-----------------------|------------
`blocks/`          |                       | Blocks directory; can be specified by `-blocksdir` option (except for `blocks/index/`)
`blocks/index/`    | LevelDB database      | Block index; `-blocksdir` option does not affect this path
`blocks/`          | `blkNNNNN.dat`<sup>[\[2\]](#note2)</sup> | Actual Dash blocks (in network format, dumped in raw on disk, 128 MiB per file)
`blocks/`          | `revNNNNN.dat`<sup>[\[2\]](#note2)</sup> | Block undo data (custom format)
`chainstate/`      | LevelDB database      | Blockchain state (a compact representation of all currently unspent transaction outputs and some metadata about the transactions they are from)
`indexes/txindex/` | LevelDB database      | Transaction index; *optional*, used if `-txindex=1`
`indexes/blockfilter/basic/db/` | LevelDB database      | Blockfilter index LevelDB database for the basic filtertype; *optional*, used if `-blockfilterindex=basic`
`indexes/blockfilter/basic/`    | `fltrNNNNN.dat`<sup>[\[2\]](#note2)</sup> | Blockfilter index filters for the basic filtertype; *optional*, used if `-blockfilterindex=basic`
`wallets/`         |                       | [Contains wallets](#multi-wallet-environment); can be specified by `-walletdir` option; if `wallets/` subdirectory does not exist, a wallet resides in the data directory
`evodb/`         |                       |special txes and quorums database
`llmq/`          |                       |quorum signatures database
`./`               | `banlist.dat`         | Stores the IPs/subnets of banned nodes
`./`               | `dash.conf`        | Contains [configuration settings](scc-conf.md) for `dashd` or `scc-qt`; can be specified by `-conf` option
`./`               | `dashd.pid`        | Stores the process ID (PID) of `dashd` or `scc-qt` while running; created at start and deleted on shutdown; can be specified by `-pid` option
`./`               | `debug.log`           | Contains debug information and general logging generated by `dashd` or `scc-qt`; can be specified by `-debuglogfile` option
`./`               | `governance.dat`      | stores data for governance objects
`./`               | `mncache.dat`         | stores data for masternode list
`./`               | `netfulfilled.dat`    | stores data about recently made network requests
`./`               | `fee_estimates.dat`   | Stores statistics used to estimate minimum transaction fees and priorities required for confirmation
`./`               | `guisettings.ini.bak` | Backup of former [GUI settings](#gui-settings) after `-resetguisettings` option is used
`./`               | `mempool.dat`         | Dump of the mempool's transactions
`./`               | `onion_v3_private_key` | Cached Tor hidden service private key for `-listenonion` option
`./`               | `peers.dat`           | Peer IP address database (custom format)
`./`               | `.cookie`             | Session RPC authentication cookie; if used, created at start and deleted on shutdown; can be specified by `-rpccookiefile` option
`./`               | `.lock`               | Data directory lock file

## Multi-wallet environment

Wallets are Berkeley DB (BDB) databases:

Subdirectory | File(s)           | Description
-------------|-------------------|------------
`database/`  | BDB logging files | Part of BDB environment; created at start and deleted on shutdown; a user *must keep it as safe* as personal wallet `wallet.dat`
`./`         | `db.log`          | BDB error file
`./`         | `wallet.dat`      | Personal wallet (BDB) with keys and transactions
`./`         | `.walletlock`     | Wallet lock file

1. Each user-defined wallet named "wallet_name" resides in `wallets/wallet_name/` subdirectory.

2. The default (unnamed) wallet resides in `wallets/` subdirectory; if the latter does not exist, the wallet resides in the data directory.

3. A wallet database path can be specified by `-wallet` option.

## GUI settings

`scc-qt` uses [`QSettings`](https://doc.qt.io/qt-5/qsettings.html) class; this implies platform-specific [locations where application settings are stored](https://doc.qt.io/qt-5/qsettings.html#locations-where-application-settings-are-stored).

## Legacy subdirectories and files

These subdirectories and files are no longer used by the Dash Core:

Path           | Description | Repository notes
---------------|-------------|-----------------
`blktree/`     | Blockchain index; replaced by `blocks/index/` in [0.8.0](https://github.com/dash/dash/blob/master/doc/release-notes/release-notes-0.8.0.md#improvements) | [PR #2231](https://github.com/dash/dash/pull/2231), [`8fdc94cc`](https://github.com/dash/dash/commit/8fdc94cc8f0341e96b1edb3a5b56811c0b20bd15)
`coins/`       | Unspent transaction output database; replaced by `chainstate/` in 0.8.0 | [PR #2231](https://github.com/dash/dash/pull/2231), [`8fdc94cc`](https://github.com/dash/dash/commit/8fdc94cc8f0341e96b1edb3a5b56811c0b20bd15)
`blkindex.dat` | Blockchain index BDB database; replaced by {`chainstate/`, `blocks/index/`, `blocks/revNNNNN.dat`<sup>[\[2\]](#note2)</sup>} in 0.8.0 | [PR #1677](https://github.com/dash/dash/pull/1677)
`blk000?.dat`  | Block data (custom format, 2 GiB per file); replaced by `blocks/blkNNNNN.dat`<sup>[\[2\]](#note2)</sup> in 0.8.0 | [PR #1677](https://github.com/dash/dash/pull/1677)
`addr.dat`     | Peer IP address BDB database; replaced by `peers.dat` in [0.7.0](https://github.com/dash/dash/blob/master/doc/release-notes/release-notes-0.7.0.md) | [PR #1198](https://github.com/dash/dash/pull/1198), [`928d3a01`](https://github.com/dash/dash/commit/928d3a011cc66c7f907c4d053f674ea77dc611cc)

## Notes

<a name="note1">1</a>. The `/` (slash, U+002F) is used as the platform-independent path component separator in this paper.

<a name="note2">2</a>. `NNNNN` matches `[0-9]{5}` regex.

