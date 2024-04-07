use core::hash::{HashStateTrait, HashStateExTrait};
use core::poseidon::{poseidon_hash_span, PoseidonTrait};
use core::ec::{EcPoint, EcPointTrait, EcStateTrait};
use core::ec;


// Checks a proof that Y = xG1 and Z = xG2 have the same discrete log (x)
// Protocol:
// Prover picks k 
// Prover sends c = pedersen(G1, G2, Y, Z, kG1, kG2)
// Prover sends s = k - c*x
// Verifier computes c' = pedersen(G1, G2, Y, Z, sG1 + cY, sG2 + cZ)
// Verifier checks c == c'
fn check_logeq_proof(
    g1: felt252, g2: felt252, y: felt252, z: felt252, c: felt252, s: felt252
) -> bool {
    // Check that proof parameters are valid
    if s == 0 || s == ec::stark_curve::ORDER || c == ec::stark_curve::ORDER {
        return false;
    }

    // Fetch generators
    let g1_point = match EcPointTrait::new_from_x(g1) {
        Option::Some(point) => point,
        Option::None => {
            return false;
        },
    };

    let g2_point = match EcPointTrait::new_from_x(g2) {
        Option::Some(point) => point,
        Option::None => {
            return false;
        },
    };

    // Compute points
    let y_point = match EcPointTrait::new_from_x(y) {
        Option::Some(point) => point,
        Option::None => {
            return false;
        },
    };

    let z_point = match EcPointTrait::new_from_x(z) {
        Option::Some(point) => point,
        Option::None => {
            return false;
        },
    };

    // Compute sG1 and cY
    let sG1: EcPoint = g1_point.mul(s);
    let cY: EcPoint = y_point.mul(c);

    // Compute sG2 and cZ
    let sG2: EcPoint = g2_point.mul(s);
    let cZ: EcPoint = z_point.mul(c);

    // Compute data
    let g1_x = get_x(g1_point).expect('cannot get x from G1');
    let g2_x = get_x(g2_point).expect('cannot get x from G2');
    let y_x = get_x(y_point).expect('cannot get x from Y');
    let z_x = get_x(z_point).expect('cannot get x from Z');
    let A_x = get_x(sG1 - cY).expect('cannot get x from sG1 - cY');
    let B_x = get_x(sG2 - cZ).expect('cannot get x from sG2 - cZ');

    let data = array![g1_x, g2_x, y_x, z_x, A_x, B_x];
    let c_prime = poseidon_hash_span(data.span());
    c == c_prime
}

fn get_x(p: EcPoint) -> Option<felt252> {
    match p.try_into() {
        Option::Some(pt) => {
            let (x, _) = ec::ec_point_unwrap(pt);
            Option::Some(x)
        },
        Option::None => {
            Option::None
        },
    }
}
