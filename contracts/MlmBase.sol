// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract MlmSystem {
    
    uint8 public constant MINIMUM_ENTER = 20 wei;
    uint256[10] public levelInvestments = [0.005*1e18, 0.01*1e18, 0.02*1e18, 0.05*1e18, 0.1*1e18, 0.2*1e18, 0.5*1e18, 1e18, 2*1e18, 5*1e18];
    uint256[10] public levelComissions = [10, 7, 5, 2, 1, 1, 1, 1, 1, 1]; // .../10 - per cent

    mapping (address => address[]) partnersUsers;       // address of directPartner -> users who entered with his referalLink
    mapping (address => uint256) accountBalance;        // user address - balance of his account
    mapping (address => address) referalUser;           // user - referal (who invited user)

    receive() payable external {}
    fallback() payable external {}

    function enter(address _referalLink) private {   
        if(_referalLink != address(0)) {
            partnersUsers[_referalLink].push(msg.sender);   
            accountBalance[msg.sender] = 0;      
        } else {
            partnersUsers[msg.sender].push(address(0));
            accountBalance[msg.sender] = 0;  
        }
    }

    function investing(uint256 _amountInvest) public payable {
        require(_amountInvest >= MINIMUM_ENTER, "Didn't send enough");
        payable(address(msg.sender)).transfer(_amountInvest - (_amountInvest / 20));
        payable(address(this)).transfer(_amountInvest / 20);
        accountBalance[msg.sender] += _amountInvest - (_amountInvest / 20);
    }

    function getLevel(address _userAddress) private view returns(uint256) {
        for(uint i = 0; i<levelInvestments.length; i++) {   
            if (accountBalance[_userAddress] == levelInvestments[i]) {
                return i+1;
            }
        }
    }

    // user can see the amount of direct partners and their level
    function directPartnersInfo() private view returns(address, uint256) {
        address[] memory _addressDirectPartner = partnersUsers[msg.sender];
        for(uint i = 0; i<_addressDirectPartner.length; i++){
            return (_addressDirectPartner[i], getLevel(_addressDirectPartner[i]));
        }
    }

    // send money to user account
    function send(uint256 _amount) public payable returns(bool) {
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
        accountBalance[msg.sender] = 0;
        return true;
    }

    function comissionSend(address _partnerAddress) public payable {  
        uint counterDepth = 0;
        address current = msg.sender;
        while(current!=address(0)) {
            if (referalUser[current] != address(0)){
                counterDepth ++;
                current = referalUser[current];
            } else { current = address(0); }
        }

        require(getLevel(msg.sender) >= counterDepth, "Comission to user won't be send");

        // direct partner withdraw money - % of money will go to user's account
        uint256 amount = accountBalance[_partnerAddress];
        (bool success, ) = payable(_partnerAddress).call{value: amount}("");
        require(success, "Transfer failed");
        accountBalance[_partnerAddress] = 0;

        send(amount * levelComissions[getLevel(msg.sender)] / 10);
    }

    // money to user from his account
    function withdraw() public returns(bool) {
        require( accountBalance[msg.sender] > 0, "Your current balance is 0");
        
        (bool success, ) = payable(msg.sender).call{value: accountBalance[msg.sender]}("");
        require(success, "Transfer failed");
        accountBalance[msg.sender] = 0;

        return true;
    }

}