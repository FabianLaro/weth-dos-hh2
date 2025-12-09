// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8  public decimals = 18;
    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) external {
        require(balanceOf[msg.sender] >= wad, "insufficient balance");
        balanceOf[msg.sender] -= wad;
        // Vulnerable pattern: 2300 gas stipend via transfer
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    receive() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
