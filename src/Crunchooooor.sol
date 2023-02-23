// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { CrunchParams, CrunchScore, Commitment } from "./lib/Structs.sol";
import { Create2AddressDeriver } from
    "create2-helpers/lib/Create2AddressDeriver.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { CommitReveal } from "./lib/CommitReveal.sol";

contract Crunchooooor is CommitReveal {
    error CrunchInProgress(uint256 crunchId);
    error CrunchEnded(uint256 crunchId);
    error CrunchDoesNotExist(uint256 crunchId);
    error ScoreTooLow(uint256 got, uint256 want);
    error NotHighScore(uint256 got, uint256 want);
    error BountyClaimed(uint256 crunchId);

    event CrunchCreated(
        uint256 indexed crunchId,
        address indexed deployer,
        bytes32 indexed initCodeHash,
        uint256 endTimestamp,
        uint256 initialBounty
    );

    event CrunchUpdated(uint256 indexed crunchId, uint256 newBounty);
    event NewCrunchLeader(uint256 indexed crunchId, address indexed submitter);
    event CrunchFinalized(uint256 indexed crunchId);

    address public constant IMMUTABLE_CREATE2_FACTORY =
        0x0000000000FFe8B47B3e2130213B802212439497;

    uint256 constant MINIMUM_COMMITMENT_DELAY = 1 minutes;

    mapping(uint256 crunchId => CrunchParams) public crunches;
    mapping(uint256 crunchId => CrunchScore) public crunchLeaders;

    function _computeCommitmentHash(address derivedAddress, address msgSender)
        internal
        pure
        returns (bytes32 computedCommitmentHash)
    {
        assembly {
            mstore(0, derivedAddress)
            mstore(0x20, msgSender)
            computedCommitmentHash := keccak256(0, 0x40)
        }
    }

    /**
     * @notice Score a salt from the submitter, validating that it has been
     *         committed. Validation prevents censorship and front-running.
     * @param crunchId id of the crunch submission
     * @param salt salt to derive create2 address
     */
    function revealSubmission(uint256 crunchId, bytes32 salt) public {
        CrunchParams memory params = crunches[crunchId];
        if (block.timestamp > params.endTimestamp) {
            revert CrunchEnded(crunchId);
        }
        address deployer = params.deployer;
        bytes32 initCodeHash = params.initCodeHash;

        address addr = Create2AddressDeriver.deriveCreate2AddressFromHash(
            deployer, salt, initCodeHash
        );
        _assertCommittedReveal(_computeCommitmentHash(addr, msg.sender));

        (uint256 leading, uint256 total) = _countBytes(addr);
        uint256 score = _score(leading, total);

        CrunchScore memory currentScore = crunchLeaders[crunchId];
        if (score < params.minScore) {
            revert ScoreTooLow({ got: score, want: params.minScore });
        }
        if (score > currentScore.score) {
            crunchLeaders[crunchId] =
                CrunchScore({ score: uint16(score), submitter: msg.sender });
        } else {
            revert NotHighScore({ got: score, want: currentScore.score });
        }
    }

    /**
     * @notice once a crunch has ended, pay out the bounty to the leader
     * @param crunchId id of the crunch to finalize
     */
    function finalize(uint256 crunchId) public {
        CrunchParams memory params = crunches[crunchId];
        if (block.timestamp == 0) {
            revert CrunchDoesNotExist(crunchId);
        }
        if (block.timestamp <= params.endTimestamp) {
            revert CrunchInProgress(crunchId);
        }
        uint256 bounty = params.bounty;
        if (bounty == 0) {
            revert BountyClaimed(crunchId);
        }
        crunches[crunchId].bounty = 0;

        CrunchScore memory leader = crunchLeaders[crunchId];
        address recipient;
        if (leader.submitter == address(0)) {
            // return bounty to proposer
            recipient = params.proposer;
        } else {
            recipient = leader.submitter;
        }
        SafeTransferLib.safeTransferETH(recipient, bounty);
    }

    function _countBytes(address addr)
        internal
        pure
        returns (uint256 numLeading, uint256 numTotal)
    {
        assembly {
            let leadingInterrupted
            for { let i := 12 } lt(i, 32) { i := add(i, 1) } {
                let thisByte := byte(i, addr)
                let thisByteIsZero := iszero(thisByte)
                leadingInterrupted :=
                    or(iszero(thisByteIsZero), leadingInterrupted)
                numTotal := add(numTotal, thisByteIsZero)
                numLeading :=
                    add(numLeading, mul(thisByteIsZero, iszero(leadingInterrupted)))
            }
        }
    }

    function _score(uint256 leading, uint256 total)
        internal
        pure
        returns (uint256 score)
    {
        assembly {
            score := add(mul(leading, leading), total)
        }
    }
}
