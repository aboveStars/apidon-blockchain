// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PaymentContract {
  address public owner;
  address public admin;
  struct ProviderPaymentRule {
        address payable recipient;
        uint256 amount;
        uint256 ID;
        uint256 dueDate;
    }

    struct UserPaymentRule {
        address userAddress;
        uint256 amount;
        uint256 ID;
    }

  ProviderPaymentRule[] public makePaymentRules;
  mapping(uint256 => bool) public makePaymentRulesStatus;
  UserPaymentRule[] public userPaymentRules;

    constructor() {
        owner = msg.sender;
    }


function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can access this function");
        _;
    }
modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }


function createPaymentRule(address payable _recipient, uint256 _amount, uint256 _ID,uint16 year, uint8 month, uint8 day) external
 onlyAdmin onlyOwner {
       
    // Check if the recipient address already exists in the makePaymentRules array
    for (uint256 i = 0; i < makePaymentRules.length; i++) {
        require(makePaymentRules[i].recipient != _recipient, "Recipient address already exists");
    }

    // Check if the ID already exists in the makePaymentRules array
    for (uint256 i = 0; i < makePaymentRules.length; i++) {
        require(makePaymentRules[i].ID != _ID, "ID already exists");
    }
    uint256 _dueDate = getUnixTimestamp(year, month, day);
        ProviderPaymentRule memory newRule = ProviderPaymentRule({
            recipient: _recipient,
            amount: _amount,
            ID: _ID,
            dueDate: _dueDate
        });

        makePaymentRules.push(newRule);
        makePaymentRulesStatus[_ID] = false; // Set the status to false initially
    }
// to change the date or amount
function updatePaymentRule(uint256 _ID, uint256 _newAmount, uint16 year, uint8 month, uint8 day) external  onlyAdmin onlyOwner{
        uint256 _newDueDate = getUnixTimestamp(year, month, day);
        for (uint256 i = 0; i < makePaymentRules.length; i++) {
            if (makePaymentRules[i].ID == _ID) {
                makePaymentRules[i].amount = _newAmount;
                makePaymentRules[i].dueDate = _newDueDate;
                return;
            }
        }
        revert("Payment rule with given ID does not exist");
    }
// Infos about provider
function getPaymentRuleByID(uint256 _ID) external  view onlyAdmin onlyOwner returns (address payable recipient, uint256 amount, uint256 dueDate) {
        for (uint256 i = 0; i < makePaymentRules.length; i++) {
            if (makePaymentRules[i].ID == _ID) {
                return (makePaymentRules[i].recipient, makePaymentRules[i].amount, makePaymentRules[i].dueDate);
            }
        }
        revert("Payment rule with given ID does not exist");
    }
    // provider makes the payment
function makePayment(uint256 _ID) external payable {
        uint256 amountToSend = 0;
        address payable recipientAddress;
        uint256 i; // Declare 'i' here
        // Find the payment rule and recipient associated with the specified ID
        for (i = 0; i < makePaymentRules.length; i++) {
            if (makePaymentRules[i].ID == _ID) {
                amountToSend = makePaymentRules[i].amount;
                recipientAddress = makePaymentRules[i].recipient;
                break;
            }
        }

        

        // Revert if the payment rule with the given ID does not exist, or if the sent amount exceeds the amount specified in the payment rule
        require(amountToSend > 0, "Payment rule with the given ID does not exist");
        require(msg.value == amountToSend, "Incorrect amount sent");

        // Check if the sender is the recipient of the payment rule
        require(recipientAddress == payable(msg.sender), "Sender is not the recipient of the payment rule");
        
        // Check if it is the right time of the payment rule
        require(block.timestamp <= makePaymentRules[i].dueDate, "Due date has passed");

        // Update payment rule status to true
        makePaymentRulesStatus[_ID] = true;

        // Perform the payment
        // At this point, the ETH sent by the user will be transferred to the contract
    }
// To get the payment status false or true
function getPaymentRuleStatus(uint256 _ID) external view onlyAdmin onlyOwner returns (bool) {
        return makePaymentRulesStatus[_ID];
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


// Function to add a new user payment rule, accessible only by the contract owner and admin
function addUserPaymentRule(address _userAddress, uint256 _amount, uint256 _ID) external onlyAdmin onlyOwner {
        
        UserPaymentRule memory newRule = UserPaymentRule(_userAddress, _amount, _ID);
        userPaymentRules.push(newRule);
    }

     // Function to get a payment rule by its ID, accessible by the ID owner and contract owner
function getUserPaymentRuleByID(uint256 _ID) public view onlyAdmin onlyOwner returns (UserPaymentRule memory) {
        for (uint256 i = 0; i < userPaymentRules.length; i++) {
            if (userPaymentRules[i].ID == _ID && (userPaymentRules[i].userAddress == msg.sender || msg.sender == owner)) {
                return userPaymentRules[i];
            }
        }
        revert("Payment rule not found or unauthorized");
    }
    // Function to allow a user to withdraw a certain amount or all of it from their own address
function getPayment(uint256 _ID, uint256 _amountToWithdraw) public {
        for (uint256 i = 0; i < userPaymentRules.length; i++) {
            if (userPaymentRules[i].ID == _ID && userPaymentRules[i].userAddress == msg.sender) {
                require(_amountToWithdraw <= userPaymentRules[i].amount, "Insufficient balance");
                payable(msg.sender).transfer(_amountToWithdraw);
                userPaymentRules[i].amount -= _amountToWithdraw; // Reduce the amount by the withdrawn amount
                return;
            }
        }
        revert("Payment rule not found or unauthorized");
    }
}