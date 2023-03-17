include!(concat!(env!("OUT_DIR"), "/generated.rs"));

#[test]
fn test_phone_number() {
    use nixpkgs::cross::overlay::example::{PhoneNumber, PhoneType};

    let number = PhoneNumber::default();
    assert_eq!(number.kind, PhoneType::Home.into());
}
