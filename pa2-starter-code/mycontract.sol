// Please paste your contract's solidity code here
// Note that writing a contract here WILL NOT deploy it and allow you to access it from your client
// You should write and develop your contract in Remix and then, before submitting, copy and paste it here

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Splitwise {
    mapping(address => mapping(address => uint256)) public debts;
    mapping(address => mapping(address => bool)) private hasDebt;
    address[] public users;
    mapping(address => bool) public isUser;

    function lookup(address debtor, address creditor) public view returns (uint256) {
        if (!hasDebt[debtor][creditor]) {
            return 0;
        }
        return debts[debtor][creditor];
    }


    function add_IOU(address creditor, uint256 amount) public {
        debts[msg.sender][creditor] += amount;
        hasDebt[msg.sender][creditor] = true; 
        addToUsers(creditor);
        addToUsers(msg.sender);

    }

    function repay_IOU(address payer, address creditor, uint256 amount) public {
        debts[payer][creditor] -= amount;
    }

    function addToUsers(address add) private {
        if (!isUser[add]) {
            users.push(add);
            isUser[add] = true;
        }
    }

    function getUsers() public view returns (address[] memory) {
        return users;
    }
}
