public  class ExternalSystemService {

    private String webServiceURL;

    public ExternalSystemService(){
        this.webServiceURL = 'https://th-apex-http-callout.herokuapp.com/animals';
    }

    public void registerAttendees(Case caseObj){
            for(Account accountObj : [SELECT id FROM Account where id = :caseObj.AccountId]){
                for(Contact contactObj : [SELECT id,name, email FROM Contact where accountid =: accountObj.id ]){
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(this.webServiceURL);
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    // Set the body as a JSON object
                    request.setBody('{"name":"'+ c.name + '-' + c.email  +'}');
                    HttpResponse response = http.send(request);
                    // Parse the JSON response
                    if (response.getStatusCode() != 201) {
                        System.debug('The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus());
                    } else {
                       // Everything went as expected.
                       notifyAttendeeByEmail(contactObj, caseObj);
                    }
                }
            
        }
    } 

    public void notifyAttendeeByEmail(Contact contactObj, Case caseObj){
      
        Task tk = new Task();
        tk.Subject = 'Send Email To' + contactObj.name;
        tk.Status = 'Open';
        tk.Priority = 'Normal';
        tk.WhatId = contactObj.ID;
        insert tk;

        //JBEN - 13092022 - Add sending emails automatically

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {contactObj.email}; 
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);

        // Specify the name used as the display name.
        mail.setSenderDisplayName('B Hotels Event');

        // Specify the subject line for your email address.
        mail.setSubject('Registration successfully completed!');

        // Specify the text content of the email.
        mail.setPlainTextBody('Your registration has been created.');

        mail.setHtmlBody('Hi <b>'+ contactObj.name + ' We are pleased to let you know that your registration:<b> ' + caseObj.Id +' </b>  has been successfully created. <p>'+
            'To view your case <a href=https://MyDomainName.my.salesforce.com/'+caseObj.Id+'>click here.</a>');

        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 


}
