public class ShareHelper { 
  //---------------------------------------------
  // Properties
  private static final String RT_SORTING_REPORT = 'Sorting_Report';
  private static final String RT_INCIDENT_CLAIM = 'Incident_Claim';

  private static Id supplierRT = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Supplier');
  private static Id plantRT = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Plant');


  //---------------------------------------------
  // Methods
  public static void share(SObject o) {
    share(new sObject[] {o});
  }

  public static void share(SObject[] scope) {
    if ((null != scope) && (!scope.isEmpty())) {
      // retrieve all account ids associated with sobject id value from list of sobjects 
      Map<String, String> accountIdsMap = getAccountIdsPerSObjects(scope);
      
      Set<String> accountIds = new Set<String>();
      accountIds.addAll(getCustomerAccountIds(scope));
      accountIds.addAll(accountIdsMap.values());

      // query all needed users to share
      Map<String, User[]> shareUsersMap = queryShareUsers(accountIds);

      if (!shareUsersMap.isEmpty()) {
        // Allocate storage for a list of records.
        List<Part_Incident_Report__Share> partIncidentReportShares = new List<Part_Incident_Report__Share>();
        List<Sorting_Report__Share> sortingReportShares = new List<Sorting_Report__Share>();
        List<Monetary_Claim__Share> monetaryClaimShares = new List<Monetary_Claim__Share>();

        for (SObject o : scope) {
          String soId = (String) o.get('id');
          String customerId = (String) o.get('Customer__c');
          String accountId = accountIdsMap.get(soId);
          User[] usersList = new User[] {};
          if (shareUsersMap.containsKey(accountId)) {
            usersList.addAll(shareUsersMap.get(accountId));
          }

          if (shareUsersMap.containsKey(customerId)) {
            usersList.addAll(shareUsersMap.get(customerId));
          }

          for (User u : usersList) {
            if (null != u) {
              if (isPartIncidentReport(o)) {
                 partIncidentReportShares.add(createPartIncidentReportShare(u.id, soId));
              } else if (isSortingReport(o)) {
                 sortingReportShares.add(createSortingReportShare(u.Id, soId));
              } else if (isMonetaryClaim(o)) {
                 monetaryClaimShares.add(createMonetaryClaimShare(u.Id, soId));
              }
            }
          }
        }

        // Insert all of the newly created Share records and capture save result
        if (!partIncidentReportShares.isEmpty()) {
          Database.SaveResult[] partIncidentReportSharesInsertResult = Database.insert(partIncidentReportShares, false);
        }

        if (!sortingReportShares.isEmpty()) {
          Database.SaveResult[] sortingReportSharesInsertResult = Database.insert(sortingReportShares, false);
        }

        if (!monetaryClaimShares.isEmpty()) {
          Database.SaveResult[] monetaryClaimShareInsertResult = Database.insert(monetaryClaimShares, false);
        }
      }
    }
  }

  //---------------------------------------------
  // Helpers
  private static Map<String, String> getAccountIdsPerSObjects(SObject[] scope) {
    Set<String> partIncidentReportIds = new Set<String>();
    Set<String> sortingReportIds = new Set<String>();
    Set<String> monetaryClaimIds = new Set<String>();

    for (SObject o : scope) {
      if (isPartIncidentReport(o)) {
        partIncidentReportIds.add((String)o.get('Id'));
      } else if (isSortingReport(o)) {
        sortingReportIds.add((String)o.get('Id'));
      } else if (isMonetaryClaim(o)) {
        monetaryClaimIds.add((String)o.get('Id'));
      }
    }

    Map<String, String> accountIdsMap = new Map<String, String>();

    // query all accounts
    accountIdsMap.putAll(queryPartIncedentReportAccounts(partIncidentReportIds));
    accountIdsMap.putAll(querySortingReportAccounts(sortingReportIds));
    accountIdsMap.putAll(queryMonetaryClaimAccounts(monetaryClaimIds));

    return accountIdsMap;
  }

