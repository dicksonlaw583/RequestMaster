///@func __jsons_decode_real__(@seekrec)
///@param @seekrec
function __jsons_decode_real__(argument0) {
	var i = argument0.pos;
	var len = string_length(argument0.str);
	var c = string_char_at(argument0.str, i);
	// Determine starting state
	var state;
	switch (c) {
		case "+": case "-":
			state = 0;
		break;
		default:
			state = 1;
		break;
	}
	var str = c;
	++i;
	// Loop until no more digits found
	var done = false;
	for (i = i; !done && i <= len; ++i) {
		c = string_char_at(argument0.str, i);
		// Parsing logic adapted from JSOnion
		switch (state) {
			//0: Found a sign, looking for a starting number
			case 0:
				switch (c) {
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = 1;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a digit");
				}
			break;
			//1: Found a starting digit, looking for decimal dot, e, E, or more digits
			case 1:
				if (__jsons_is_whitespace__(c)) || (string_pos(c, ":,]}") > 0) {
					done = true;
					--i;
				} else {
					switch (c) {
						case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
							str += c;
						break;
						case ".":
							str += c;
							state = 2;
						break;
						case "e": case "E":
							str += c;
							state = 3;
						break;
						default:
							throw new JsonStructParseException(i, "Expecting a dot, e, E or a digit");
					}
				}
			break;
			//2: Found a decimal dot, looking for more digits
			case 2:
				switch (c) {
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = -2;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a digit");
				}
			break;
			//-2: Found a decimal dot and a digit after it, looking for more digits, e, or E
			case -2:
				if (__jsons_is_whitespace__(c)) || (string_pos(c, ":,]}") > 0) {
					done = true;
					--i;
				} else {
					switch (c) {
						case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
							str += c;
						break;
						case "e": case "E":
							str += c;
							state = 3;
						break;
						default:
							throw new JsonStructParseException(i, "Expecting an e, E or a digit");
					}
				}
			break;
			//3: Found an e/E, looking for +, - or more digits
			case 3:
				switch (c) {
					case "+": case "-":
						str += c;
						state = 4;
					break;
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = 5;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a +, - or a digit");
				}
			break;
			//4: Found an e/E exponent sign, looking for more digits
			case 4:
				switch (c) {
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = 5;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a digit");
				}
			break;
			//5: Looking for final digits of the exponent
			case 5:
				if (__jsons_is_whitespace__(c)) || (string_pos(c, ":,]}") > 0) {
					done = true;
					--i;
				} else {
					switch (c) {
						case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
							str += c;
							state = 5;
						break;
						default:
							throw new JsonStructParseException(i, "Expecting a digit");
					}
				}
			break;
		}
	}
	// Set seeker's position to loop's end
	argument0.pos = --i;
	// Am I still expecting more characters?
	if (done || state == 1 || state == -2 || state == 5) {
		return real(str);
	}
	// Error: Unexpected ending
	throw new JsonStructParseException(argument0.pos, "Unexpected end of real");
}
