/**********************************************************************
  Name: Controller_PreCall_Forms_For_Attachment
  Copyright ?? notice: Nissan Motor Company
  ======================================================
  Purpose:
  Controller of PreCall_Forms_PDF_Engine, PreCall_Forms_PDF_CVT, PreCall_Forms_PDF_LEAF pages

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Arkadiy Sychev 02/19/2015 Created
  ***********************************************************************/
public class Controller_PreCall_Forms_PDF { 
	public List<Attachment> attachmentsList {get; set;}
	public Id warrantyCaseId {get; set;}
	private ApexPages.StandardController controller;
	private Warranty_Case__c warrantyCase;
	public String currentTime {get; set;}
	private List<Warranty_Case__c> warrntyCaseWithFields;

	public String repairWorkOrderOpenDate {get; set;}
    public String techLineContactDate {get; set;}
	public String anyAdditionalDetails {get; set;}
	public String vin {get;	set;}

	// Variables for the Checkbox fields of Warranty Case record
	public String AnyCVTfluidleakspresent {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Any_CVT_fluid_leaks_present__c);
		} set;}
	public String AnyOilLeaksPresent {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Any_Oil_Leaks_Present__c);
		} set;}
	public String AreThereAnyCoolantLeaks {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Are_there_any_coolant_leaks__c);
		} set;}
	public String BulletinRelatedToThisReport {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Bulletin_related_to_this_report__c);
		} set;}
	public String CoolantPressureTestPerformed {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Coolant_Pressure_Test_performed__c);
		} set;}
	public String DiagnosticTroubleCodesPresent {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Diagnostic_Trouble_Codes_present__c);
		} set;}
	public String DidTheVehicleOverheat {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Did_the_Vehicle_overheat__c);
		} set;}
	public String DoesTechnicianHaveAappropriateHVTools {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].DoesTechnicianHaveAappropriateHVTools__c);
		} set;}
	public String DuplicatedByTheTech {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Duplicated_by_the_Tech__c);
		} set;}
	public String ExternalTraumaToEngineComponents {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].External_trauma_to_engine_components__c);
		} set;}
	public String ForceGoodwillCoverage {get {
			return retrieveYesNoValue(Boolean.valueOf(warrntyCaseWithFields[0].Force_Goodwill_Coverage__c));
		} set;}
	public String HasTECHLINEBeenContacted {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Has_TECH_LINE_been_contacted__c);
		} set;}
	public String HasTechnicianPrintedOutBatteryInfoSheet {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].HasTechnicianPrintedOutBatteryInfoSheet__c);
		} set;}
	public String isApprovalStatusChanged {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].isApprovalStatusChanged__c);
		} set;}
	public String IsBatteryShowingLessThan8Bars {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Is_Battery_Showing_Less_Than_8_Bars__c);
		} set;}
	public String IsDTCPO746Stored {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Is_DTC_PO746_Stored__c);
		} set;}
	public String isSystemUpdate {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].isSystemUpdate__c);
		} set;}
	public String IsTechnicianLEAFCertified {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Is_Technician_LEAF_Certified__c);
		} set;}
	public String IsTheCoolantOilMixed {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Is_the_coolant_oil_mixed__c);
		} set;}
	public String IsTheVehicleAtTheDealership {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Is_The_Vehicle_at_The_Dealership__c);
		} set;}
	public String IsThisAccidentRelated {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].Is_This_Accident_Related__c);
		} set;}
	public String isVCANUpdate {get {
			return retrieveYesNoValue(warrntyCaseWithFields[0].isVCANUpdate__c);
		} set;}
	public String PartsAtCost {get {
			return retrieveYesNoValue(Boolean.valueOf(warrntyCaseWithFields[0].Parts_at_Cost__c));
		} set;}
	public String PostDTCCheckWasC3ManuallySynced {get {
			return retrieveYesNoValue(Boolean.valueOf(warrntyCaseWithFields[0].Post_DTC_check_was_C3_manually_synced__c));
		} set;}
	public String TraumaToTheCylinderHeadValveTrain {get {
			return retrieveYesNoValue(Boolean.valueOf(warrntyCaseWithFields[0].Trauma_to_the_Cylinder_Head_Valve_Train__c));
		} set;}
	
	public Controller_PreCall_Forms_PDF(ApexPages.StandardController c) {
		currentTime = DateTime.now().format('MM/dd/yyyy hh:mm:ss a',  'America/Chicago'); //GMT�06:00

		controller = c;
		warrantyCase = (Warranty_Case__c)c.getRecord();
		String cId = warrantyCase.Id;

		repairWorkOrderOpenDate = '';
		techLineContactDate = '';

		if (cId != null) {
			//Formating DateTime fields 
			warrntyCaseWithFields = Database.query('SELECT Id, When_was_TECH_LINE_contacted__c, Repair_Work_Order_Open_Date__c, Any_CVT_fluid_leaks_present__c,' +
													' Any_Oil_Leaks_Present__c , Are_there_any_coolant_leaks__c, Bulletin_related_to_this_report__c,' +
													' Coolant_Pressure_Test_performed__c, Diagnostic_Trouble_Codes_present__c, Did_the_Vehicle_overheat__c,' + 
													' DoesTechnicianHaveAappropriateHVTools__c, Duplicated_by_the_Tech__c, External_trauma_to_engine_components__c,' + 
													' Force_Goodwill_Coverage__c, Has_TECH_LINE_been_contacted__c, HasTechnicianPrintedOutBatteryInfoSheet__c,' +
													' isApprovalStatusChanged__c, Is_Battery_Showing_Less_Than_8_Bars__c, Is_DTC_PO746_Stored__c, isSystemUpdate__c,' + 
													' Is_Technician_LEAF_Certified__c, Is_the_coolant_oil_mixed__c, Is_The_Vehicle_at_The_Dealership__c, Is_This_Accident_Related__c,' +
													' isVCANUpdate__c, Parts_at_Cost__c, Post_DTC_check_was_C3_manually_synced__c, Trauma_to_the_Cylinder_Head_Valve_Train__c, ' +
													' Any_additional_details_info_diagnosis__c, Vehicle__r.Vehicle_identification_Number__c, Send_a_copy_of_this_form_to__c, Coverage_Type__c FROM Warranty_Case__c WHERE Id =: cId');
			setDateFields(warrntyCaseWithFields[0]);
			anyAdditionalDetails = warrntyCaseWithFields[0].Any_additional_details_info_diagnosis__c;
			attachmentsList = new List<Attachment>();
			attachmentsList = Database.query('SELECT Id, Name, Description FROM Attachment WHERE ParentId =: cId' );

			vin = getMaskedVin(warrntyCaseWithFields[0].Vehicle__r.Vehicle_identification_Number__c);
		} else {
			return;
		}
	}

	private void setDateFields(Warranty_Case__c warrCase) {
		if (warrCase.When_was_TECH_LINE_contacted__c != null) {
			DateTime techLineContactDateTime = warrCase.When_was_TECH_LINE_contacted__c;
			techLineContactDate = techLineContactDateTime.format('MM/dd/yyyy');
		}
		if (warrCase.Repair_Work_Order_Open_Date__c != null) {
			DateTime repairWorkOrderOpenDateTime = warrCase.Repair_Work_Order_Open_Date__c;
			repairWorkOrderOpenDate = repairWorkOrderOpenDateTime.format('MM/dd/yyyy');
		}

	}

	public String retrieveYesNoValue(Boolean fieldValue) {
		if(fieldValue != null) {
			if(fieldValue) {
				return 'Yes';
			}
			return 'No';
		}
		return null;
	}

	private String getMaskedVin(String vinValue) {
		Integer vinLength = vinValue.length();
		String str = vinValue.substring(vinLength - 8); 
		return 'XXXXXXXXX' + str;
	}
}