/**********************************************************************
Name: ConsoleLinksController_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for ConsoleLinksController Controller.
 
======================================================
History:

VERSION    AUTHOR         DATE         DETAIL
1.0 -     Vivek Batham    04/01/2015  Created 
***********************************************************************/
@isTest
public class ConsoleLinksController_Test {

    static testmethod void linksTest(){
        ConsoleLinksController links = new ConsoleLinksController();
        
        links.linkUrl = links.nissanConLinks[0].Link_Url__c;
        links.launchNissan();
        
        System.assert(links.infinitiConLinks.size() > 0);
        System.assert(links.nissanConLinks.size() > 0);
    
    }
}