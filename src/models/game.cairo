use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32,
    ended: bool,
    // commitment to the game state?
    server_hash: felt252,
}
