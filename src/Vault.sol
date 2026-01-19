// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Vault {
    mapping(address => uint256) public balances;
    mapping(address => bool) public isActive;
    address public owner;
    IERC20 public token;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external {
        require(amount > 0 && amount <= token.balanceOf(msg.sender), "Invalid amount");

        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        isActive[msg.sender] = true;

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);

        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);

        if (balances[msg.sender] == 0) {
            isActive[msg.sender] = false;
        }

        emit Withdraw(msg.sender, amount);
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function emergencyWithdraw(address to, uint256 amount) external {
        require(msg.sender == owner);
        token.transfer(to, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
