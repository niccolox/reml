extern crate abci_rs;
extern crate chrono;
extern crate clap;
extern crate db_key;
extern crate leveldb;
extern crate rand;
extern crate ed25519_dalek;
extern crate tiny_keccak;
extern crate sha2;
extern crate rlp;
extern crate hex;

#[macro_use]
extern crate log;
extern crate fern;

#[macro_use]
extern crate lazy_static;

#[macro_use]
extern crate failure;

use std::sync::Mutex;

use clap::{App, Arg, SubCommand};
use rand::{OsRng};
use ed25519_dalek::{Keypair, PublicKey};
use tiny_keccak::Keccak;
use sha2::Sha512;

use abci_rs::server;

mod app;
mod store;
mod transaction;
mod agents;
mod vm;

use app::Pallium;
use transaction::Transaction;
use store::Store;

fn main() {
    setup_logger();

    let matches = App::new("Pallium Network CLI")
        .version("0.1.0")
        .author("Neocortex R&D Ltd.")
        .subcommand(SubCommand::with_name("create")
                    .about("Create new agent")
                    .arg(Arg::with_name("code")
                         .help("alias for pure agent address")
                         .index(1)))
        .subcommand(SubCommand::with_name("node").about("Run the Pallium Network node"))
        .get_matches();

    if let Some(matches) = matches.subcommand_matches("create") {
        let code:Vec<u8> = Vec::new();
        create_agent(code);
    }

    if let Some(matches) = matches.subcommand_matches("node") {

        lazy_static! {
            static ref STORE: Mutex<Store> = Mutex::new(Store::new());
            static ref APP: Pallium = Pallium::connect(&*STORE);
        };

        let addr = "127.0.0.1:46658".parse().unwrap();
        info!("Starting ABCIServer on {:?}", addr);
        server::start(addr, &*APP);
    }
}

fn create_agent(code: Vec<u8>){
    let mut cspring: OsRng = OsRng::new().unwrap();
    let keypair: Keypair = Keypair::generate::<Sha512>(&mut cspring);

    let public_key: PublicKey = keypair.public;
    let address = get_address(&public_key);
    
    let tx = Transaction::new(0, hex::encode(address), 0, hex::encode(code));
    println!("{:?}", tx);
    tx.send();
}

fn get_address(public_key: &PublicKey) -> [u8; 32]{
    let mut keccak = Keccak::new_keccak256();
    let mut result = [0u8; 32];
    keccak.update(&public_key.to_bytes().to_vec());
    keccak.finalize(&mut result);
    result
}

use std::io;

fn setup_logger() {
    let log_level = log::LevelFilter::Debug;
    let fern_dispatch = fern::Dispatch::default()
        .level(log::LevelFilter::Error)
        .level_for("pallium", log_level)
        .format(|out, message, record| {
            out.finish(format_args!(
                "{}[{}][{}] {}",
                chrono::Local::now().format("[%Y-%m-%d][%H:%M:%S]"),
                record.target(),
                record.level(),
                message
            ))
        });

    fern_dispatch.chain(io::stderr()).apply().unwrap();
}
// fn to_hex(bytes: &Vec<u8>) -
// }