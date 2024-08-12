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
        vm.setEnv("OWNER_SAFE", vm.toString(address(safeInstance.safe)));
    }

    function test_builder_sign () public {
        builder.sign();
    }

    /* function test_builder_verify () public view { */
    /*     builder.verify(bytes("test")); */
    /* } */

    /* function test_builder_nonce () public view { */
    /*     builder.nonce(); */
    /* } */

    /* function test_builder_simulateSigned () public { */
    /*     builder.simulateSigned(bytes("test")); */
    /* } */

    /* function test_builder_run () public { */
    /*     builder.run(bytes("test")); */
    /* } */

}
