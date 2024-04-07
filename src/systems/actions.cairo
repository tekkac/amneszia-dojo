use starknet::ContractAddress;
use memory::models::game::Game;
use memory::models::player::Player;
use memory::models::tile::{Tile, Vec2};

// define the interface
#[dojo::interface]
trait IActions {
    fn spawn(pub_keys: Span<felt252>, width: u32, height: u32, g1_x: felt252, g2_x: felt252) -> u32;
    fn join(address: ContractAddress, name: felt252, game_id: u32);
    fn match_tiles(
        address: ContractAddress,
        pos1: Vec2,
        pos2: Vec2,
        proof_c: felt252,
        proof_s: felt252,
        game_id: u32,
    );
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::IActions;
    use memory::models::{tile::{Tile, Vec2}, player::Player, game::Game};
    use memory::utils::check_logeq_proof;

    use starknet::{ContractAddress, get_caller_address};

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Matched: Matched,
        Joined: Joined,
    }

    #[derive(starknet::Event, Model, Copy, Drop, Serde)]
    struct Matched {
        #[key]
        game_id: u32,
        address: ContractAddress,
        pos1: Vec2,
        pos2: Vec2,
    }

    #[derive(starknet::Event, Model, Copy, Drop, Serde)]
    struct Joined {
        #[key]
        game_id: u32,
        address: ContractAddress,
        name: felt252,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(
            world: IWorldDispatcher,
            mut pub_keys: Span<felt252>,
            width: u32,
            height: u32,
            g1_x: felt252,
            g2_x: felt252
        ) -> u32 {
            let game_id = world.uuid();

            assert(width * height == pub_keys.len(), 'invalid number of keys');

            // Create tiles
            let hidden = true;
            let mut x = 0;
            loop {
                if x == width {
                    break;
                }
                let mut y = 0;
                loop {
                    if y == height {
                        break;
                    }
                    let position = Vec2 { x, y };
                    let public_key = *pub_keys.pop_front().expect('invalid number of keys');

                    let tile = Tile { game_id, position, public_key, hidden };
                    set!(world, (tile));
                    y += 1;
                };
                x += 1;
            };

            let game = Game { game_id, ended: false, server_hash: 0xdefaced, g1_x, g2_x };
            set!(world, (game));

            game_id
        }

        fn join(world: IWorldDispatcher, address: ContractAddress, name: felt252, game_id: u32) {
            let player = Player { game_id, address, name, score: 0_u32, };
            set!(world, (player));

            emit!(world, Joined { game_id, address, name });
        }
        fn match_tiles(
            world: IWorldDispatcher,
            address: ContractAddress,
            pos1: Vec2,
            pos2: Vec2,
            proof_c: felt252,
            proof_s: felt252,
            game_id: u32,
        ) {
            let mut tile1 = get!(world, (game_id, pos1), (Tile));
            let mut tile2 = get!(world, (game_id, pos2), (Tile));
            let mut player = get!(world, (game_id, address), (Player));

            // Check player has joined
            assert(player.address == address, 'player not found');

            // Check proof that the tiles are the same
            let game = get!(world, (game_id), (Game));
            assert(game.ended == false, 'game ended');
            let g1 = game.g1_x;
            let g2 = game.g2_x;
            let y = tile1.public_key;
            let z = tile2.public_key;
            let way1 = check_logeq_proof(g1, g2, y, z, proof_c, proof_s);
            let way2 = check_logeq_proof(g1, g2, z, y, proof_c, proof_s);
            assert(way1 || way2, 'proof failed');

            tile1.hidden = false;
            tile2.hidden = false;

            player.score += 1;

            set!(world, (player));
            set!(world, (tile1, tile2));

            emit!(world, Matched { game_id, address, pos1, pos2 });
        }
    }
}
