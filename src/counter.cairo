mod ownable_component;

#[starknet::interface]
trait ICounter<TContractState> {
    fn run_counter(ref self: TContractState);
    fn get_counter(self: @TContractState) -> u128;
}

#[starknet::contract]
mod Counter {
    use super::ownable_component::OwnableComponent;
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    component!(path: OwnableComponent, storage: ownable, event: OwnershipEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::Ownable<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        counter: u128,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn run_counter(ref self: ContractState) {
            self.ownable.assert_only_owner();
            self.counter.write(self.counter.read() + 1);
        }

        fn get_counter(self: @ContractState) -> u128 {
            self.counter.read()
        }
    }
}