# Cartesi Rollups EigenLayer Consensus

[Cartesi Rollups](https://docs.cartesi.io/cartesi-rollups/) consensus implementation using [EigenLayer](https://www.eigenlayer.xyz/) to provide economic security and fast finality.

## Introduction

[Cartesi](https://cartesi.io) provides an [app-specific rollups solution](https://docs.cartesi.io/cartesi-rollups/) which settles claims via a configurable [consensus](https://github.com/cartesi/rollups-contracts/blob/v2.0.0-rc.15/contracts/consensus/IConsensus.sol) contract.

In its simplest form, the Cartesi Rollups [Authority](https://github.com/cartesi/rollups-contracts/blob/v2.0.0-rc.15/contracts/consensus/authority/IAuthority.sol) consensus implementation just settles a claim when a single pre-defined address submits it. 
Another solution allows a [Quorum](https://github.com/cartesi/rollups-contracts/blob/v2.0.0-rc.15/contracts/consensus/quorum/IQuorum.sol) of validators to control the consensus, and settles when the majority agrees that a given claim is valid.
Finally, a consensus powered by a [full interactive fraud proof system](https://github.com/cartesi/dave) is envisioned to enable true decentralized and permissionless settlement that inherits the security of the base layer.

In this project, we propose an alternative consensus implementation that leverages [EigenLayer](https://www.eigenlayer.xyz/) restaking to provide strong economic security, while maintaining fast finality and a high degree of permissionless decentralization.
The implementation is quite simple and works similarly to the Quorum consensus, in which a claim is accepted once the number of votes in its favor surpasses 50% of the validator set. For this EigenLayer-based consensus, settlement happens when the total value of operator stakes backing a claim surpasses a given threshold.

## Architecture

This implementation has two main classes:

1. [EigenLayerConsensusServiceManager](./src/EigenLayerConsensusServiceManager.sol): an EigenLayer AVS for operators to commit stake in order to register as validators for Cartesi Rollups applications;

1. [EigenLayerConsensus](./src/EigenLayerConsensus.sol): a Cartesi Rollups consensus implementation that settles when operator stakes backing a claim surpass a threshold defined by the consensus; this implementation can be directly used by a standard Cartesi Node v2 to submit claims;

In the future, EigenLayer slashing could be implemented by permissionlessly allowing anyone to challenge the settled result using a fraud proof system like [Dave](https://github.com/cartesi/dave).

## Building

Make sure to clone the repository with submodules:

```sh
git clone --recurse-submodules https://github.com/miltonjonat/rollups-eigenlayer-consensus.git
cd rollups-eigenlayer-consensus/
```

Then, install dependencies for the `rollups-contracts` lib:

```sh
cd lib/rollups-contracts/
pnpm install
cd ../..
```

Back in the project's home directory, build and test using forge:

```sh
forge build
```

```sh
forge test
```

## Deploying

TODO

