public with sharing class HandlerNewCase implements BotHandler {
    
    static String OUR_CUSTOMERS_ACCOUNT_ID = '001f200001XrwpdAAB';
    static String CASE_RECTYPEID_HELP_REQUEST = '012f2000000MhTUAA0';

    public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        
        if (session == null) {
            session = new Map<String, String>();
            session.put('nextCommand', 'HandlerNewCase');
            session.put('step', 'askContactId');
            return new BotResponse(new BotMessage('Bot', 'What\'s the contact\'s Id? If you don\'t know it, say \'exit\' and use the contact command to look them up'), session);
        }
        
        String step = session.get('step');
        if (step == 'askContactId') {
            if (utterance == 'exit') {
                return new BotResponse(new BotMessage('Bot', 'Ok, exiting'), null);
            }
            
            session.put('contactId', utterance);
            session.put('nextCommand', 'HandlerNewCase');
            session.put('step', 'askIssue');
            return new BotResponse(new BotMessage('Bot', 'What is the contact\'s issue?'), session);
        } else {
            String contactId = session.get('contactId');
            Case newCase = new Case(
                RecordTypeId = CASE_RECTYPEID_HELP_REQUEST,
                Priority = 'High',
                Origin = 'Community',
                Status = 'New',
                Reason = 'Other',
                Subject = 'Trouble with Account: Issue',
                Description = utterance,
                ContactId = contactId,
                AccountId = OUR_CUSTOMERS_ACCOUNT_ID
            );
            insert(newCase);
            return new BotResponse(new BotMessage('Bot', 'Created new Case'));
        }
    }
}