# GNATI Proxy Project

The use of this Contract will be to reduce the circulating supply of a token from 254bits to 64bits to use on the Verus protocol.

The max supply of any currency on Verus is limited to 9,999,999,999. (1 less 10 Billion)

$NATI has a circulating supply of 33 Trillion. (3,300,000,000 max NATI.vETH supply is in debate)

The Proxy Bridge should store the ERC20 Token. In this case NATI or GNATI for testing. The contract will send a newly created token to the Verus Bridge to be conveted into NATI.vETH to the users R-address.. (or I-address??)

When a user wants to convert back, NATI.vETH should be sent to the contract where the contract will send the NATI.vETH to the bridge and the correct amout of $NATI should be sent to the users ETH address.

This contract is currently in development for NATI but can use used in the future for any ERC20 token to reduce their supply to fit within the parameter of Verus.

We are asking for Developers to Audit//Update this code to accomplish this in a secure manner while accounting for any aditions to benifit functionality of the Proxy.

Thank you for your time & efforts.

IlluminatiCoin Community

   The GoerliNATI contract used for testing is 0x4aD8300d9349428a49526c3a85B2ed975Cc6E781

   The Original NATI contract is 0x0B9aE6b1D4f0EEeD904D1CEF68b9bd47499f3fFF

Try running some of the following tasks:

```shell
npm install
npx hardhat vars set INFURA_API_KEY
npx hardhat vars set PRIVATE_KEY
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Proxy.ts --network localhost
```

or
```shell
npx hardhat ignition deploy ./ignition/modules/Proxy.ts --network sepolia
```
