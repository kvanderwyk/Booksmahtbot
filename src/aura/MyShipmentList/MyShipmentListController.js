({
	myAction : function(component, event, helper) {
		
        component.set("v.Columns", [
    
    {label:"ShipmentId4", fieldName:"Id", type:"Id"},
    {label:"Status", fieldName:"Status__c", type:"text"},
 //  {label:"Phone", fieldName:"Phone", type:"phone"},
//	{label:"Email", fieldName:"Email", type:"email"}
            
]);

        var action = component.get("c.getShipments");
		action.setParams({
    recordId: component.get("v.recordId")
});
		action.setCallback(this, function(data) {
    		component.set("v.Shipments", data.getReturnValue());
			});
	$A.enqueueAction(action);

	}
})