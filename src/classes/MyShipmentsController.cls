public class MyShipmentsController {
@AuraEnabled
public static List<Shipment__c> getShipments(Id recordId) {
  return [SELECT Contact__c,Id,LastModifiedDate,Location__c,Name,Place_On_Hold__c,Status__c FROM Shipment__c WHERE Contact__c = '003f200002OzSgjAAF'];
}

}