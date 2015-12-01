public class Text_Util {
    public static final Integer LINE_LENGTH = 78;
    public static final Integer MAX_LINES = 30;
    public static final String ZCA_DATE_FORMAT = 'yyyyMMdd';
    public static final String ZCA_TIME_FORMAT = 'HHmmss';
    public static final String[] falseString = new String[] {'N', '0', 'FALSE', 'NO'};
    public static final String[] trueString = new String[] {'Y', '1', 'TRUE', 'YES'};
    public static final Pattern EMAIL_PATTERN = Pattern.compile('^[_a-zA-Z0-9-]+(\\.([_a-zA-Z0-9-]+))*@[a-zA-Z0-9-]+(\\.([a-zA-Z0-9-]+))*\\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))$');
    
    /* Convert a list of String lines into a single String. */
    public static String combineStrings(List<String> lines) {
        String combinedString = '';
        
        // Loop through the Strings and construct a String with the line number and
        // text for each String on a separate line.
        for(String line: lines) {
            combinedString = combinedString + line +'\n';
        }
        
        return combinedString;
    }
    
    /* Convert a list of String lines into a single String and number each line starting at a
       certain index. */
    public static String combineStrings(List<String> lines, Integer lineNumber) {
        String combinedString = '';
        
        // Loop through the Strings and construct a String with the line number and
        // text for each String on a separate line.
        for(String line: lines) {
            combinedString = combinedString + lineNumber++ + '. ' + line +'\n';
        }
        
        return combinedString;
    }
    
    /* Call splitString method with the default LINE_LENGTH */
    public static List<String> splitString(String toSplit) {
        return splitString(toSplit, LINE_LENGTH);
    }

    /* Convert a string into a List of lines. The String is first broken apart on newline characters 
       so that a newline always results in a new line.  Then if any of the Strings resulting from
       this are longer than the LINE_LENGTH, they are broken down further to fit in that size. */
    public static List<String> splitString(String toSplit, Integer lineLength) {
        // Initialize variables
        List<String> newLines = new List<String>();
        String singleLine;

        if (toSplit != null) {
            // Split the input String on the newline character
            List<String> lines = toSplit.split('\n');
    
            // For each portion of the full String after being split by newlines, create
            // a String for each group of LINE_LENGTH characters.  If the
            // String is very long, it will be split into many comment lines.  If it is
            // less than LINE_LENGTH in size, it will be put into a single comment line.  
            for(String line: lines) {
                // Handle splitting while the line is still longer than LINE_LENGTH,
                // removing the split characters from the line each time through the loop
                // to shorten it.
                while (line.length() > LINE_LENGTH) {
                    singleLine = line.substring(0, LINE_LENGTH);
                    newLines.add(singleLine);
                    line = line.substring(LINE_LENGTH);
                }
                
                // Handle the last portion of the line which is now under LINE_LENGTH in size.
                singleLine = line;
                newLines.add(singleLine);
            }
        }        
        return newLines;
    }
    
    public static String getFormattedDate(Date d) {
        String returnDate = null;
        if (d != null) {
            Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            returnDate = dt.format(ZCA_DATE_FORMAT);
        }
        return returnDate;
    }

    public static String getFormattedDateTime(DateTime d) {
        String returnDate = null;
        if (d != null) {
            returnDate = d.format(ZCA_DATE_FORMAT);
        }
        return returnDate;
    }
    
    public static String getFormattedTime(DateTime d) {
        String returnTime = null;
        if (d != null) {
            returnTime = d.format(ZCA_TIME_FORMAT);
        }
        return returnTime;
    }
    
    //date formatted in YYYY-MM-DD
    public static Date CCYYMMDDtoDate(String CCYYMMDD) {
        if(CCYYMMDD == null || CCYYMMDD.length() < 10)
            return null;
        
        try {
            Integer CCYY = Integer.valueOf(CCYYMMDD.substring(0, 4));
            Integer MM = Integer.valueOf(CCYYMMDD.substring(5, 7));
            Integer DD = Integer.valueOf(CCYYMMDD.substring(8, 10));
            if (CCYY <= 1800)
                return null;
            
            return Date.newInstance(CCYY, MM, DD);
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }

    //date formatted in YYYYMMDD
    public static Date CCYYMMDDNoDashesToDate(String CCYYMMDD) {
        if(CCYYMMDD == null || CCYYMMDD.length() < 8)
            return null;
        
        try {
            Integer CCYY = Integer.valueOf(CCYYMMDD.substring(0, 4));
            Integer MM = Integer.valueOf(CCYYMMDD.substring(4, 6));
            Integer DD = Integer.valueOf(CCYYMMDD.substring(6, 8));
            if (CCYY <= 1800)
                return null;
            
            return Date.newInstance(CCYY, MM, DD);
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }
    
    //date formatted in MM/DD/YYYY
    public static Date MMDDCCYYtoDate(String MMDDCCYY) {
        if(MMDDCCYY == null || MMDDCCYY.length() < 8)
            return null;
        
        try {
            String[] MDY = MMDDCCYY.split(' ')[0].split('/');
            if (MDY.size() == 3) {
                Integer M = Integer.valueOf(MDY[0]);
                Integer D = Integer.valueOf(MDY[1]);
                Integer Y = Integer.valueOf(MDY[2]);
                return Date.newInstance(Y, M, D);
            }
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }

    //date formatted in MMDDYY
    public static Date MMDDYYtoDate(String MMDDYY) {
        if(MMDDYY == null || MMDDYY.length() < 6)
            return null;
        
        try {
            Integer YY = Integer.valueOf(MMDDYY.substring(4, 6));
            Integer MM = Integer.valueOf(MMDDYY.substring(0, 2));
            Integer DD = Integer.valueOf(MMDDYY.substring(2, 4));
            YY = YY + 2000;
            
            return Date.newInstance(YY, MM, DD);
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }

    public static Boolean BooleanLookup(String input, Boolean defaultValue) {
        if (input == null)
            return defaultValue;
        
        for (String s : trueString) {
            if (input.equalsIgnoreCase(s)) 
                return true;
        }
        
        for (String s : falseString) {
            if (input.equalsIgnoreCase(s)) 
                return false;
        }
        
        return defaultValue;
    }
    
    public static String validatePhone(String input) {
        return input == '0000000000' ? null : input;
    }
    
    public static String valueConcatenation(String source, String target) {
        if (target == null || target == '')
            return source;
        else
            return target + ', ' + source;
    }
    
    public static String valueConcatenation_Delim(String line1, String line2, String delimiter) {
        if (line1 == null || line1 == '') {
            if (line2 == null || line2 == '') 
                return null;
            else 
                return line2;
        } else {
            if (line2 == null || line2 == '') 
                return line1;
            else 
                return line1 + delimiter + line2;
        }
    }
        
    public static String toValidEmail(String emailAddr) {
        String retVal = null;
        if( null != emailAddr && emailAddr.length() > 0) {
            if (EMAIL_PATTERN.matcher(emailAddr).matches())
                retVal = emailAddr;
        }
        
        return retVal;
    }
    
    //silence exception
    public static Decimal DecimalValueOf(String input) {
        if (input == null)
            return null;
        
        try {
            return Decimal.valueOf(input);
        } catch (TypeException ex) {
            System.Debug(ex.getMessage());
        }
        return null;
    }
    
    //date formatted in YYYY-MM-DD
    public static DateTime CCYYMMDDtoDateTime(String CCYYMMDD) {
        System.Debug('******* CCYYMMDD ' + CCYYMMDD);
        if(CCYYMMDD == null || CCYYMMDD.length() < 10)
            return null;
        
        try {
            Integer CCYY = Integer.valueOf(CCYYMMDD.substring(0, 4));
            Integer MM = Integer.valueOf(CCYYMMDD.substring(5, 7));
            Integer DD = Integer.valueOf(CCYYMMDD.substring(8, 10));
            if (CCYY <= 1800)
                return null;
            
            System.Debug('******* CCYYMMDD ' + CCYY + ', ' + MM + ', ' + DD);
            return DateTime.newInstance(CCYY, MM, DD, 0, 0, 0);
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }

    //date formatted in YYYY-MM-DD HH:MI:SS
    public static DateTime CCYYMMDDHHMISStoDateTime(String CCYYMMDDHHMISS) {
        System.Debug('******* CCYYMMDDHHMISS ' + CCYYMMDDHHMISS);
        if(CCYYMMDDHHMISS == null || CCYYMMDDHHMISS.length() < 19)
            return null;
        
        try {
            Integer CCYY = Integer.valueOf(CCYYMMDDHHMISS.substring(0, 4));
            Integer MM = Integer.valueOf(CCYYMMDDHHMISS.substring(5, 7));
            Integer DD = Integer.valueOf(CCYYMMDDHHMISS.substring(8, 10));
            Integer HH = Integer.valueOf(CCYYMMDDHHMISS.substring(11,13));
            Integer MI = Integer.valueOf(CCYYMMDDHHMISS.substring(14,16));
            Integer SS = Integer.valueOf(CCYYMMDDHHMISS.substring(17,19));
            if (CCYY <= 1800)
                return null;
            
            System.Debug('******* CCYYMMDDHHMISS ' + CCYY + ', ' + MM + ', ' + DD + ', ' + HH + ', ' + MI + ', ' + SS);
            return DateTime.newInstance(CCYY, MM, DD, HH, MI, SS);
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }

    //date formatted in YYYYMMDD
    public static DateTime CCYYMMDDNoDashesToDateTime(String CCYYMMDD) {
        System.Debug('******* CCYYMMDD ' + CCYYMMDD);
        if(CCYYMMDD == null || CCYYMMDD.length() < 8)
            return null;
        
        try {
            Integer CCYY = Integer.valueOf(CCYYMMDD.substring(0, 4));
            Integer MM = Integer.valueOf(CCYYMMDD.substring(4, 6));
            Integer DD = Integer.valueOf(CCYYMMDD.substring(6, 8));
            if (CCYY <= 1800)
                return null;
            
            System.Debug('******* CCYYMMDD ' + CCYY + ', ' + MM + ', ' + DD);
            return DateTime.newInstance(CCYY, MM, DD, 0, 0, 0);
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }

    //date formatted in MM/DD/YYYY
    public static DateTime MMDDCCYYtoDateTime(String MMDDCCYY) {
        System.Debug('******* MMDDCCYY ' + MMDDCCYY);
        if(MMDDCCYY == null || MMDDCCYY.length() < 8)
            return null;
        
        try {
            String[] MDY = MMDDCCYY.split(' ')[0].split('/');
            if (MDY.size() == 3) {
                Integer M = Integer.valueOf(MDY[0]);
                Integer D = Integer.valueOf(MDY[1]);
                Integer Y = Integer.valueOf(MDY[2]);
                
                System.Debug('******* CCYYMMDD ' + Y + ', ' + M + ', ' + D);
                return DateTime.newInstance(Y, M, D, 0, 0, 0);
            }
        } catch (Exception e){
            System.Debug(e.getMessage());
        }
        
        return null;
    }

    public static Map<String, ID> getDealderIDMap(List<String> dealerCodes) {
        Map<String, ID> dealerMap = new Map<String, ID>();
        if (dealerCodes.size() > 0) {
            for (Account dealer : [Select Id, Dealer_Code__c From Account WHERE RecordType.Name =: System.Label.AccRTDealer and Dealer_Code__c in: dealerCodes]) {
                if (!dealerMap.containsKey(dealer.Dealer_Code__c))
                    dealerMap.put(dealer.Dealer_Code__c, dealer.ID);
            }
        }
        
        return dealerMap;
    }
    
    public static Map<String, ID> getVehicleIDMap(List<String> inputVINs) {
        Map<String, ID> vehicleMap = new Map<String, ID>();
        if (inputVINs.size() > 0) {
            for (Vehicle__c vehicle : [Select Id, Vehicle_identification_Number__c From Vehicle__c Where Vehicle_identification_Number__c in: inputVINs]) {
                if (!vehicleMap.containsKey(vehicle.Vehicle_identification_Number__c))
                    vehicleMap.put(vehicle.Vehicle_identification_Number__c, vehicle.ID);
            }
        }
        
        return vehicleMap;
    }

    public static Map<String, Account> linkDealersByDealerCode(Map<String, Account> inputDealerCodes, Map<String, Account> newDealers, List<Error_Log__c> errors) {
        if (inputDealerCodes.size() == 0) 
            return null;
        
        Map<String, Account> dealerMap = new Map<String, Account>();
        List<String> dealerExternalIds = new List<String>();
        for (String dealerCode: inputDealerCodes.keySet()) {
            dealerExternalIds.add(dealerCode + System.Label.Dealer_USA);
        }
        for (Account dealer : [Select Region_Name__c,
                                    Region_Code__c,
                                    District_Name__c,
                                    District_ID__c,
                                    District_Code__c,
                                    Dealer_Inactive_Indicator__c,
                                    Dealer_External_Id__c,
                                    Dealer_Code__c,
                                    BillingStreet,
                                    BillingState,
                                    BillingPostalCode,
                                    BillingCountry,
                                    BillingCity,
                                    Dealer_Time_Zone__c
                                From Account
                                Where RecordType.Name =: System.Label.AccRTDealer
                                and Dealer_External_Id__c in: dealerExternalIds]) {
            dealerMap.put(dealer.Dealer_Code__c, dealer);
        }
        
        Map<String, Account> dealersToCreate = new Map<String, Account>();
        for (String dealercode : inputDealerCodes.keySet()) {
            if (!dealerMap.containsKey(dealercode))
                dealersToCreate.put(dealercode, inputDealerCodes.get(dealercode));
        }
        
        if (dealersToCreate.size() == 0) 
            return dealerMap;
        
        //still using upsert, in case that the dealer has been created by some other batches.
        List<Account> createds = dealersToCreate.values();
        Database.UpsertResult[] dbResult = Database.upsert(createds, Account.Dealer_Code__c, false);
        for (integer row = 0; row < createds.size(); row++) {
            Account dealer = createds[row];         
            Database.UpsertResult result = dbResult[row];
            if (!result.isSuccess()) {
                if (errors != null) {
                    Database.Error err = result.getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = dealer.Id,
                                                Record_Type__c = 'Account', 
                                                Error_Message__c = err.getMessage(), 
                                                TimeStamp__c = System.now(), 
                                                Operation_Name__c = 'linkDealersByDealerCode', 
                                                Source__c='Salesforce', 
                                                Log_Type__c = 'Error', 
                                                Log_Level__c = 1));
                }
            } else {
                dealerMap.put(dealer.Dealer_Code__c, dealer);
                
                if (result.isCreated() && newDealers != null)
                    newDealers.put(dealer.Dealer_Code__c, dealer);
            }
        }
        
        System.Debug('*** newDealers ' + newDealers);
        return dealerMap;
    }

    public static Map<String, Code__c> getCodeIDMap(Set<String> codes, String codeType) {
        Map<String, Code__c> codeMap = new Map<String, Code__c>();
        if (codes.size() > 0) {
            for (Code__c c : [Select Type__c, Secondary_Code__c, Name, Id, Description__c, Code__c, Active__c From Code__c WHERE Type__c =: codeType and Code__c in: codes]) {
                if (!codeMap.containsKey(c.Code__c))
                    codeMap.put(c.Code__c, c);
            }
        }
        
        return codeMap;
    }

    public static Map<String, Account> getCustomerIDMap(List<String> customerIds) {
        Map<String, Account> customerMap = new Map<String, Account>();
        if (customerIds.size() > 0) {
            for (Account customer : [Select Maritz_Returned_Customer_Id__c, Customer_ID__c, Phone, PersonMailingStreet, PersonMailingState, PersonMailingPostalCode, PersonContactID, 
                                        PersonMailingCountry, PersonMailingCity, PersonOtherPhone, PersonEmail, LastName, FirstName, PersonHomePhone
                                    From Account WHERE RecordType.Name =: System.Label.AccRTMaritz and Customer_ID__c in: customerIds]) {
                if (!customerMap.containsKey(customer.Customer_ID__c))
                    customerMap.put(customer.Customer_ID__c, customer);
            }
        }
        
        return customerMap;
    }

    /**
        get existing vehicle by VINs, as well as creating non-existing vehicles.
    */
    public static Map<String, Vehicle__c> linkVehiclesByVIN(List<Vehicle__c> VINs, List<Error_Log__c> errors) {
        Map<String, Vehicle__c> mVINs = new Map<String, Vehicle__c>();
        for (Vehicle__c vin : VINs) {
            if (vin.Vehicle_identification_Number__c != null)
                mVINs.put(vin.Vehicle_identification_Number__c, vin);
        }
        
        return linkVehiclesByVIN(mVINs, errors);
    }
    
    /**
        get existing vehicle by VINs, as well as creating non-existing vehicles.
    */
    public static Map<String, Vehicle__c> linkVehiclesByVIN(Set<String> VINs, List<Error_Log__c> errors) {
        Map<String, Vehicle__c> mVINs = new Map<String, Vehicle__c>();
        for (String vin : VINs) {
            if (vin != null && vin != '')
                mVINs.put(vin, new Vehicle__c(Name = vin, Vehicle_Identification_Number__c = vin, OwnerId = System.Label.Batch_Record_Owner, RecordTypeID = '012A0000000OfXm'));
        }
        
        return linkVehiclesByVIN(mVINs, errors);
    }
    
    /**
        get existing vehicle by VINs, as well as creating non-existing vehicles.
    */
    public static Map<String, Vehicle__c> linkVehiclesByVIN(Map<String, Vehicle__c> VINs, List<Error_Log__c> errors) {
        return linkVehiclesByVIN(VINs, null, errors);
    }
    
    /**
        get existing vehicle by VINs, as well as creating non-existing vehicles.
        List<Error_Log__c> errors = new List<Error_Log__c>();
        List<Vehicle__c> VINs = new List<Vehicle__c>{new Vehicle__c(Name = '12345678912345678', 
                                                                    Vehicle_Identification_Number__c = '12345678912345678', 
                                                                    Make_Name__c = 'Nissan',
                                                                    OwnerId = System.Label.Batch_Record_Owner, 
                                                                    RecordTypeID = '012A0000000OfXm')};
        Text_Util.linkVehiclesByVIN(VINs, errors);
        
        Set<String> sVINs = new Set<String>{'98765432187654321'};
        Text_Util.linkVehiclesByVIN(sVINs, errors);
        
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Map<String, Vehicle__c> newVehicles = new Map<String, Vehicle__c>();
        List<Vehicle__c> VINs = new List<Vehicle__c>{new Vehicle__c(Name = '12345678912345678', 
                                                                    Vehicle_Identification_Number__c = '12345678912345678', 
                                                                    Make_Name__c = 'Nissan',
                                                                    OwnerId = System.Label.Batch_Record_Owner, 
                                                                    RecordTypeID = '012A0000000OfXm'),
                                                    new Vehicle__c(Name = '98765432187654321', 
                                                                    Vehicle_Identification_Number__c = '98765432187654321', 
                                                                    Make_Name__c = 'Nissan',
                                                                    OwnerId = System.Label.Batch_Record_Owner, 
                                                                    RecordTypeID = '012A0000000OfXm')};
        Map<String, Vehicle__c> mVINs = new Map<String, Vehicle__c>();
        for (Vehicle__c vin : VINs) {
            if (vin.Vehicle_identification_Number__c != null)
                mVINs.put(vin.Vehicle_identification_Number__c, vin);
        }
        Text_Util.linkVehiclesByVIN(mVINs, newVehicles, errors);
    */
    public static Map<String, Vehicle__c> linkVehiclesByVIN(Map<String, Vehicle__c> inputVINs, Map<String, Vehicle__c> newVehicles, List<Error_Log__c> errors) {
        if (inputVINs.size() == 0) 
            return null;
        
        Map<String, Vehicle__c> vehicleMap = new Map<String, Vehicle__c>();
        for (Vehicle__c vehicle : [Select Vehicle_identification_Number__c, 
                                    Vehicle_Type__c, 
                                    RecordTypeId, Name, 
                                    Model_Year__c, 
                                    Model_Name__c, 
                                    Model_Line_Name__c, 
                                    Model_Line_Code__c, 
                                    Model_Code__c, 
                                    Manufacturer_Date__c, 
                                    Make_Name__c, 
                                    Make_Model__c, 
                                    Latest_Recorded_Mileage_Units__c, 
                                    Latest_Recorded_Mileage_Number__c, 
                                    In_Service_Date__c, Id, 
                                    Channel_Code__c 
                                From Vehicle__c 
                                Where Vehicle_identification_Number__c in: inputVINs.keySet()]) {
            vehicleMap.put(vehicle.Vehicle_Identification_Number__c, vehicle);
        }
        
        Map<String, Vehicle__c> vehiclesToCreate = new Map<String, Vehicle__c>();
        for (String vin : inputVINs.keySet()) {
            if (vin != null && vin.length() >= 10 && !vehicleMap.containsKey(vin))
                vehiclesToCreate.put(vin, inputVINs.get(vin));
        }
        
        if (vehiclesToCreate.size() == 0) 
            return vehicleMap;
        
        //still using upsert, in case that the vehicle has been created by some other batches.
        List<Vehicle__c> createds = vehiclesToCreate.values();
        Database.UpsertResult[] dbResult = Database.upsert(createds, Vehicle__c.Vehicle_Identification_Number__c, false);
        for (integer row = 0; row < createds.size(); row++) {
            Vehicle__c vehicle = createds[row];
            Database.UpsertResult result = dbResult[row];
            if (!result.isSuccess()) {
                if (errors != null) {
                    Database.Error err = result.getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = vehicle.Id,
                                                Record_Type__c = 'Vehicle__c', 
                                                Error_Message__c = err.getMessage(), 
                                                TimeStamp__c = System.now(), 
                                                Operation_Name__c = 'linkVehiclesByVIN', 
                                                Source__c='Salesforce', 
                                                Log_Type__c = 'Error', 
                                                Log_Level__c = 1));
                }
            } else {
                vehicleMap.put(vehicle.Vehicle_Identification_Number__c, vehicle);
                
                if (result.isCreated() && newVehicles != null)
                    newVehicles.put(vehicle.Vehicle_Identification_Number__c, vehicle);
            }
        }
        
        System.Debug('*** newVehicles ' + newVehicles);
        return vehicleMap;
    }
    
    public static Boolean isSameDay(DateTime lastDate) {
        return lastDate == null ? false : lastDate.isSameDay(datetime.now());
    }

    public static String TruncateString(String toTrunc, Integer length) {
        if (toTrunc == null)
            return toTrunc;
        return toTrunc.substring(0, toTrunc.length() > length ? length : toTrunc.length());
    }
    
    public static List<ID> sortIDByName(Map<ID, String> IDtoNameMap) {
        Map<String, ID[]> nameToID = new Map<String, ID[]>();
        List<ID> sortedIDs = new List<ID>();
        
        for (String key : IDtoNameMap.keySet()) {
            String name = IDtoNameMap.get(key);
            
            if (nameToID.containsKey(name))
                nameToID.get(name).add(key);
            else
                nameToID.put(name, new ID[]{key});
        }
        
        String[] keys = new List<String>(nameToID.keySet());
        keys.sort();
        for (String key : keys) {
            ID[] ids = nameToID.get(key);
            sortedIDs.addAll(ids);
        }
        return sortedIDs;
    }
    
    public static String getSoqlFormattedDate(Date d) {
        DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
        String formattedDate = dt.formatGmt('yyyy-MM-dd') + 'T' + dt.formatGMT('hh:mm:ss') + 'Z';
        
        return formattedDate;
    }
    
    static testMethod void testTextUtil() {
        RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
        RecordType personType = [select id, name from recordtype where name =: System.Label.AccRTMaritz and sobjecttype = 'Account' limit 1];
        
        Test.startTest();
        List<String> lines = new List<String>{'test1', 'test2', 'test3'};
        Text_Util.combineStrings(lines);
        Text_Util.combineStrings(lines, 1);
        
        String toSplit = 'veryverylongtext1veryverylongtext1veryverylongtext1veryverylongtext1veryverylongtext1\n' + 
                            'test2\ntest3';
        Text_Util.splitString(toSplit);
        
        Date d = Date.newInstance(2012, 12, 21);
        Text_Util.getFormattedDate(d);
        
        DateTime dt = DateTime.newInstance(2012, 12, 21, 12, 0, 0);
        Text_Util.getFormattedDateTime(dt);
        Text_Util.getFormattedTime(dt);
        
        Text_Util.CCYYMMDDtoDate('anytext');
        Text_Util.CCYYMMDDtoDate('0001-01-01');
        Text_Util.CCYYMMDDtoDate('2012-12-21');
        Text_Util.CCYYMMDDtoDate('not-a-date');
        
        Text_Util.CCYYMMDDNoDashesToDate('anytext');
        Text_Util.CCYYMMDDNoDashesToDate('00010101');
        Text_Util.CCYYMMDDNoDashesToDate('20121221');
        Text_Util.CCYYMMDDNoDashesToDate('notadate');
        
        Text_Util.MMDDCCYYtoDate('anytext');
        Text_Util.MMDDCCYYtoDate('01/01/0001');
        Text_Util.MMDDCCYYtoDate('12/21/2012');
        Text_Util.MMDDCCYYtoDate('not/a/date');
        
        Text_Util.CCYYMMDDtoDateTime('anytext');
        Text_Util.CCYYMMDDtoDateTime('0001-01-01');
        Text_Util.CCYYMMDDtoDateTime('2012-12-21');
        Text_Util.CCYYMMDDtoDateTime('not-a-date');
        
        Text_Util.CCYYMMDDNoDashesToDateTime('anytext');
        Text_Util.CCYYMMDDNoDashesToDateTime('00010101');
        Text_Util.CCYYMMDDNoDashesToDateTime('20121221');
        Text_Util.CCYYMMDDNoDashesToDateTime('notadate');
        
        Text_Util.MMDDCCYYtoDateTime('anytext');
        Text_Util.MMDDCCYYtoDateTime('01/01/0001');
        Text_Util.MMDDCCYYtoDateTime('12/21/2012');
        Text_Util.MMDDCCYYtoDateTime('not-a-date');
        
        Text_Util.BooleanLookup(null, false);
        Text_Util.BooleanLookup('Y', true);
        Text_Util.BooleanLookup('0', true);
        Text_Util.BooleanLookup('!', false);
        
        Text_Util.validatePhone('0000000000');
        Text_Util.validatePhone('5555555555');
        
        Text_Util.valueConcatenation(null, null);
        Text_Util.valueConcatenation('source', 'target');
        
        System.Debug('*** null, null ='  + Text_Util.valueConcatenation_Delim(null, null, ' ') + '***');
        System.Debug('*** target, null ='  + Text_Util.valueConcatenation_Delim('target', null, ' ') + '***');
        System.Debug('*** null, source ='  + Text_Util.valueConcatenation_Delim(null, 'source', ' ') + '***');
        System.Debug('*** target, source ='  + Text_Util.valueConcatenation_Delim('target', 'source', '') + '***');
        
        Text_Util.DecimalValueOf(null);
        Text_Util.DecimalValueOf('text');
        Text_Util.DecimalValueOf('123');
        
        Text_Util.isSameDay(dt);
        
        Text_Util.toValidEmail('CCCCCCCCC');
        Text_Util.toValidEmail('somebody@BuCunZaideJiaEmailDiZhi.com');
        
        List<Error_Log__c> errors = new List<Error_Log__c>();
        
        ByVinsInAccount_TestUtil.TestData();
        
        Text_Util.getDealderIDMap(new List<String>{ByVinsInAccount_TestUtil.DEALER_CODE});
        
        Map<String, Account> inputDealers = new Map<String, Account>{
                                                    ByVinsInAccount_TestUtil.DEALER_CODE => new Account(Dealer_Code__C = ByVinsInAccount_TestUtil.DEALER_CODE, RecordTypeID = dealerType.Id),
                                                    'DLR@@' => new Account(Dealer_Code__C = 'DLR@@', RecordTypeID = dealerType.Id, Name = 'Dealer DLR@@')
                                                };
        Text_Util.linkDealersByDealerCode(inputDealers, new Map<String, Account>(), errors);
        
        Text_Util.getCustomerIDMap(new List<String>{ByVinsInAccount_TestUtil.CUSTOMER_ID});
        
        List<Vehicle__c> testNewVehicles = new List<Vehicle__c>();
        testNewVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000111'));
        testNewVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000112'));
        testNewVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000113'));
        ByVinsInAccount_TestUtil.testVehicles.addAll(testNewVehicles);
        
        Map<String, Vehicle__c> inputVehicles = new Map<String, Vehicle__c>();
        for (Vehicle__c v : ByVinsInAccount_TestUtil.testVehicles)
            inputVehicles.put(v.Vehicle_Identification_Number__c, v);
        
        Map<String, Vehicle__c> newVehicles = new Map<String, Vehicle__c>();
        
        Text_Util.linkVehiclesByVIN(inputVehicles, newVehicles, errors);
        
        Text_Util.linkVehiclesByVIN(ByVinsInAccount_TestUtil.testVehicles, errors);
        Text_Util.linkVehiclesByVIN(new Set<String>(ByVinsInAccount_TestUtil.testVINs), errors);
        Text_Util.linkVehiclesByVIN(inputVehicles, errors);
        
        List<Code__c> codes = new List<Code__c> {new Code__c(Type__c = 'TextUtil', Code__c = '3', Description__c = 'C'),
                                                new Code__c(Type__c = 'TextUtil', Code__c = '1', Description__c = 'A'),
                                                new Code__c(Type__c = 'TextUtil', Code__c = '4', Description__c = 'D'),
                                                new Code__c(Type__c = 'TextUtil', Code__c = '2', Description__c = 'B')};
        insert codes;
        Text_Util.getCodeIDMap(new Set<String>{'2'}, 'TextUtil');

        Map<ID, String> IDtoNameMap = new Map<ID, String>();
        for (Code__c c : [select id, Description__c from Code__c where Type__c = 'TextUtil'])
            IDtoNameMap.put(c.ID, c.Description__c);
        List<ID> sortedIDs = Text_Util.sortIDByName(IDtoNameMap);
        System.assert(IDtoNameMap.get(sortedIDs[0]) == 'A');
        System.assert(IDtoNameMap.get(sortedIDs[1]) == 'B');
        System.assert(IDtoNameMap.get(sortedIDs[2]) == 'C');
        System.assert(IDtoNameMap.get(sortedIDs[3]) == 'D');
        
        System.assert(Text_Util.TruncateString(null, 5) == null);
        System.assert(Text_Util.TruncateString('123456789', 5) == '12345');
        Test.stopTest();
    }
    
    public static String getDocumentId(String caseDocumentId, String caseNumber, String recordTypeName) {
        Integer caseNum;
        String documentId = null;
        if (caseDocumentId != null && caseNumber != null && recordTypeName != null) {
            if (recordTypeName == 'Roadside Assistance') {
                caseNum = Integer.valueOf(caseNumber);
                if (caseNum > 9000000)
                    caseNum = caseNum - 8000000;
                documentId = 'CA' + String.valueOf(caseNum);
            } else {
                caseNum = Integer.valueOf(caseDocumentId.substring(2,caseDocumentId.length()));
                if (caseNum > 9000000)
                    caseNum = caseNum - 8000000;
                documentId = 'CA' + String.valueOf(caseNum);
            }
        }
        
        return documentId;
    }

    /* Convert NNA Portal Username and Dealer Code into the corresponding Salesforce username.
     * This will take the form 'user-dealercode@nissan.com'.
     */
    public static String createPortalUsername(String userId, String dealerCode) {
        String portalUsername = userId + System.Label.SSO_Username_Delimiter + dealerCode + System.Label.SSO_Username_Suffix;
        return portalUsername;
    }

    /* Convert NNA Portal Username and Dealer Code into the corresponding Salesforce username.  Convert result to lowercase for
         * Map key comparisons to lowercased Strings retrieved from the database.
     * This will take the form 'user-dealercode@nissan.com'.
     */
    public static String createPortalUsernameLowercase(String userId, String dealerCode) {
        return Text_Util.createPortalUsername(userId, dealerCode).toLowerCase();
    }
    
    /* Returns a List of Strings of a certain length, without cutting words */
    public static List<String> splitStringExtended(String targetText, Integer maxLength) {
        List<String> resultCollection = new List<String>();
        
        if (targetText != null && targetText != '' && maxLength > 0) {
            Integer startIndex = 0;
            Integer endIndex;
            Integer totalLength = targetText.length();
            
            while (totalLength > startIndex) {
                endIndex = startIndex + maxLength;
                    
                if (endIndex > totalLength) {
                    endIndex = totalLength;
                }
                else {
                    String textBlock = targetText.substring(startIndex, endIndex);
                    Integer lastBreakLine = textBlock.lastIndexOf('\n\b');
                    
                    /*Integer lastSpace = textBlock.lastIndexOf(' ');
                    
                    if (lastBreakLine > 0 || lastSpace > 0) {
                        if (lastBreakLine > lastSpace) {
                            endIndex = startIndex + lastBreakLine + 1; 
                        }
                        else {
                            endIndex = startIndex + lastSpace + 1;
                        }   
                    }*/
                    
                    if (lastBreakLine > 0) {
                        endIndex = startIndex + lastBreakLine + 1;
                    }
                    else {
                        Integer lastSpace = textBlock.lastIndexOf(' ');
                        if (lastSpace > 0) {
                            endIndex = startIndex + lastSpace + 1;
                        }
                    }
                }
                
                resultCollection.add(targetText.substring(startIndex, endIndex));
                
                startIndex = endIndex;
            }
        }
        
        return resultCollection;
    }
    
    public static String convertYear(String inYear) {
        String outYear = '';
        if (inYear != null) {
            if (inYear.length() == 4) {
                inYear = inYear + '.0';
            }
            outYear = inYear.substring(2,4) + inYear.substring(5,6);
        }
                
        return outYear;
    }
    
     public static String getNormalizedZipCode(Case c) {
        String zip = null;
        if (c.Mailing_Zip_Code__c != null)
            zip = getNormalizedZipCode(c.Mailing_Zip_Code__c);
        
        if (zip == null && c.Contact.MailingPostalCode != null)
            zip = getNormalizedZipCode(c.Contact.MailingPostalCode);
            
        return zip;
    }
    
    public static String getNormalizedZipCode(String zip) {
        String outZip = '';
        String hex;
        
        // Convert each character to hex and create a new String with only numbers 0-9, all other
        // characters are stripped out.
        for (Integer zipChar = 0; zipChar < zip.length(); zipChar++) {
            hex = encodingUtil.convertToHex(Blob.valueOf(zip.substring(zipChar, zipChar + 1)));
            if (hex == '30' || hex == '31' || hex == '32' || hex == '33' || hex == '34' ||
                    hex == '35' || hex == '36' || hex == '37' || hex == '38' || hex == '39') {
                outZip = outZip + zip.substring(zipChar, zipChar + 1);
            }
        }
        
        // Return a String of 9 numbers if possible, otherwise a String of 5 numbers, otherwise blank.
        if (outZip.length() > 9) {
            outZip = outZip.substring(0,9);
        } else if (outZip.length() != 9 && outZip.length() > 5) {
            outZip = outZip.substring(0,5);
        } else if (outZip.length() != 9 && outZip.length() != 5) {
            outZip = '';
        }
        
        return outZip;
    }
    
    
    
    
}