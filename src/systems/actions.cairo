use starknet::ContractAddress;
use memory::models::game::Game;
use memory::models::player::Player;
use memory::models::tile::{Tile, Vec2};

// define the interface
#[dojo::interface]
trait IActions {
    fn spawn() -> u32;
    fn join(address: ContractAddress, name: felt252, game_id: u32);
    fn match_tiles(pos1: Vec2, pos2: Vec2, game_id: u32);
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
    }

    // declaring custom event struct
    #[derive(starknet::Event, Model, Copy, Drop, Serde)]
    struct Matched {
        #[key]
        player: ContractAddress,
        pos1: Vec2,
        pos2: Vec2,
    }

    // impl: implement functions specified in trait
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
        }
        fn match_tiles(pos1: Vec2, pos2: Vec2, game_id: u32) {}
    }
}
