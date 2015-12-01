trigger ContactEmailScrub_Before on Contact (before insert, before update) {
    Contact newContact;


    for (Contact c: Trigger.new) {
        if(c.Email != null && !c.Email.endsWith('.qa')) {
            c.Email = c.Email + '.qa';

        }
    }
}