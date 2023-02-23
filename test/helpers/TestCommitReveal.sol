// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { CommitReveal } from "../../src/lib/CommitReveal.sol";

contract TestCommitReveal is CommitReveal {
    function assertCommittedReveal(bytes32 computedCommitmentHash)
        external
        view
    {
        _assertCommittedReveal(computedCommitmentHash);
    }
}
