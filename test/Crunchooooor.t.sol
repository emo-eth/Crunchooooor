// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseTest } from "./BaseTest.sol";
import { TestCrunchooooor } from "./helpers/TestCrunchooooor.sol";

contract CrunchooooorTest is BaseTest {
    TestCrunchooooor test;

    function setUp() public virtual override {
        super.setUp();
        test = new TestCrunchooooor();
    }

    function testCountBytes() public {
        (uint256 leading, uint256 total) = test.countBytes(address(0));
        assertEq(leading, 20);
        assertEq(total, 20);

        (leading, total) = test.countBytes(address(1));
        assertEq(leading, 19, "leading");
        assertEq(total, 19, "total");

        (leading, total) = test.countBytes(address(bytes20(bytes1(0x01))));
        assertEq(leading, 0, "leading");
        assertEq(total, 19, "total");

        (leading, total) = test.countBytes(address(bytes20(bytes2(0x0001))));
        assertEq(leading, 1, "leading");
        assertEq(total, 19, "total");
    }

    function testScore() public {
        uint256 score = test.score({ leading: 0, total: 0 });
        assertEq(score, 0, "score");
        score = test.score({ leading: 1, total: 0 });
        assertEq(score, 1, "score");
        score = test.score({ leading: 1, total: 1 });
        assertEq(score, 2, "score");
        score = test.score({ leading: 2, total: 1 });
        assertEq(score, 5, "score");
        score = test.score({ leading: 2, total: 2 });
        assertEq(score, 6, "score");
        score = test.score({ leading: 20, total: 20 });
        assertEq(score, 420, "score");
    }
}
