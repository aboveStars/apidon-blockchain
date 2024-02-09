# apidon-blockchain
**This repository will incorporate both 'Payment' and 'NFT' features. It'll contain test files along with various deployment files.**
You can use remix.ethereum to see how the functions work.
As first copy the codes of solidity file that you want to test and past them into remix.ethereum.
You need to compile as first.(compiler is under the search button)
Then deploy it.
You can change the account to see wheter someone can use the tested function beside owner and admin.
(for red button (it is payable) set an amount in value box)





Only owner of the contract can use this functions:
setAdmin (owner can set an admin)(write an address)
changeAdmin (owner is able to change the admin)(write an address)

Only admin and owner can use this functions:
function addKnownAddress (Can add address to make payment or take payment from them.)(write an address)
function setDebt (Can set an amount for user. they can withdraw this money from contract.) (write the amount)
function setEthAmount (can set an amount for provider to pay the contract to pay this ether.) (write the amount)
function getAddressData (admin and owner can see the deadline and amount that needed to bee paid from wanted address.(provider))
function changeEthAmount (can change the amount for provider to pay the contract.) (write the amount)
function setDueDate (add a deadline for provider to make the payment) (write => address, year, month, day)

Everyone can use this functions:
function isAddressKnown (to see wheter that address is in the list) (write an address)
function getDebt (for users to see the amount they can withdraw from the contract)
function payToUser (for users to withdraw the amount from the contract) (write the amount)
function sendEtherToContract (provider can send money until the deadline with this function) (write the amount)