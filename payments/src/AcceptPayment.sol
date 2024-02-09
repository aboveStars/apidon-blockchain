// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract AcceptPayment {
  address public owner;
  address[] knownAddresses ;
  mapping(address => uint256) public addressToEthBalance;
  mapping(address => uint256) public addressToDueDate;
  mapping(address => uint256) public addressToDebt;
  address public admin;
constructor() {
        owner = msg.sender; // since we will be the first ones to deploy owner of the contract cannot be changed. ?
    }
function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }
function changeAdmin(address _newAdmin) external onlyOwner {
        admin = _newAdmin;
    }
function addKnownAddress(address _newAddress) external  onlyOwner{
        require(!isAddressKnown(_newAddress), "Address already known");
        knownAddresses.push(_newAddress);
    }
function isAddressKnown(address _addressToCheck) public view returns (bool) {
        for (uint i = 0; i < knownAddresses.length; i++) {
            if (knownAddresses[i] == _addressToCheck) {
                return true;
            }
        }
        return false;
    }
modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
function setDebt(address _address, uint256 _debtAmount) external onlyOwner onlyAdmin{
        require(isAddressKnown(_address), "Address is not a known address");
        addressToDebt[_address] = _debtAmount;
    }
function getDebt(address _address) external view returns (uint256) {
        require(isAddressKnown(_address), "Address is not a known address");
        return addressToDebt[_address];
    }
function payToUser(uint256 _amount) external {
        require(isAddressKnown(msg.sender), "Sender is not a known address");
        address payable _sender = payable(msg.sender);
        uint256 debtAmount = addressToDebt[_sender];
        require(debtAmount >= _amount, "Insufficient debt");
        require(_amount > 0, "Invalid amount");
        require(address(this).balance >= _amount, "Insufficient contract balance");
         addressToDebt[_sender] -= _amount; //  Deduct the paid amount from the debt
        _sender.transfer(_amount);
    }
function setEthAmountAndDueDate(address _address, uint256 _ethAmount, uint256 _dueDate) external onlyOwner onlyAdmin{
        addressToEthBalance[_address] = _ethAmount;
        addressToDueDate[_address] = _dueDate;
    }

function getAddressData(address _address) external view onlyOwner onlyAdmin returns (uint256 ethAmount, uint256 dueDate) {
        ethAmount = addressToEthBalance[_address];
        dueDate = addressToDueDate[_address];
    }
function sendEtherToContract() external payable {
    require(addressToEthBalance[msg.sender] > 0, "No Ether balance assigned");
    require(block.timestamp <= addressToDueDate[msg.sender], "Due date has passed");

    uint256 ethAmountAllowed = addressToEthBalance[msg.sender];
    require(msg.value == ethAmountAllowed, "Incorrect Ether amount");

    address payable contractAddress = payable(address(this));
    contractAddress.transfer(ethAmountAllowed);
}
function changeEthAmountAndDueDate(address _address, uint256 _newEthAmount, uint256 _newDueDate) external onlyOwner onlyAdmin {
        addressToEthBalance[_address] = _newEthAmount;
        addressToDueDate[_address] = _newDueDate;
    }
function getUnixTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint256) {
        require(year >= 1970, "Year must be 1970 or later");
        require(month > 0 && month <= 12, "Invalid month");
        require(day > 0 && day <= 31, "Invalid day");

        uint256 timestamp = 0;
        
        uint8[12] memory monthDays = [
            31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
        ];

        for (uint16 i = 1970; i < year; i++) {
            if (i % 4 == 0 && (i % 100 != 0 || i % 400 == 0)) {
                timestamp += 366 days;
            } else {
                timestamp += 365 days;
            }
        }

        for (uint8 i = 1; i < month; i++) {
            timestamp += uint256(monthDays[i - 1]) * 1 days;
        }

        timestamp += uint256(day - 1) * 1 days;

        return timestamp;
    }

function setDueDate(address _address, uint16 year, uint8 month, uint8 day) external onlyOwner onlyAdmin {
        uint256 dueDate = getUnixTimestamp(year, month, day);
        addressToDueDate[_address] = dueDate;
    }
      // Function to prevent direct transfer of Ether to the contract
receive() external payable {
        revert("Direct transfers not allowed");
    }

    // Fallback function to prevent direct transfer of Ether to the contract
fallback() external {
        revert("Fallback function not allowed");
    }

  
}


