/**********************************************************************
  Name: NNAScheduledCheckDealerIntCertTests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Unit-tests for NNAScheduledCheckDealerIntCert scheduled job
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 06/12/2015 Created
 ***********************************************************************/
 @isTest
 public class NNAScheduledCheckDealerIntCertTests {
 	
		@isTest
		static void ScheduledJobShouldDoNothingIfAccountNotValid(){
			insertAccounts(1, false);
			System.AssertEquals(0, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
			System.AssertEquals(1, [SELECT Count() FROM Account]);
			Test.startTest();
				String CRON_EXP = '0 0 0 15 3 ? 2022';

				String jobId = System.schedule('TestZZZZZZZZ Check For Dealer Internet Certification', CRON_EXP, new NNAScheduledCheckDealerIntCert());

				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

         		System.assertEquals(CRON_EXP, ct.CronExpression);
     			System.assertEquals(0, ct.TimesTriggered);
      			System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
			Test.stopTest();
			System.AssertEquals(0, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
			System.AssertEquals(1, [SELECT Count() FROM Account]);
		}

		@isTest
		static void ScheduledJobShouldDoNothingIfAccountNotValidForBulk(){
			insertAccounts(80, false);
			System.AssertEquals(0, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
			System.AssertEquals(80, [SELECT Count() FROM Account]);
			Test.startTest();
				String CRON_EXP = '0 0 0 15 3 ? 2022';

				String jobId = System.schedule('TestSDASDAZZZ Check For Dealer Internet Certification', CRON_EXP, new NNAScheduledCheckDealerIntCert());

				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

         		System.assertEquals(CRON_EXP, ct.CronExpression);
     			System.assertEquals(0, ct.TimesTriggered);
      			System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
			Test.stopTest();
			System.AssertEquals(0, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
			System.AssertEquals(80, [SELECT Count() FROM Account]);
		}

		@isTest
		static void ScheduledJobShouldChangeInternetCertifiedIfAccountValid(){
			Test.startTest();
				insertAccounts(1, true);
				System.AssertEquals(0, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
				System.AssertEquals(1, [SELECT Count() FROM Account]);
				
				Database.executeBatch(new NNABatchCheckDealerIntCert(), 90);

			Test.stopTest();
			System.AssertEquals(1, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
			System.AssertEquals(1, [SELECT Count() FROM Account]);
		}

		@isTest
		static void ScheduledJobShouldChangeInternetCertifiedIfAccountValidForBulk(){
			Test.startTest();
				insertAccounts(80, true);
				System.AssertEquals(0, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
				System.AssertEquals(80, [SELECT Count() FROM Account]);
				String CRON_EXP = '0 0 0 15 3 ? 2022';

				Database.executeBatch(new NNABatchCheckDealerIntCert(), 90);
			Test.stopTest();
			System.AssertEquals(80, [SELECT Count() FROM Account WHERE Internet_Certified__c = true]);
			System.AssertEquals(80, [SELECT Count() FROM Account]);
		}

		private static void insertAccounts(Integer quantity, Boolean isValid){
			List<Account> accs = new List<Account>();

			for(Integer i = 0; i < quantity; i++){
				Account acc = new Account();
				acc.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');
				if(isValid){
					acc.Dealer_Code__c = '01010';
					acc.Dealer_Code_NCV__c = '01010';
					acc.Dealer_External_Id__c = '01010'+String.valueOf(i);
				}
				else{
					acc.Dealer_Code__c = '11111';
				}
				acc.Dealer_Inactive_Indicator__c = false;
				acc.Name = 'Account No' + String.valueof(i);
				accs.add(acc);
			}

			insert accs;
			System.DEBUG([SELECT Dealer_Code__c FROM Account]);
		}
  }