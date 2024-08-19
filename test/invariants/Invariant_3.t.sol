// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console, StdCheats, StdUtils} from "../../lib/forge-std/src/Test.sol";
import {CommonBase} from "../../lib/forge-std/src/Base.sol";
import {WETH} from "../../src/WETH.sol";
import {Handler} from "./Invariant_2.t.sol";

// Topics
// - Actor management

contract ActorManager is CommonBase, StdCheats, StdUtils {
    Handler[] public handlers;

    constructor(Handler[] memory _handlers) {
        handlers = _handlers;
    }

    function sendToFallback(uint handlerIndex, uint amount) public {
        uint index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].sendToFallback(amount);
    }

    function deposit(uint handlerIndex, uint amount) public {
        uint index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].deposit(amount);
    }

    function withdraw(uint handlerIndex, uint amount) public {
        uint index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].withdraw(amount);
    }
}

contract WETH_Multi_Handler_Invariant_Tests is Test {
    WETH public weth;
    ActorManager public manager;
    Handler[] public handlers;

    function setUp() public {
        weth = new WETH();

        for (uint i = 0; i < 3; i++) {
            handlers.push(new Handler(weth));
            deal(address(handlers[i]), 100 * 1e18);
        }

        manager = new ActorManager(handlers);

        targetContract(address(manager));
    }

    function invariant_eth_balance() public view {
        uint total = 0;

        for (uint i; i < handlers.length - 1; i++) {
            total += handlers[i].wethBalance();
        }
        console.log("ETH total ", total / 1e18);
        assertGe(address(weth).balance, total);
    }
}