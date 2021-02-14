type action is
  | SendRequest of (address)
  | GetInfo of (nat * nat)

type store is nat * nat

type callback is contract(nat * nat)

type return is list (operation) * store

const nop: list (operation) = (nil: list(operation));

const owner: address = ("tz1RiffSJssQNXH5BBriGZMhhcqm5j637ehr": address);

function get_info (const p: store; var store : store) : return is
  block {
    store := p;
    if (p.1 mod 2n) = 0n then store.1 := 33n;
    else skip
  } with (nop, store)
  
// KT1WYEpgbT3sobMQmYCaWf8kvffrzLJCukFw
function send_request (const destinationAddress : address; const store : store) : return is
  block {
    if Tezos.sender =/= owner then failwith ("Only owner is allowed to call");
    else skip; 
    if store.1 =/= 0n then failwith ("Method was already invoked once");
    else skip;
    const callback : callback =
    case (Tezos.get_entrypoint_opt("%getInfo", Tezos.self_address) : option(callback)) of 
    | Some (cb) -> cb
    | None -> (failwith ("Bad contract"): callback)
    end;
    const destination : contract (callback) =
    case (Tezos.get_contract_opt (destinationAddress) : option (contract (callback))) of
    | Some (dest) -> dest
    | None -> (failwith ("Contract not found.") : contract (callback))
    end;
} with (list [Tezos.transaction (callback, 0mutez, destination)], store)

// real entrypoint that re-routes the flow based
// on the action provided
function main (const action : action ; const store : store) : return is
  case action of
  | SendRequest(a) -> send_request(a, store)
  | GetInfo(n) -> get_info(n, store)
  end;
