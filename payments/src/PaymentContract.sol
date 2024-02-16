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

  ProviderPaymentRule[] public makeProviderPaymentRules;
  mapping(uint256 => bool) public makeProviderPaymentRulesStatus;
  UserPaymentRule[] public userPaymentRules;
  mapping(uint256 => bool) public userPaymentRulesStatus;
    constructor() {
        owner = msg.sender;
        admin = address(0); // Initialize admin to an empty address
    }


function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can access this function");
        _;
    }

modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner || msg.sender == admin, "Only owner or admin can call this function.");
        _;
    }


function createProviderPaymentRule(address payable _recipient, uint256 _amount, uint256 _ID,uint16 year, uint8 month, uint8 day) external
 onlyOwnerOrAdmin {
       

    // Check if the ID already exists in the makeProviderPaymentRules array
    for (uint256 i = 0; i < makeProviderPaymentRules.length; i++) {
        require(makeProviderPaymentRules[i].ID != _ID, "ID already exists");
    }
    uint256 _dueDate = getUnixTimestamp(year, month, day);
        ProviderPaymentRule memory newRule = ProviderPaymentRule({
            recipient: _recipient,
            amount: _amount,
            ID: _ID,
            dueDate: _dueDate
        });

        makeProviderPaymentRules.push(newRule);
        makeProviderPaymentRulesStatus[_ID] = false; // Set the status to false initially
    }
// Allow updating payment rule only if the due date set in createPaymentRule hasn't passed and makeProviderPaymentRulesStatus is false
function updateProviderPaymentRule(uint256 _ID, uint256 _newAmount, uint16 year, uint8 month, uint8 day) external onlyOwnerOrAdmin {
    uint256 _newDueDate = getUnixTimestamp(year, month, day);

    // Check if the due date has passed for the payment rule and if the status is false
    for (uint256 i = 0; i < makeProviderPaymentRules.length; i++) {
        if (makeProviderPaymentRules[i].ID == _ID) {
            require(block.timestamp <= makeProviderPaymentRules[i].dueDate, "Due date has passed, cannot update");
            require(!makeProviderPaymentRulesStatus[_ID], "Payment rule status is true, cannot update");
            break;
        }
    }

    // Update the payment rule
    for (uint256 i = 0; i < makeProviderPaymentRules.length; i++) {
        if (makeProviderPaymentRules[i].ID == _ID) {
            makeProviderPaymentRules[i].amount = _newAmount;
            makeProviderPaymentRules[i].dueDate = _newDueDate;
            return;
        }
    }
    revert("Payment rule with given ID does not exist");
}


// Infos about provider
function getProviderPaymentRuleByID(uint256 _ID) external  view onlyOwnerOrAdmin returns (address payable recipient, uint256 amount, uint256 dueDate) {
        for (uint256 i = 0; i < makeProviderPaymentRules.length; i++) {
            if (makeProviderPaymentRules[i].ID == _ID) {
                return (makeProviderPaymentRules[i].recipient, makeProviderPaymentRules[i].amount, makeProviderPaymentRules[i].dueDate);
            }
        }
        revert("Payment rule with given ID does not exist");
    }
    // provider makes the payment
function makeProviderPayment(uint256 _ID) external payable {
        uint256 amountToSend = 0;
        address payable recipientAddress;
        uint256 i; // Declare 'i' here
        // Find the payment rule and recipient associated with the specified ID
        for (i = 0; i < makeProviderPaymentRules.length; i++) {
            if (makeProviderPaymentRules[i].ID == _ID) {
                amountToSend = makeProviderPaymentRules[i].amount;
                recipientAddress = makeProviderPaymentRules[i].recipient;
                break;
            }
        }

        

        // Revert if the payment rule with the given ID does not exist, or if the sent amount exceeds the amount specified in the payment rule
        require(amountToSend > 0, "Payment rule with the given ID does not exist");
        require(msg.value == amountToSend, "Incorrect amount sent");

        // Check if the sender is the recipient of the payment rule
        require(recipientAddress == payable(msg.sender), "Sender is not the recipient of the payment rule");
        
        // Check if it is the right time of the payment rule
        require(block.timestamp <= makeProviderPaymentRules[i].dueDate, "Due date has passed");

        // Update payment rule status to true
        makeProviderPaymentRulesStatus[_ID] = true;

        // Perform the payment
        // At this point, the ETH sent by the user will be transferred to the contract
    }
// To get the payment status false or true
function getProviderPaymentRuleStatus(uint256 _ID) external view onlyOwnerOrAdmin returns (bool) {
        return makeProviderPaymentRulesStatus[_ID];
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
function addUserPaymentRule(address _userAddress, uint256 _amount, uint256 _ID) external onlyOwnerOrAdmin {
        // Check if the ID already exists in the userPaymentRules array
    for (uint256 i = 0; i < userPaymentRules.length; i++) {
        require(userPaymentRules[i].ID != _ID, "ID already exists");
    }
        
        UserPaymentRule memory newRule = UserPaymentRule(_userAddress, _amount, _ID);
        userPaymentRules.push(newRule);
        userPaymentRulesStatus[_ID] = false; // Set the status to false initially
    }

     // Function to get a payment rule by its ID, accessible by  contract owner and admin
function getUserPaymentRuleByID(uint256 _ID) external view onlyOwnerOrAdmin returns (address userAddress, uint256 amount, uint256 ID) {
        for (uint256 i = 0; i < userPaymentRules.length; i++) {
            if (userPaymentRules[i].ID == _ID ) {
                return (userPaymentRules[i].userAddress, userPaymentRules[i].amount, userPaymentRules[i].ID);
            }
        }
        revert("Payment rule not found or unauthorized");
    }

// Function to allow a user to withdraw the full amount assigned to them from their own address
function getUserPayment(uint256 _ID) public {
    for (uint256 i = 0; i < userPaymentRules.length; i++) {
        if (userPaymentRules[i].ID == _ID && userPaymentRules[i].userAddress == msg.sender) {
            uint256 amountToWithdraw = userPaymentRules[i].amount;
            require(amountToWithdraw > 0, "No balance available to withdraw");
            payable(msg.sender).transfer(amountToWithdraw);
            userPaymentRules[i].amount = 0; // Set the remaining amount to zero after withdrawal
            return;
        }
    }
    userPaymentRulesStatus[_ID] = true;
    revert("Payment rule not found or unauthorized");
}
function getUserPaymentRuleStatus(uint256 _ID) external view onlyOwnerOrAdmin returns (bool) {
        return userPaymentRulesStatus[_ID];
    }

}