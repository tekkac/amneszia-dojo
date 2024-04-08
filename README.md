# Amneszia dojo contracts

## About
Dojo contracts for Amnesia, a multiplayer memory-game with hidden information and zero-knowledg proofs.

## Actions
 - [x] `spawn`: creates a new board based on a commitment to its tiles
 - [x] `join`: players join a game with a name a Starknet mainnet address
 - [x] `match_tiles`: a player that has gained private information about two matching can prove they did by sending a zero-knowledge proof
 - [ ] `reveal`: ask for a tile to be revealed
 - [ ] `buy_action`: buy an action with $LORDS (can be used to reveal more cards)
 - [ ] `sell`: sell private information you own using MPC and receive $LORDS payment.


## ZK & Hidden info:
## Game Server
- Generate a secret board
- Sends public keys for each tile in board to contract
- Reveals tile private keys to players on click

## Players
- Gets private information on selected items
- Get points if they match two tiles tiles by zk-proving they know they match (matching private keys)

## Board generation:
- Server chooses two public curve generators: $G_1, G_2$
- Server picks random seed $server\_seed$ and commits to $hash(server\_seed)$
- Server shuffles and encode each tile $t_i$ by $h_i = hash(server\_seed, t_i)$ as $h_iG_1$ and $h_iG_2$ 
- Server publishes $hash(server\_seed), G1, G2, (h_iG_1, h_iG_2)_i$
## Public contract
- checks user proofs that two tiles $t1 = h_iG, t2 = h_jG$, match and sets them as revealed.

## Zero Knowledge Proof:
_Players show that two tiles match using NIZK proofs of discrete-log equality_
[Reference](https://asecuritysite.com/encryption/logeq)
