#[derive(Model, Drop, Serde)]
struct Tile {
    #[key]
    game_id: u32,
    #[key]
    position: Vec2,
    hidden: bool,
    public_key: felt252,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Vec2 {
    x: u32,
    y: u32
}
