module 0xCAFE::IMCoin {
  use Std::Signer;

  const MAX_SUPPLY: u64 = 1024;
  const ISSUER: address = @0xCAFE;

  struct Coin has key {
    supply: u64,
    holders: u64,
  }

  struct Balance {
    value: u64
  }

  // complete this function
  public fun issue(issuer: &signer) {
    let issuer_addr = Signer::address_of(issuer);

  }

  // complete this function
  public fun supply(): u64 acquires Coin {

    borrow_global<Coin>(ISSUER).supply
  }

  public fun holders(): u64 acquires Coin {
    assert!(exists<Coin>(ISSUER), 1003);

    borrow_global<Coin>(ISSUER).holders
  }

  // complete this function
  public fun register(account: &signer) {

    
  }

  // complete this function
  public fun deposit(issuer: &signer, receiver: address, amount: u64) {
    let issuer_addr = Signer::address_of(issuer);
    
  }

  // complete this function
  public fun balance(addr: address): u64 {
    assert!(exists<Balance>(addr), 2002);
    
    
  }

  // complete this function
  public fun transfer(sender: &signer, receiver: address, amount: u64) {
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