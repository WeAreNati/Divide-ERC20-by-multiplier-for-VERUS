import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TOKEN_NAME = "GNATI"
const TOKEN_TICKER = "NOT"
const LINKED_CONTRACT ="0xe73b92e469c49a4651aeff204ecfe920a78022db" //use the real ERC20 that will be reduced.
const IADDRESS = "0xffEce948b8A38bBcC813411D2597f7f8485a0689"   // convert the iaddress of the Verus token mapped to to  20 bytes
const VERUSBRIDGE = "0xcaa98a4ec79dac8a06cb3bfdcf5351b6576d939f" // The verus bridge contract delegator address.

const p = buildModule("Proxy", (m) => {

  const proxy = m.contract("GNATI_BRIDGE", [TOKEN_NAME, TOKEN_TICKER, LINKED_CONTRACT, IADDRESS, VERUSBRIDGE], {});

  return { proxy };
});

export default p;
