package thing

Thing_Manager :: struct {
	things: [dynamic]Thing,
}

append_thing :: proc(thing_manager: ^Thing_Manager, thing: Thing) {
	append(&thing_manager.things, thing);
}