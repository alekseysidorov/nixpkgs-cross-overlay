fn main() {
    let _client = rdkafka::config::ClientConfig::new()
        .create_native_config()
        .unwrap();

    println!("Hello, rdkafka!");
}
