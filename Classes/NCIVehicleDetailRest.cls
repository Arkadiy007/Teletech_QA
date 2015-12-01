/*
  Page Title: NCIVehicleDetailRest
  Author: Aaron Bessey
  Create Date: 3/23/2015
  Last Update: 3/23/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/

@RestResource(urlMapping = '/casl/api/v1/vehicle/*')
global class NCIVehicleDetailRest {
    global class VehicleDetailHandler
    {
        public Long requestId { get; set; }
        public String status { get; set; }
        public String type { get; set; }
        public VehicleHandler vehicle { get; set; }
        public ResultHandler result { get; set; }

        public VehicleDetailHandler()
        {
            vehicle = new VehicleHandler();
            result = new ResultHandler();
        }
        public VehicleDetailHandler(Long iRID, String sStatus, String sType)
        {
            requestId = iRID;
            status = sStatus;
            type = sType;
            vehicle = new VehicleHandler();
            result = new ResultHandler();
        }
    }

    global class VehicleHandler
    {
        public String vinCode { get; set; }
        public String make { get; set; }
        public Integer modelYear { get; set; }
        public String seriesCode { get; set; }
        public String seriesDesc { get; set; }
        public String modelCode { get; set; }
        public String modelDesc { get; set; }
        public String optionGroupCode { get; set; }
        public String optionGroupDesc { get; set; }
        public String colourCode { get; set; }
        public String colourDesc { get; set; }
        public String trimCode { get; set; }
        public String eimCode { get; set; }
        public String vehicleTypeName { get; set; }
        public String vehicleTypeDesc { get; set; }
        public Date manufactureDate { get; set; }
        public String wholesaleTypeCode { get; set; }
        public String wholesaleTypeDesc { get; set; }
        public Date wholesaleDate { get; set; }
        public Date warrantyStartDate { get; set; }
        public Decimal msrpAmount { get; set; }
        public String originalRetailTypeCode { get; set; }
        public String originalRetailTypeDesc { get; set; }
        public String manufacturerPlantCode { get; set; }
        public String manufacturerPlantDesc { get; set; }
        public String bodyStyleCode { get; set; }
        public String bodyStyleDesc { get; set; }
        public String vehicleBodyTypeCode {get; set;}
        public String emissionsTypeCode { get; set; }
        public String emissionsTypeDesc { get; set; }
        public String modelOptionGroupDesc {get; set;}
        public String transmissionTypeCode { get; set; }
        public String vehicleEngineCylinderCount {get; set;}
        public String transmissionTypeDesc { get; set; }
    }

    global class ResultHandler
    {
        public integer code { get; set; }
        public string message { get; set; }
    }

}