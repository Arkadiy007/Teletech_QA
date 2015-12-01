public class Maritz_custom_settings_Controller {
    public Integer customSettingType { get; set; }

    public List<SelectOption> businessRulesOptions { get; set; }
    public List<SelectOption> businessRulesActitivyOptions { get; set; }
    public String selectedBusinessRulesOptions { get; set; }
    public String selectedBusinessRulesActitivyOptions { get; set; }
    public Map<String, List<CustomSettingWrapper>> MaritzBusinessRules { get; Set; }
    public Map<String, List<CustomSettingWrapper>> DisplayedMaritzBusinessRules { get; Set; }
    public List<SelectOption> objectsByIdList { get; private set; }
    public Map<String, List<SelectOption>> fieldsByIdList { get; private set; }
    public List<SelectOption> operatorByIdList { get; private set; }

    public List<CustomSettingWrapper> BackfeedRTRecords { get; set; }
    public List<CustomSettingWrapper> BackfeedProfileRecords { get; set; }
    public CustomSettingWrapper BackfeedTriggerRecords { get; set; }
    public Map<String, List<SelectOption>> RecordTypeMap { get; private set; }
    public Map<String, ID> mapRecordTypesbyName { get; private set; }
    public List<SelectOption> objectNameList { get; private set; }
    public Map<Id, String> profilesByIdMap { get; private set; }
    public List<SelectOption> profilesByIdList { get; private set; }

    public String csId_toDel { get; set; }
    public String csName_toDel { get; set; }
    public String csType { get; set; }
    public Integer DeleteRulePos { get; set; }
    public String businesRuleName { get; set; }
    public Boolean displayPopup { get; set; }
    public String BusinessRuleName { get; set; }

    public Maritz_custom_settings_Controller() {
        // BackfeedRT
        objectNameList = new List<SelectOption> ();
        mapRecordTypesbyName = new Map<String, ID> ();
        BackfeedRTRecords = fillBackfeedRTRecords();
        RecordTypeMap = fillRecordTypeMap();

        //BackfeedProfile 
        profilesByIdList = new List<SelectOption> ();
        profilesByIdMap = fillProfileById();
        BackfeedProfileRecords = fillBackfeedProfileRecords();

        //Backfeedrecord        
        BackfeedTriggerRecords = fillBackfeedTriggerRecords();

        //BusinessRules
        fieldsByIdList = new Map<String,List<SelectOption>> ();

        MaritzBusinessRules = fillMaritzBusinessRules();
        this.displayPopup = false;
    }

    public List<CustomSettingWrapper> fillBackfeedRTRecords() {
        List<CustomSettingWrapper> listSettings = new List<CustomSettingWrapper> ();

        for (Maritz_Backfeed_RT__c item : Maritz_Backfeed_RT__c.getall().values()) {
            listSettings.add(new CustomSettingWrapper(item));
        }
        return listSettings;
    }

    public List<CustomSettingWrapper> fillBackfeedProfileRecords() {
        List<CustomSettingWrapper> listSettings = new List<CustomSettingWrapper> ();
        for (Maritz_Backfeed_Profiles__c item : Maritz_Backfeed_Profiles__c.getall().values()) {
            listSettings.add(new CustomSettingWrapper(item));
        }
        return listSettings;
    }

    public Map<String, List<CustomSettingWrapper>> fillMaritzBusinessRules() {
        Set<String> objects = new Set<String> ();
        objects.add('Case');
        objects.add('EmailMessage');

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        objectsByIdList = new List<SelectOption> ();
        for (String obj : objects)
        {
            List<SelectOption> fieldsOption = new List<SelectOption>();
            objectsByIdList.add(new SelectOption(obj, obj));
            Schema.SObjectType sobjType = gd.get(obj);
            Schema.DescribeSObjectResult describeResult = sobjType.getDescribe();
            List<Schema.SObjectField> fields = describeResult.fields.getMap().values();

            for (Schema.SObjectField field : fields) {
                String name = field.getDescribe().getName();
                fieldsOption.add(new SelectOption(name, name));
            }

            fieldsByIdList.put(obj,fieldsOption);
        }

        operatorByIdList = new List<SelectOption> ();
        operatorByIdList.add(new SelectOption('equal', '='));
        operatorByIdList.add(new SelectOption('not equal', '!='));
        operatorByIdList.add(new SelectOption('contain', 'contain'));
        operatorByIdList.add(new SelectOption('not contain', 'not contain'));

        businessRulesOptions = new List<SelectOption> ();
    businessRulesOptions.add(new SelectOption('', '-- None --'));

        businessRulesActitivyOptions = new List<SelectOption> ();
        businessRulesActitivyOptions.add(new SelectOption('Email', 'Email'));
        businessRulesActitivyOptions.add(new SelectOption('Call/Phone', 'Call/Phone'));
        businessRulesActitivyOptions.add(new SelectOption('Chat', 'Chat'));

        Map<String, List<CustomSettingWrapper>> rules = new Map<String, List<CustomSettingWrapper>> ();
        Set<String> businessGroups = new Set<String> ();

        for (Maritz_Business_Rules__c item : Maritz_Business_Rules__c.getall().values()) {
            businessGroups.add(item.BR_Name__c);

            if (!rules.containsKey(item.BR_Group__c)) {
                List<CustomSettingWrapper> wrappers = new List<CustomSettingWrapper> ();
                wrappers.add(new CustomSettingWrapper(item));

                rules.put(item.BR_Group__c, wrappers);
            }
            else {
                rules.get(item.BR_Group__c).add(new CustomSettingWrapper(item));
            }
        }

        for (String grp : businessGroups) {
            businessRulesOptions.add(new SelectOption(grp, grp));
        }

        return rules;
    }

    public Map<String, List<SelectOption>> fillRecordTypeMap() {
        List<String> objectList = new List<String> { 'Account', 'Case', 'Call__c', 'Task' };
        Map<String, List<SelectOption>> mapObjectToRecordType = new Map<String, List<SelectOption>> ();
		mapObjectToRecordType.put('---', new List<SelectOption>{new SelectOption('---', '---')});
		objectNameList.add(new SelectOption('---', '---'));
        for (RecordType rt :[SELECT Id, Name, sObjectType FROM RecordType WHERE Sobjecttype in :objectList]) {
            if (!mapObjectToRecordType.containsKey(rt.sObjectType)) {
                mapObjectToRecordType.put(rt.sObjectType, new List<SelectOption> { new SelectOption(rt.Name, rt.Name) });
                objectNameList.add(new SelectOption(String.valueof(rt.sObjectType), String.valueof(rt.sObjectType)));
            } else {
                mapObjectToRecordType.get(rt.sObjectType).add(new SelectOption(rt.Name, rt.Name));
            }
            mapRecordTypesbyName.put(rt.Name, rt.Id);
        }

        return mapObjectToRecordType;
    }

    public Map<Id, String> fillProfileById() {
        Map<Id, String> profiles = new Map<Id, String> ();
        for (Profile prof :[Select Id, Name from Profile]) {
            profiles.put(prof.Id, prof.Name);
            profilesByIdList.add(new SelectOption(prof.Id, prof.Name));
        }
		profilesByIdList.add(0, new SelectOption('---', '---'));
        return profiles;
    }

    public CustomSettingWrapper fillBackfeedTriggerRecords() {
        CustomSettingWrapper backfeedTrigger = new CustomSettingWrapper(Maritz_Backfeed_Trigger_Enabled__c.getOrgDefaults());
        return backfeedTrigger;
    }

    public void AddBackfeedRT() {
        BackfeedRTRecords.add(0, new CustomSettingWrapper(new Maritz_Backfeed_RT__c(Name = 'temp' + Datetime.now().getTime() ,Object_Name__c = '---', RecordTypeName__c = '---')));
    }

    public void SaveBackfeedRT() {
        List<Maritz_Backfeed_RT__c> BackfeedRTRecords_toUpsert = new List<Maritz_Backfeed_RT__c> ();

        for (CustomSettingWrapper cs : BackfeedRTRecords) {
			if (!cs.recordTypeName.contains('---' )){
			
			System.debug(String.valueOf(mapRecordTypesbyName.get(cs.RecordTypeName)).right(7));
			System.debug(String.valueOf(Datetime.now().getTime()).right(5));
			System.debug(String.valueOf(cs.ObjectName).left(4));
			
            BackfeedRTRecords_toUpsert.add(new Maritz_Backfeed_RT__c(id = cs.id,
                                                                     Name = String.valueOf(cs.ObjectName).left(4) + String.valueOf(mapRecordTypesbyName.get(cs.RecordTypeName)).right(7) + String.valueOf(Datetime.now().getTime()).right(5),
                                                                     Object_Name__c = cs.ObjectName,
                                                                     RecordTypeId__c = mapRecordTypesbyName.get(cs.RecordTypeName),
                                                                     RecordTypeName__c = cs.RecordTypeName));
			} else {
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, select Object and Recort Type names from picklists'));
				return;
			}
        }

        Database.UpsertResult[] result = DataBase.upsert(BackfeedRTRecords_toUpsert, false);

        BackfeedRTRecords.clear();
        for (Maritz_Backfeed_RT__c cs : BackfeedRTRecords_toUpsert) {
            BackfeedRTRecords.add(new CustomSettingWrapper(cs));
        }

        for (Database.UpsertResult r : result) {
            if (!r.isSuccess()) {
                for (Database.Error err : r.getErrors()) {
                    System.debug(err);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
                }
            }
        }

        if (ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom settings were successfully updated/inserted!'));
        }
    }


    public void AddProfile() {
        BackfeedProfileRecords.add(0, new CustomSettingWrapper(new Maritz_Backfeed_Profiles__c(Name = 'test' + Datetime.now().getTime(), Profile_Id__c = '---', Profile_Name__c = '---')));
    }

    public void SaveProfile() {
        List<Maritz_Backfeed_Profiles__c> BackfeedProfile_toUpsert = new List<Maritz_Backfeed_Profiles__c> ();

        for (CustomSettingWrapper cs : BackfeedProfileRecords) {
			if (!cs.Profileid.contains('---')){
            BackfeedProfile_toUpsert.add(new Maritz_Backfeed_Profiles__c(id = cs.id,
                                                                         Name = 'BP' + String.valueOf(cs.ProfileId).right(7) + String.valueOf(Datetime.now().getTime()).right(5),
                                                                         Profile_Id__c = cs.ProfileId,
                                                                         Profile_Name__c = profilesByIdMap.get(cs.ProfileId)));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, select Profile from picklists'));
				return;
			}
		} 

        Database.UpsertResult[] result = DataBase.upsert(BackfeedProfile_toUpsert, false);

        BackfeedProfileRecords.clear();
        for (Maritz_Backfeed_Profiles__c cs : BackfeedProfile_toUpsert) {
            BackfeedProfileRecords.add(new CustomSettingWrapper(cs));
        }

        for (Database.UpsertResult r : result) {
            if (!r.isSuccess()) {
                for (Database.Error err : r.getErrors()) {
                    System.debug(err);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
                }
            }
        }

        if (ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom settings were successfully updated/inserted!'));
        }

    }

    public void SaveTrigger() {
        Maritz_Backfeed_Trigger_Enabled__c triggerToUpdate = new Maritz_Backfeed_Trigger_Enabled__c(EnabledForCall__c = BackfeedTriggerRecords.EnabledForCall,
                                                                                                    EnabledForEmail__c = BackfeedTriggerRecords.EnabledForEmail,
                                                                                                    EnabledForChat__c = BackfeedTriggerRecords.EnabledForChat,
                                                                                                    EnabledForTask__c = BackfeedTriggerRecords.EnabledForTask,
                                                                                                    Id = BackfeedTriggerRecords.Id);
        Database.SaveResult result = DataBase.update(triggerToUpdate, false);

        if (!result.isSuccess()) {
            for (Database.Error err : result.getErrors()) {
                System.debug(err);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not updated, something bad happened!'));
            }
        }

        if (ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom setting was successfully updated!'));
        }
    }

    public void SaveMaritzBusinessRule() {
      if (selectedBusinessRulesActitivyOptions == null || selectedBusinessRulesActitivyOptions.trim().length() == 0
              || selectedBusinessRulesOptions == null || selectedBusinessRulesOptions.trim().length() == 0) {
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please choose Business rule and Activity Type'));
        return;
      }

      List<Maritz_Business_Rules__c> businessRules = new List<Maritz_Business_Rules__c> ();

      // determine name with max value
      Integer index = 0;
      for (Maritz_Business_Rules__c item : Maritz_Business_Rules__c.getall().values()) {
        if (item.name.isNumeric()) {
          index = Math.max(index, Integer.valueOf(item.name) + 1);
        }
      }

      for (String key : DisplayedMaritzBusinessRules.keySet()) {
        for (CustomSettingWrapper cs : DisplayedMaritzBusinessRules.get(key)) {
          String name = cs.Name;
          if (name == null || name.trim().length() == 0) {
            name = ('0000000000000000' + index).right(9);
            index++;
          }

          Maritz_Business_Rules__c br =new Maritz_Business_Rules__c(
            id = cs.id,
            Name = name,
            Operator__c = cs.Operator,
            Object__c = cs.ObjectName,
            Field_Value__c = cs.FieldValue,
            Field_API_Name__c = cs.FieldAPIName,
            BR_Name__c = cs.BRName,
            BR_Group__c = cs.BRGroup,
            Activity_Type__c = cs.ActivityType
          );

          if (br.Field_API_Name__c == 'RecordTypeId' && br.Operator__c == 'equal') {
            br.Operator__c = 'RT equal';
          }

          businessRules.add(br);
        }
      }

      Database.UpsertResult[] result = DataBase.upsert(businessRules, false);
      for (Database.UpsertResult r : result) {
          if (!r.isSuccess()) {
              for (Database.Error err : r.getErrors()) {
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
              }
          }
      }

      if (ApexPages.getMessages().isEmpty()) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom settings were successfully updated/inserted!'));
          MaritzBusinessRules = fillMaritzBusinessRules();
          RuleChanged();
      }
    }

    public void RuleChanged() {
        if (selectedBusinessRulesActitivyOptions == null || selectedBusinessRulesActitivyOptions.trim().length() == 0
                || selectedBusinessRulesOptions == null || selectedBusinessRulesOptions.trim().length() == 0) {
          DisplayedMaritzBusinessRules = new Map<String, List<CustomSettingWrapper>> ();
          return;
        }      

        DisplayedMaritzBusinessRules = new Map<String, List<CustomSettingWrapper>> ();

        for (String rule : MaritzBusinessRules.keySet()) {            
            if (rule.startsWith(selectedBusinessRulesOptions)) {
                List<CustomSettingWrapper> wrappers = new List<CustomSettingWrapper> ();

                for (CustomSettingWrapper wrapper : MaritzBusinessRules.get(rule)) {
                    if (wrapper.ActivityType == selectedBusinessRulesActitivyOptions) {
                        wrappers.add(wrapper);
                    }
                }

                if (wrappers.size() > 0)
                {
                    DisplayedMaritzBusinessRules.put(rule, wrappers);
                }
                
            }
        }
    }

    public void Cancel() {
      RuleChanged();
    }

    public void Del() {
        if (CSId_toDel != null && CSId_toDel != '') {
            Database.DeleteResult delResult = DataBase.delete((Id) CSId_toDel, false);

            if (!delResult.isSuccess()) {
                for (Database.Error err : delResult.getErrors()) {
                    System.debug(err);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not deleted, something bad happened!'));
                }
            }
        }

        if (csType == 'BackfeedRT') {
            for (Integer i = 0; i < BackfeedRTRecords.size(); i++) {
                if (BackfeedRTRecords[i].name == CSName_toDel) {
                    BackfeedRTRecords.remove(i);
                    break;
                }
            }
        } else if (csType == 'BackfeedProfiles') {
            for (Integer i = 0; i < BackfeedProfileRecords.size(); i++) {
                if (BackfeedProfileRecords[i].name == CSName_toDel) {
                    BackfeedProfileRecords.remove(i);
                    break;
                }
            }
        } else if (csType == 'MaritzBusinessRule') {
          CustomSettingWrapper ruleToDel = DisplayedMaritzBusinessRules.get(businesRuleName).remove(DeleteRulePos);
        }

        if (ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom setting was successfully deleted!'));
        }
    }

  public void DeleteBrGroup() {
    if (DisplayedMaritzBusinessRules.containsKey(businesRuleName)) {
      List<String> idsToDel = new List<String>();
      for (CustomSettingWrapper wr : DisplayedMaritzBusinessRules.get(businesRuleName)) {
        if (wr.Id != null) {
          idsToDel.add(wr.Id);
        }
      }

      Savepoint sp = Database.setSavepoint();
      Database.DeleteResult[] delResults = DataBase.delete(idsToDel, false);
      Boolean isSucces = true;
      for (Database.DeleteResult dr : delResults) {
        if (!dr.isSuccess()) {
          isSucces = false;
          break;
        }
      }

      if (isSucces) {
        DisplayedMaritzBusinessRules.remove(businesRuleName);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom settings was successfully deleted!'));
      } else {
        Database.rollback(sp);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not deleted, something bad happened!'));
      }
    }
  }

  public void AddBusinessRule() {
    if (DisplayedMaritzBusinessRules.containsKey(businesRuleName)) {
      DisplayedMaritzBusinessRules.get(businesRuleName).add(
        new CustomSettingWrapper(new Maritz_Business_Rules__c(
          Activity_Type__c = selectedBusinessRulesActitivyOptions,
          BR_Group__c = businesRuleName,
          BR_Name__c = selectedBusinessRulesOptions,
          Object__c = objectsByIdList[0].getValue()
        ))
      );
    }
  }

  public void AddBusinesGroup() {
    if (null != selectedBusinessRulesOptions && null != selectedBusinessRulesActitivyOptions) {
      // determine max name
      Integer index = 1;
      for (String rule : MaritzBusinessRules.keySet()) {
        if (rule.startsWith(selectedBusinessRulesOptions)) {
          String strIndex = rule.removeStart(selectedBusinessRulesOptions);
          index = Math.max(index, Integer.valueOf(strIndex) + 1);
        }
      }

      DisplayedMaritzBusinessRules.put(selectedBusinessRulesOptions + index, new List<CustomSettingWrapper>());
    } else {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please choose Business rule and Activity Type'));
    }
  }

  public void AddBusinessGroupName() {
    if (BusinessRuleName != null && BusinessRuleName.trim().length() != 0) {
      // check that value is unique
      for (SelectOption so : businessRulesOptions) {
        if (BusinessRuleName == so.getValue()) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Business Rule name should be unique.'));
          return;
        }
      }

      displayPopup = false;
      businessRulesOptions.add(new SelectOption(BusinessRuleName, BusinessRuleName));
      selectedBusinessRulesOptions = BusinessRuleName;
      BusinessRuleName = '';
      RuleChanged();
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Business Rule name successfully added.'));
    } else {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please input correct business rule name.'));
    }
  }

  public void ClosePopup() {
    displayPopup = false;
    BusinessRuleName = '';
  }

  public void ShowPopup() {
    displayPopup = true;
  }

  public class CustomSettingWrapper {
        public Boolean EnabledForCall { get; set; }
        public Boolean EnabledForChat { get; set; }
        public Boolean EnabledForEmail { get; set; }
        public Boolean EnabledForTask { get; set; }
        public String ProfileId { get; set; }
        public String ProfileName { get; set; }
        public String ObjectName { get; set; }
        public String RecordTypeId { get; set; }
        public String RecordTypeName { get; set; }
        public String ActivityType { get; set; }
        public String BRGroup { get; set; }
        public String BRName { get; set; }
        public String FieldAPIName { get; set; }
        public String FieldValue { get; set; }
        public String Operator { get; set; }
        public String Name { get; set; }
        public Id Id { get; set; }

        public CustomSettingWrapper(Maritz_Backfeed_RT__c BackfeedRT) {
            this.ObjectName = BackfeedRT.Object_Name__c;
            this.RecordTypeId = BackfeedRT.RecordTypeId__c;
            this.RecordTypeName = BackfeedRT.RecordTypeName__c;
            this.Name = BackfeedRT.Name;
            this.Id = BackfeedRT.Id;
        }

        public CustomSettingWrapper(Maritz_Backfeed_Profiles__c BackfeedProfiles) {
            this.ProfileId = BackfeedProfiles.Profile_Id__c;
            this.ProfileName = BackfeedProfiles.Profile_Name__c;
            this.Name = BackfeedProfiles.Name;
            this.Id = BackfeedProfiles.Id;
        }

        public CustomSettingWrapper(Maritz_Backfeed_Trigger_Enabled__c BackfeedTrigger) {
            this.EnabledForcall = BackfeedTrigger.EnabledForCall__c;
            this.EnabledForChat = BackfeedTrigger.EnabledForChat__c;
            this.EnabledForEmail = BackfeedTrigger.EnabledForEmail__c;
            this.EnabledForTask = BackfeedTrigger.EnabledForTask__c;
            this.ID = BackfeedTrigger.ID;
        }

        public CustomSettingWrapper(Maritz_Business_Rules__c BusinnesRules) {
            this.ActivityType = BusinnesRules.Activity_Type__c;
            this.BRGroup = BusinnesRules.BR_Group__c;
            this.BRName = BusinnesRules.BR_Name__c;
            this.FieldAPIName = BusinnesRules.Field_API_Name__c;
            this.FieldValue = BusinnesRules.Field_Value__c;
            this.ObjectName = BusinnesRules.Object__c;
            this.Operator = BusinnesRules.Operator__c;
            this.Name = BusinnesRules.Name;
            this.Id = BusinnesRules.Id;
        }
    }
}