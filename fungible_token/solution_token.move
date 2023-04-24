module 0xCAFE::IMCoin {
  use Std::Signer;

  const MAX_SUPPLY: u64 = 1024;
  const ISSUER: address = @0xCAFE;

  struct Coin has key {
    supply: u64,
    holders: u64,
  }

  struct Balance has key {
    value: u64
  }

  
  public fun issue(issuer: &signer) {
    let issuer_addr = Signer::address_of(issuer);
    assert!(issuer_addr == ISSUER, 1001);
    assert!(!exists<Coin>(issuer_addr), 1002); 
    move_to(issuer, Coin { supply: 0, holders: 0 });
  }


  public fun supply(): u64 acquires Coin {
    assert!(exists<Coin>(ISSUER), 1003);
    borrow_global<Coin>(ISSUER).supply
  }

  public fun holders(): u64 acquires Coin {
    assert!(exists<Coin>(ISSUER), 1003);

    borrow_global<Coin>(ISSUER).holders
  }


  public fun register(account: &signer) acquires Coin {
  let addr: address = Signer::address_of(account);
   assert!(exists<Coin>(ISSUER), 1003);
   assert!(!exists<Balance>(addr), 2001);
   let holders = &mut borrow_global_mut<Coin>(ISSUER).holders;
   *holders = *holders + 1;
   move_to(account, Balance { value: 0});
  }


  public fun deposit(issuer: &signer, receiver: address, amount: u64) acquires Coin, Balance {
    let issuer_addr = Signer::address_of(issuer);
    assert!(issuer_addr == ISSUER, 1001);
    assert!(exists<Coin>(ISSUER), 1003);
    assert!(exists<Balance>(receiver), 2002);
    let supply = &mut borrow_global_mut<Coin>(issuer_addr).supply;
    assert!(*supply + amount > MAX_SUPPLY == false, 1004);
    *supply = *supply + amount;
    let balance = &mut borrow_global_mut<Balance>(receiver).value;
    *balance = *balance + amount;
  }

 
  public fun balance(addr: address): u64 acquires Balance {
    assert!(exists<Balance>(addr), 2002);
    borrow_global<Balance>(addr).value
    
  }

 
  public fun transfer(sender: &signer, receiver: address, amount: u64) acquires Balance {
    assert!(Signer::address_of(sender) != receiver, 2003);
    let balance:u64 = borrow_global<Balance>(Signer::address_of(sender)).value;
    assert!(balance >= amount, 2004);
    sub_balance(Signer::address_of(sender), amount);
    add_balance(receiver, amount);
  }

  fun add_balance(addr: address, amount: u64) acquires Balance {
    assert!(exists<Balance>(addr), 2002);

    let value_ref = &mut borrow_global_mut<Balance>(addr).value;
    *value_ref = *value_ref + amount;
  }

  fun sub_balance(addr: address, amount: u64) acquires Balance {
    assert!(exists<Balance>(addr), 2002);

    let value_ref = &mut borrow_global_mut<Balance>(addr).value;
    assert!(*value_ref >= amount, 2004);
    *value_ref = *value_ref - amount;
  }
}