Set-Content -Path .\test\weth-dos-test.js -Value @'
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WETH9 transfer gas-stipend DoS reproducer", function () {
  it("should revert (run out of gas) when withdraw sends to an expensive fallback", async function () {
    const [deployer] = await ethers.getSigners();

    // Deploy WETH9
    const WETH = await ethers.getContractFactory("WETH9");
    const weth = await WETH.deploy();
    await weth.deployed();

    // Deploy ExpensiveFallback with WETH address
    const Exp = await ethers.getContractFactory("ExpensiveFallback");
    const exp = await Exp.deploy(weth.address);
    await exp.deployed();

    // Deposit 1 ETH from ExpensiveFallback into WETH
    const depositTx = await exp.connect(deployer).doDeposit({
      value: ethers.utils.parseEther("1"),
    });
    await depositTx.wait();

    // Check WETH balance of the contract (numerisch vergleichen)
    const bal = await weth.balanceOf(exp.address);
    expect(bal.toString()).to.equal(ethers.utils.parseEther("1").toString());

    // Jetzt: withdraw → wir ERWARTEN einen Revert wegen out-of-gas im fallback
    let reverted = false;
    let revertMessage = "";

    try {
      await exp.connect(deployer).doWithdraw(ethers.utils.parseEther("1"));
    } catch (err) {
      reverted = true;
      revertMessage = err.message || String(err);
      console.log("Withdraw reverted as expected:", revertMessage);
    }

    expect(reverted).to.equal(true);
    expect(revertMessage.toLowerCase()).to.include("gas") ; // grobe Prüfung auf related message
  });
});
