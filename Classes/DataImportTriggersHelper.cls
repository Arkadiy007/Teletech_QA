public class DataImportTriggersHelper {
    private static Map <String, String > monthsMap = new Map <String, String > {
        '1' => 'January',
        '2' => 'February',
        '3' => 'March',
        '4' => 'April',
        '5' => 'May',
        '6' => 'June',
        '7' => 'July',
        '8' => 'August',
        '9' => 'September',
        '10' => 'October',
        '11' => 'November',
        '12' => 'December'
    };

    public static string GetMonthNameUsingNumber(String monthNumber) {
        return monthsMap.get(monthNumber);
    }

    public static Date GetDateFromOCPDate(String dateValue) {
        /*return Date.parse((dateValue.length() == 7) ? String.format('{0}/{1}/{2}', new String[]
          { 
          dateValue.substring(0,1),
          dateValue.substring(1,3),
          dateValue.substring(4,7)
          }) :
          String.format('{0}/{1}/{2}', new String[]
          { 
          dateValue.substring(0,2),
          dateValue.substring(2,4),
          dateValue.substring(4,8)
          }));*/

        if (dateValue.contains('/')){
            return Date.parse(dateValue);
        }
        Integer year = 0;
        Integer month = 0;
        Integer day = 0;

        if (dateValue.length() == 7) {
            month = Integer.valueof(dateValue.substring(0, 1));
            day = Integer.valueof(dateValue.substring(1, 3));
            year = Integer.valueof(dateValue.substring(3, 7));
        }
        else {
            month = Integer.valueof(dateValue.substring(0, 2));
            day = Integer.valueof(dateValue.substring(2, 4));
            year = Integer.valueof(dateValue.substring(4, 8));
        }

        return Date.newInstance(year, month, day);
    }

    /*public static List <Case > MapNewAccountsToNewCases(List <Account > insertedAccounts, List <Case > casesWithoutAccounts) {
        List <Case > mappedCases = new List <Case > ();

        Set<Id> accIds = (new Map <Id, Account > (insertedAccounts)).keySet();

        List <Account > updatedAccounts = [Select Id, PersonContactId, Customer_ID__c from Account where Id IN :accIds];

        Map <String, Account > customersMap = new Map <String, Account > ();
        for (Account customer : updatedAccounts) {
            customersMap.put(customer.Customer_ID__c, customer);
        }

        for (Case c : casesWithoutAccounts) {
            if (customersMap.containsKey(c.Contact_ID__c)) {
                Account customer = customersMap.get(c.Contact_ID__c);
                c.AccountId = customer.Id;
                c.ContactId = customer.PersonContactId;
                mappedCases.add(c);
            }
        }

        return mappedCases;
    }**/
}