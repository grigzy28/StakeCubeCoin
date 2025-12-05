Provide a general summary of your changes in the Title above

Please provide clear motivation for your patch and explain how it improves
SCC Core user experience or SCC Core developer experience
significantly:


Needed changes to be able to build on newer operating systems which led to all kinds of other optimizations and updates to dependencies and core code.


## Issue being fixed or feature implemented

Operating system upgrades and unable to build on newer systems plus several other enhancements and fixes in core code

Allows building on newer operating system and also improves resource usage for masternodes


## What was done?

Some memory optimizations
Improved startup times
Introduced contributions cleanup code from newer Dash code
Reduced some (not needed) logging functions to reduce debug log writes during normal operation
Created a GETBLOCKCOUNT buffer variable to increase the speed of getblockcount rpc calls
Created RPC calls for only enabled masternode lists for speed of the StakeCube systems

FIX: Major updates to dependencies and internal support dependencies for building on newer operating systems
FIX: deadlock(race condition) on an RPC call that would completely lock up the wallet if queried from the wallet too fast
FIX: Introduced a routine to validate consensus rules faster for quicker startup times

Update: Added some checkpoint entries

## How Has This Been Tested?

Ran for many, many months on own systems and finally on "Earn" systems over the past month(s)

## Breaking Changes

All that have been discovered, so far, have been corrected

