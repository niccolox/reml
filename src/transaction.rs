use rlp::{self, Encodable, RlpStream};

#[derive(Debug)]
pub struct Transaction {
    nonce: usize,
    to: Vec<u8>,
    value: usize,
    data: Vec<u8>
}

impl Encodable for Transaction {
    fn rlp_append(&self, s: &mut RlpStream) {
        s.append(&self.nonce);
        s.append(&self.to);
        s.append(&self.value);
        s.append(&self.data);
    }
}

impl Transaction {
    pub fn new(nonce: usize, to: Vec<u8>, value: usize, data: Vec<u8>) -> Self{
        Transaction {nonce, to, value, data}
    }

    pub fn serialize(&self) -> Vec<u8> {
        rlp::encode(self).into_vec()
    }

    pub fn send(&self) -> bool {
        let tx = self.serialize();
        println!("RLP: {:?}", tx);
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