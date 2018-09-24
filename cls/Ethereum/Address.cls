Class Ethereum.Address Extends %RegisteredObject
{
	Property Address as %String;
	
	/// Set a valid regex pattern for address validation
	Parameter REGEX As %String = "0x[0-9a-f]{40}";
	
	Method %OnNew(val as %String ) as %Status
	{
	    set val = $ZCVT(val,"L")
		return ..AddressSet(val)
	}
	
	Method AddressSet(val as %String) as %Status
	{
		set st = ..IsAddress(val)
		if ($$$ISOK(st)) {
			set i%Address = val
			return $$$OK
		} 
		return st
	} 
	
	ClassMethod IsAddress(val as %String) as %Status
	{
		try {
			if '$MATCH(val, ..#REGEX) {
				return $$$ERROR($$$GeneralError, "String "_val_" is not a valid ethereum address")
			}
		} catch Ex {
			return $$$ERROR($$$URegexRuleSyntax)
		}
		return $$$OK
	}
}