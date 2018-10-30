Class Ethereum.Demo.CallBackRESTService Extends Ens.BusinessService
{

Method OnProcessInput(pRequest As %CSP.Request, pOutput As Ens.StringContainer) As %Status
{
        set requestJSON = ##class(%Library.DynamicObject).%FromJSON(pRequest.Content) 
        set ^deferred($ZDT($H)) = requestJSON.%ToJSON()
        if (requestJSON.status=1) {
            set st = ..SendDeferredResponse(requestJSON.data.responseToken,##class(Ens.StringContainer).%New(requestJSON.data.data.%ToJSON()))
        } else {
            //error processing 
        }
        return $$$OK
}

}
