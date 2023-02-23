// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

struct CrunchParams {
    uint16 minScore;
    uint80 endTimestamp;
    address deployer;
    bytes32 initCodeHash;
    address proposer;
    uint96 bounty;
}

struct CrunchScore {
    uint16 score;
    address submitter;
}

struct Commitment {
    bytes32 commitmentHash;
    uint256 timestamp;
}
