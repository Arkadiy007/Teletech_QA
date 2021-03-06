//Generated by wsdl2apex

public class Nna360RepairOrderServiceSoap {
    public class ArrayOfPart {
        public String[] Part;
        private String[] Part_type_info = new String[]{'Part','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','string','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'Part'};
    }
    public class ArrayOfOpCode {
        public Nna360RepairOrderServiceSoap.OpCode[] OpCode;
        private String[] OpCode_type_info = new String[]{'OpCode','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','OpCode','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'OpCode'};
    }
    public class ArrayOfRepairOrder {
        public Nna360RepairOrderServiceSoap.RepairOrder[] RepairOrder;
        private String[] RepairOrder_type_info = new String[]{'RepairOrder','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','RepairOrder','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'RepairOrder'};
    }
    public class StatusCheckResponse_element {
        public Nna360RepairOrderServiceSoap.Response StatusCheckResult;
        private String[] StatusCheckResult_type_info = new String[]{'StatusCheckResult','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','Response','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'StatusCheckResult'};
    }
    public class Response {
        public String Message;
        public String status;
        private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] status_att_info = new String[]{'status'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'Message'};
    }
    public class ArrayOfString {
        public String[] string_x;
        private String[] string_x_type_info = new String[]{'string','http://www.w3.org/2001/XMLSchema','string','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'string_x'};
    }
    public class ServiceAuthHeader {
        public String UserName;
        public String Password;
        private String[] UserName_type_info = new String[]{'UserName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'UserName','Password'};
    }
    public class ArrayOfVehicle {
        public Nna360RepairOrderServiceSoap.Vehicle[] Vehicle;
        private String[] Vehicle_type_info = new String[]{'Vehicle','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','Vehicle','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'Vehicle'};
    }
    public class StatusCheck_element {
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class RepairOrderResponse {
        public String Message;
        public Nna360RepairOrderServiceSoap.ArrayOfVehicle Vehicles;
        public String Status;
        private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Vehicles_type_info = new String[]{'Vehicles','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','ArrayOfVehicle','0','1','false'};
        private String[] Status_att_info = new String[]{'Status'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'Message','Vehicles'};
    }
    public class RepairOrderSoap {
        public String endpoint_x = System.label.Nna360_EndPoint_RepairOrder; //'https://nissanstage.loyaltysite.com/CIEServices/NNA360s/vehicle/repairorder.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public Nna360RepairOrderServiceSoap.ServiceAuthHeader ServiceAuthHeader;
        private String ServiceAuthHeader_hns = 'ServiceAuthHeader=https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle';
        private String[] ns_map_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle', 'Nna360RepairOrderServiceSoap'};
        public Nna360RepairOrderServiceSoap.Response StatusCheck() {
            Nna360RepairOrderServiceSoap.StatusCheck_element request_x = new Nna360RepairOrderServiceSoap.StatusCheck_element();
            Nna360RepairOrderServiceSoap.StatusCheckResponse_element response_x;
            Map<String, Nna360RepairOrderServiceSoap.StatusCheckResponse_element> response_map_x = new Map<String, Nna360RepairOrderServiceSoap.StatusCheckResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle/StatusCheck',
              'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle',
              'StatusCheck',
              'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle',
              'StatusCheckResponse',
              'Nna360RepairOrderServiceSoap.StatusCheckResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.StatusCheckResult;
        }
        public Nna360RepairOrderServiceSoap.RepairOrderResponse GetRepairOrdersByVIN(Nna360RepairOrderServiceSoap.ArrayOfString vins) {
            Nna360RepairOrderServiceSoap.GetRepairOrdersByVIN_element request_x = new Nna360RepairOrderServiceSoap.GetRepairOrdersByVIN_element();
            Nna360RepairOrderServiceSoap.GetRepairOrdersByVINResponse_element response_x;
            request_x.vins = vins;
            Map<String, Nna360RepairOrderServiceSoap.GetRepairOrdersByVINResponse_element> response_map_x = new Map<String, Nna360RepairOrderServiceSoap.GetRepairOrdersByVINResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle/GetRepairOrdersByVIN',
              'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle',
              'GetRepairOrdersByVIN',
              'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle',
              'GetRepairOrdersByVINResponse',
              'Nna360RepairOrderServiceSoap.GetRepairOrdersByVINResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RepairOrderResponse;
        }
    }
    public class OpCode {
    	public String OpCodeDesc;
        public Nna360RepairOrderServiceSoap.ArrayOfPart Parts;
        public String Code;
        public String TechNum;
        public String PayType;
        private String[] OpCodeDesc_type_info = new String[]{'OpCodeDesc','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','ArrayOfPart','0','1','false'};
        private String[] Parts_type_info = new String[]{'Parts','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','string','0','1','false'};
        private String[] Code_att_info = new String[]{'Code'};
        private String[] TechNum_att_info = new String[]{'TechNum'};
        private String[] PayType_att_info = new String[]{'PayType'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'Parts'};
    }
    public class RepairOrder {
        public String ContactId;
        public String CDIID;
        public String FirstName;
        public String MiddleInit;
        public String LastName;
        public String Line1;
        public String Line2;
        public String City;
        public String State;
        public String Zip;
        public String HomePhone;
        public String WorkPhone;
        public String EmailAddress;
        public String DomainId;
        public String CloseDate;
        public String Mileage;
        public Decimal PartsAmount;
        public Decimal LaborAmount;
        public Decimal TotalAmount;
        public String CustNameType;
        public Decimal CustLaborAmount;
        public Decimal CustPartsAmount;
        public Decimal CustMiscAmount;
        public Decimal WarrantyLaborAmount;
        public Decimal WarrantyPartsAmount;
        public Decimal WarrantyMiscAmount;
        public Decimal InternalLaborAmount;
        public Decimal InternalPartsAmount;
        public Decimal InternalMiscAmount;
        public Nna360RepairOrderServiceSoap.ArrayOfOpCode Details;
        public String Number_x;
        public String DealerCode;
        private String[] ContactId_type_info = new String[]{'ContactId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CDIID_type_info = new String[]{'CDIID','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FirstName_type_info = new String[]{'FirstName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MiddleInit_type_info = new String[]{'MiddleInit','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LastName_type_info = new String[]{'LastName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Line1_type_info = new String[]{'Line1','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Line2_type_info = new String[]{'Line2','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] City_type_info = new String[]{'City','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] State_type_info = new String[]{'State','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Zip_type_info = new String[]{'Zip','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HomePhone_type_info = new String[]{'HomePhone','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] WorkPhone_type_info = new String[]{'WorkPhone','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DomainId_type_info = new String[]{'DomainId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CloseDate_type_info = new String[]{'CloseDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Mileage_type_info = new String[]{'Mileage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PartsAmount_type_info = new String[]{'PartsAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] LaborAmount_type_info = new String[]{'LaborAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TotalAmount_type_info = new String[]{'TotalAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] CustNameType_type_info = new String[]{'CustNameType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustLaborAmount_type_info = new String[]{'CustLaborAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] CustPartsAmount_type_info = new String[]{'CustPartsAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] CustMiscAmount_type_info = new String[]{'CustMiscAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] WarrantyLaborAmount_type_info = new String[]{'WarrantyLaborAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] WarrantyPartsAmount_type_info = new String[]{'WarrantyPartsAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] WarrantyMiscAmount_type_info = new String[]{'WarrantyMiscAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] InternalLaborAmount_type_info = new String[]{'InternalLaborAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] InternalPartsAmount_type_info = new String[]{'InternalPartsAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] InternalMiscAmount_type_info = new String[]{'InternalMiscAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Details_type_info = new String[]{'Details','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','ArrayOfOpCode','0','1','false'};
        private String[] Number_x_att_info = new String[]{'Number'};
        private String[] DealerCode_att_info = new String[]{'DealerCode'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'ContactId','CDIID','FirstName','MiddleInit','LastName','Line1','Line2','City','State','Zip','HomePhone','WorkPhone','EmailAddress','DomainId','CloseDate','Mileage','PartsAmount','LaborAmount','TotalAmount','CustNameType','CustLaborAmount','CustPartsAmount','CustMiscAmount','WarrantyLaborAmount','WarrantyPartsAmount','WarrantyMiscAmount','InternalLaborAmount','InternalPartsAmount','InternalMiscAmount','Details'};
    }
    public class GetRepairOrdersByVINResponse_element {
        public Nna360RepairOrderServiceSoap.RepairOrderResponse RepairOrderResponse;
        private String[] RepairOrderResponse_type_info = new String[]{'RepairOrderResponse','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','RepairOrderResponse','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'RepairOrderResponse'};
    }
    /*public class Part {
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{};
    }*/
    public class GetRepairOrdersByVIN_element {
        public Nna360RepairOrderServiceSoap.ArrayOfString vins;
        private String[] vins_type_info = new String[]{'vins','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'vins'};
    }
    public class Vehicle {
        public Nna360RepairOrderServiceSoap.ArrayOfRepairOrder RepairOrders;
        public String VIN;
        private String[] RepairOrders_type_info = new String[]{'RepairOrders','https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','ArrayOfRepairOrder','0','1','false'};
        private String[] VIN_att_info = new String[]{'VIN'};
        private String[] apex_schema_type_info = new String[]{'https://nnainfowebservices.com/CIEServices/NNA360s/Vehicle','true','false'};
        private String[] field_order_type_info = new String[]{'RepairOrders'};
    }
}