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
  *function createProviderPaymentRule(address payable _recipient, uint256 _amount, uint256 _ID,uint16 year, uint8 month, uint8 day) to create paymentrule for provider.
  *function updateProviderPaymentRule(uint256 _ID, uint256 _newAmount, uint16 year, uint8 month, uint8 day) to change the date and amount for provider !! cannot use createPaymentRule for the same ID.
  *funciton getProviderPaymentRuleByID(uint256 _ID) to get the infos about Provider
  *function getProviderPaymentRuleStatus(uint256 _ID) learn wheter its paid
  *function addUserPaymentRule(address _userAddress, uint256 _amount, uint256 _ID) Function to add a new user payment rule, accessible only by the contract owner and admin
  *function getUserPaymentRuleByID(uint256 _ID) Function to get a payment rule by its ID, accessible by the ID owner and contract owner


Everyone can call this funcitons:
  *function makePayment(uint256 _ID) Providers make payment with thier ID.
  *function getPayment(uint256 _ID) Function to allow a user to withdraw all of the ethers from their own address.





----------------------OPTIMIZED PAYMENT CONTRACT------------------ 
  In this modified version, the ProviderPaymentRule and UserPaymentRule structs each have a status field of type boolean, which is used to track payment statuses. This eliminates the need for mapping storage variables (makeProviderPaymentRulesStatus and userPaymentRulesStatus), resulting in reduced storage writes and gas costs.




To minimize the number of storage reads and writes, especially within loops, we have used local variables to store values retrieved from storage since they are accessed multiple times within a function. Additionally, we have considered using mappings instead of arrays to reduce gas costs.



YOU CAN SEE THE OPTIMIZED VERSİON USES LESS GAS BY DEPLOYING BOTH CINTRACTS TO REMIX.ETH AND VIEWING THEIR GASES.



reentrancy attack---- checks, effects, interactions---nonReentrant modifier



overflow under flow---- solidity version



DoS---- optimization made











