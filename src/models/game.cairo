use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32,
    ended: bool,
    // commitment to the game state?
    server_hash: felt252,
    g1_x: felt252,
    g2_x: felt252
}
