// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PokemonDio is ERC721, ReentrancyGuard {

    struct Pokemon {
        string name;
        uint8 level; // Assuming levels won't exceed 255
        string img;
    }

    Pokemon[] public pokemons;
    address public immutable gameOwner;

    event PokemonCreated(uint indexed id, string name, address indexed owner);
    event BattleOutcome(uint indexed attackerId, uint indexed defenderId, uint8 attackerLevel, uint8 defenderLevel);

    constructor () ERC721("PokemonDio", "PKD") {
        gameOwner = msg.sender;
    } 

    modifier onlyOwnerOf(uint _monsterId) {
        require(ownerOf(_monsterId) == msg.sender, "Only the owner can battle with this Pokemon");
        _;
    }

    function battle(uint _attackingPokemon, uint _defendingPokemon) public onlyOwnerOf(_attackingPokemon) nonReentrant {
        Pokemon storage attacker = pokemons[_attackingPokemon];
        Pokemon storage defender = pokemons[_defendingPokemon];

        if (attacker.level >= defender.level) {
            attacker.level += 3;
            defender.level += 1;
        } else {
            attacker.level += 1;
            defender.level += 3;
        }

        emit BattleOutcome(_attackingPokemon, _defendingPokemon, attacker.level, defender.level);
    }

    function createNewPokemon(string memory _name, address _to, string memory _img) public {
        require(msg.sender == gameOwner, "Only the game owner can create new Pokemons");

        uint id = pokemons.length;
        pokemons.push(Pokemon(_name, 1, _img));
        _safeMint(_to, id);

        emit PokemonCreated(id, _name, _to);
    }
}
