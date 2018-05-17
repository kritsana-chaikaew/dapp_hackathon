pragma solidity ^0.4.23;

contract TicTacToe {
    // game configuration
    address[2] _playerAddress; // address of both players
    uint32 _turnLength; // max time for each turn

    // nonce material used to pick the first player
    bytes32 _p1Commitment;
    uint8 _p2Nonce;

    // game state
    int8[9] _board; // serialized 3x3 array
    uint8 _currentPlayer; // 0 or 1, indicating whose turn it is
    uint256 _turnDeadline; // deadline for submitting next move
    
    uint256 _pot;
    int8[2] _flags;

    // Create a new game, challenging a named opponent.
    // The value passed in is the stake which the opponent must match.
    // The challenger commits to its nonce used to determine first mover.
    constructor (address opponent, uint32 turnLength, bytes32 p1Commitment) public payable {
        _flags[0] = -1;
        _flags[1] = 1;
        _playerAddress[0] = msg.sender;
        _playerAddress[1] = opponent;
        _turnLength = turnLength;
        _p1Commitment = p1Commitment;
        _pot = address(this).balance;
    }

    // Join a game as the second player.
    function joinGame(uint8 p2Nonce) public payable {
        // only the specified opponent may join
        require (msg.sender == _playerAddress[1]);
        // must match player 1's stake.
        require ((msg.value * 2) >= _pot);

        _p2Nonce = p2Nonce;
    }

    // Revealing player 1's nonce to choose who goes first.
    function startGame(uint8 p1Nonce) public {
        // must open the original commitment
        require (keccak256(abi.encodePacked(p1Nonce)) == _p1Commitment);

        // XOR both nonces and take the last bit to pick the first player
        _currentPlayer = (p1Nonce ^ _p2Nonce) & 0x01;

        // start the clock for the next move
        _turnDeadline = block.number + _turnLength;
    }

    // Submit a move
    function playMove(uint8 squareToPlay) public {
        // make sure correct player is submitting a move
        require (msg.sender == _playerAddress[_currentPlayer]);

        // claim this square for the current player.
        require (_board[squareToPlay] == 0);
        _board[squareToPlay] = _flags[_currentPlayer];

        // If the game is won, send the pot to the winner
        if (checkGameOver())
        selfdestruct(msg.sender);

        // Flip the current player
        _currentPlayer ^= 0x1;

        // start the clock for the next move
        _turnDeadline = block.number + _turnLength;
    }

    // Default the game if a player takes too long to submit a move
    function defaultGame() public {
        if (block.number > _turnDeadline)
        selfdestruct(msg.sender);
    }

    function checkGameOver() internal view returns (bool) {
        if ((_board[0] + _board[1] + _board[2] == 3 * _flags[_currentPlayer])
            || (_board[3] + _board[4] + _board[5] == 3 * _flags[_currentPlayer]) 
            || (_board[6] + _board[7] + _board[8] == 3 * _flags[_currentPlayer])
            || (_board[0] + _board[3] + _board[6] == 3 * _flags[_currentPlayer])
            || (_board[1] + _board[4] + _board[7] == 3 * _flags[_currentPlayer])
            || (_board[2] + _board[5] + _board[8] == 3 * _flags[_currentPlayer])
            || (_board[0] * _board[4] * _board[8] == 3 * _flags[_currentPlayer])
            || (_board[2] * _board[4] * _board[6] == 3 * _flags[_currentPlayer])) {
            return true;
        }
        return false;
    }
    
    function getBalance() view public returns (uint256) {
        return address(this).balance;
    }
    
    function getCurrentPlayer() view public returns (uint8) {
        return _currentPlayer;
    }
    
    function getBoard() view public returns (int8[9]) {
        return _board;
    }
}