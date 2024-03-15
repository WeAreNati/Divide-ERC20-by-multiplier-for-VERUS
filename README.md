This is a Solidity Contract in development.

The use of this Contract will be to reduce the circulating supply of a token from 254bits to 64bits to use on the Verus protocol.

The max supply of any currency on Verus is limited to 9,999,999,999. (one less 10 Billion)

$NATI has a circulating supply of 33 Trillion. (3,300,000,000 max NATI.vETH is in debate)

The Proxy Bridge should store the ERC20 Token. In this case NATI or GNATI for testing.
The contract will send a division of the created token to the Verus Bridge.

The Verus bridge will convert the newly created token into NATI.vETH.

When a user wants to convert back, NATI.vETH should be sent to the contract
and the correct amout of $NATI should be sent to the users ETH address.

This contract is currently in development for NATI but can use used in the 
future for any ERC20 token to reduce their supply to fit within the parameter 
of Verus.

We are asking for Developers to Audit//Update this code to accomplish this
in a secure matter to protect user's funds. 

