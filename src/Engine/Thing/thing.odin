package thing

import mth "../math"

Thing :: struct {
	position: mth.V3f,
	uuid: u64,
}

create_thing :: proc(pos: mth.V3f) -> Thing {
	result: Thing;
	
	result.position = pos;
	result.uuid = 5;
	
	return result;
}

