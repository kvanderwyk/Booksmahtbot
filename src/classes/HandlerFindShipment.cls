public with sharing class HandlerFindShipment implements BotHandler {

    public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        
        String key = '%' + params[0] + '%';
        List<Shipment__c> shipments = [
            SELECT Id, Name, Location__c, Status__c, Place_On_Hold__c, Contact__r.Id FROM Shipment__c
            WHERE Contact__r.Name LIKE :key
            ORDER BY Name
        ];
        
        List<BotRecord> records = new List<BotRecord>();
        for (Shipment__c s : shipments) {
            List<BotField> fields = new List<BotField>();
            fields.add(new BotField('Shipment Number', s.Name, '#/sObject/' + s.Id + '/view'));
            fields.add(new BotField('Pickup Location', s.Location__c));
            fields.add(new BotField('Shipment Status', s.Status__c));
            fields.add(new BotField('Shipment on Hold?', String.valueOf(s.Place_On_Hold__c)));
            records.add(new BotRecord(fields));
        }
        
        return new BotResponse(new BotMessage('Bot', 'Here is a list of shipments matching "' + params[0] + '": ', records));
    }
}