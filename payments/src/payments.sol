// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PaymentContract {
    address public owner;
    mapping(address => uint256) public balances;

    event Deposit(address indexed depositor, uint256 amount);
    event LendPayment(address indexed lender, address indexed borrower, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit(uint256 amount) external payable {
        require(amount > 0, "Deposit amount must be greater than 0");
        require(msg.value == amount, "Sent Ether must match the specified amount");
        
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

 function lendPayment(address borrower, uint256 amount) external onlyOwner payable {
    require(amount > 0, "Lend amount must be greater than 0");
    require(msg.value == amount, "Sent Ether must match the specified amount");
    
    balances[borrower] += amount;
    emit LendPayment(owner, borrower, amount);
}


    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
