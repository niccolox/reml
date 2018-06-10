use rlp::{self, Encodable, Decodable, RlpStream, UntrustedRlp, DecoderError, Rlp};
use std::fmt::Write;
use hex; 

type Address = String;

#[derive(Debug)]
pub struct Transaction {
    nonce: usize,
    to: Address,
    value: usize,
    data: String
}

impl Encodable for Transaction {
    fn rlp_append(&self, s: &mut RlpStream) {
        s.begin_list(4)
            .append(&self.nonce)
            .append(&self.to)
            .append(&self.value)
            .append(&self.data);
    }
}

impl Decodable for Transaction {
    fn decode(rlp: &UntrustedRlp) -> Result<Self, DecoderError> {
        let tx = Transaction {
            nonce: rlp.at(0).unwrap().as_val::<usize>().unwrap(),
            to: rlp.at(1).unwrap().as_val::<String>().unwrap(),
            value: rlp.at(2).unwrap().as_val::<usize>().unwrap(),
            data: rlp.at(3).unwrap().as_val::<String>().unwrap(),
        };
        
        Ok(tx)
    }
}

impl Transaction {
    pub fn new(nonce: usize, to: Address, value: usize, data: String) -> Self{
        Transaction {nonce, to, value, data}
    }

    pub fn serialize(&self) -> Vec<u8> {
        rlp::encode(self).into_vec()
    }

    pub fn deserialize(rlp: Vec<u8>) -> Self {
        rlp::decode(&rlp)
    }

    pub fn send(&self) -> bool {
        let tx = self.serialize();

       // vm::executor(hex::encode(tx));
        
        true
    }

    pub fn sign(&self) {
        //let keypair_bytes: [u8; KEYPAIR_LENGTH] = keypair.to_bytes();

        // let message: &[u8] = "This is a test of the tsunami alert system.".as_bytes();
        // let signature: Signature = keypair.sign::<Sha512>(message);

        // let verified: bool = keypair.verify::<Sha512>(message, &signature);
        // assert!(verified);
    }
}

