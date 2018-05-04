// use std::{env, path::Path};

// use db_key::Key;
// use leveldb::{self, database::Database, kv::KV, options::{Options, ReadOptions, WriteOptions}};

// pub struct Store {
//     db: Database<StoreKey>,
// }

// pub struct Agent {
//     address: Vec<u8>,
//     nonce: usize,
//     balance: usize,
//     state: String,
//     code: Vec<u8>
// }

// impl Agent {
//     fn new(address: Vec<u8>, code: Vec<u8>) -> Self{
//         Agent {address, 0, 0, "", code}
//     }
//     fn load(address: Vec<u8>) -> Self {
        
//     }
// }

// pub struct AgentsManager {
//     db: Database<StoreKey>
// }

// impl AgentsManager {
//     pub fn new() -> Self {
//         let mut options = Options::new();
//         options.create_if_missing = true;

//         let home = env::home_dir().expect("Impossible to get your home dir!");

//         let path = Path::new(&home).join(".pallium/agents.lvldb");

//         let db = Database::open(&path, options).unwrap();

//         AgentsManager { db }
//     }

//     pub fn insert (&self, key: &Vec<u8>, value: &Vec<u8>) -> bool {
//         unimplemented!();
//     }

//     pub fn get_from_address(&self, address: &Vec<u8>) -> Agent {

//     }
// }

// pub struct StoreKey {
//     inner: Vec<u8>,
// }

// impl Key for StoreKey {
//     fn from_u8(key: &[u8]) -> Self {
//         StoreKey {
//             inner: Vec::from(key),
//         }
//     }

//     fn as_slice<T, F: Fn(&[u8]) -> T>(&self, f: F) -> T {
//         f(&self.inner)
//     }
// }