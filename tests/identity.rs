use jekko_memory::{identity, validate_identity};

#[test]
fn public_identity_contract_is_stable() {
    validate_identity().expect("identity validates");
    let (repo, role, profile) = identity();
    assert_eq!(repo, "jekko-memory");
    assert_eq!(role, "data");
    assert_eq!(profile, "rust-data");
}
