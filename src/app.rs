use abci_rs::Application;
use abci_rs::types::*;

#[derive(Copy, Clone)]
pub struct Pallium;

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
