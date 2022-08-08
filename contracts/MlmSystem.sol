// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./MlmToken.sol";

contract MlmSystem is Initializable {

    address mlmToken;
    uint8[10] public levelComissions;        // array of comissions according to the level of the user
    uint64 public MINIMUM_ENTER;               // minimum amount to log in into system
    uint64[10] public levelInvestments;       // array with levels of investments according to the amount of ether

    mapping (address => uint256) public accountBalance;        // user address - balance of his account
    mapping (address => address[]) public partnersUsers;       // address of directPartner -> users who entered with his referalLink //referals
    mapping (address => address) public referalOfTheUser;      // user - referal (who invited user) 

    function initialize(uint64 _MINIMUM_ENTER, uint64[10] memory _levelInvestments, uint8[10] memory _levelComissions, address tokenAddress) external initializer {
        MINIMUM_ENTER = _MINIMUM_ENTER;
        levelInvestments = _levelInvestments;
        levelComissions = _levelComissions; 
        mlmToken = tokenAddress;
    }

    receive() external payable {}
    fallback() external payable {}

    /** @notice Function to invest funds to the account    
     */
    function invest(uint256 _amount) external {
        require(_amount >= MINIMUM_ENTER, "Didn't send enough");
        uint256 _comissionToContract = _amount * 5 / 100;             // calculate the amount that should be invested to contract (5%)

        MlmToken(mlmToken).transferFrom(msg.sender, address(this), _amount);            // transfer tokens to the address
        accountBalance[msg.sender] += _amount - _comissionToContract;                     // change balance afther investing
    }

    /** @notice Function to withdraw funds from the account and send comissions according to the depth of referals
        @return Boolean value that withdraw function was executed correctly
     */
    function withdraw() external returns(bool) {
        uint _userBalance = accountBalance[msg.sender];
        require(_userBalance > 0, "Your current balance is 0");

        uint16 getPercentage = 1000;               // in array levelComissions we have int numbers, to get proportion we need: value / 10
        address _current = msg.sender;
        uint _counterDepth = 0;
        uint _comission = 0;
    
        for (uint i = 0; i < 10; i++) {              // calculate the depth of the referals
            while(_current != address(0)) {
                _counterDepth++;
                _current = referalOfTheUser[msg.sender];
                _comission = _userBalance * levelComissions[getLevel(_current)] / getPercentage;    // value / 10 (to get value of comission)
                MlmToken(mlmToken).approve(msg.sender, _comission);
                MlmToken(mlmToken).transferFrom(msg.sender, payable(_current), _comission);
                _userBalance -= _comission;
            }
        }

        accountBalance[msg.sender] = 0;

        MlmToken(mlmToken).transfer(address(this), _userBalance);
        return true;
    }

    /** @notice Function to registrate in the system
    *   @param _referalLink Referal link (if exists) by which the user registers
    */
    function logIn(address _referalLink) external {             
        if(_referalLink != address(0)) {    
            partnersUsers[_referalLink].push(msg.sender); }     // add user to array of people who entered with referal link of the partner              
        // } else {
        //     partnersUsers[msg.sender].push(address(0));         // create new direct partner (referal link = address of new user)
        // }
    }

    /** @notice Function to see by address of the user amount of direct partners and their levels
        @return Function returns the amount of direct partners and array with their levels
    */
    function directPartnersInfo() external view returns(uint, uint[] memory) {
        address[] memory _partnersAddresses = partnersUsers[msg.sender];    // array with partners' addresses of the user
        uint256 amountPartners = _partnersAddresses.length;
        uint256[] memory _partnersLevel = new uint256[](amountPartners);
        
        for(uint i = 0; i < amountPartners; i++) {
            _partnersLevel[i] = getLevel(_partnersAddresses[i]);            // get level of every partner of the user
        }
        return(amountPartners, _partnersLevel);
    }

    /** @notice Function to get level of the user according to the amount of his investments
    *   @param _userAddress Address of the user 
        @return Function returns level of the user in the system
    */
    function getLevel(address _userAddress) private view returns(uint256) {
        for(uint256 i = 0; i <= levelInvestments.length - 1; i++) {
            if(accountBalance[_userAddress] < levelInvestments[i]) {
                return i + 1;
            }
        }
        return levelInvestments.length;
    }

}