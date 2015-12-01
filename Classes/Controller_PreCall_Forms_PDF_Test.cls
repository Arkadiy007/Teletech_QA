/**********************************************************************
Name: Controller_PreCall_Forms_PDF_Test
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for Controller_PreCall_Forms_PDF

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 03/06/2015 Created
***********************************************************************/
@isTest
public class Controller_PreCall_Forms_PDF_Test {
	private static String warrantyCaseRecordTypeName = 'Engine VCAN';
	private static String dealerRecordTypeName = 'Dealer';
	private static String nissanRecordTypeName = 'Nissan';

	static testmethod void testPDFGeneratedWithoutDateFields() {
		Warranty_Case__c warrantyCaseRecord = setWarrantyCase();

		PageReference pageRef = Page.PreCall_Forms_PDF_Engine;
		Test.setCurrentPage(pageRef);
		System.currentPageReference().getParameters().put('id', warrantyCaseRecord.Id);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(warrantyCaseRecord);
		Controller_PreCall_Forms_PDF controllerPreCallFormsPDF = new Controller_PreCall_Forms_PDF(sc);

		//Getting all variables
		String testStr;
		testStr = controllerPreCallFormsPDF.AnyCVTfluidleakspresent;
		testStr = controllerPreCallFormsPDF.AnyOilLeaksPresent;
		testStr = controllerPreCallFormsPDF.AreThereAnyCoolantLeaks;
		testStr = controllerPreCallFormsPDF.BulletinRelatedToThisReport;
		testStr = controllerPreCallFormsPDF.CoolantPressureTestPerformed;
		testStr = controllerPreCallFormsPDF.DiagnosticTroubleCodesPresent;
		testStr = controllerPreCallFormsPDF.DidTheVehicleOverheat;
		testStr = controllerPreCallFormsPDF.DoesTechnicianHaveAappropriateHVTools;
		testStr = controllerPreCallFormsPDF.DuplicatedByTheTech;
		testStr = controllerPreCallFormsPDF.ExternalTraumaToEngineComponents;
		testStr = controllerPreCallFormsPDF.ForceGoodwillCoverage;
		testStr = controllerPreCallFormsPDF.HasTECHLINEBeenContacted;
		testStr = controllerPreCallFormsPDF.HasTechnicianPrintedOutBatteryInfoSheet;
		testStr = controllerPreCallFormsPDF.isApprovalStatusChanged;
		testStr = controllerPreCallFormsPDF.IsBatteryShowingLessThan8Bars;
		testStr = controllerPreCallFormsPDF.IsDTCPO746Stored;
		testStr = controllerPreCallFormsPDF.isSystemUpdate;
		testStr = controllerPreCallFormsPDF.IsTechnicianLEAFCertified;
		testStr = controllerPreCallFormsPDF.IsTheCoolantOilMixed;
		testStr = controllerPreCallFormsPDF.IsTheVehicleAtTheDealership;
		testStr = controllerPreCallFormsPDF.IsThisAccidentRelated;
		testStr = controllerPreCallFormsPDF.isVCANUpdate;
		testStr = controllerPreCallFormsPDF.PartsAtCost;
		testStr = controllerPreCallFormsPDF.PostDTCCheckWasC3ManuallySynced;
		testStr = controllerPreCallFormsPDF.TraumaToTheCylinderHeadValveTrain;

		System.assertNotEquals(controllerPreCallFormsPDF.currentTime, null);
	}

	// HELPERS-----------------------------------------------------------//
	private static Warranty_Case__c  setWarrantyCase() {
		//retrieving Warranty_Case__c record type
		List<RecordType> rt = Database.query('SELECT Id, Name FROM RecordType WHERE Name=: warrantyCaseRecordTypeName');
		//creation of Warranty_Case__c record
		Date repair_Work_Order_Open_Date = Date.today();
		Account testAccount = setDealerAccount();
        Vehicle__c testVehicle = setVehicle();
		Warranty_Case__c warrantyCaseRecord = New Warranty_Case__c (RecordTypeId = rt[0].Id, Customer_Name__c = 'test', Approval_Status__c = 'Pending',
                                                                    Requestor_s_Name__c = 'testReq', Vehicle_Mileage__c = 120, Repair_Work_Order_Open_Date__c = repair_Work_Order_Open_Date, 
																	When_was_TECH_LINE_contacted__c = repair_Work_Order_Open_Date, Vehicle__c = testVehicle.Id, Dealer__c = testAccount.Id, 
																	Job_Line_Number__c = '123', Repair_Work_Order__c = '123', Parts_at_Cost__c = 'true', Force_Goodwill_Coverage__c = 'true'
                                                                    ); 
		insert warrantyCaseRecord;
		return warrantyCaseRecord;
	}

	private static Account  setDealerAccount() {
		//retrieving Dealer record type
		List<RecordType> rt = Database.query('SELECT Id, Name FROM RecordType WHERE Name=:dealerRecordTypeName');
		//creation of Dealer Account
		Account dealer = new Account(RecordTypeId = rt[0].Id, Dealer_Code__c = '123', Name = 'TestDealer');

		insert dealer;
		return dealer;
	}

	private static Vehicle__c  setVehicle() {
		//retrieving Dealer record type
		String sobjectTypeVeh = 'Vehicle__c'; 
		List<RecordType> rt = Database.query('SELECT Id, Name FROM RecordType WHERE Name=: nissanRecordTypeName AND SobjectType=: sobjectTypeVeh');
		//creation of Vehicle
		Vehicle__c veh = new Vehicle__c(RecordTypeId = rt[0].Id, Vehicle_identification_Number__c = '11111111111111111');

		insert veh;
		return veh;
	}

 }