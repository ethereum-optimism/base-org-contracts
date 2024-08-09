// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { CommonTest } from "test/CommonTest.t.sol";
import { MultisigBuilder } from "script/universal/MultisigBuilder.sol";
import { GnosisSafe as Safe } from "@safe-contracts/GnosisSafe.sol";
import "@eth-optimism-bedrock/test/safe-tools/SafeTestTools.sol";
import {IMulticall3} from "forge-std/interfaces/IMulticall3.sol";

contract TestMultisigBuilder is MultisigBuilder {
    function _buildCalls() internal view override returns (IMulticall3.Call3[] memory) {
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](1);

        calls[0] = IMulticall3.Call3({
            target: _ownerSafe(),
            allowFailure: false,
            callData: abi.encodeCall(Safe.approveHash, (0x0))
            });

        return calls;
    }
    function _ownerSafe() internal view override returns (address) {
        return vm.envAddress("OWNER_SAFE");
    }
    function _postCheck(Vm.AccountAccess[] memory accesses, SimulationPayload memory simPayload)
                internal
                virtual
                override
    {}
}

contract MultisigBuilderTest is CommonTest, SafeTestTools {
    using SafeTestLib for SafeInstance;

    MultisigBuilder builder;
    SafeInstance safeInstance;

    function setUp() public override {
        builder = new TestMultisigBuilder();

        uint256 threshold = 10;
        uint256 ownerCount = 13;
        (, uint256[] memory privKeys) = SafeTestLib.makeAddrsAndKeys("test-owners", ownerCount);
        safeInstance = _setupSafe(privKeys, threshold);
    }

    function test_builder_overrideSafeThreshold () public view {
        MultisigBuilder.SimulationStateOverride memory sso = builder.overrideSafeThreshold(address(safeInstance.safe));
        assertEq(sso.contractAddress, address(safeInstance.safe));
        assertEq(sso.overrides.length, 1);
        assertEq(sso.overrides[0].key, bytes32(uint256(0x4)));
        assertEq(sso.overrides[0].value, bytes32(uint256(0x1)));
    }

    function test_builder_overrideSafeThresholdAndNonce () public view {
        MultisigBuilder.SimulationStateOverride memory sso = builder.overrideSafeThresholdAndNonce(address(safeInstance.safe), 987);
        assertEq(sso.contractAddress, address(safeInstance.safe));
        assertEq(sso.overrides.length, 2);
        assertEq(sso.overrides[0].key, bytes32(uint256(0x4)));
        assertEq(sso.overrides[0].value, bytes32(uint256(0x1)));
        assertEq(sso.overrides[1].key, bytes32(uint256(0x5)));
        assertEq(sso.overrides[1].value, bytes32(uint256(987)));
    }

    function test_builder_overrideSafeThresholdAndOwner () public view {
        MultisigBuilder.SimulationStateOverride memory sso = builder.overrideSafeThresholdAndOwner(address(safeInstance.safe), address(0xdead));
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
}
