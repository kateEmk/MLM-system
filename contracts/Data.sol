// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

contract Data {

    uint256 investedPrice;
    uint256 requiredPrice;
    uint256 partnerDepth;
    uint256 public refLink;
    bool isRefLink;
    uint public constant MINIMUM_ENTER = 20 wei;
    uint public investToContract = MINIMUM_ENTER * 0.05;
    address[] public investors;

    mapping (address => mapping(address=>address)) directPartners;  //address direct partner - люди по его ссылке (их адрес - их)
    mapping (address => uint256) directPartnLevel; 

    constructor () {
        uint256 LEVEL1 = 0.005 ether;
        uint256 LEVEL2 = 0.01 ether;
        uint256 LEVEL3 = 0.02 ether;
        uint256 LEVEL4 = 0.05 ether;
        uint256 LEVEL5 = 0.1 ether;
        uint256 LEVEL6 = 0.2 ether;
        uint256 LEVEL7 = 0.5 ether;
        uint256 LEVEL8 = 1 ether;
        uint256 LEVEL9 = 2 ether;
        uint256 LEVEL10 = 5 ether;

        //partnetLevel1 = 0.01;
        //partnetLevel2 = 0.007;
        //partnetLevel3 = 0.005;
        //partnetLevel4 = 0.002;
        //partnetLevel5 = 0.001;
        //partnetLevel6 = 0.001;
        //partnetLevel7 = 0.001;
        //partnetLevel8 = 0.001;
        //partnetLevel9 = 0.001;
        //partnetLevel10 = 0.001;
    }


}
