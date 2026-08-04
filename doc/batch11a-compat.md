# SCC 3.5.2.0 Batch11A compatibility devnet

This source is patched to join the SCC v5 Batch11A named devnet during the
legacy compatibility era.

Use the same settings on old and new nodes:

```ini
devnet=batch11a

[devnet]
port=20000
minimumdifficultyblocks=10000
highsubsidyblocks=300
highsubsidyfactor=1000
powtargetspacing=30
llmqchainlocks=llmq_devnet
llmqdevnetparams=12:6
sporkaddr=YOUR_SHARED_DEVNET_SPORK_ADDRESS
```

The 3.5.2.0 daemon continues to advertise protocol 70224 and uses legacy BLS.
The patched v5 daemon advertises 70240 and keeps all shared quorum activity in
legacy mode through height 479. At the v5 V19 boundary for block 480, v5 nodes
disconnect protocol 70224 peers and switch to basic BLS.

Both binaries must start from empty `devnet-batch11a` datadirs after applying
the paired compatibility patches. The named height-1 genesis and the rules for
blocks 2 onward differ from an unpatched 3.5.2.0 devnet.
