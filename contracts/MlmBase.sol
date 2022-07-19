// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Data.sol";

contract MlmSystem is Data, Ownable {
    
    fallback() payable external{}
    receive() payable external{}

    function getLevel(address _parnerAddress) public view returns(uint256){
        require(_parnerAddress != address(0), "Wrong address of direct partner");
        return directPartnLevel[_parnerAddress];
    }

    function isReflinkEnabled() public {
        // if(){

        // }
    }

    function transfer(address payable _to) public payable {     
        _to.transfer(msg.value); 
    } 

    function send() public payable returns(bool) {
        //send wei to the contract
        require(msg.value >= MINIMUM_ENTER, "Didn't send enough");
        address(this).transfer(msg.value);
        investors.push(msg.sender);
        directPartners[msg.sender] = msg.value;
        return true;
    }
    
    function withdraw() external onlyOwner {
        //owner.transfer(this.balance);    //this.balance - общий баланс контракта, transfer – для перевода эфира на адрес
        uint amount = msg.value;
        msg.sender.transfer(amount);
    }








    // External functions
    // ...

    // External functions that are view
    // ...

    // External functions that are pure
    // ...

    // Public functions
    // ...

    // Internal functions
    // ...

    // Private functions
    // ...


    //withdraw, invest, getPartners
}