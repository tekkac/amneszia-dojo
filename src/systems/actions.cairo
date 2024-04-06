use starknet::ContractAddress;
use memory::models::game::Game;
use memory::models::player::Player;
use memory::models::tile::{Tile, Vec2};

// define the interface
#[dojo::interface]
trait IActions {
    fn spawn() -> u32;
    fn join(address: ContractAddress, name: felt252, game_id: u32);
    fn match_tiles(address: ContractAddress, pos1: Vec2, pos2: Vec2, game_id: u32);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::IActions;
    use memory::models::{tile::{Tile, Vec2}, player::Player, game::Game};

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
        fn spawn(world: IWorldDispatcher) -> u32 {
            let game_id = world.uuid();

            // Default tile
            let tile_id = 0;
            let revealed = false;
            let mut x = 0;
            loop {
                if x == 10 {
                    break;
                }
                let mut y = 0;
                loop {
                    if y == 10 {
                        break;
                    }
                    let position = Vec2 { x, y };
                    let tile = Tile { game_id, position, tile_id, revealed };
                    set!(world, (tile));
                    y += 1;
                };
                x += 1;
            };

            let game = Game { game_id, ended: false, server_hash: 0xdefaced, };
            set!(world, (game));

            game_id
        }

        fn join(world: IWorldDispatcher, address: ContractAddress, name: felt252, game_id: u32) {
            let player = Player { game_id, address, name, score: 0_u32, };
            set!(world, (player));

            emit!(world, Joined { game_id, address, name });
        }
        fn match_tiles(
            world: IWorldDispatcher, address: ContractAddress, pos1: Vec2, pos2: Vec2, game_id: u32
        ) {
            let mut tile1 = get!(world, (game_id, pos1), (Tile));
            let mut tile2 = get!(world, (game_id, pos2), (Tile));
            let mut player = get!(world, (game_id, address), (Player));

            //TODO: Check if the tiles are the same
            tile1.revealed = true;
            tile2.revealed = true;

            player.score += 1;

            set!(world, (player));
            set!(world, (tile1, tile2));

            emit!(world, Matched { game_id, address, pos1, pos2 });
        }
    }
}
