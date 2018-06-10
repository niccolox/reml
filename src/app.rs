use abci_rs::Application;
use abci_rs::types::*;
use store::Store;

use std::sync::Mutex;

#[derive(Debug)]
pub struct Pallium {
    store: &'static Mutex<Store>
}

impl Pallium {
    #[inline]
    pub fn connect(store: &'static Mutex<Store>) -> Pallium {
        Pallium {
            store: store
        }
    }
}

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
        self.store.lock().unwrap().insert("1".into(), p.get_message().into());

        let mut response = ResponseEcho::new();
        //response.set_message(p.get_message().to_owned());
        response.set_message(self.store.lock().unwrap().get("1".to_owned()));
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
        println!("info {:?}", p);
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
