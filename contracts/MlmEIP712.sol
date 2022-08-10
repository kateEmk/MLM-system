// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MlmEIP712 is EIP712 {
    using ECDSA for bytes32;

    struct Message {
        address from;           // Externally-owned account (EOA) making the request.
        uint256 value;
        bytes32 salt;
        bytes signature;
    }

    struct Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    bytes32 private constant message_HASH = keccak256("Message(address from, address to, uint256 value, bytes data, bytes32 salt)");
   
    constructor() EIP712("MlmEIP712", "0.0.1") {}   

    function verify(Message calldata req) public returns(bool) {
        bytes32 hash = checkHash(req);
        return ECDSA.recover(hash, req.signature) == msg.sender;
    }

    function checkHash(Message calldata req) public returns( bytes32) {
        require(verify(req), "Signature does not match request");
        bytes32 hash = _hashTypedDataV4(keccak256(abi.encode(
            message_HASH,
            req.from,
            req.value,
            req.salt
        )));
        return hash;
    }

}


// const domain = {
//     name: 'Ether Mail',
//     version: '1',
//     chainId: 1,
//     verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC'
// };
