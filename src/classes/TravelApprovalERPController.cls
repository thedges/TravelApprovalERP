global class TravelApprovalERPController {

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

    @AuraEnabled
    public static void storeExpenseToERP(String params)
    {
        try {
             System.debug('storeExpenseToERP invoked...');
             Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);
             System.debug(JSON.serializePretty(paramMap));

             //String queryStr = 'https://mocksvc.mulesoft.com/mocks/4df5290d-c0be-4112-a0b3-506c902894ec/paymentRequests';
             String queryStr = 'https://mocksvc-proxy.anypoint.mulesoft.com/exchange/88fb3f3e-d381-4074-b373-064205d30227/payments-api/1.0.3/paymentRequests';

             Map<String, Object> restBody = new Map<String, Object>();
             restBody.put('id', 1);
             restBody.put('travelApproval', paramMap.get('travelApproval'));
             restBody.put('requestDate', Date.today());
             restBody.put('approvedAmount', Decimal.valueOf(paramMap.get('approvedAmount')));
             restBody.put('requestedAmount', Decimal.valueOf(paramMap.get('requestedAmount')));
             System.debug('restBody=' + JSON.serializePretty(restBody));
             
            
            // setup the REST API call
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(queryStr);
            request.setMethod('POST');
            request.setBody(JSON.serializePretty(restBody));
            request.setHeader('Content-Type', 'application/json');
            
            request.setTimeout(120000);   // 2 minute (maximum that can be set)
            
            // set the BASIC authentication header
            MuleSoftCreds__c creds = MuleSoftCreds__c.getInstance();
            Blob headerValue = Blob.valueOf(creds.username__c + ':' + creds.password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            System.debug('authorizationHeader=' + authorizationHeader);
            request.setHeader('Authorization', authorizationHeader);

            
            // query the IBM Watson service
            HttpResponse response = http.send(request);
            
            // If the request is successful, process the response
            if (response.getStatusCode() == 201) {
                
                // Deserialize the JSON string into collections of primitive data types.
                System.debug(response.getBody());
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
}