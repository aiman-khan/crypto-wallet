//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract FirstContract {
    int balance = 0;

    constructor() {
        balance = 0;
    }

    function getBalance() view public returns (int){
        return balance;
    } 

    function depositBalance(int amount) public {
        balance = balance + amount;
    } 

     function withdrawBalance(int amount) public {
        balance = balance - amount;
    } 
}
