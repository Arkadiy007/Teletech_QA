@isTest
private class Maritz_custom_settings_Controller_Test {
	//----------------------------------------------------
	// Tests
	public static Profile[] profiles = [Select Id, Name from Profile Limit 10];


	@testSetup static void testSetup() {
		// Backfeed Record Types
		Maritz_Backfeed_RT__c[] backfeedRTs = new Maritz_Backfeed_RT__c[] { };

		Maritz_Backfeed_RT__c backfeedRT1 = new Maritz_Backfeed_RT__c(
		                                                              Name = 'backfeed1',
		                                                              Object_Name__c = 'Object1',
		                                                              RecordTypeId__c = 'ID123',
		                                                              RecordTypeName__c = 'Name1');
		backfeedRTs.add(backfeedRT1);

		Maritz_Backfeed_RT__c backfeedRT2 = new Maritz_Backfeed_RT__c(
		                                                              Name = 'backfeed2',
		                                                              Object_Name__c = 'Object2',
		                                                              RecordTypeId__c = 'ID12334',
		                                                              RecordTypeName__c = 'Name2');
		backfeedRTs.add(backfeedRT2);

		insert backfeedRTs;

		// Backfeed Profile
		Maritz_Backfeed_Profiles__c[] BackfeedProfiles = new Maritz_Backfeed_Profiles__c[] { };

		Maritz_Backfeed_Profiles__c profile1 = new Maritz_Backfeed_Profiles__c(
		                                                                       Name = 'Profile1',
		                                                                       Profile_Id__c = profiles[0].ID,
		                                                                       Profile_Name__c = profiles[0].Name);
		BackfeedProfiles.add(profile1);

		Maritz_Backfeed_Profiles__c profile2 = new Maritz_Backfeed_Profiles__c(
		                                                                       Name = 'Profile2',
		                                                                       Profile_Id__c = profiles[1].Id,
		                                                                       Profile_Name__c = profiles[1].Name);
		BackfeedProfiles.add(profile2);

		insert BackfeedProfiles;

		// Backfeed Trigger
		Maritz_Backfeed_Trigger_Enabled__c backfeedTrigger = new Maritz_Backfeed_Trigger_Enabled__c(
		                                                                                            EnabledForCall__c = true,
		                                                                                            EnabledForChat__c = true,
		                                                                                            EnabledForEmail__c = true,
		                                                                                            EnabledForTask__c = true);

		insert backfeedTrigger;

		//Businnes Rules
		Maritz_Business_Rules__c[] rules = new Maritz_Business_Rules__c[] { };

		Maritz_Business_Rules__c rule1 = new Maritz_Business_Rules__c(
		                                                              Name = '00000001',
		                                                              Activity_Type__c = 'Email',
		                                                              BR_Group__c = 'First1',
		                                                              BR_Name__c = 'First',
		                                                              Field_API_Name__c = 'Id',
		                                                              Field_Value__c = '123',
		                                                              Object__c = 'Case',
		                                                              Operator__c = 'equal'
		);
		rules.add(rule1);

		Maritz_Business_Rules__c rule2 = new Maritz_Business_Rules__c(
		                                                              Name = '00000002',
		                                                              Activity_Type__c = 'Email',
		                                                              BR_Group__c = 'Second1',
		                                                              BR_Name__c = 'Second',
		                                                              Field_API_Name__c = 'Id',
		                                                              Field_Value__c = '123',
		                                                              Object__c = 'Case',
		                                                              Operator__c = 'equal'
		);
		rules.add(rule2);

		insert rules;
	}

