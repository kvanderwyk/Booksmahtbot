public with sharing class HandlerNewCase implements BotHandler {

    public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        
        Case newCase = new Case();
        // TODO: If negative sentiment analysis, create different record type
        newCase.RecordTypeId = '012f2000000MhTUAA0'; // Help Request
        newCase.Priority = 'High';
        newCase.Origin = 'Community';
        newCase.Status = 'New';
        newCase.Reason = 'Other';
        newCase.Subject = 'Trouble with Account: Issue';
        newCase.Description = utterance;
        newCase.Contact.Id = UserInfo.getUserId();
        insert(newCase);
        
        return new BotResponse(new BotMessage('Bot', 'I don\'t know how to answer that, but I\'ve created a Support Case for your query and someone from our fantastic customer service team should get back to you shortly! You can see the status of your case by typing \'My Open Cases\''));
    }
}