// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PaymentContract {
    address public owner;
    address public admin;
    bool private _notEntered;

    error Deny(string reason);
    error Status(string reason);
    error DueDateHasPassed();
    error IdAlreadyExists();
    error IdNotExist();
    error IncorrectAmount();
    error InvalidPayer();
    error Unauthorized();
    error NoBalance(string reason);

    event ProviderPaymentRuleCreated(address indexed payer, uint256 amount, uint256 indexed ID, uint256 dueDate);
    event ProviderPaymentRuleUpdated(uint256 indexed ID, uint256 newAmount, uint256 dueDate);
    event ProviderPaymentMade(uint256 indexed ID, bool status);
    event UserPaymentProcessed(uint256 indexed ID, bool status);
    event UserPaymentRuleAdded(address indexed userAddress, uint256 amount, uint256 indexed ID);

    struct ProviderPaymentRule {
        uint256 ID;
        address payable payer;
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
        _notEntered = true; // Initialize _notEntered to true
    }

    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }
     modifier nonReentrant() {
        require(_notEntered, "Reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can access this function");
        _;
    }

    modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner || msg.sender == admin, "Only owner or admin can call this function.");
        _;
    }

    function createProviderPaymentRule(address payable _payer, uint256 _amount, uint256 _ID, uint256 _dueDate) external onlyOwnerOrAdmin {
        // Check if the ID already exists
        if (providerPaymentRules[_ID].amount != 0) {
            revert IdAlreadyExists();
        }

        // Check If due date is valid
        if(_dueDate < getBlockTimestampInMilliseconds()) {
            revert DueDateHasPassed();
        }

        providerPaymentRules[_ID] = ProviderPaymentRule({
            ID: _ID,
            payer: _payer,
            amount: _amount,
            dueDate: _dueDate,
            status: false // Set the status to false initially
        });

        emit ProviderPaymentRuleCreated(_payer, _amount, _ID, _dueDate);
    }

    function updateProviderPaymentRule(uint256 _ID, uint256 _newAmount, uint256 _dueDate) external onlyOwnerOrAdmin {
        ProviderPaymentRule storage rule = providerPaymentRules[_ID];

        if (getBlockTimestampInMilliseconds() > rule.dueDate) {
            revert DueDateHasPassed();
        }

        // Check If due date is valid (checking new due date)
        if(_dueDate < getBlockTimestampInMilliseconds()) {
            revert DueDateHasPassed();
        }

        // Check the status of the payment rule
        if (rule.status) {
            revert Status("Payment rule status is true, cannot update");
        }
        // Update the payment rule
        rule.amount = _newAmount;
        rule.dueDate = _dueDate;

        emit ProviderPaymentRuleUpdated(_ID, _newAmount, _dueDate);
    }

    function getProviderPaymentRuleByID(uint256 _ID) external view onlyOwnerOrAdmin returns (uint256 ID, address payable payer, uint256 amount, uint256 dueDate) {
        ProviderPaymentRule storage rule = providerPaymentRules[_ID];
        return (rule.ID, rule.payer, rule.amount, rule.dueDate);
    }

    function makeProviderPayment(uint256 _ID) external payable nonReentrant {
        ProviderPaymentRule storage rule = providerPaymentRules[_ID];
        //CHECK
        // Check if the payment rule has already been paid
        if (rule.status) {
            revert Status("Payment rule has already been processed");
        }
        // Check if the payment rule exists
        if (rule.amount == 0) {
            revert IdNotExist();
        }
        // Check if the sent amount matches the expected amount
        if (msg.value != rule.amount) {
            revert IncorrectAmount();
        }
        // Check if the sender is the payer of the payment rule 
        if (rule.payer != payable(msg.sender)) {
            revert InvalidPayer();
        }
        if (getBlockTimestampInMilliseconds()> rule.dueDate) {
            revert DueDateHasPassed();
        }
        //EFFECTS
        // Update payment rule status to true
        rule.status = true;

        // INTERACTIONS (last step)
        (bool success, ) = rule.payer.call{value: msg.value}("");
        require(success, "Payment failed");

        emit ProviderPaymentMade(_ID, rule.status);
    }

    function getUserPaymentRuleByID(uint256 _ID) external view onlyOwnerOrAdmin returns (address userAddress, uint256 amount, uint256 ID) {
        UserPaymentRule storage rule = userPaymentRules[_ID];
        return (rule.userAddress, rule.amount, rule.ID);
    }

    function getUserPayment(uint256 _ID) public nonReentrant {
        UserPaymentRule storage rule = userPaymentRules[_ID];
        //CHECKS
        // Check if the caller is authorized to withdraw the payment
        if (rule.userAddress != msg.sender) {
            revert Unauthorized();
        }
        // Check the status of the payment rule
        if (rule.status) {
            revert Status("Payment rule status is true, cannot withdraw");
        }
        // Check if there is a balance available to withdraw
        if (rule.amount == 0) {
            revert NoBalance("No balance available to withdraw");
        }
        
        //EFFECTS
        rule.status = true; // Update payment rule status to true
        //INTERACTIONS (last step)
        payable(msg.sender).transfer(rule.amount);

        emit UserPaymentProcessed(_ID, rule.status);
    }

    // Function to add a new user payment rule, accessible only by the contract owner and admin
    function addUserPaymentRule(address _userAddress, uint256 _amount, uint256 _ID) external onlyOwnerOrAdmin {
        // Check if the ID already exists
        if (userPaymentRules[_ID].amount != 0) {
            revert IdAlreadyExists();
        }
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

    /**
     * Because the JavaScript environment uses an epoch-based timestamp in milliseconds, we need to adjust for the block.timestamp function, which returns the value in seconds.
     */
    function getBlockTimestampInMilliseconds() public view returns (uint256 milliseconds) {
        milliseconds = block.timestamp * 1000;
        return milliseconds; // We basically coverted seconds to milliseconds.
    }

    receive() external payable {
        revert Deny("No direct payments.");
    }
    fallback() external payable {
        revert Deny("No direct payments.");
    }
}
