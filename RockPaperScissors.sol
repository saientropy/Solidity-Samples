// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.7.0 <0.9.0;

contract rps {
    uint256 public startBlock = block.number;
    
    address public playerA;
    address public playerB;

    bytes32 playerA_choice;
    bytes32 playerB_choice;

    enum Choice {
        Empty,
        Rock, 
        Paper, 
        Scissor
    }

    enum Outcome {
        Player_A_wins,
        Player_B_wins,
        Draw,
        None
    }
    
    Choice public aChoice = Choice.Empty;
    Choice public bChoice = Choice.Empty;

    bool gameEnded = false;

    function resetAll() public {
        require(gameEnded);
        startBlock = block.number;
        playerA = address(0x0);
        playerB = address(0x0);
        playerA_choice = 0;
        playerB_choice = 0;
        aChoice = Choice.Empty;
        bChoice = Choice.Empty;
        gameEnded = false;
    }

    // modifier isNew(){
    //     require(playerA != msg.sender && playerB != msg.sender);
    //     _;
    // }

    //Initialize players
    function init() public{
        if(playerA == address(0x0)){
            playerA = msg.sender;
        }
        else if(playerB == address(0x0)){
            playerB = msg.sender;
        }
        return;
    }

    // commit the choice (Rock / Paper / Scissor)
    function commitChoice(bytes32 hash) public payable {
        require(block.number < (startBlock + 100));
        require((msg.sender == playerA && playerA_choice == 0) || (msg.sender == playerB && playerB_choice == 0), "not A or B");

        if(msg.sender == playerA) {
            playerA_choice = hash;
        } else {
            playerB_choice = hash;
        }
    }

    // reveal the choice (Rock / Paper / Scissor)
    function revealChoice(Choice choice, uint nonce) public {
        require(block.number >= (startBlock + 100) && block.number < (startBlock + 200));
        require(msg.sender == playerA || msg.sender == playerB, "not A or B");
        require(playerA_choice != 0 && playerB_choice != 0, "someone did not submit hash");
        require(choice != Choice.Empty, "have to choose Rock/Paper/Scissor");
        
        if(msg.sender == playerA) {
            if (playerA_choice == sha256(abi.encodePacked(choice, nonce))) {
                aChoice = choice;
            }
        } else {
            if (playerB_choice == sha256(abi.encodePacked(choice, nonce))) {
                bChoice = choice;
            }
        }
    }

    // check the result
    function findResult() public returns (Outcome) {
        require(block.number > (startBlock + 200));
        require(!gameEnded, "can only compute result once");
        require(aChoice != Choice.Empty && bChoice != Choice.Empty, "someone did not reveal their choice");

        // draw
        if (aChoice == bChoice) {
            return Outcome.Draw;
        } 
        else if (aChoice == Choice.Rock) {
            if (bChoice == Choice.Paper) {
                // alice: rock, bob: paper, bob win
                gameEnded = true;
                return Outcome.Player_B_wins;
            } 
            else {
                gameEnded = true;
                return Outcome.Player_A_wins;
            }
        } 
        else if (aChoice == Choice.Paper) {
            if (bChoice == Choice.Scissor) {
                gameEnded = true;
                return Outcome.Player_B_wins;
            } else {
                gameEnded = true;
                return Outcome.Player_A_wins;
            }
        } else if (aChoice == Choice.Scissor) {
            if (bChoice == Choice.Rock) {
                gameEnded = true;
                return Outcome.Player_B_wins;
            } else {
                gameEnded = true;
                return Outcome.Player_A_wins;
            }
        }
    }

}
