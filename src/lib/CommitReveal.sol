// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CommitReveal {
    error CommitmentExpired(uint256 committedTimestamp);
    error CommitmentPending(uint256 committedTimestamp);

    uint256 public constant COMMITMENT_LIFESPAN = 5 minutes;
    uint256 public constant COMMITMENT_DELAY = 1 minutes;
    ///@dev mapping of user to key to commitment hash to timestamp.
    mapping(address user => mapping(bytes32 commitment => uint256 timestamp))
        public commitments;

    /**
     * @notice Commit a hash to the contract, to be retrieved and verified after
     * a delay.
     * @param commitment The hash to commit.
     */
    function commit(bytes32 commitment) external {
        assembly {
            // calculate location of the mapping(bytes32 commitment => uint256
            // timestamp)
            // store caller
            mstore(0, caller())
            // store slot of commitments mapping
            mstore(0x20, commitments.slot)
            // compute slot of mapping(bytes32 => uint256) for the caller
            let commitmentMapSlot := keccak256(0, 0x40)
            // calculate the slot for the timestamp associated with the
            // commitment
            // store the commitment hash
            mstore(0, commitment)
            // store the derived intermediate map slot
            mstore(0x20, commitmentMapSlot)
            // compute slot of the timestamp
            let timestampSlot := keccak256(0, 0x40)
            // store the timestamp
            sstore(timestampSlot, timestamp())
        }
    }

    /**
     * @dev Assert that a commitment has been made and is within a valid time
     * window.
     * @param computedCommitmentHash The derived commitment hash to verify.
     */
    function _assertCommittedReveal(bytes32 computedCommitmentHash)
        internal
        view
    {
        // retrieve the timestamp of the commitment (if it exists)
        uint256 retrievedTimestamp =
            commitments[msg.sender][computedCommitmentHash];
        // compute the time difference
        uint256 timeDiff;
        // unchecked; assume blockchain time is monotonically increasing
        unchecked {
            timeDiff = block.timestamp - retrievedTimestamp;
        }
        // if the time difference is greater than the commitment lifespan, the
        // commitment
        // has expired
        if (timeDiff > COMMITMENT_LIFESPAN) {
            revert CommitmentExpired(retrievedTimestamp);
        } else if (timeDiff < COMMITMENT_DELAY) {
            // if the time difference is less than the commitment delay, the
            // commitment is
            // pending
            revert CommitmentPending(retrievedTimestamp);
        }
    }
}
