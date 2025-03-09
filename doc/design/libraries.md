# Libraries

| Name                     | Description |
|--------------------------|-------------|
| *libbbcoin_cli*         | RPC client functionality used by *bbcoin-cli* executable |
| *libbbcoin_common*      | Home for common functionality shared by different executables and libraries. Similar to *libbbcoin_util*, but higher-level (see [Dependencies](#dependencies)). |
| *libbbcoin_consensus*   | Consensus functionality used by *libbbcoin_node* and *libbbcoin_wallet*. |
| *libbbcoin_crypto*      | Hardware-optimized functions for data encryption, hashing, message authentication, and key derivation. |
| *libbbcoin_kernel*      | Consensus engine and support library used for validation by *libbbcoin_node*. |
| *libbbcoinqt*           | GUI functionality used by *bbcoin-qt* and *bbcoin-gui* executables. |
| *libbbcoin_ipc*         | IPC functionality used by *bbcoin-node*, *bbcoin-wallet*, *bbcoin-gui* executables to communicate when [`-DWITH_MULTIPROCESS=ON`](multiprocess.md) is used. |
| *libbbcoin_node*        | P2P and RPC server functionality used by *bbcoind* and *bbcoin-qt* executables. |
| *libbbcoin_util*        | Home for common functionality shared by different executables and libraries. Similar to *libbbcoin_common*, but lower-level (see [Dependencies](#dependencies)). |
| *libbbcoin_wallet*      | Wallet functionality used by *bbcoind* and *bbcoin-wallet* executables. |
| *libbbcoin_wallet_tool* | Lower-level wallet functionality used by *bbcoin-wallet* executable. |
| *libbbcoin_zmq*         | [ZeroMQ](../zmq.md) functionality used by *bbcoind* and *bbcoin-qt* executables. |

## Conventions

- Most libraries are internal libraries and have APIs which are completely unstable! There are few or no restrictions on backwards compatibility or rules about external dependencies. An exception is *libbbcoin_kernel*, which, at some future point, will have a documented external interface.

- Generally each library should have a corresponding source directory and namespace. Source code organization is a work in progress, so it is true that some namespaces are applied inconsistently, and if you look at [`add_library(bbcoin_* ...)`](../../src/CMakeLists.txt) lists you can see that many libraries pull in files from outside their source directory. But when working with libraries, it is good to follow a consistent pattern like:

  - *libbbcoin_node* code lives in `src/node/` in the `node::` namespace
  - *libbbcoin_wallet* code lives in `src/wallet/` in the `wallet::` namespace
  - *libbbcoin_ipc* code lives in `src/ipc/` in the `ipc::` namespace
  - *libbbcoin_util* code lives in `src/util/` in the `util::` namespace
  - *libbbcoin_consensus* code lives in `src/consensus/` in the `Consensus::` namespace

## Dependencies

- Libraries should minimize what other libraries they depend on, and only reference symbols following the arrows shown in the dependency graph below:

<table><tr><td>

```mermaid

%%{ init : { "flowchart" : { "curve" : "basis" }}}%%

graph TD;

bbcoin-cli[bbcoin-cli]-->libbbcoin_cli;

bbcoind[bbcoind]-->libbbcoin_node;
bbcoind[bbcoind]-->libbbcoin_wallet;

bbcoin-qt[bbcoin-qt]-->libbbcoin_node;
bbcoin-qt[bbcoin-qt]-->libbbcoinqt;
bbcoin-qt[bbcoin-qt]-->libbbcoin_wallet;

bbcoin-wallet[bbcoin-wallet]-->libbbcoin_wallet;
bbcoin-wallet[bbcoin-wallet]-->libbbcoin_wallet_tool;

libbbcoin_cli-->libbbcoin_util;
libbbcoin_cli-->libbbcoin_common;

libbbcoin_consensus-->libbbcoin_crypto;

libbbcoin_common-->libbbcoin_consensus;
libbbcoin_common-->libbbcoin_crypto;
libbbcoin_common-->libbbcoin_util;

libbbcoin_kernel-->libbbcoin_consensus;
libbbcoin_kernel-->libbbcoin_crypto;
libbbcoin_kernel-->libbbcoin_util;

libbbcoin_node-->libbbcoin_consensus;
libbbcoin_node-->libbbcoin_crypto;
libbbcoin_node-->libbbcoin_kernel;
libbbcoin_node-->libbbcoin_common;
libbbcoin_node-->libbbcoin_util;

libbbcoinqt-->libbbcoin_common;
libbbcoinqt-->libbbcoin_util;

libbbcoin_util-->libbbcoin_crypto;

libbbcoin_wallet-->libbbcoin_common;
libbbcoin_wallet-->libbbcoin_crypto;
libbbcoin_wallet-->libbbcoin_util;

libbbcoin_wallet_tool-->libbbcoin_wallet;
libbbcoin_wallet_tool-->libbbcoin_util;

classDef bold stroke-width:2px, font-weight:bold, font-size: smaller;
class bbcoin-qt,bbcoind,bbcoin-cli,bbcoin-wallet bold
```
</td></tr><tr><td>

**Dependency graph**. Arrows show linker symbol dependencies. *Crypto* lib depends on nothing. *Util* lib is depended on by everything. *Kernel* lib depends only on consensus, crypto, and util.

</td></tr></table>

- The graph shows what _linker symbols_ (functions and variables) from each library other libraries can call and reference directly, but it is not a call graph. For example, there is no arrow connecting *libbbcoin_wallet* and *libbbcoin_node* libraries, because these libraries are intended to be modular and not depend on each other's internal implementation details. But wallet code is still able to call node code indirectly through the `interfaces::Chain` abstract class in [`interfaces/chain.h`](../../src/interfaces/chain.h) and node code calls wallet code through the `interfaces::ChainClient` and `interfaces::Chain::Notifications` abstract classes in the same file. In general, defining abstract classes in [`src/interfaces/`](../../src/interfaces/) can be a convenient way of avoiding unwanted direct dependencies or circular dependencies between libraries.

- *libbbcoin_crypto* should be a standalone dependency that any library can depend on, and it should not depend on any other libraries itself.

- *libbbcoin_consensus* should only depend on *libbbcoin_crypto*, and all other libraries besides *libbbcoin_crypto* should be allowed to depend on it.

- *libbbcoin_util* should be a standalone dependency that any library can depend on, and it should not depend on other libraries except *libbbcoin_crypto*. It provides basic utilities that fill in gaps in the C++ standard library and provide lightweight abstractions over platform-specific features. Since the util library is distributed with the kernel and is usable by kernel applications, it shouldn't contain functions that external code shouldn't call, like higher level code targeted at the node or wallet. (*libbbcoin_common* is a better place for higher level code, or code that is meant to be used by internal applications only.)

- *libbbcoin_common* is a home for miscellaneous shared code used by different Bitcoin Core applications. It should not depend on anything other than *libbbcoin_util*, *libbbcoin_consensus*, and *libbbcoin_crypto*.

- *libbbcoin_kernel* should only depend on *libbbcoin_util*, *libbbcoin_consensus*, and *libbbcoin_crypto*.

- The only thing that should depend on *libbbcoin_kernel* internally should be *libbbcoin_node*. GUI and wallet libraries *libbbcoinqt* and *libbbcoin_wallet* in particular should not depend on *libbbcoin_kernel* and the unneeded functionality it would pull in, like block validation. To the extent that GUI and wallet code need scripting and signing functionality, they should be get able it from *libbbcoin_consensus*, *libbbcoin_common*, *libbbcoin_crypto*, and *libbbcoin_util*, instead of *libbbcoin_kernel*.

- GUI, node, and wallet code internal implementations should all be independent of each other, and the *libbbcoinqt*, *libbbcoin_node*, *libbbcoin_wallet* libraries should never reference each other's symbols. They should only call each other through [`src/interfaces/`](../../src/interfaces/) abstract interfaces.

## Work in progress

- Validation code is moving from *libbbcoin_node* to *libbbcoin_kernel* as part of [The libbbcoinkernel Project #27587](https://github.com/bbcoin/bbcoin/issues/27587)
