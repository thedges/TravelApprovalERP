({
	doInit : function(component, event, helper) {
		helper.loadRecord(component);
	},
	submitExpense : function(component, event, helper) {
		helper.submitExpenseToERP(component);
	}
})