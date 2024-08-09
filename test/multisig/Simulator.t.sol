// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { CommonTest } from "test/CommonTest.t.sol";
import { Simulator } from "script/universal/Simulator.sol";

contract TestSimulator is Simulator {

}

contract SimulatorTest is CommonTest {
    Simulator simulator;

    function setUp() public override {
        simulator = new TestSimulator();
    }

    function test_simulator_overrideSafeThreshold () public {
        // TODO
    }

    function test_simulator_overrideSafeThresholdAndNonce () public {
        // TODO
    }

    function test_simulator_overrideSafeThresholdAndOwner () public {
        // TODO
    }

    function test_simulator_overrideSafeThresholdOwnerAndNonce () public {
        // TODO
    }

    function test_simulator_addOverride () public {
        // TODO
    }

    function test_simulator_logSimulationLinkfunction () public {
        // TODO
    }
}
