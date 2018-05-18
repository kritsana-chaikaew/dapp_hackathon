pragma solidity ^0.4.8;


contract TwoPartyLottery {
    address[2] _playerAddress;
    uint32 _turnLength;

    bytes32 _p1Commitment;
    bytes32 _p2Commitment;
    uint8 _p1Nonce;
    uint8 _p2Nonce;

    uint256 _turnDeadline;
    
    bool _isStart;
    bool _isP1Join;
    bool _isP2Join;
    bool _isP1Ready;
    bool _isP2Ready;

    uint8 _result;

    function TwoPartyLottery () public {
        _turnLength = 10;
        _isStart = false;
        _isP1Join = false;
        _isP2Join = false;
        _isP1Ready = false;
        _isP2Ready = false;
    }
    
    function joinGame(bytes32 commitment) public payable {
        require((_isP1Join && _isP2Join) == false);

        if (_isP1Join==false) {
            require(address(this).balance > 0);
            _playerAddress[0] = msg.sender;
            _p1Commitment = commitment;
            _isP1Join = true;
        } else {
            require(msg.sender != _playerAddress[0]);
            require((msg.value * 2) >= address(this).balance);
            _playerAddress[1] = msg.sender;
            _p2Commitment = commitment;
            _isP2Join = true;
        }
    }

    function ready(uint8 nonce) public {
        require(_isP1Join && _isP2Join && (_isStart == false));

        if (msg.sender == _playerAddress[0]) {
            require(keccak256(nonce) == _p1Commitment);
            _p1Nonce = nonce;
            _isP1Ready = true;
        } else if (msg.sender == _playerAddress[1]) {
            require(keccak256(nonce) == _p2Commitment);
            _p2Nonce = nonce;
            _isP2Ready = true;
        }

        if (_isP1Ready && _isP2Ready) {
            _result = _p1Nonce ^ _p2Nonce & 0x1;
            selfdestruct(_playerAddress[_result]);
        }

        _turnDeadline = block.number + _turnLength;
        _isStart = true;
    }

    function defaultGame() public {
        require (block.number > _turnDeadline);
        if (_isP1Ready) {
            selfdestruct(_playerAddress[0]);
        } else if (_isP1Ready) {
            selfdestruct(_playerAddress[1]);
        }
    }

    function getResult() view public returns (uint256) {
        return _result;
    }

    function getAddress() view public returns (address, address) {
        return (_playerAddress[0], _playerAddress[1]);
    }

    function getFlags() view public returns (bool, bool, bool, bool) {
        return (_isP1Join, _isP2Join, _isP1Ready, _isP2Ready);
    }


}