  private static Set<String> getCustomerAccountIds(SObject[] scope) {
    Set<String> accountIds = new Set<String>();

    for (SObject o : scope) {
      accountIds.add((String) o.get('Customer__c'));
    }

    accountIds.remove(null);
    return accountIds;
  }

  private static Map<String, User[]> queryShareUsers(Set<String> accountIds) {
    Map<String, User[]> shareUsersMap = new Map<String, User[]>();
    
    if (!accountIds.isEmpty()) {
      // Get users to share
      List<User> shareUsersList = [SELECT Id, Profile.Name, Contact.AccountId
                                     FROM User 
                                    WHERE Profile.Name IN ('EQA-Supplier Partner User', 'EQA-Customer Partner User') 
                                          AND Profile.UserLicense.Name = 'Gold Partner' 
                                          AND Contact.AccountId IN :accountIds
                                          AND IsActive = true];
    
      for (User u : shareUsersList) {
        if (shareUsersMap.containsKey(u.Contact.AccountId)) {
          shareUsersMap.get(u.Contact.AccountId).add(u);
        } else {
          shareUsersMap.put(u.Contact.AccountId, new User[] {u});
        }
      }
    }

    return shareUsersMap;
  }

  // verify that sobject is Part_Incident_Report__c
  private static Boolean isPartIncidentReport(SObject o) {
    return o.getSObjectType() == Part_Incident_Report__c.SObjectType;
  }

  // verify that sobject is Sorting_Report__c
  private static Boolean isSortingReport(SObject o) {
    return o.getSObjectType() == Sorting_Report__c.SObjectType;
  }

  // verify that sobject is Monetary_Claim__c
  private static Boolean isMonetaryClaim(SObject o) {
    return o.getSObjectType() == Monetary_Claim__c.SObjectType;
  }

  // query Part_Incident_Report__c for retrieve account id
  private static Map<String, String> queryPartIncedentReportAccounts(Set<String> partIncidentReportIds) {
    Map<String, String> result = new Map<String, String>();
    
    if (!partIncidentReportIds.isEmpty()) {
      for (Part_Incident_Report__c pi : [SELECT Id, Part__r.Supplier__c 
                                           FROM Part_Incident_Report__c
                                          WHERE Id IN :partIncidentReportIds]) {
        result.put(pi.Id, pi.Part__r.Supplier__c);
      }
    }

    return result;
  }

  // query Sorting_Report__c for retrieve account id
  private static Map<String, String> querySortingReportAccounts(Set<String> sortingReportIds) {
    Map<String, String> result = new Map<String, String>();
    
    if (!sortingReportIds.isEmpty()) {
      for (Sorting_Report__c sr : [SELECT Id, Part__r.Supplier__c 
                                     FROM Sorting_Report__c
                                    WHERE Id IN :sortingReportIds]) {
        result.put(sr.Id, sr.Part__r.Supplier__c);
      }
    }

    return result;
  }

  // query Monetary_Claim__c for retrieve account id
  private static Map<String, String> queryMonetaryClaimAccounts(Set<String> monetaryClaimIds) {
    Map<String, String> result = new Map<String, String>();
    
    if (!monetaryClaimIds.isEmpty()) {
      for (Monetary_Claim__c mc : [SELECT Id, Sorting_Report__r.Part__r.Supplier__c, RecordType.DeveloperName,
                                          Part_Incident_Report__r.Part__r.Supplier__c
                                     FROM Monetary_Claim__c
                                    WHERE Id IN :monetaryClaimIds]) {
        
        if (RT_SORTING_REPORT == mc.RecordType.DeveloperName) {
          result.put(mc.Id, mc.Sorting_Report__r.Part__r.Supplier__c);
        } else if (RT_INCIDENT_CLAIM == mc.RecordType.DeveloperName) {
          result.put(mc.Id, mc.Part_Incident_Report__r.Part__r.Supplier__c);
        }
      }
    }

    return result;
  }

