// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract MlmSystem {

    uint64 MINIMUM_ENTER;               // minimum amount to log in into system
    uint256[10] levelInvestments;       // array with levels of investments according to the amount of ether
    uint256[10] levelComissions;        // array of comissions according to the level of the user

    mapping (address => uint256) public accountBalance;        // user address - balance of his account
    mapping (address => address[]) public partnersUsers;       // address of directPartner -> users who entered with his referalLink //referals
    mapping (address => address) public referalOfTheUser;      // user - referal (who invited user) 

    constructor() {
        MINIMUM_ENTER = 0.005 ether;
        levelInvestments = [0.005 ether,    // 1st level
                            0.01 ether, 
                            0.02 ether, 
                            0.05 ether, 
                            0.1 ether, 
                            0.2 ether, 
                            0.5 ether, 
                            1 ether, 
                            2 ether, 
                            5 ether];      // 10th level
        levelComissions = [10, 7, 5, 2, 1, 1, 1, 1, 1, 1];      // .../10 - get number in %
    }

    receive() payable external {}
    fallback() payable external {}

    /** @notice Function to invest funds to the account    
     */
    function invest() external payable {
        require(msg.value >= MINIMUM_ENTER, "Didn't send enough");
        uint256 _comissionToContract = msg.value * 5 / 100;             // calculate the amount that should be invested to contract (5%)
        uint256 _valueToUser = msg.value - _comissionToContract;        // calculate the amount that left in user's balance after investing to contract (95%)

        accountBalance[msg.sender] += _valueToUser;                     // change balance afther investing
    }

    /** @notice Function to withdraw funds from the account and send comissions according to the depth of referals
    */
    function withdraw() external returns(bool) {
        uint _userBalance = accountBalance[msg.sender];
        require(_userBalance > 0, "Your current balance is 0");

        uint16 getPercentage = 1000;               // in array levelComissions we have int numbers, to get proportion we need: value / 10
        address _current = msg.sender;
        uint _counterDepth = 0;
        uint _comission = 0;
    
        for (uint i = 0; i<10; i++) {              // calculate the depth of the referals
            while(_current != address(0)) {
                _counterDepth++;
                _current = referalOfTheUser[msg.sender];
                _comission = _userBalance * levelComissions[getLevel(_current)] / getPercentage;    // value / 10 (to get value of comission)
                (bool success, ) = payable(_current).call{value: _comission}("");
                require(success, "Transfer failed");
                _userBalance -= _comission;
            }
        }

        (bool successUser, ) = payable(msg.sender).call{value: _userBalance}("");       // withdraw funds
        require(successUser, "Transfer failed");
        accountBalance[msg.sender] = 0;

        return true;
    }

    /** @notice Function to registrate in the system
    *   @param _referalLink Referal link (if exists) by which the user registers
    */
    function logIn(address _referalLink) external {             
        if(_referalLink != address(0)) {    
            partnersUsers[_referalLink].push(msg.sender);       // add user to array of people who entered with referal link of the partner              
        } else {
            partnersUsers[msg.sender].push(address(0));         // create new direct partner (referal link = address of new user)
        }
    }

    /** @notice Function to see by address of the user amount of direct partners and their levels
    */
    function directPartnersInfo() external view returns(uint, uint[] memory) {
        uint[] memory _partnersLevel;
        address[] memory _partnersAddresses = partnersUsers[msg.sender];    // array with partners' addresses of the user
        for(uint i = 0; i<partnersUsers[msg.sender].length; i++){
            _partnersLevel[i] = getLevel(_partnersAddresses[i]);            // get level of every partner of the user
        }
        return(partnersUsers[msg.sender].length, _partnersLevel);
    }

    /** @notice Function to get level of the user according to the amount of his investments
    *   @param _userAddress Address of the user 
    */
    function getLevel(address _userAddress) public view returns(uint256) {
        for(uint i = 1; i<levelInvestments.length; i++) {   
            if (accountBalance[_userAddress] <= levelInvestments[i] &&          //checkick that the user's account
                accountBalance[_userAddress] >= levelInvestments[i-1]) {        // between 2 levels
                return i-1;     // return level of the user
            }
        }
    }

}