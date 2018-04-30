extern crate clap;
extern crate abci_rs;

use clap::{App, Arg, SubCommand};

use abci_rs::{Application, server};
//use abci_rs::Application;
use abci_rs::types::*;

#[derive(Copy, Clone)]
struct Pallium;

// Socket implementation
impl Application for Pallium {
    fn begin_block(&self, p: &RequestBeginBlock) -> ResponseBeginBlock {
        println!("begin_block");
        ResponseBeginBlock::new()
    }

    fn check_tx(&self, p: &RequestCheckTx) -> ResponseCheckTx {
        println!("check_tx");
        ResponseCheckTx::new()
    }

    fn commit(&self, p: &RequestCommit) -> ResponseCommit {
        println!("commit");
        ResponseCommit::new()
    }

    fn deliver_tx(&self, p: &RequestDeliverTx) -> ResponseDeliverTx {
        println!("deliver_tx");
        ResponseDeliverTx::new()
    }

    fn echo(&self, p: &RequestEcho) -> ResponseEcho {
        let mut response = ResponseEcho::new();
        response.set_message(p.get_message().to_owned());
        return response;
    }

    fn end_block(&self, p: &RequestEndBlock) -> ResponseEndBlock {
        println!("end_block");
        ResponseEndBlock::new()
    }

    fn flush(&self, p: &RequestFlush) -> ResponseFlush {
        println!("flush");
        ResponseFlush::new()
    }

    fn init_chain(&self, p: &RequestInitChain) -> ResponseInitChain {
        println!("init_chain");
        ResponseInitChain::new()
    }

    fn info(&self, p: &RequestInfo) -> ResponseInfo {
        //println!("info");
        println!("indo {:?}", p);
        ResponseInfo::new()
    }

    fn query(&self, p: &RequestQuery) -> ResponseQuery {
        println!("query");
        ResponseQuery::new()
    }

    fn set_option(&self, p: &RequestSetOption) -> ResponseSetOption {
        println!("set_option {:?}", p);
        ResponseSetOption::new()
    }
}

fn main() {
    let matches = App::new("Pallium Network CLI")
        .version("0.1.0")
        .author("Neocortex R&D Ltd.")
        .subcommand(SubCommand::with_name("node")
                    .about("Run the Pallium Network node"))
        .get_matches();

    if let Some(matches) = matches.subcommand_matches("node") {
        static APP: Pallium = Pallium;
        let addr = "127.0.0.1:46658".parse().unwrap();
        println!("Starting ABCIServer on {:?}", addr);
        server::start(addr, &APP);
    }

    // loop {
    //     thread::park();
    // }
}