#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use memory::models::{game::{game, Game}, player::{player, Player}, tile::{tile, Vec2, Tile}};
    use memory::systems::actions::{actions, IActionsDispatcher, IActionsDispatcherTrait};

    // helper setup function
    fn setup_world() -> (IWorldDispatcher, IActionsDispatcher) {
        let mut models = array![
            game::TEST_CLASS_HASH, player::TEST_CLASS_HASH, tile::TEST_CLASS_HASH
        ];
        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        (world, actions_system)
    }

    fn init_game(actions_system: IActionsDispatcher) -> u32 {
        let g1 = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
        let pub_keys = array![g1, g1];
        let width = 1;
        let height = 2;
        actions_system.spawn(pub_keys.span(), width, height, g1, g1)
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_spawn() {
        let (world, actions_system) = setup_world();

        let game_id = init_game(actions_system);

        let game = get!(world, game_id, (Game));
        assert!(game.server_hash == 0xdefaced, "server_hash not set");
        assert!(game.ended == false, "game ended");

        //get tile (0,0)
        let curr_pos = Vec2 { x: 0, y: 0 };
        let t1 = get!(world, (game_id, curr_pos), (Tile));
        assert!(t1.public_key != 0, "tile x not set");
        assert!(t1.hidden == true, "tile should be hidden");

        //get tile (9,9)
        let curr_pos = Vec2 { x: 0, y: 1 };
        let t1 = get!(world, (game_id, curr_pos), (Tile));
        assert!(t1.public_key != 0, "tile x not set");
        assert!(t1.hidden == true, "tile should be hidden");

        //get unset tile
        let curr_pos = Vec2 { x: 0xdead, y: 0xbad };
        let t1 = get!(world, (game_id, curr_pos), (Tile));
        assert!(t1.public_key == 0, "tile x should be 0");
        assert!(t1.hidden == false, "tile should be hidden");
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_join() {
        let (world, actions_system) = setup_world();
        let game_id = init_game(actions_system);

        let player_address = starknet::contract_address_const::<0x4A1D0>();
        let player_name = 'val12';
        actions_system.join(player_address, player_name, game_id);

        let player = get!(world, (game_id, player_address), (Player));
        assert!(player.name == player_name, "player name not set");
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_match_tiles() {
        let (world, actions_system) = setup_world();
        let game_id = init_game(actions_system);

        let player_address = starknet::contract_address_const::<0x4A1D0>();
        let player_name = 'val12';
        actions_system.join(player_address, player_name, game_id);
        let player = get!(world, (game_id, player_address), (Player));
        assert!(player.score == 0, "player score should be 0");

        let tile1_pos = Vec2 { x: 0, y: 0 };
        let tile2_pos = Vec2 { x: 0, y: 1 };
        let proof_c = 0x1a036bbef2d14e4b59f1eed5cc5bca7c8be1689f7863d6fa907ce6b444c351;
        let proof_s = 0x1a036bbef2d14e4b59f1eed5cc5bca7c8be1689f7863d6fa907ce6b444c352;

        actions_system.match_tiles(player_address, tile1_pos, tile2_pos, proof_c, proof_s, game_id);

        let t1 = get!(world, (game_id, tile1_pos), (Tile));
        let t2 = get!(world, (game_id, tile2_pos), (Tile));
        let player = get!(world, (game_id, player_address), (Player));
        assert!(t1.hidden == false, "tile 1 should be visible");
        assert!(t2.hidden == false, "tile 2 should be visible");
        assert!(player.score == 1, "player score should be 1");
    }
}
