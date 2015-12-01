/**********************************************************************
Name: Controller_virtualacademycomp
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Controller Class virtualacademycomp VF page.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         03/26/2014 Created
***********************************************************************/
public class Controller_virtualacademycomp {

    public List<TechlineVirtualAcademy__c> indvas {get;set;}
    public string dealercode {get;set;}
    public string lastname {get;set;}
    public string fullname {get;set;}
    public boolean showindvrecords {get;set;}
    public String error {get;set;}
    public Boolean showerror {get;set;}
        
    public Controller_virtualacademycomp(){
    showindvrecords = false;
    showerror = false;
    error='';
    }
    
    public void techrecord(){
    showerror = false;
      
      List<String> specialties = New List<String>();          
       specialties.add('SCOPE Engine Specialist');
       specialties.add('SCOPE Driveline Specialist');
       specialties.add('SCOPE Chassis Specialist');
       specialties.add('SCOPE Electrical Specialist');
       specialties.add('KEI Engine Specialist');
       specialties.add('KEI Driveline Specialist');
       specialties.add('KEI Chassis Specialist');
       specialties.add('KEI Electrical Specialist');
       specialties.add('DFRT Nissan (OBDII Cert)');
       specialties.add('DFRT Infiniti (OBDII Cert)');
       specialties.add('ASE L1');
       specialties.add('Nissan Hybrid Specialist');
       specialties.add('GT-R Specialist');
       specialties.add('EV Specialist');
       specialties.add('Infiniti Hybrid Specialist');
               
    List<String> profs = new List<String>();
        profs.add('Trainee');
        profs.add('Infiniti KEI Master');
        profs.add('Infiniti KEI Senior Specialist');
        profs.add('Infiniti KEI Specialist');
        profs.add('Infiniti Technician');
        profs.add('Nissan SCOPE Master');
        profs.add('Nissan SCOPE Senior Specialist');
        profs.add('Nissan SCOPE Specialist');
        profs.add('Nissan SCOPE Technician');
        
       
      if(dealercode == '' || dealercode == null){
        error = 'Please enter a Dealer Code';
       showerror = true;
      } 
      
      if(lastname != '' && lastname != null){
       indvas = [select Id, Full_Name__c, Dealer_Code__c, Last_Name__c, Dealer_Name__c, Specialty__c, 
                Certification_Level__c, Technician_Proficiency_Level__c, DealerResourceId_Role__c, 
                (Select Id, Specialty__c from Specialties__r where Specialty__c in :specialties Order by Specialty__c)  
                from TechlineVirtualAcademy__c where Dealer_Code__c = :dealercode and Last_Name__c = :lastname 
                and Technician_Proficiency_Level__c in :profs Order by Last_Name__c];
                }
                
      if(lastname == '' || lastname == null){ 
       indvas = [select Id, Full_Name__c, Dealer_Code__c, Last_Name__c, Dealer_Name__c, Specialty__c, 
                Certification_Level__c, Technician_Proficiency_Level__c, DealerResourceId_Role__c, 
                (Select Id, Specialty__c from Specialties__r where Specialty__c in :specialties Order by Specialty__c) 
                from TechlineVirtualAcademy__c where Dealer_Code__c = :dealercode 
                and Technician_Proficiency_Level__c in :profs Order by Last_Name__c];
                }         
   
      if(dealercode != '' && dealercode != null && indvas.size() > 0){
           showindvrecords = true;
           showerror = false;
       
       for(TechlineVirtualAcademy__c tva : indvas){
           
           String proflevel = tva.Technician_Proficiency_Level__c;
           if(proflevel.contains('Nissan SCOPE')){tva.Technician_Proficiency_Level__c = proflevel.replace('Nissan SCOPE ','');}   
           if(proflevel.contains('Infiniti KEI')){tva.Technician_Proficiency_Level__c = proflevel.replace('Infiniti KEI ','');}
           if(proflevel.contains('Infiniti')){tva.Technician_Proficiency_Level__c = proflevel.replace('Infiniti ','');} 
                      
               }
       
       }
        
       if(dealercode != '' && dealercode != null && indvas.size() == 0){
       error = 'No Results Found';
       showerror = true;
       }
       
       
    
    }
    
        
    public void clear(){
        showindvrecords = false;
        dealercode='';
        lastname='';
        showerror = false;
        error='';
        }
        
        
        




}