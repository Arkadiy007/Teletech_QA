public class ManageEqaPortalUsersController { 
    //----------------------------------------------------
    // Constants
    public static final String EQA_SUPPLIER_PROFILE = 'EQA-Supplier Partner User';
    public static final String EQA_CUSTOMER_PROFILE = 'EQA-Customer Partner User';
    public static final String EQA_INTERNAL_PROFILE = 'EQAInternalPortal User';

    private static final String EQA_INTERNAL_GROUP = 'EQA_Internal_Partner_Group';

    //----------------------------------------------------
    // Properties
    public static SelectOption[] eqaProfileOptions {get; private set;}
    public String selectedProfile {get; set;}
    public String selectedUserId {get; set;}
    public Boolean dispalyNewUserPopup {get; set;}
    public User[] usersList { get; set; }
    public Contact newContact { get; set; }
    public User newUser { get; set; }
    public Boolean isShowCreateButton {
      get {
        Profile p = profilesMap.get(selectedProfile);

        if (null != p) {
          return p.Name == EQA_SUPPLIER_PROFILE
              || p.Name == EQA_CUSTOMER_PROFILE
              || p.Name == EQA_INTERNAL_PROFILE;
        } 

        return false;
      }
    }

    //----------------------------------------------------
    // Controller
    private static Map<Id, Profile> profilesMap = new Map<Id, Profile>();
    static {
      profilesMap = new Map<Id, Profile>(
        [SELECT Id, Name
            FROM Profile
          WHERE Name IN (:EQA_SUPPLIER_PROFILE, :EQA_CUSTOMER_PROFILE, :EQA_INTERNAL_PROFILE)]
      );

      eqaProfileOptions = new SelectOption[] {};
      eqaProfileOptions.add(new SelectOption('', '-- None --'));
      for (Profile p : profilesMap.values()) {
        eqaProfileOptions.add(
          new SelectOption(p.Id, p.Name)
        );
      }
    }

    public ManageEqaPortalUsersController() {
      this.usersList = new User[] {};
      this.dispalyNewUserPopup = false;
    }

    //----------------------------------------------------
    // Methods
    public PageReference searchUsers() {
      if (null != selectedProfile && selectedProfile.length() != 0) {
        usersList = [SELECT Id, Name, ContactId, Contact.AccountId, isActive
                       FROM User
                      WHERE ProfileId = :selectedProfile AND isPortalEnabled = true];
      } else {
        usersList = new User[] {};
      }

      return null;
    }

    public PageReference showNewUserPopup() {
      dispalyNewUserPopup = true;

      newContact = new Contact();
      newUser = new User(isActive = true);

      return null;
    }

    public PageReference closeNewUserPopup() {
      dispalyNewUserPopup = false;
      return null;
    }

    public PageReference createUser() {
      SavePoint sp = Database.setSavepoint();


      try {
        newContact.Contact_Type__c = 'Other';
        newContact.Email = newUser.Email;
        newContact.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Contact.SObjectType, 'Contact');
        insert newContact;

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;
        Boolean isActiveUser = newUser.isActive;

        newUser.ProfileId = selectedProfile;
        newUser.ContactId = newContact.Id;
        newUser.firstname = newContact.firstname;
        newUser.lastname = newContact.lastname;
        newUser.emailencodingkey = 'UTF-8';
        newUser.languagelocalekey = 'en_US';
        newUser.localesidkey = 'en_US';
        newUser.timezonesidkey = 'America/Los_Angeles';
        newUser.Cost_Center__c = 'Partner Portal';
        newUser.Location__c = 'Other / Remote';
        newUser.isActive = true;
        Database.SaveResult sr = Database.insert(newUser, dmo);
        
        if (sr.isSuccess()) {
          // Operation was successful
          Profile p = profilesMap.get(selectedProfile);
          if (p != null && p.Name == EQA_INTERNAL_PROFILE) {
            createGroupMember(newUser.Id);
          }
          
          // call future method for disable user
          if (false == isActiveUser) {
            disactivateUser(newUser.Id);
          }
            
          System.enqueueJob(new ShareHelper.AsyncShareRecords(newUser.Id));

          // research all users
          searchUsers();
    
          dispalyNewUserPopup = false;
        } else {
          // Operation failed, so get all errors                
          for(Database.Error err : sr.getErrors()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
          }
          
          Database.rollback(sp);
          newContact.ID = null;
          newUser.ID = null;
        }
      } catch(Exception ex) {
        Database.rollback(sp);
        ApexPages.addMessages(ex);

        newContact.ID = null;
        newUser.ID = null;
      }

      return null;
    }

    @future private static void createGroupMember(String userId) {
      User[] users = [SELECT Id FROM User WHERE Id = :userId];
      Group[] groups = [SELECT Id FROM Group WHERE DeveloperName = :EQA_INTERNAL_GROUP];

      if (!users.isEmpty() && !groups.isEmpty()) {
        GroupMember gm = new GroupMember(
          GroupId = groups[0].Id,
          UserOrGroupId = users[0].Id
        );
        insert gm;
      }
    }

    @future private static void disactivateUser(String userId) {
       User[] users = [SELECT Id, isActive FROM User WHERE Id = :userId];
       if (!users.isEmpty()) {
         users[0].isActive = false;
         update users[0];
       }
    }

    public PageReference enableDisableUser() {
      User selectedUser;
      for (User u : usersList) {
        if (selectedUserId == u.Id) {
          selectedUser = u;
          break;
        }
      }

      if (null != selectedUser) {
        selectedUser.IsActive = !selectedUser.IsActive;
        update selectedUser;
      }

      return null;
    }
}