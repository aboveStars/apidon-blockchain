# apidon-blockchain
**This repository will incorporate both 'Payment' and 'NFT' features. It'll contain test files along with various deployment files.**
You can use remix.ethereum to see how the functions work.
As first copy the codes of solidity file that you want to test and past them into remix.ethereum.
You need to compile as first.(compiler is under the search button)
Then deploy it.
You can change the account to see wheter someone can use the tested function beside owner and admin.
(for red button (it is payable) set an amount in value box)





*Only owner of the contract can use this functions:
  *setAdmin (owner can set an admin)(write an address)
  *changeAdmin (owner is able to change the admin)(write an address)

*Only admin and owner can use this functions:
  *function createPaymentRule(address payable _recipient, uint256 _amount, uint256 _ID,uint16 year, uint8 month, uint8 day) to create paymentrule for provider.
  *function updatePaymentRule(uint256 _ID, uint256 _newAmount, uint16 year, uint8 month, uint8 day) to change the date and amount for provider !! cannot use createPaymentRule for the same ID.
  *funciton getPaymentRuleByID(uint256 _ID) to get the infos about Provider
  *function getPaymentRuleStatus(uint256 _ID) learn wheter its paid
  *function addUserPaymentRule(address _userAddress, uint256 _amount, uint256 _ID) Function to add a new user payment rule, accessible only by the contract owner and admin
  *function getUserPaymentRuleByID(uint256 _ID) Function to get a payment rule by its ID, accessible by the ID owner and contract owner


Everyone can call this funcitons:
  *function makePayment(uint256 _ID) Providers make payment with thier ID.
  *function getPayment(uint256 _ID, uint256 _amountToWithdraw) Function to allow a user to withdraw a certain amount or all of it from their own address.












