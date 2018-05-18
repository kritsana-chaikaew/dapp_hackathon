pragma solidity ^0.4.8;

contract NameRegistry {

    struct Contract {
        address owner;
        address addr;
        bytes32 description;
    }

    uint public numContracts;
    mapping (bytes32 => bool) public flags;

    mapping (bytes32 => Contract) public contracts;

    function NameRegistry() public {
        numContracts = 0;
    }

    function register(bytes32 _name) public returns (bool) {
        require(flags[_name]==false);
        contracts[_name].owner = msg.sender;
        contracts[_name].addr = msg.sender;
        flags[_name]==true;
        numContracts = numContracts + 1;
    }

    function unregister(bytes32 _name) public returns (bool) {
        require(flags[_name]);
        flags[_name]==false;
        numContracts = numContracts - 1;
    }

    function changeOwner(bytes32 _name, address _newOwner) public {
        require(flags[_name]);
        require(msg.sender==contracts[_name].owner);
        contracts[_name].owner = _newOwner;
    }

    function getOwner(bytes32 _name) view public returns (address) {
        return contracts[_name].owner;
    }

    function setAddr(bytes32 _name, address _addr) public {
        require(flags[_name]);
        require(msg.sender==contracts[_name].owner);
        contracts[_name].addr = _addr;
    }

    function getAddr(bytes32 _name) view public returns (address) {
        return contracts[_name].addr;
    }

    function setDescription(bytes32 _name, bytes32 _description) public {
        require(flags[_name]);
        require(msg.sender==contracts[_name].owner);
        contracts[_name].description = _description;
    }

    function getDescription(bytes32 _name) view public returns (bytes32) {
        return contracts[_name].description;
    }

}
