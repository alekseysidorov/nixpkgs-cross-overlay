fn main() {
    prost_build::Config::new()
        .include_file("generated.rs")
        .compile_protos(&["proto/sample.proto"], &["proto/"])
        .unwrap();
}
