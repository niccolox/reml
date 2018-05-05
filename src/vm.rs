// This is emulation of the Pallium Virtual Machine.

// The implementation of turing complete virtual machine is 
// https://github.com/neocortexlab/pallium-core/tree/master/pvm

use hex; 
use agents;
use transaction::{Transaction};

pub fn executor(tx: String) {
    let tx_raw = Transaction::deserialize(hex::decode(tx).unwrap());

    println!("Transaction: {:?}", tx_raw);
}