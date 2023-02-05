fn main() {
    let path = tempfile::tempdir().unwrap();
    let _db = rocksdb::DB::open_default(&path).unwrap();

    println!("Hello, world!");
}
