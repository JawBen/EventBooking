public class CaseManagement {
    
    
public static void insertHandler(List<Case> TriggerObject){
    Case r = TriggerObject[0];
    
    // Testing if the content of case is null or not to avoid NPE ;) 
    if(r != null && r.AccountId != null){

        List<Account> account =  [SELECT ID, (select id from contacts) FROM Account where id = :r.AccountId LIMIT 1];
        if (account.size()>0){
            Integer s = account[0].Contacts.size();

            if(s ==0){
                r.addError('You cannot create a request for accounts without contacts');
            }   else {
                switch on r.Origin {
                    when 'Web' {
                        if(s >= 2 ){
                            r.addError('Web request are only allowed to have one attendee');
                        }
                    }
                    when 'Phone'{
                        if(s >= 4 ){
                            r.addError('Phone request are only allowed to have three attendee');
                        }
                    }
                }    
                            
            }
        }  
    }else {
        r.addError('You cannot create a request without attaching an account');
    } 
    

}

public static void updateHandler(List<Case> triggerObject){
    Boolean requestSentToExternalSystem = false;
    Integer i=0;
    
    Case request = triggerObject[0];

    List<Case> r = [SELECT Status FROM Case where id=:request.ID LIMIT 1];
    if (r.size()>0){
        if(r[0].Status == 'Closed'){
            ExternalSystemService service = new ExternalSystemService();
            service.registerAttendees(r[0]);
        }
    }

}