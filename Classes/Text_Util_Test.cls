@isTest
public class Text_Util_Test {

    static testMethod void allStringTest()
    { 
        String targetText = 'abcdefeghijklmnñopqrstuvwxyz';
        List<String> result = Text_Util.splitStringExtended(targetText, 5);
        
        for (String line : result) {
            system.debug('-----> ' + line);
        }
        
        Text_Util.combineStrings(result);
        Text_Util.combineStrings(result,2);
        Text_Util.splitString('f');
        
        targetText = 'Este correo electrónico es para informarle que el comunicado informativo sobre la revisión de su desempeño ya se encuentra disponible. Por favor, inicie sesión en el sistema para documentar sus logros significativos para este ciclo de revisión';
        result = Text_Util.splitStringExtended(targetText, 30);
        
        for (String line : result) {
            system.debug('-----> ' + line);
        }
    }
    
    static testMethod void allDateTest(){
    
        Text_Util.getFormattedDate(Date.today());
        Text_Util.getFormattedDateTime(Datetime.now());
        Text_Util.getFormattedTime(Datetime.now());
        
        Text_Util.CCYYMMDDtoDate('20000101');
        Text_Util.CCYYMMDDNoDashesToDate('20000101');
        Text_Util.MMDDCCYYtoDate('01012001');
        Text_Util.MMDDYYtoDate('010101');
        Text_Util.BooleanLookup('Y',false);
        Text_Util.BooleanLookup('N',true);
        
    }
    
     static testMethod void validationTest(){
         Text_Util.validatePhone('8976546789');
         Text_Util.valueConcatenation('x', 'y');
         Text_Util.valueConcatenation_Delim('x','y','-');
         Text_Util.toValidEmail('ax@bn.com');
         Text_Util.DecimalValueOf('89');
     }
    
    
 }