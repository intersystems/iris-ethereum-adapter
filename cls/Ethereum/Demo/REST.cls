include Ensemble
Class Ethereum.Demo.REST Extends %CSP.REST
{

    XData UrlMap
    {
        <Routes>
            <Route Url="/deferred" Method="POST" Call="Deferred" />
          </Routes>
    }

    ClassMethod Deferred() As %Status
    {
        set tSC=##class(Ens.Director).CreateBusinessService("Ethereum.Demo.CallBackRESTService",.tService)
        if ($$$ISERR(tSC)) { 
            return $$$ERROR($$$GeneralError,"Can't get Business Service. Please start the Production and try again later") 
        }
        set tSC=tService.ProcessInput(%request,.output)
        if ($$$ISERR(tSC)) { 
            return tSC
        }
        write {"result":"1"}.%ToJSON()
        return $$$OK
    }

}
