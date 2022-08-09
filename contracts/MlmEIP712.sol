// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MlmEIP712 is EIP712 {
    using ECDSA for bytes32;

    struct Message {
        address from;           // Externally-owned account (EOA) making the request.
        address to;             // Destination address, normally a smart contract.
        uint256 value;
        bytes data;            // (Call)data to be sent to the destination.
    }

    struct Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }

    bytes32 private constant message_HASH = keccak256("Message(address from, address to, uint256 value, bytes data)");
    bytes32 private constant domain_HASH = keccak256("Domain(string name, string version, uint256 chainId, address verifyingContract, bytes32 salt)");

    constructor() EIP712("MlmEIP712", "0.0.1") {}

    // Returns the domain separator used in the encoding of the signature for `execute`, as defined by {EIP712}.
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function veryfyingContract() public view returns(address) {
        return address(this);
    }

    function verify(Message calldata req, bytes calldata signature) public view returns(bool) {
        address signer = _hashTypedDataV4(keccak256(abi.encode(
            message_HASH,
            req.from,
            req.to,
            req.value,
            keccak256(req.data)
        ))).recover(signature);
        return signer == req.from;
    }

    function execute(Message calldata req, bytes calldata signature) public payable returns(bool, bytes memory) {
        // require(verify(req, signature), "Signature does not match request");

        // (bool success, bytes memory returndata) = req.to.call{value: req.value}(
        //     abi.encodePacked(req.data, req.from)
        // );

        // return (success, returndata);
    }

}


// const domain = {
//     name: 'Ether Mail',
//     version: '1',
//     chainId: 1,
//     verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC'
// };