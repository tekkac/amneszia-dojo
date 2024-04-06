#[derive(Model, Drop, Serde)]
struct Tile {
    #[key]
    game_id: u32,
    #[key]
    position: Vec2,
    // nft token id
    tile_id: u32,
    revealed: bool,
// commitment to the tile's value
// hash: felt252
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Vec2 {
    x: u32,
    y: u32
}
