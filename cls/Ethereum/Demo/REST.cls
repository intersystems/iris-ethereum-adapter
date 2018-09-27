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
        set request = ##class(%Library.DynamicObject).%FromJSON(%request.Content)
        
        set tSC=##class(Ens.Director).CreateBusinessService("Ethereum.Demo.CallBackRESTService",.tService)
        if ($$$ISERR(tSC)) { 
            return $$$ERROR($$$GeneralError,"Can't get Business Service. Please start the Production and try again later") 
        }
        set tSC=tService.ProcessInput(##class(Ens.StringContainer).%New(request.%ToJSON()),.output)
        if ($$$ISERR(tSC)) { 
            return tSC
        }
        write {"result":"1"}.%ToJSON()
        return $$$OK
    }

}
