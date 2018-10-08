global class TravelApprovalERPController {
    
    @AuraEnabled
    public static void storeExpenseToERP(String params)
    {
        try {
            System.debug('storeExpenseToERP invoked...');
            
            /////////////////////////////////////
            // read in the input parameter map //
            /////////////////////////////////////
            Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);
            System.debug(JSON.serializePretty(paramMap));
            
            ///////////////////////////////////////////////////////
            // create a key=value map to send as JSON to service //
            ///////////////////////////////////////////////////////
            Map<String, Object> restBody = new Map<String, Object>();
            restBody.put('travelApproval', paramMap.get('travelApproval'));
            restBody.put('requestDate', Date.today());
            restBody.put('approvedAmount', Decimal.valueOf(paramMap.get('approvedAmount')));
            restBody.put('requestedAmount', Decimal.valueOf(paramMap.get('requestedAmount')));
            System.debug('restBody=' + JSON.serializePretty(restBody));
            
            /////////////////////////////
            // setup the REST API call //
            /////////////////////////////
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:MuleSoft');                  // utilize "MuleSoft" NamedCredential configuration
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);                               // in milliseconds         

            ///////////////////////////////////////////////
            // convert the key=value map and set as body //
            ///////////////////////////////////////////////
            request.setBody(JSON.serializePretty(restBody));
                        
            ////////////////////////////
            // make the REST API call //
            ////////////////////////////
            HttpResponse response = http.send(request);
            
            ////////////////////////////////////////////////////////
            // If the request is successful, process the response //
            ////////////////////////////////////////////////////////
            if (response.getStatusCode() == 201) { 
                System.debug(response.getBody());
                
                ///////////////////////////////////////////////////
                // update travel approval record with backend id //
                ///////////////////////////////////////////////////
                Travel_Approval__c ta = new Travel_Approval__c();
                ta.Id = paramMap.get('recordId');
                ta.ERP_Travel_Approval_ID__c = paramMap.get('travelApproval');
                update ta;
            }
            else {
                throw new AuraHandledException(response.toString());
            }
        }
        catch (AuraHandledException ae) {
            throw ae;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static Object queryRecord(String recordId)
    {
        try {
            System.debug('queryRecord invoked...');
            return [SELECT Id, Name, ERP_Travel_Approval_ID__c, Total_Expenses__c FROM Travel_Approval__c WHERE id = :recordId][0];
        }
        catch (AuraHandledException ae) {
            throw ae;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    
}