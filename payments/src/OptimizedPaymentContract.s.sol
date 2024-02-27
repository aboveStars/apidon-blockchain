// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract OptimizedPaymentContract {
    address public owner;
    address public admin;

    event ProviderPaymentRuleCreated(address indexed recipient, uint256 amount, uint256 indexed ID, uint16 year, uint8 month, uint8 day);
    event ProviderPaymentRuleUpdated(uint256 indexed ID, uint256 newAmount, uint16 year, uint8 month, uint8 day);
    event ProviderPaymentMade(uint256 indexed ID, bool status);
    event UserPaymentProcessed(uint256 indexed ID, bool status);
    event UserPaymentRuleAdded(address indexed userAddress, uint256 amount, uint256 indexed ID);

    struct ProviderPaymentRule {
        uint256 ID;
        address payable recipient;
        uint256 amount;
        uint256 dueDate;
        bool status; // Payment status flag
    }

  

    struct UserPaymentRule {
        uint256 ID;
        address userAddress;
        uint256 amount;
        bool status; // Payment status flag
    }

    mapping(uint256 => ProviderPaymentRule) public providerPaymentRules;
    mapping(uint256 => UserPaymentRule) public userPaymentRules;

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

    function createProviderPaymentRule(address payable _recipient, uint256 _amount, uint256 _ID, uint16 year, uint8 month, uint8 day) external onlyOwnerOrAdmin {
        require(providerPaymentRules[_ID].amount == 0, "ID already exists");
        uint256 _dueDate = getUnixTimestamp(year, month, day);
        providerPaymentRules[_ID] = ProviderPaymentRule({
            ID: _ID,
            recipient: _recipient,
            amount: _amount,
            dueDate: _dueDate,
            status: false // Set the status to false initially
        });

        emit ProviderPaymentRuleCreated(_recipient, _amount, _ID, year, month, day);
    }

    function updateProviderPaymentRule(uint256 _ID, uint256 _newAmount, uint16 year, uint8 month, uint8 day) external onlyOwnerOrAdmin {
        ProviderPaymentRule storage rule = providerPaymentRules[_ID];
        require(block.timestamp <= rule.dueDate, "Due date has passed, cannot update");
        require(!rule.status, "Payment rule status is true, cannot update");
        // Update the payment rule
        rule.amount = _newAmount;
        rule.dueDate = getUnixTimestamp(year, month, day);

         emit ProviderPaymentRuleUpdated(_ID, _newAmount, year, month, day);
    }

    function getProviderPaymentRuleByID(uint256 _ID) external view onlyOwnerOrAdmin returns (uint256 ID, address payable recipient, uint256 amount, uint256 dueDate) {
        ProviderPaymentRule storage rule = providerPaymentRules[_ID];
        return (rule.ID, rule.recipient, rule.amount, rule.dueDate);
    }

    function makeProviderPayment(uint256 _ID) external payable {
        ProviderPaymentRule storage rule = providerPaymentRules[_ID];
        require(rule.amount > 0, "Payment rule with the given ID does not exist");
        require(msg.value == rule.amount, "Incorrect amount sent");
        require(rule.recipient == payable(msg.sender), "Sender is not the recipient of the payment rule");
        require(block.timestamp <= rule.dueDate, "Due date has passed");
        // Update payment rule status to true
        rule.status = true;

        emit ProviderPaymentMade(_ID, rule.status);
    }

    function getUserPaymentRuleByID(uint256 _ID) external view onlyOwnerOrAdmin returns (address userAddress, uint256 amount, uint256 ID) {
        UserPaymentRule storage rule = userPaymentRules[_ID];
        return (rule.userAddress, rule.amount, rule.ID);
    }

    function getUserPayment(uint256 _ID) public {
        UserPaymentRule storage rule = userPaymentRules[_ID];
        require(rule.userAddress == msg.sender, "Unauthorized");
        require(rule.amount > 0, "No balance available to withdraw");
        payable(msg.sender).transfer(rule.amount);
        rule.amount = 0; // Set the remaining amount to zero after withdrawal
        rule.status = true; // Update payment rule status to true

        emit UserPaymentProcessed(_ID, rule.status);
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
        require(userPaymentRules[_ID].amount == 0, "ID already exists");
        UserPaymentRule memory newRule = UserPaymentRule({
            ID: _ID,
            userAddress: _userAddress,
            amount: _amount,
            status: false // Set the status to false initially
        });
        userPaymentRules[_ID] = newRule;

        emit UserPaymentRuleAdded(_userAddress, _amount, _ID);
    }

    // Function to get the status of a user payment rule by its ID, accessible by contract owner and admin
    function getUserPaymentRuleStatus(uint256 _ID) external view onlyOwnerOrAdmin returns (bool) {
        UserPaymentRule storage rule = userPaymentRules[_ID];
        return rule.status;
    }

    // Function to get the status of a provider payment rule by its ID, accessible by contract owner and admin
    function getProviderPaymentRuleStatus(uint256 _ID) external view onlyOwnerOrAdmin returns (bool) {
        ProviderPaymentRule storage rule = providerPaymentRules[_ID];
        return rule.status;
    }
}
