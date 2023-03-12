module basics::counter{
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};


    struct Counter has key {
        id: UID,
        owner: address,
        value: u64,
    }

    public fun counter_value(counter: &Counter): u64 {
        counter.value
    }

    public fun owner(counter: &Counter): address {
        counter.owner
    }

    public entry fun create(ctx: &mut TxContext){
        let counter_object = Counter {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            value: 0
        };
        transfer::share_object(counter_object)
    }

    public entry fun increment(counter: &mut Counter) {
        counter.value = counter.value + 1;
    }

    public entry fun set_value(counter: &mut Counter, value: u64, ctx: &TxContext){
        assert!(tx_context::sender(ctx) == counter.owner, 0);
        counter.value = value;
    }

}

    #[test_only]

    module basics::counter_test {
        use sui::test_scenario;
        use basics::counter;


        #[test]

        fun test_counter() {

            let owner = @0xC0FFEE;
            let user1 = @0x80;

            let scenario_val = test_scenario::begin(user1);
            let scenario = &mut scenario_val;

            test_scenario::next_tx(scenario, owner);
            {
                counter::create(test_scenario::ctx(scenario));
            };

            test_scenario::next_tx(scenario, user1); 
            {

                let counter_val = test_scenario::take_shared<counter::Counter>(scenario);
                let counter_contract = &mut counter_val;

                assert!(counter::owner(counter_contract) == owner, 0 );
                assert!(counter::counter_value(counter_contract) == 0, 1);

                counter::increment(counter_contract);
                counter::increment(counter_contract);
                counter::increment(counter_contract);

                test_scenario::return_shared(counter_val);
            };

            test_scenario::next_tx(scenario, owner); 
            {
            let counter_val = test_scenario::take_shared<counter::Counter>(scenario);
            let counter_contract = &mut counter_val;

            counter::set_value(counter_contract, 100, test_scenario::ctx(scenario));

            test_scenario::return_shared(counter_val);
            };

            test_scenario::next_tx(scenario, user1);
        {
            let counter_val = test_scenario::take_shared<counter::Counter>(scenario);
            let counter_contract = &mut counter_val;

            assert!(counter::owner(counter_contract) == owner, 0);
            assert!(counter::counter_value(counter_contract) == 100, 1);

            counter::increment(counter_contract);

            assert!(counter::counter_value(counter_contract) == 101, 2);

            test_scenario::return_shared(counter_val);
        };
        test_scenario::end(scenario_val);
        }

    }