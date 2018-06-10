use std::{env, path::Path};

// use db_key::Key;
// use leveldb::{self, database::Database, kv::KV, options::{Options, ReadOptions, WriteOptions}};

use std::collections::BTreeMap;

#[derive(Debug)]
pub struct Store {
    //db: Database<StoreKey>,
    pub db: BTreeMap<String, String>
}

impl Store {
    pub fn new() -> Self {
        // let mut options = Options::new();
        // options.create_if_missing = true;

        // let home = env::home_dir().expect("Impossible to get your home dir!");
        // let path = Path::new(&home).join(".pallium/store.lvldb");
        // let db = Database::open(&path, options).unwrap();
        let db =  BTreeMap::new();
        Store { db: db }
    }

    pub fn insert(&mut self, key: String, value: String) {
        self.db.insert(key, value);
    }

    pub fn get(&self, key: String) -> String {
        let value = self.db.get("1");
        value.unwrap().to_owned()
    }
}

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