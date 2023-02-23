// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Crunchooooor } from "../../src/Crunchooooor.sol";

contract TestCrunchooooor is Crunchooooor {
    function countBytes(address addr) public pure returns (uint256, uint256) {
        return _countBytes(addr);
    }

    function score(uint256 leading, uint256 total)
        public
        pure
        returns (uint256)
    {
        return _score(leading, total);
    }
}
