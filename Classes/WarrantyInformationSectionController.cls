public with sharing class WarrantyInformationSectionController {
    
    
    private integer iCounter = 0; 
    //sets the page size or number of rows
    private integer iList_size = Integer.valueOf(Label.Warranty_Information_Size);
    
    
    Set<String> VINs = new Set<String>();
    Map<Integer, Warranty_Information__c> warrantyInfoMap;    
    public List<WarrantyInformationWrapper> WRTs {get; set;}
    
    public integer iTotal_size {get;set;} 
    public boolean disablePrev {get; set;}
    public boolean disableNext {get; set;}     
    public String vehicleId {get; set;}
    public Vehicle__c vehObj {get; set;}
    public Boolean searchAll {get; set;}
    
        
    public WarrantyInformationSectionController(ApexPages.StandardController controller) {
        
       warrantyInfoMap = new Map<Integer, Warranty_Information__c>();
       WRTs = new List<WarrantyInformationWrapper>();
       Vehicle__c veh = (Vehicle__c)controller.getRecord();
       vehicleId = veh.Id;
        
       System.debug('veh:: '+veh);
        if(veh != null){
        
            vehObj = [Select Id, Name from Vehicle__c where Id =: vehicleId];
        }
    }
    
     public void onLoad(){
      
      loadData();       
       
    }
    
   
    public void loadData(){
       VINs.add(vehObj.Name);
       searchAll = false; 
       try{
       WRTs = VehicleWarrantyIntegrationUtility.warrantyCallout(VINs, warrantyInfoMap);
       System.debug('Service History:::'+WRTs);
       
       if(WRTs != null && !WRTs.isEmpty()) { 
            iTotal_size = WRTs.size();
           
            iList_size = (iTotal_size > iList_size) ? iList_size : iTotal_size;
    
            //if (iList_size == iTotal_size) { iList_size = 5;}
            
            disablePrev = !(iCounter > 0);
            disableNext = !(iCounter + iList_size < iTotal_size);
       }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No records found for Warranty Information.'));
       }
       
       if(ApexPages.CurrentPage().getParameters().containskey('searchAll') 
           && ApexPages.CurrentPage().getParameters().get('searchAll') == 'Yes'){
               searchAll = true; 
         }
       }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured with Warranty Coverage Service. Please contact your administator.'));
       }
    }
    
    public List<WarrantyInformationWrapper> lstWarranties
    {
        get{
            lstWarranties = constructlstWarranties();
            return lstWarranties;
        }
        set;
    }
    
       
    /*
     * Method Name : Beginning
     * Description : Returns the first list of the records in the response
     * Return type : PageReference
     * Paramater : None 
     */
    public PageReference Beginning() 
    { 
        //user clicked beginning        
        iCounter = 0;
        disablePrev = !(iCounter > 0);
        disableNext = !(iCounter + iList_size < iTotal_size);
        return null;
    }

    /*
     * Method Name : Previous
     * Description : Returns the Previous list of the records in the response
     * Return type : PageReference
     * Paramater : None 
     */
    public PageReference Previous() 
    { 
        //user clicked previous button      
        iCounter -= iList_size;
        disablePrev = !(iCounter > 0);
        disableNext = !(iCounter + iList_size < iTotal_size);
        return null;
    }

    /*
     * Method Name : Next
     * Description : Returns the Next list of the records in the response
     * Return type : PageReference
     * Paramater : None 
     */
    public PageReference Next() 
    { 
        //user clicked next button  
        iCounter += iList_size;
        disablePrev = !(iCounter > 0);
        disableNext = !(iCounter + iList_size < iTotal_size);
        return null;
    }

    /*
     * Method Name : End
     * Description : Returns the Last list of the records in the response
     * Return type : PageReference
     * Paramater : None 
     */
    public PageReference End() 
    { 
        //user clicked end
        iCounter = iTotal_size - math.mod(iTotal_size, iList_size);
        disablePrev = !(iCounter > 0);
        disableNext = !(iCounter + iList_size < iTotal_size);
        return null;
    } 
    
    
    /*
     * Method Name : getITotal_size
     * Description : This function is used to get the size of the date 
     * Return type : Integer
     * Paramater : None 
     */
    public Integer getITotal_size() {
        return iTotal_size;
    }

    
    /*
     * Method Name : getTotalPages
     * Description : This function is return the the total page numbers 
     * Return type : Integer
     * Paramater : None 
     */
    public Integer getTotalPages()
    {
        if(Math.mod(iTotal_size, iList_size) > 0){
        return ((iTotal_size / iList_size) +1);
        }else{
            return (iTotal_size / iList_size);
        }
    }
    
    public Integer getPageNumber()
    {
        return ((iCounter/iList_size)+1);
    }
    
    /*
     * Method Name : constructlstWarranties
     * Description : This method is used to asign values to listWrtys
     * Return type : list <WarrantyInformationWrapper> 
     * Paramater : None 
     */
    private list<WarrantyInformationWrapper> constructlstWarranties()
    {
        list <WarrantyInformationWrapper> listWrtys = new list <WarrantyInformationWrapper>();
        integer iIntLoop = 0, iMax_limit = 0; 
        
        if(searchAll){
            for(WarrantyInformationWrapper wrtyInfo : WRTs){
                listWrtys.add(wrtyInfo);
            }
            
            return listWrtys;
        }
        
        if(WRTs != null && WRTs.size() > 0){
        iMax_limit = ((iCounter + iList_size) > iTotal_size) ? iTotal_size : (iCounter + iList_size);
        
        if(iCounter == iMax_limit){
            iCounter -= iList_size;
        }
        
        for (iIntLoop = iCounter; iIntLoop < iMax_limit; iIntLoop++) 
        {
            listWrtys.add(WRTs.get(iIntLoop));
        }
        }
        return listWrtys;
    }
    

}