  // create Part_Incident_Report__Share record
  private static Part_Incident_Report__Share createPartIncidentReportShare(String userId, String soId) {
    Part_Incident_Report__Share partIncidentReportShare = new Part_Incident_Report__Share();
    partIncidentReportShare.ParentId = soId;
    partIncidentReportShare.AccessLevel = 'Edit';
    partIncidentReportShare.UserOrGroupId = userId;
    return partIncidentReportShare;
  }

  // create Sorting_Report__Share record
  private static Sorting_Report__Share createSortingReportShare(String userId, String soId) {
    Sorting_Report__Share sortingReportShare = new Sorting_Report__Share();
    sortingReportShare.ParentId = soId;
    sortingReportShare.AccessLevel = 'Edit';
    sortingReportShare.UserOrGroupId = userId;
    return sortingReportShare;
  }

  // create Monetary_Claim__Share record
  private static Monetary_Claim__Share createMonetaryClaimShare(String userId, String soId) {
    Monetary_Claim__Share monetaryClaimShare = new Monetary_Claim__Share();
    monetaryClaimShare.ParentId = soId;
    monetaryClaimShare.AccessLevel = 'Edit';
    monetaryClaimShare.UserOrGroupId = userId;
    return monetaryClaimShare;
  }

  // create Part__Share record
  private static Part__Share createPartShare(String userId, String soId) {
    Part__Share partShare = new Part__Share();
    partShare.ParentId = soId;
    partShare.AccessLevel = 'Read';
    partShare.UserOrGroupId = userId;
    return partShare;
  }

  public static void shareNewParts(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        for(Account newAcc : newMap.values()){
            if(isEQART(newAcc) || codesFieldsAreChanged(newAcc, oldMap.get(newAcc.id))){
                System.enqueueJob(new ShareHelper.AsyncShareRecords(newAcc));
            }
        }
  }

  private static Boolean isEQART(Account newAcc){
        if (newAcc.RecordTypeId != supplierRT && newAcc.RecordTypeId != plantRT){
            return false;
        }

        return true;
  }

  private static Boolean codesFieldsAreChanged(Account newAcc, Account oldAcc){
        if (newAcc.Supplier_Code__c == oldAcc.Supplier_Code__c && newAcc.Available_Customer_Numbers__c == oldAcc.Available_Customer_Numbers__c){
            return false;
        }

        return true;
  }


  /**
   * Queueable Job for share existing records with newly created user
   */
  public class AsyncShareRecords implements Queueable {
    private Id userId;
    private Id accountId;
    private Set<String> accountCustomersCodes;
    private String profileName;
    private final Integer SOQL_LIMIT = 10000;

    public AsyncShareRecords(Account eqaAccount){
        Set<Id> userIds = getUserIds(eqaAccount);

        for(Id uId: userIds){
            System.enqueueJob(new ShareHelper.AsyncShareRecords(uId));
        }
    }

    public Set<Id> getUserIds(Account eqaAccount){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();        

        for(Contact c : [SELECT Id FROM Contact WHERE AccountId = :eqaAccount.Id]){
            contactIds.add(c.id);
        }

        for(User u : [SELECT Id FROM User WHERE ContactId IN : contactIds]){
            userIds.add(u.id);
        }
    
        return userIds;
    }

    public AsyncShareRecords(Id userId) {
      User[] users = [SELECT Id, Contact.AccountId, Contact.Account.Available_Customer_Numbers__c, Profile.Name
                        FROM User
                       WHERE Id = :userId];

      if (!users.isEmpty()) {
        this.userId = userId;
        this.accountId = users[0].Contact.AccountId;
        this.profileName = users[0].Profile.Name;
        
      if(String.isNotBlank(users[0].Contact.Account.Available_Customer_Numbers__c)){
        this.accountCustomersCodes = new Set<String>(users[0].Contact.Account.Available_Customer_Numbers__c.split(';'));
      }
      else{
        this.accountCustomersCodes = new Set<String>();
      }
      }
    }

    public AsyncShareRecords(Id userId, Id accountId, String profileName, Set<String> customerCodes) {
      this.userId = userId;
      this.accountId = accountId;
      this.profileName = profileName;
      this.accountCustomersCodes = customerCodes;
    }

