import { expect } from "chai";
import hre from "hardhat";

const TOKEN_NAME = "GNATI"
const TOKEN_TICKER = "NOT"
const LINKED_CONTRACT ="0xe73b92e469c49a4651aeff204ecfe920a78022db" //use the real ERC20 that will be reduced.
const IADDRESS = "0xffEce948b8A38bBcC813411D2597f7f8485a0689"   // convert the iaddress of the Verus token mapped to to  20 bytes


describe("Proxy contract", function () {
  it("Deployment work successfully", async function () {
       
    // Deploy the contract with constructor arguments
    const contract = await hre.ethers.deployContract("GNATI_BRIDGE", [TOKEN_NAME, TOKEN_TICKER, LINKED_CONTRACT, IADDRESS], {});
    
    // Wait for the contract to be deployed
    const bridgeiaddress = await contract.bridgeiaddress();

    expect(bridgeiaddress).to.equal("0xffEce948b8A38bBcC813411D2597f7f8485a0689");
  });
});
