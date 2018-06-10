// This is emulation of the Pallium Virtual Machine.

// The implementation of turing complete virtual machine is 
// https://github.com/neocortexlab/pallium-core/tree/master/pvm

use hex; 
//use agents;
use transaction::{Transaction};
use std::collections::BTreeMap;

type Code = Vec<u8>;

#[derive(Clone, Debug)]
pub struct Vm {
    state: BTreeMap<u8, Vec<u8>>,
    code: Code,
    position: u64
}

#[derive(Copy, Clone, Debug)]
pub struct Opcode {
    name: &'static str,
    instruction: u8,
    first_arg_lenght: u8,
    second_arg_lenght: u8,
}

impl Opcode {
    pub fn new(name: &'static str, instruction: u8, first_arg_lenght: u8, second_arg_lenght: u8) -> Self {
        Opcode {name, instruction, first_arg_lenght, second_arg_lenght}
    }

    pub fn length(&self) -> u64 {
        (1 + self.first_arg_lenght + self.second_arg_lenght) as u64
    }

    pub fn default() -> Self {
        Opcode {
            name: "",
            instruction: 0,
            first_arg_lenght: 0,
            second_arg_lenght: 0
        }
    }
}

lazy_static! {
    pub static ref OPCODES: [Opcode; 0x100] = {
        let mut arr = [Opcode::default(); 0x100];
        // insert value to state
        arr[0x00 as usize] = Opcode::new("INSERT", 0x00, 32, 32);
        // get value from state
        arr[0x01 as usize] = Opcode::new("GET", 0x00, 32, 0);
        arr
    };
}

fn do_insert(pvm: Vm, opcode: Opcode) -> Vm{
    let mut code:Vec<u8> = Vec::new();
    let mut state:BTreeMap<u8,Vec<u8>> = BTreeMap::new();

    code.clone_from(&pvm.code);
    state.clone_from(&pvm.state);

    let key = &code[1 as usize .. opcode.first_arg_lenght as usize];
    let value = &code[33 as usize ..];
    let key:u8 = 1;
    //let value = &code[(1 + opcode.first_arg_lenght) as usize .. opcode.second_arg_lenght as usize];
    state.insert(key, value.to_vec());

    Vm {
        state: state,
        position: opcode.length(),
        ..pvm
    }
}

impl Vm {
    pub fn new() -> Self {
        Vm {state: BTreeMap::new(), code: Vec::new(), position: 0}
    }

    pub fn set_state(&mut self, next_state: BTreeMap<u8,Vec<u8>>) {
        self.state.clone_from(&next_state);
    }

    pub fn set_code(&mut self, code: Code) {
        self.code = code;
    }

    pub fn execute(&mut self) {
        let code_lenght = self.code.len() as u64;

        if code_lenght > 0 {
            loop {

                if self.position >= code_lenght {
                    break;
                }

                let mut clone = Vm::new();
                clone.clone_from(&self);

                let command = self.code[self.position as usize];

                self.clone_from(&match command {
                        0x00 => do_insert(clone, OPCODES[0x00]),
                        __ => clone,
                    });
            }
        }
    }
}

#[test]
fn run_vm() {
    use tiny_keccak::Keccak;

    let mut keccak = Keccak::new_keccak256();
    let mut key = [0u8; 32];

    let mut value = vec![0u8; 32];
    let mut s: Vec<u8> = From::from("cat");

    value.resize(29, 0);
    value.append(&mut s);

    keccak.update(&value);
    keccak.finalize(&mut key);

    let mut code:Vec<u8> = Vec::new();

    code.push(0x00);
    code.append(&mut key.to_vec());
    code.append(&mut value.to_vec());

    assert_eq!(value, vec![]);
    
        
    // let mut vm = Vm::new();
    // vm.set_code(code);
    // vm.execute();
    // //let str_key = String::from_utf8(key.to_vec()).unwrap();
    // let value = vm.state.get(&1);
    //vm.execute();
    //assert_eq!(value, Some(&value)); //Some(&String::from_utf8(value).unwrap()));
   // assert_eq!(value.len(), 32);
}
// pub fn executor(tx: String) {
//     let tx_raw = Transaction::deserialize(hex::decode(tx).unwrap());

//     println!("Transaction: {:?}", tx_raw);
// }