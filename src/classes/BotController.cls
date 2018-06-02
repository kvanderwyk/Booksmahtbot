public with sharing class BotController {
    
    static String OUR_CUSTOMERS_ACCOUNT_ID = '001f200001XrwpdAAB';
    static String CASE_RECTYPEID_HELP_REQUEST = '012f2000000MhTUAA0';

    class HandlerMapping {
        
        public String handlerClassName;
        public Pattern utterancePattern;

        public HandlerMapping(String handlerClassName, String patternStr) {
            this.handlerClassName = handlerClassName;
            this.utterancePattern = Pattern.compile(patternStr);
        }

    }

    static List<HandlerMapping> handlerMappings;
    
    static {
        List<Bot_Command__c> commands = [SELECT apex_class__c, pattern__c FROM Bot_Command__c WHERE Active__c = True ORDER BY Name];
        System.debug(commands);
        List<HandlerMapping> mappings = new List<HandlerMapping>();
        for (Bot_Command__c command : commands) {
			mappings.add(new HandlerMapping(command.apex_class__c, command.pattern__c));
        }
        handlerMappings = mappings;
    }
    
	@AuraEnabled
    public static BotResponse upload(String fileName, String content) {
        try {
            ContentVersion v = new ContentVersion();
            v.versionData = EncodingUtil.base64Decode(content);
            v.title = fileName;
            v.pathOnClient = fileName;
            insert v;
			ContentDocument doc = [SELECT Id FROM ContentDocument where LatestPublishedVersionId = :v.Id];
			List<BotRecord> records = new List<BotRecord>();
            List<BotField> fields = new List<BotField>();
            fields.add(new BotField('Id', v.Id, '#/sObject/ContentDocument/' + doc.Id));
            fields.add(new BotField('Name', v.title));
            records.add(new BotRecord(fields));
	        return new BotResponse(new BotMessage('Bot', 'Your file was uploaded successfully', records));
        } catch (Exception e) {
			return new BotResponse(new BotMessage('Bot', 'An error occurred while uploading the file'));
        }
    }    
    
    @AuraEnabled
    public static BotResponse submit(String utterance, Map<String, String> session) {

        try {
            
            if (session != null) {
                String nextCommand = session.get('nextCommand');
                if (nextCommand != null) {
                    Type t = Type.forName('', nextCommand);
                    BotHandler h = (BotHandler)t.newInstance();
                    return h.handle(utterance, null, session);
                }
            }
        
            for (HandlerMapping mapping : BotController.handlerMappings) {
                Matcher utteranceMatcher = mapping.utterancePattern.matcher(utterance);
                if (utteranceMatcher.matches()) {
                    Type t = Type.forName('', mapping.handlerClassName);
                    BotHandler h = (BotHandler)t.newInstance();
                    List<String> params = new List<String>();
                    for (Integer i=1; i<=utteranceMatcher.groupCount(); i=i+1) {
                        params.add(utteranceMatcher.group(i).trim());
                    }
                    return h.handle(utterance, params, session);
                }
            }
            
            User currentUser = [
                SELECT ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            
            // TODO: If negative sentiment analysis, create different record type
            Case newCase = new Case(
                RecordTypeId = CASE_RECTYPEID_HELP_REQUEST,
                Priority = 'High',
                Origin = 'Community',
                Status = 'New',
                Reason = 'Other',
                Subject = 'Trouble with Account: Issue',
                Description = utterance,
                ContactId = currentUser.ContactId,
                AccountId = OUR_CUSTOMERS_ACCOUNT_ID
            );
            insert(newCase);
    
            return new BotResponse(new BotMessage('Bot', 'I don\'t know how to answer that, but I\'ve created a Support Case for your query and someone from our fantastic customer service team should get back to you shortly! You can see the status of your case by typing \'My Open Cases\''));
            
        } catch (Exception e) {
            System.debug(e);                
            return new BotResponse(new BotMessage('Bot', 'Oops, something went wrong invoking that command'));
        }
        
    }
    
}