    public void execute(QueueableContext context) {
      List<Part_Incident_Report__c> notSharedPartIncidentReports = new List<Part_Incident_Report__c>();
      List<Sorting_Report__c> notSharedSortingReports = new List<Sorting_Report__c>();
      List<Monetary_Claim__c> notSharedMonetaryClaims = new List<Monetary_Claim__c>();
      List<Part__c> notSharedParts = new List<Part__c>();

      if (ManageEqaPortalUsersController.EQA_CUSTOMER_PROFILE == profileName) {
        // share records with Customer Profile
        notSharedPartIncidentReports = queryPartIncidentReportsForCustomer(userId, accountId);
        notSharedSortingReports = querySortingReportsForCustomer(userId, accountId);
        notSharedMonetaryClaims = queryMonetaryClaimForCustomer(userId, accountId);
        notSharedParts = queryPartsForCustomer(userId, accountId);
      } else if (ManageEqaPortalUsersController.EQA_SUPPLIER_PROFILE == profileName) {
        // share records with Supplier Profile
        notSharedPartIncidentReports = queryPartIncidentReportsForSupplier(userId, accountId);
        notSharedSortingReports = querySortingReportsForSupplier(userId, accountId);
        notSharedMonetaryClaims = queryMonetaryClaimForSupplier(userId, accountId);
        notSharedParts = queryPartsForSupplier(userId, accountId);
      }

      List<Part_Incident_Report__Share> partIncidentReportShares = new List<Part_Incident_Report__Share>();
      List<Sorting_Report__Share> sortingReportShares = new List<Sorting_Report__Share>();
      List<Monetary_Claim__Share> monetaryClaimShares = new List<Monetary_Claim__Share>();
      List<Part__Share> partShares = new List<Part__Share>();
     
      
      for (Part_Incident_Report__c pir : notSharedPartIncidentReports) {
        partIncidentReportShares.add(ShareHelper.createPartIncidentReportShare(userId, pir.Id));
      }

      for (Sorting_Report__c sr : notSharedSortingReports) {
        sortingReportShares.add(ShareHelper.createSortingReportShare(userId, sr.Id));
      }

      for (Monetary_Claim__c mc : notSharedMonetaryClaims) {
        monetaryClaimShares.add(ShareHelper.createMonetaryClaimShare(userId, mc.Id));
      }
  
      for (Part__c part : notSharedParts) {
        partShares.add(ShareHelper.createPartShare(userId, part.Id));
      }

      // Insert all of the newly created Share records and capture save result
      if (!partIncidentReportShares.isEmpty()) {
        Database.SaveResult[] partIncidentReportSharesInsertResult = Database.insert(partIncidentReportShares, false);
      }

      if (!sortingReportShares.isEmpty()) {
        Database.SaveResult[] sortingReportSharesInsertResult = Database.insert(sortingReportShares, false);
      }

      if (!monetaryClaimShares.isEmpty()) {
        Database.SaveResult[] monetaryClaimShareInsertResult = Database.insert(monetaryClaimShares, false);
      }

      if (!partShares.isEmpty()) {
        Database.SaveResult[] partShareInsertResult = Database.insert(partShares, false);
      }
      // if need rerun Job
      if (notSharedPartIncidentReports.size() == SOQL_LIMIT 
              || notSharedSortingReports.size() == SOQL_LIMIT
              || notSharedMonetaryClaims.size() == SOQL_LIMIT) {
        System.enqueueJob(new AsyncShareRecords(userId, accountId, profileName, accountCustomersCodes));
      }
    }

    // Helpers method for query not shared record with EQA Customer Profile
    private Part_Incident_Report__c[] queryPartIncidentReportsForCustomer(Id userId, Id accountId) {
      Part_Incident_Report__c[] notSharedPartIncidentReports = 
        [SELECT Id 
            FROM Part_Incident_Report__c 
          WHERE Id NOT IN (SELECT ParentId FROM Part_Incident_Report__Share WHERE UserOrGroupId = :userId)
                AND Customer__c = :accountId
          LIMIT :SOQL_LIMIT];

      return notSharedPartIncidentReports;
    }

