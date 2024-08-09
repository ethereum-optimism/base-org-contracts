// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { CommonTest } from "test/CommonTest.t.sol";
import { Simulator } from "script/universal/Simulator.sol";
import { GnosisSafe as Safe } from "@safe-contracts/GnosisSafe.sol";
import "@eth-optimism-bedrock/test/safe-tools/SafeTestTools.sol";

contract TestSimulator is Simulator {

}

contract SimulatorTest is CommonTest, SafeTestTools {
    using SafeTestLib for SafeInstance;

    Simulator simulator;
    SafeInstance safeInstance;

    function setUp() public override {
        simulator = new TestSimulator();

        uint256 threshold = 10;
        uint256 ownerCount = 13;
        (, uint256[] memory privKeys) = SafeTestLib.makeAddrsAndKeys("test-owners", ownerCount);
        safeInstance = _setupSafe(privKeys, threshold);
    }

    function test_simulator_overrideSafeThreshold () public view {
        Simulator.SimulationStateOverride memory sso = simulator.overrideSafeThreshold(address(safeInstance.safe));
        assertEq(sso.contractAddress, address(safeInstance.safe));
        assertEq(sso.overrides.length, 1);
        assertEq(sso.overrides[0].key, bytes32(uint256(0x4)));
        assertEq(sso.overrides[0].value, bytes32(uint256(0x1)));
    }

    function test_simulator_overrideSafeThresholdAndNonce () public view {
        Simulator.SimulationStateOverride memory sso = simulator.overrideSafeThresholdAndNonce(address(safeInstance.safe), 987);
        assertEq(sso.contractAddress, address(safeInstance.safe));
        assertEq(sso.overrides.length, 2);
        assertEq(sso.overrides[0].key, bytes32(uint256(0x4)));
        assertEq(sso.overrides[0].value, bytes32(uint256(0x1)));
        assertEq(sso.overrides[1].key, bytes32(uint256(0x5)));
        assertEq(sso.overrides[1].value, bytes32(uint256(987)));
    }

    function test_simulator_overrideSafeThresholdAndOwner () public view {
        Simulator.SimulationStateOverride memory sso = simulator.overrideSafeThresholdAndOwner(address(safeInstance.safe), address(0xdead));
        assertEq(sso.contractAddress, address(safeInstance.safe));
        assertEq(sso.overrides.length, 4);
        assertEq(sso.overrides[0].key, bytes32(uint256(0x4)));
        assertEq(sso.overrides[0].value, bytes32(uint256(0x1)));
        assertEq(sso.overrides[1].key, bytes32(uint256(0x3)));
        assertEq(sso.overrides[1].value, bytes32(uint256(0x1)));
        assertEq(sso.overrides[2].key, bytes32(uint256(0xe90b7bceb6e7df5418fb78d8ee546e97c83a08bbccc01a0644d599ccd2a7c2e0)));
        assertEq(sso.overrides[2].value, bytes32(uint256(0xdead)));
        assertEq(sso.overrides[3].key, bytes32(uint256(0x6a9609baa168169acaea398c4407efea4be641bb08e21e88806d9836fd9333cc)));
        assertEq(sso.overrides[3].value, bytes32(uint256(0x1)));
    }

    function test_simulator_simulationLink () public view {
        (string memory url, string memory rawInput) = simulator.simulationLink(address(0xbeef), bytes("test"), address(0xdead), new Simulator.SimulationStateOverride[](0));
        assertEq(url, "https://dashboard.tenderly.co/TENDERLY_USERNAME/TENDERLY_PROJECT/simulator/new?network=31337&contractAddress=0x000000000000000000000000000000000000bEEF&from=0x000000000000000000000000000000000000dEaD&stateOverrides=%5B%5D&rawFunctionInput=0x74657374");
        assertEq(rawInput, "");
    }
}