	@isTest static void testConstructor_BackfeedRecordType() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.BackfeedRTRecords);
			System.assertEquals(2, controller.BackfeedRTRecords.size());
			System.assert(controller.BackfeedRTRecords[0].Name.contains('backfeed1'));
			System.assert(controller.BackfeedRTRecords[1].ObjectName.contains('Object2'));

			Maritz_custom_settings_Controller.CustomSettingWrapper firstWrapper = controller.BackfeedRTRecords[0];
			System.assertEquals('backfeed1', firstWrapper.Name);
			System.assertEquals('Object1', firstWrapper.ObjectName);
			System.assertEquals('ID123', firstWrapper.RecordTypeId);
			System.assertEquals('Name1', firstWrapper.recordTypeName);
			System.assertNotEquals(null, firstWrapper.Id);

			Maritz_custom_settings_Controller.CustomSettingWrapper secondWrapper = controller.BackfeedRTRecords[1];
			System.assertEquals('backfeed2', secondWrapper.Name);
			System.assertEquals('Object2', secondWrapper.ObjectName);
			System.assertEquals('ID12334', secondWrapper.RecordTypeId);
			System.assertEquals('Name2', secondWrapper.recordTypeName);
			System.assertNotEquals(null, secondWrapper.Id);
		}
	}

	@isTest static void testChangeRecordType_BackfeedRecordType() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.BackfeedRTRecords[0].ObjectName = 'Account';
			controller.BackfeedRTRecords[0].RecordTypeName = 'Dealer';
			controller.BackfeedRTRecords[1].ObjectName = 'Case';
			controller.BackfeedRTRecords[1].RecordTypeName = 'Live Agent';
			controller.SaveBackfeedRT();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.MaritzBusinessRules);
			System.assertEquals(2, controller.BackfeedRTRecords.size());
			System.assert(controller.BackfeedRTRecords[0].ObjectName.contains('Account'));
			System.assert(controller.BackfeedRTRecords[1].ObjectName.contains('Case'));

		}
	}

	@isTest static void testAddInvalidRecordType_BackfeedRecordType() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller control = new Maritz_custom_settings_Controller();
			control.AddBackfeedRT();
			control.SaveBackfeedRT();
			Test.stopTest();

			// check that initial value is correct
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			System.assertNotEquals(NULL, controller.MaritzBusinessRules);
			System.assertEquals(2, controller.BackfeedRTRecords.size());
		}
	}

	@isTest static void testAddRecordType_BackfeedRecordType() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.AddBackfeedRT();
			controller.BackfeedRTRecords[0].Name = 'CompleteNewRecord';
			controller.SaveBackfeedRT();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.MaritzBusinessRules);
			System.assertEquals(3, controller.BackfeedRTRecords.size());
			System.assert(controller.BackfeedRTRecords[0].Name.contains('CompleteNewRecord'));

		}
	}

	@isTest static void testDeleteRecordType_BackfeedRecordType() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller control = new Maritz_custom_settings_Controller();
			control.CSId_toDel = control.BackfeedRTRecords[0].Id;
			control.csType = 'BackfeedRT';
			control.Del();
			Test.stopTest();

			// check that initial value is correct
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			System.assertNotEquals(NULL, controller.BackfeedRTRecords);
			System.assertEquals(1, controller.BackfeedRTRecords.size());
			System.assert(controller.BackfeedRTRecords[0].ObjectName.contains('Object2'));

		}
	}

	@isTest static void testCancelRecordType_BackfeedRecordType() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.Cancel();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.BackfeedRTRecords);
			System.assertEquals(2, controller.BackfeedRTRecords.size());
			System.assert(controller.BackfeedRTRecords[0].Name.contains('backfeed1'));
			System.assert(controller.BackfeedRTRecords[1].ObjectName.contains('Object2'));
		}
	}

	@isTest static void testConstructor_BackfeedProfile() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.BackfeedProfileRecords);
			System.assertEquals(2, controller.BackfeedProfileRecords.size());
			System.assert(controller.BackfeedProfileRecords[0].Name.contains('Profile1'));
			System.assert(controller.BackfeedProfileRecords[1].ProfileName.contains(profiles[1].Name));

			Maritz_custom_settings_Controller.CustomSettingWrapper firstWrapper = controller.BackfeedProfileRecords[0];
			System.assertEquals('Profile1', firstWrapper.Name);
			System.assertEquals(profiles[0].Id, firstWrapper.ProfileId);
			System.assertEquals(profiles[0].Name, firstWrapper.ProfileName);
			System.assertNotEquals(null, firstWrapper.Id);

			Maritz_custom_settings_Controller.CustomSettingWrapper secondWrapper = controller.BackfeedProfileRecords[1];
			System.assertEquals('Profile2', secondWrapper.Name);
			System.assertEquals(profiles[1].Id, secondWrapper.ProfileId);
			System.assertEquals(profiles[1].Name, secondWrapper.ProfileName);
			System.assertNotEquals(null, secondWrapper.Id);
		}
	}

	@isTest static void testChangeProfile_BackfeedProfile() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();

			controller.BackfeedProfileRecords[0].ProfileId = profiles[2].Id;
			controller.BackfeedProfileRecords[1].ProfileId = profiles[3].Id;
			controller.SaveProfile();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.BackfeedProfileRecords);
			System.assertEquals(2, controller.BackfeedProfileRecords.size());

			Maritz_custom_settings_Controller.CustomSettingWrapper firstWrapper = controller.BackfeedProfileRecords[0];
			System.assertNotEquals(null, firstWrapper.Id);
			System.assertEquals(profiles[2].Id, firstWrapper.ProfileId);
			System.assertEquals(profiles[2].Name, firstWrapper.ProfileName);

			Maritz_custom_settings_Controller.CustomSettingWrapper secondWrapper = controller.BackfeedProfileRecords[1];
			System.assertNotEquals(null, secondWrapper.Id);
			System.assertEquals(profiles[3].Id, secondWrapper.ProfileId);
			System.assertEquals(profiles[3].Name, secondWrapper.ProfileName);
		}
	}

	@isTest static void testAddIncorrectProfile_BackfeedProfile() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller control = new Maritz_custom_settings_Controller();
			control.AddProfile();
			control.SaveProfile();
			Test.stopTest();

			// check that initial value is correct
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			System.assertNotEquals(NULL, controller.BackfeedProfileRecords);
			System.assertEquals(2, controller.BackfeedProfileRecords.size());
			System.assert(controller.BackfeedProfileRecords[0].Name.contains('Profile1'));
			System.assert(controller.BackfeedProfileRecords[1].ProfileName.contains(profiles[1].Name));
		}
	}

	@isTest static void testAddProfile_BackfeedProfile() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller control = new Maritz_custom_settings_Controller();
			control.AddProfile();
			control.BackfeedProfileRecords[0].ProfileId = profiles[2].Id;
			control.SaveProfile();
			Test.stopTest();

			// check that initial value is correct
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			System.assertNotEquals(NULL, controller.BackfeedProfileRecords);
			System.assertEquals(3, controller.BackfeedProfileRecords.size());
			System.assertNotEquals(NULL, controller.BackfeedProfileRecords[0].Id);

			Maritz_custom_settings_Controller.CustomSettingWrapper firstWrapper = controller.BackfeedProfileRecords[0];
			System.assertNotEquals(null, firstWrapper.Id);
			System.assertEquals(profiles[0].Id, firstWrapper.ProfileId);
			System.assertEquals(profiles[0].Name, firstWrapper.ProfileName);

			Maritz_custom_settings_Controller.CustomSettingWrapper secondWrapper = controller.BackfeedProfileRecords[1];
			System.assertNotEquals(null, secondWrapper.Id);
			System.assertEquals(profiles[1].Id, secondWrapper.ProfileId);
			System.assertEquals(profiles[1].Name, secondWrapper.ProfileName);

			Maritz_custom_settings_Controller.CustomSettingWrapper thirdWrapper = controller.BackfeedProfileRecords[2];
			System.assertNotEquals(null, thirdWrapper.Id);
			System.assertEquals(profiles[2].Id, thirdWrapper.ProfileId);
			System.assertEquals(profiles[2].Name, thirdWrapper.ProfileName);
		}
	}

	@isTest static void testCancel_BackfeedProfile() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.Cancel();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.BackfeedProfileRecords);
			System.assertEquals(2, controller.BackfeedProfileRecords.size());
			System.assert(controller.BackfeedProfileRecords[0].Name.contains('Profile1'));
			System.assert(controller.BackfeedProfileRecords[1].ProfileName.contains(profiles[1].Name));

			Maritz_custom_settings_Controller.CustomSettingWrapper firstWrapper = controller.BackfeedProfileRecords[0];
			System.assertEquals('Profile1', firstWrapper.Name);
			System.assertEquals(profiles[0].Id, firstWrapper.ProfileId);
			System.assertEquals(profiles[0].Name, firstWrapper.ProfileName);
			System.assertNotEquals(null, firstWrapper.Id);

			Maritz_custom_settings_Controller.CustomSettingWrapper secondWrapper = controller.BackfeedProfileRecords[1];
			System.assertEquals('Profile2', secondWrapper.Name);
			System.assertEquals(profiles[1].Id, secondWrapper.ProfileId);
			System.assertEquals(profiles[1].Name, secondWrapper.ProfileName);
			System.assertNotEquals(null, secondWrapper.Id);
		}
	}

	@isTest static void testDelete_BackfeedProfile() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller control = new Maritz_custom_settings_Controller();
			control.CSId_toDel = control.BackfeedProfileRecords[0].Id;
			control.csName_toDel = control.BackfeedProfileRecords[0].Name;
			control.csType = 'BackfeedProfiles';
			control.Del();
			Test.stopTest();

			// check that initial value is correct
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			System.assertNotEquals(NULL, controller.BackfeedProfileRecords);
			System.assertEquals(1, controller.BackfeedProfileRecords.size());
			System.assert(controller.BackfeedProfileRecords[0].Name.contains('Profile2'));
			System.assert(controller.BackfeedProfileRecords[0].ProfileName.contains(profiles[1].Name));
		}
	}

	@isTest static void testConstructor_BackfeedTrigger() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.BackfeedTriggerRecords);

			Maritz_custom_settings_Controller.CustomSettingWrapper firstWrappers = controller.BackfeedTriggerRecords;
			System.assertEquals(true, firstWrappers.EnabledForCall);
			System.assertEquals(true, firstWrappers.EnabledForChat);
			System.assertEquals(true, firstWrappers.EnabledForEmail);
			System.assertEquals(true, firstWrappers.EnabledForTask);

		}
	}

	@isTest static void testChange_BackfeedTrigger() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.BackfeedTriggerRecords.EnabledForCall = false;
			controller.BackfeedTriggerRecords.EnabledForTask = false;
			controller.SaveTrigger();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.BackfeedTriggerRecords);

			Maritz_custom_settings_Controller.CustomSettingWrapper firstWrappers = controller.BackfeedTriggerRecords;
			System.assertEquals(false, firstWrappers.EnabledForCall);
			System.assertEquals(true, firstWrappers.EnabledForChat);
			System.assertEquals(true, firstWrappers.EnabledForEmail);
			System.assertEquals(false, firstWrappers.EnabledForTask);

		}
	}


	@isTest static void testConstructor_BusinessRule() {
		System.runAs(adminUser) {
			Test.startTest();
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			Test.stopTest();

			// check that initial value is correct
			System.assertNotEquals(NULL, controller.MaritzBusinessRules);
			System.assertEquals(2, controller.MaritzBusinessRules.size());
			System.assert(controller.MaritzBusinessRules.containsKey('First1'));
			System.assert(controller.MaritzBusinessRules.containsKey('Second1'));

			Maritz_custom_settings_Controller.CustomSettingWrapper[] firstWrappers = controller.MaritzBusinessRules.get('First1');
			System.assertEquals(1, firstWrappers.size());
			System.assertEquals('Email', firstWrappers[0].ActivityType);
			System.assertEquals('First1', firstWrappers[0].BRGroup);
			System.assertEquals('First', firstWrappers[0].BRName);
			System.assertEquals('Id', firstWrappers[0].FieldAPIName);
			System.assertEquals('123', firstWrappers[0].FieldValue);
			System.assertEquals('Case', firstWrappers[0].ObjectName);
			System.assertEquals('equal', firstWrappers[0].Operator);
			System.assertEquals('00000001', firstWrappers[0].Name);
			System.assertNotEquals(null, firstWrappers[0].Id);

			Maritz_custom_settings_Controller.CustomSettingWrapper[] secondWrappers = controller.MaritzBusinessRules.get('Second1');
			System.assertEquals(1, secondWrappers.size());
			System.assertEquals('Email', secondWrappers[0].ActivityType);
			System.assertEquals('Second1', secondWrappers[0].BRGroup);
			System.assertEquals('Second', secondWrappers[0].BRName);
			System.assertEquals('Id', secondWrappers[0].FieldAPIName);
			System.assertEquals('123', secondWrappers[0].FieldValue);
			System.assertEquals('Case', secondWrappers[0].ObjectName);
			System.assertEquals('equal', secondWrappers[0].Operator);
			System.assertEquals('00000002', secondWrappers[0].Name);
			System.assertNotEquals(null, secondWrappers[0].Id);

			System.assertEquals(false, controller.displayPopup);
		}
	}

	@isTest static void testRuleChange_BusinessRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';

			Test.startTest();
			controller.RuleChanged();
			Test.stopTest();

			// check DisplayedMaritzBusinessRules
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules);
			System.assertEquals(1, controller.DisplayedMaritzBusinessRules.size());
			System.assert(controller.DisplayedMaritzBusinessRules.containsKey('Second1'));
		}
	}

	@isTest static void testAddRecordToBusinessRuleGroup_BusinessRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';
			controller.RuleChanged();

			Test.startTest();
			controller.businesRuleName = 'Second1';
			controller.AddBusinessRule();
			Test.stopTest();

			// check DisplayedMaritzBusinessRules
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules);
			System.assertEquals(1, controller.DisplayedMaritzBusinessRules.size());
			System.assert(controller.DisplayedMaritzBusinessRules.containsKey('Second1'));

			Maritz_custom_settings_Controller.CustomSettingWrapper[] wrList = controller.DisplayedMaritzBusinessRules.get('Second1');
			System.assertEquals(2, wrList.size());

			// verify new record
			System.assertEquals('Email', wrList[1].ActivityType);
			System.assertEquals('Second1', wrList[1].BRGroup);
			System.assertEquals('Second', wrList[1].BRName);
			System.assertEquals('Case', wrList[1].ObjectName);
		}
	}

	@isTest static void testAddBusinessGroupRule_BusinessRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';
			controller.RuleChanged();

			Test.startTest();
			controller.AddBusinesGroup();
			Test.stopTest();

			// check DisplayedMaritzBusinessRules
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules);
			System.assertEquals(2, controller.DisplayedMaritzBusinessRules.size());

			System.assert(controller.DisplayedMaritzBusinessRules.containsKey('Second1'));
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules.get('Second1'));
			System.assertEquals(1, controller.DisplayedMaritzBusinessRules.get('Second1').size());

			System.assert(controller.DisplayedMaritzBusinessRules.containsKey('Second2'));
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules.get('Second2'));
			System.assertEquals(0, controller.DisplayedMaritzBusinessRules.get('Second2').size());
		}
	}

	@isTest static void testAddBusinessGroupName_BusinessRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';
			controller.RuleChanged();

			Test.startTest();
			controller.ShowPopup();
			System.assertEquals(true, controller.displayPopup);

			controller.BusinessRuleName = 'Test';
			controller.AddBusinessGroupName();
			System.assertEquals(false, controller.displayPopup);
			System.assertEquals('', controller.BusinessRuleName);
			Test.stopTest();

			// check DisplayedMaritzBusinessRules
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules);
			System.assertEquals(0, controller.DisplayedMaritzBusinessRules.size());
			System.assertEquals('Test', controller.selectedBusinessRulesOptions);
		}
	}

	@isTest static void testCancelButton_BusinessRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';
			controller.RuleChanged();

			Test.startTest();
			controller.businesRuleName = 'Second1';
			controller.AddBusinessRule();

			// check DisplayedMaritzBusinessRules
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules);
			System.assertEquals(1, controller.DisplayedMaritzBusinessRules.size());
			System.assert(controller.DisplayedMaritzBusinessRules.containsKey('Second1'));

			Maritz_custom_settings_Controller.CustomSettingWrapper[] wrList = controller.DisplayedMaritzBusinessRules.get('Second1');
			System.assertEquals(2, wrList.size());

			controller.Cancel();
			wrList = controller.DisplayedMaritzBusinessRules.get('Second1');
			System.assertEquals(1, wrList.size()); // initial value
			Test.stopTest();
		}
	}

	@isTest static void testSaveButton_BusinessRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';
			controller.RuleChanged();

			Test.startTest();
			controller.businesRuleName = 'Second1';
			controller.AddBusinessRule();

			// check DisplayedMaritzBusinessRules
			System.assertNotEquals(null, controller.DisplayedMaritzBusinessRules);
			System.assertEquals(1, controller.DisplayedMaritzBusinessRules.size());
			System.assert(controller.DisplayedMaritzBusinessRules.containsKey('Second1'));

			Maritz_custom_settings_Controller.CustomSettingWrapper[] wrList = controller.DisplayedMaritzBusinessRules.get('Second1');
			System.assertEquals(2, wrList.size());

			// verify new record
			System.assertEquals('Email', wrList[1].ActivityType);
			System.assertEquals('Second1', wrList[1].BRGroup);
			System.assertEquals('Second', wrList[1].BRName);
			System.assertEquals('Case', wrList[1].ObjectName);

			wrList[1].FieldAPIName = 'Id';
			wrList[1].FieldValue = '1234321';
			wrList[1].Operator = 'equals';
			controller.SaveMaritzBusinessRule();
			Test.stopTest();

			Maritz_Business_Rules__c[] savedRule = [SELECT Id, Object__c, Field_Value__c, Field_API_Name__c, Name, BR_Name__c,
			                                        BR_Group__c, Activity_Type__c, Operator__c
			                                        FROM Maritz_Business_Rules__c
			                                        WHERE Field_Value__c = '1234321'];
			System.assertEquals(1, savedRule.size());
			System.assertEquals('Case', savedRule[0].Object__c);
			System.assertEquals('Email', savedRule[0].Activity_Type__c);
			System.assertEquals('Id', savedRule[0].Field_API_Name__c);
			System.assertEquals('000000003', savedRule[0].Name);
			System.assertEquals('Second', savedRule[0].BR_Name__c);
			System.assertEquals('Second1', savedRule[0].BR_Group__c);
			System.assertEquals('equals', savedRule[0].Operator__c);
		}
	}

	@isTest static void testDeleteButton_BusinessRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';
			controller.RuleChanged();

			Maritz_custom_settings_Controller.CustomSettingWrapper[] wrappersList = controller.DisplayedMaritzBusinessRules.get('Second1');
			System.assertEquals(1, wrappersList.size());
			System.assertNotEquals(null, wrappersList[0].Id);

			Id ruleId = wrappersList[0].Id;

			Test.startTest();
			controller.DeleteRulePos = 0;
			controller.CSId_toDel = ruleId;
			controller.csType = 'MaritzBusinessRule';
			controller.businesRuleName = 'Second1';
			controller.Del();
			Test.stopTest();

			// check that not exists setting on page in database
			wrappersList = controller.DisplayedMaritzBusinessRules.get('Second1');
			System.assertEquals(0, wrappersList.size());

			Maritz_Business_Rules__c[] settings = [SELECT ID FROM Maritz_Business_Rules__c WHERE ID = :ruleId];
			System.assertEquals(0, settings.size());
		}
	}

	@isTest static void testDeleteBusinessRuleGroup_BusinesRule() {
		System.runAs(adminUser) {
			Maritz_custom_settings_Controller controller = new Maritz_custom_settings_Controller();
			controller.selectedBusinessRulesOptions = 'Second';
			controller.selectedBusinessRulesActitivyOptions = 'Email';
			controller.RuleChanged();

			Test.startTest();
			controller.businesRuleName = 'Second1';
			controller.DeleteBrGroup();
			Test.stopTest();

			// check taht group was deleted from page
			System.assert(!controller.DisplayedMaritzBusinessRules.containsKey('Second1'));

			// check that group was deleted from org
			Maritz_Business_Rules__c[] savedRule = [SELECT Id, Object__c, Field_Value__c, Field_API_Name__c, Name, BR_Name__c,
			                                        BR_Group__c, Activity_Type__c, Operator__c
			                                        FROM Maritz_Business_Rules__c
			                                        WHERE Field_Value__c = 'Second1'];
			System.assertEquals(0, savedRule.size());
		}
	}

	//----------------------------------------------------
	// Helpers

	/** Create default user for run test */
	private static User adminUser {
		get {
			if (null == adminUser) {
				UserRole[] roles = [SELECT Id FROM UserRole WHERE DeveloperName = 'System_Administrator'];
				if (roles.isEmpty()) {
					roles.add(new UserRole(DeveloperName = 'System_Administrator', Name = 'r0'));
					insert roles;
				}

				adminUser = new User(
				                     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
				                     LastName = 'last',
				                     Email = 'user@Nissan.com',
				                     Username = 'admin@Nissan.com' + System.currentTimeMillis(),
				                     CompanyName = 'Nissan',
				                     Title = 'title',
				                     Alias = 'alias',
				                     TimeZoneSidKey = 'America/Los_Angeles',
				                     EmailEncodingKey = 'UTF-8',
				                     LanguageLocaleKey = 'en_US',
				                     LocaleSidKey = 'en_US',
				                     UserRoleId = roles[0].Id
				);

				insert adminUser;
			}

			return adminUser;
		}

		private set;
	}
}