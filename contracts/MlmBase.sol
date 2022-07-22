// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract MlmSystem {

    uint64 MINIMUM_ENTER;
    uint256[10] levelInvestments;
    uint256[10] levelComissions;

    mapping (address => address[]) public partnersUsers;       // address of directPartner -> users who entered with his referalLink //referals
    mapping (address => uint256) public accountBalance;        // user address - balance of his account
    mapping (address => address) public referalUser;           // user - referal (who invited user) //referrers

    constructor() {
        MINIMUM_ENTER = 5000000000000000;
        levelInvestments = [0.005*1e18, 0.01*1e18, 0.02*1e18, 0.05*1e18, 0.1*1e18, 0.2*1e18, 0.5*1e18, 1e18, 2*1e18, 5*1e18];
        levelComissions = [10, 7, 5, 2, 1, 1, 1, 1, 1, 1]; // .../10 - per cent
    }

    receive() payable external {}
    fallback() payable external {}

    function investing(uint256 _amountInvest) public payable {
        require(_amountInvest >= MINIMUM_ENTER, "Didn't send enough");
        uint comissionToContract = _amountInvest / 20;
        uint valueToUser = _amountInvest - comissionToContract;

        (bool successToUser, ) = payable(msg.sender).call{value: valueToUser}("");
        require(successToUser, "Transfer failed");
        accountBalance[msg.sender] += valueToUser;

        (bool sucessToContract, ) = payable(address(this)).call{value: comissionToContract}("");
        require(sucessToContract, "Transfer failed");
    }

    // money to user from his account
    function withdraw() public returns(bool) {
        uint userBalance = accountBalance[msg.sender];
        require(userBalance > 0, "Your current balance is 0");

        address current = msg.sender;
        uint counterDepth = 0;
        uint comission = 0;
    
        for (uint i = 0; i<10; i++) {
            while(current != address(0)) {
                counterDepth++;
                current = referalUser[msg.sender];
                comission = userBalance * levelComissions[_getLevel(current)] / 10;
                (bool success, ) = payable(current).call{value: comission}("");
                require(success, "Transfer failed");
                userBalance -= comission;
            }
        }

        (bool successUser, ) = payable(msg.sender).call{value: userBalance}("");
        require(successUser, "Transfer failed");
        accountBalance[msg.sender] = 0;

        return true;
    }

    function registration(address _referalLink) private {   
        if(_referalLink != address(0)) {
            partnersUsers[_referalLink].push(msg.sender);   
            accountBalance[msg.sender] = 0;      
        } else {
            partnersUsers[msg.sender].push(address(0));
            accountBalance[msg.sender] = 0;  
        }
    }

    function _getLevel(address _userAddress) private view returns(uint256) {
        for(uint i = 0; i<levelInvestments.length; i++) {   
            if (accountBalance[_userAddress] <= levelInvestments[i] && accountBalance[_userAddress] >= levelInvestments[i-1]) {
                return i+1;
            }
        }
    }

    // user can see the amount of direct partners and their level
    function _directPartnersInfo() private view returns(uint, uint[] memory) {
        uint[] memory partnersLevel;
        address[] memory partnersAddresses = partnersUsers[msg.sender];
        for(uint i = 0; i<partnersUsers[msg.sender].length; i++){
            partnersLevel[i] = _getLevel(partnersAddresses[i]);
        }
        return(partnersUsers[msg.sender].length, partnersLevel);
    }

}