    private Sorting_Report__c[] querySortingReportsForCustomer(Id userId, Id accountId) {
      Sorting_Report__c[] notSharedSortingReports = 
        [SELECT Id 
            FROM Sorting_Report__c 
          WHERE Id NOT IN (SELECT ParentId FROM Sorting_Report__Share WHERE UserOrGroupId = :userId)
                AND Customer__c = :accountId
          LIMIT :SOQL_LIMIT];

      return notSharedSortingReports;
    }

    private Monetary_Claim__c[] queryMonetaryClaimForCustomer(Id userId, Id accountId) {
      Monetary_Claim__c[] notSharedMonetaryClaims = 
        [SELECT Id 
            FROM Monetary_Claim__c 
          WHERE Id NOT IN (SELECT ParentId FROM Monetary_Claim__Share WHERE UserOrGroupId = :userId)
                AND Customer__c = :accountId
          LIMIT :SOQL_LIMIT];

      return notSharedMonetaryClaims;
    }

     private Part__c[] queryPartsForCustomer(Id userId, Id accountId) {
      
        Part__c[] notSharedParts = new List<Part__c>();
        if(!accountCustomersCodes.isEmpty()){
            notSharedParts = [SELECT Id FROM Part__c WHERE Id NOT IN (SELECT ParentId FROM Part__Share WHERE UserOrGroupId = :userId) AND Customer_Number__c IN :accountCustomersCodes LIMIT :SOQL_LIMIT];
        }

        return notSharedParts;
     }

     private Part__c[] queryPartsForSupplier(Id userId, Id accountId) {
        Part__c[] notSharedParts = [SELECT Id FROM Part__c WHERE Id NOT IN (SELECT ParentId FROM Part__Share WHERE UserOrGroupId = :userId) AND Supplier__c =  :accountId LIMIT :SOQL_LIMIT];
        return notSharedParts;
     }

    // Helpers method for query not shared record with EQA Supplier Profile
    private Part_Incident_Report__c[] queryPartIncidentReportsForSupplier(Id userId, Id accountId) {
      Part_Incident_Report__c[] notSharedPartIncidentReports = 
        [SELECT Id 
            FROM Part_Incident_Report__c 
          WHERE Id NOT IN (SELECT ParentId FROM Part_Incident_Report__Share WHERE UserOrGroupId = :userId)
                AND Part__r.Supplier__c = :accountId
          LIMIT :SOQL_LIMIT];

      return notSharedPartIncidentReports;
    }

    private Sorting_Report__c[] querySortingReportsForSupplier(Id userId, Id accountId) {
      Sorting_Report__c[] notSharedSortingReports = 
        [SELECT Id 
            FROM Sorting_Report__c 
          WHERE Id NOT IN (SELECT ParentId FROM Sorting_Report__Share WHERE UserOrGroupId = :userId)
                AND Part__r.Supplier__c = :accountId
          LIMIT :SOQL_LIMIT];

      return notSharedSortingReports;
    }

    private Monetary_Claim__c[] queryMonetaryClaimForSupplier(Id userId, Id accountId) {
      Monetary_Claim__c[] notSharedMonetaryClaims = 
        [SELECT Id 
            FROM Monetary_Claim__c 
          WHERE Id NOT IN (SELECT ParentId FROM Monetary_Claim__Share WHERE UserOrGroupId = :userId)
                AND ((RecordType.DeveloperName = :RT_SORTING_REPORT AND Sorting_Report__r.Part__r.Supplier__c = :accountId)
                  OR (RecordType.DeveloperName = :RT_INCIDENT_CLAIM AND Part_Incident_Report__r.Part__r.Supplier__c = :accountId)
                )
          LIMIT :SOQL_LIMIT];

      return notSharedMonetaryClaims;
    }
  }
}