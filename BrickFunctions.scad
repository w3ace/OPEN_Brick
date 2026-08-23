
/*

Functions for Circular Modular Bricks

*/



// Return the first matching value from an attribute list such as
// [["flattop", 1], ["window", 0]].  Keeping this lookup in one place lets a
// builder resolve each option once rather than walking the complete list at
// every stage of its CSG tree.
function attributeValue(parameter_list, name, default_value=0, index=0) =
    index >= len(parameter_list) ? default_value :
    parameter_list[index][0] == name ? parameter_list[index][1] :
    attributeValue(parameter_list, name, default_value, index+1);

function nameExists(name, parameter_list, index=0) =
    index >= len(parameter_list) ? false :
    parameter_list[index][0] == name ? true :
    nameExists(name, parameter_list, index+1);
