// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function balanceOf(address) external view returns (uint);
}

contract ExpensiveFallback {
    IWETH9 public weth;
    uint public stored; // storage write to consume gas

    event Received(address from, uint amount);

    constructor(address _weth) {
        weth = IWETH9(_weth);
    }

    function doDeposit() external payable {
        require(msg.value > 0, "need eth");
        weth.deposit{ value: msg.value }();
    }

    function doWithdraw(uint wad) external {
        weth.withdraw(wad);
    }

    receive() external payable {
        stored += 1;
        emit Received(msg.sender, msg.value);
    }
}
