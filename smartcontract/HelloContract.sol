pragma solidity ^0.4.7;
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract HelloContract {
    using strings for *;
    
    string name;

    function setName(string newName) public
    {
        name = newName;
    }
    
    function hello() view public returns(string)
    {
        return "Hello ".toSlice().concat(name.toSlice());
    }
    
}