// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import  "../src/payments.sol";


contract PaymentContractTest {
    PaymentContract paymentContract;

    address public owner;
    address public borrower;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _paymentContract) {
        paymentContract = PaymentContract(_paymentContract);
        owner = msg.sender;
        borrower = address(0x1234567890123456789012345678901234567890);
    }

    function testDepositAndLend() external {
        uint256 amount = 1 ether;

        // Deposit
        paymentContract.deposit{value: amount}(amount);  // Pass the amount argument
        uint256 ownerBalanceAfterDeposit = paymentContract.getBalance();

        require(ownerBalanceAfterDeposit == amount, "Owner's balance should be updated after deposit");

        // Lend payment
        paymentContract.lendPayment{value: amount}(borrower, amount);  // Pass the amount argument
        uint256 borrowerBalanceAfterLend = paymentContract.getBalance();

        require(borrowerBalanceAfterLend == amount, "Borrower's balance should be updated after lending payment");
    }
}



