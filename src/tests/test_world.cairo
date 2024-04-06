#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;

    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // import test utils
    use memory::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        models::{game::Game, player::Player, tile::{Tile, Vec2}}
    };

    #[test]
    #[available_gas(30000000)]
    fn test_spawn() {}

    #[test]
    #[available_gas(30000000)]
    fn test_join() {}

    #[test]
    #[available_gas(30000000)]
    fn test_match_tiles() {}
}
