public with sharing class VehicleRepairOrderSectionController {

    
    private integer iCounter = 0; 
    //sets the page size or number of rows
    private integer iList_size = Integer.valueOf(Label.Repair_Order_Section_Size);
    
    Set<String> VINs = new Set<String>();
    public List<ServiceHistoryWrapHelper> SRHs {get; set;}
    public Vehicle__c vehObj {get; set;}
    public integer iTotal_size {get;set;} 
    public boolean disablePrev {get; set;}
    public boolean disableNext {get; set;}
    public Boolean searchAll {get; set;}
    
     // Detail Page Params
    public Service_Repair_History__c servInfo{ get; set; }
    public boolean isDetail {get; set;}
    public Integer servRowNo {get; set;}
    

    public VehicleRepairOrderSectionController(ApexPages.StandardController controller) {
        isDetail = false;
        servInfo = new Service_Repair_History__c();
        
        SRHs = new List<ServiceHistoryWrapHelper>();
        Vehicle__c veh = (Vehicle__c)controller.getRecord();
        
        if(veh != null){        
            vehObj = [Select Id, Name from Vehicle__c where Id =: veh.Id];
        }
    }
    
    public void onLoad(){      
      loadData();
    } 
    
    public void loadData(){
        searchAll = false;
        VINs.add(vehObj.Name);
        
        try{
        SRHs = VehicleWarrantyIntegrationUtility.repairOrderCallout(VINs, SRHs);
        
        System.debug('Service History:::'+SRHs);
       
       if(SRHs != null && !SRHs.isEmpty()) { 
        iTotal_size = SRHs.size();
       
        iList_size = (iTotal_size > iList_size) ? iList_size : iTotal_size;

        //if (iList_size == iTotal_size) { iList_size = 5;}
        
        disablePrev = !(iCounter > 0);
        disableNext = !(iCounter + iList_size < iTotal_size);
       }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No records found for Repair Order History'));
       }
       if(ApexPages.CurrentPage().getParameters().containskey('searchAll') 
               && ApexPages.CurrentPage().getParameters().get('searchAll') == 'Yes'){
                   searchAll = true; 
       }
       if(ApexPages.currentPage().getParameters().get('isDetail') == 'true'){
            isDetail = true;
            
            if(ApexPages.currentPage().getParameters().get('line') != null ){            
                servRowNo = Integer.valueOf(ApexPages.currentPage().getParameters().get('line')); 
                servInfo = SRHs.get(servRowNo - 1).servicehistory;
                System.debug('servInfo:::'+servInfo);
            }
        }
       
       }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured with Claims Coverage Service. Please contact your administator.'));
       }
       
    }
    
    public List<ServiceHistoryWrapHelper> lstServiceHistories
    {
        get{
            lstServiceHistories = constructlstHistories();            
            return lstServiceHistories;
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
     * Return type : list <ServiceHistoryWrapHelper> 
     * Paramater : None 
     */
    private list<ServiceHistoryWrapHelper> constructlstHistories()
    {
        list <ServiceHistoryWrapHelper> listserHist = new list <ServiceHistoryWrapHelper>();
        integer iIntLoop = 0, iMax_limit = 0; 
        
        if(searchAll){
            for(ServiceHistoryWrapHelper servInfo : SRHs){
                listserHist.add(servInfo);
            }
            
            return listserHist;
        }
        
        if(SRHs != null && SRHs.size() > 0){
        iMax_limit = ((iCounter + iList_size) > iTotal_size) ? iTotal_size : (iCounter + iList_size);
        
        if(iCounter == iMax_limit){
            iCounter -= iList_size;
        }
        
        for (iIntLoop = iCounter; iIntLoop < iMax_limit; iIntLoop++) 
        {
            listserHist.add(SRHs.get(iIntLoop));
        }
        }
        return listserHist;
    }
    
}