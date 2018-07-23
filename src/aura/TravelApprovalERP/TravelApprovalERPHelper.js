({
    loadRecord: function (component) {
		var self = this;
        var recid = component.get("v.recordId");
        console.log("loadRecord id: " + recid);
        
        var action = component.get("c.queryRecord");
        
        action.setParams({
            "recordId": recid
        });
        
        
        action.setCallback(component, function(response) {

			var state = response.getState();
            if (state === "SUCCESS") 
            {   
				var data = response.getReturnValue();  
				component.set("v.travelApproval", (data.Id + '-' + data.Name).toUpperCase());
				component.set("v.approvedAmount", data.Total_Expenses__c);
				console.log('data=' + JSON.stringify(data));
            } 
            else 
            {
				self.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
	},
	submitExpenseToERP: function (component) {
		console.log('submitExpenseToERP invoked...');
        var self = this;
        
        self.showSpinner(component);
        
        var map = {};
        
		var action = component.get("c.storeExpenseToERP");
		
		map['recordId'] = component.get('v.recordId');
		map['travelApproval'] = component.get('v.travelApproval');
		map['approvedAmount'] = component.get('v.approvedAmount');
		map['requestedAmount'] = component.get('v.requestedAmount');
        
        action.setParams({
            "params": JSON.stringify(map)
        });
        
		action.setCallback(component, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") 
            {   
                self.hideSpinner(component);
                $A.get('e.force:refreshView').fire();
                
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: 'Expense Submission:',
					message: 'Your expense has been submitted successfully!',
					duration: ' 1000',
					type: 'success',
					mode: 'dismissible'
				});
				toastEvent.fire();
            } 
            else 
            {
                self.hideSpinner(component);
				self.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);

		
	},
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error!",
            message: "Unknown error", // Default error message
            type: "error",
            mode: "sticky"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    showSpinner:function(component){
        component.set("v.IsSpinner",true);
    },
    hideSpinner:function(component){
        component.set("v.IsSpinner",false);
    }
})