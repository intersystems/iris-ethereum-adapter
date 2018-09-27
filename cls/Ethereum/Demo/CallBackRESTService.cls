Class Ethereum.Demo.CallBackRESTService Extends Ens.BusinessService
{

Method OnProcessInput(pRequest As Ens.StringContainer, pOutput As Ens.StringContainer) As %Status
{
        $$$TRACE(pRequest.StringValue)
        set requestJSON = ##class(%Library.DynamicObject).%FromJSON(pRequest.StringValue) 
        if (requestJSON.data'="") {
            set st = ..SendDeferredResponse(requestJSON.responseToken,##class(Ens.StringResponse).%New(requestJSON.data.%ToJSON()))
        } else {
            //error processing if necessary
        }
        return $$$OK
}

}
