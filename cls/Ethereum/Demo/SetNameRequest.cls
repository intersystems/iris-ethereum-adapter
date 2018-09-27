Class Ethereum.Demo.SetNameRequest Extends Ens.Request
{

Property Name As %String;

Storage Default
{
<Data name="SetNameRequestDefaultData">
<Subscript>"SetNameRequest"</Subscript>
<Value name="1">
<Value>Name</Value>
</Value>
</Data>
<DefaultData>SetNameRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
