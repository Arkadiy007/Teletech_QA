/**********************************************************************
Name: XMLDom_Test 
Copyright Â© notice: Nissan Motor Company . 
======================================================
Purpose: 
Test coverage class for XMLDom
Related to: XMLDom
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Mohd Afraz Siddiqi 02/01/2011 Created
***********************************************************************/
@isTest
private Class XMLDom_Test {
    private static  XMLDom obj = new XMLDom();
    private static  XMLDom.Element element = new XMLDom.Element();
    public static String xml = '<root >' +
                                '<child param="test"></child>' + 
                                '<item param="test"></item>' +
                                '<entry param="test"></entry>' +
                                '<message>if salary &lt; 1000 then</message>' +
                               '<h:table xmlns:h="http://www.w3.org/TR/html4/"></h:table>'+                           
                               '</root>';       
    
    static testMethod void  testParseFromString(){
        test.startTest();
        obj.parseFromString(xml);
        obj = new XMLDom(xml);
        obj.dumpAll();
        obj.toXmlString();
        test.stopTest();
        
    }
    
    static testMethod void  testGetElementsByTagName(){
        obj.parseFromString(xml);
                 
        test.startTest();
        List<XMLDom.Element> nodes = obj.getElementsByTagName('child');
        test.stopTest();
        
        system.assert(nodes.size() == 1);
    }
    
    static testMethod void  testgetElementByTagName(){
        obj.parseFromString(xml);
                 
        test.startTest();
        XMLDom.Element node = obj.getElementByTagName('child');
        test.stopTest();
        
        system.assert(node != null);
    }
    
    static testMethod void  testGetAttribute(){
        obj.parseFromString(xml);
        element.firstChild();
        element = obj.ownerDocument();
        
        test.startTest();
        string attribute = element.childNodes[0].getAttribute('param');
        element.getElementByTagName('nam');
        element.getValue('nam');
        element.isEqualNode(element);
        element.cloneNode();
        element.isSameNode(element);
        test.stopTest();
        
        //system.assert(attribute == 'test');
    }
    
    static testMethod void  testAppendChild(){
        obj.parseFromString(xml);
        element = obj.ownerDocument();
        element.ownerDocument();
        XMLDom.Element childelement = new XMLDom.Element('child2');
        test.startTest();
        element.appendChild(childelement);
        test.stopTest();
        
        system.assert(element.childNodes.size() == 2);
    }
    
    static testMethod void  testRemoveChild(){
        obj.parseFromString(xml);
        element = obj.ownerDocument();
        XMLDom.Element childelement = element.childNodes[0];
        
        test.startTest();
        element.removeChild(childelement);
        test.stopTest();
        
        system.assert(element.childNodes.size() == 0);
    }
    
    static testMethod void GetElementsByTagNameTwo(){
        obj.parseFromString(xml);
        
        test.startTest();
        List<XMLDom.Element> e2 = element.getElementsByTagName('child');
        test.stopTest();
        
        system.assert(e2 != null);
    }
    
    static testMethod void  testgetElementByTagNameTwo(){
        obj.parseFromString(xml);
                 
        test.startTest();
        List<XMLDom.Element> e3 = element.getElementsByTagName('child');
        test.stopTest();
        system.assert(e3 != null);
    }
    
    static testMethod void dump(){
        test.startTest();
        element.dump();
        test.stopTest();
    }
    
    static testMethod void toXmlString(){
        test.startTest();
        string s = element.toXmlString();
        test.stopTest();
        
        system.assert(s != null);
    }
    
    static testMethod void GetElementsByPath(){
        obj.parseFromString(xml);
        element = obj.ownerDocument();
        
        test.startTest();
        List<XMLDom.Element> root = element.getElementsByPath('\root');
        test.stopTest();
        
        system.assert(root != null);
    }
    
    static testMethod void testException(){
        string str='test';
        test.startTest();
        obj.parseFromString(str);
        test.stopTest();
        
    }
    
    static testMethod void textContent(){
        obj.parseFromString(xml);
        element = obj.ownerDocument();
        
        test.startTest();
        string content = element.textContent();
        test.stopTest();
        system.assert(content != null);
        
    }
    
    static testMethod void hasChildNodes(){
        obj.parseFromString(xml);
        element = obj.ownerDocument();
        
        test.startTest();
        boolean childnodes = element.hasChildNodes();
        test.stopTest();
        system.assert(childnodes == true);
        
    }
    static testMethod void hasAttributes(){
        obj.parseFromString(xml);
        element = obj.ownerDocument();
        element.firstChild();
        test.startTest();
        boolean attribute = element.childNodes[0].hasAttributes();
        test.stopTest();
        //system.assert(attribute == true);
    }
    
    static testMethod void dumpList(){
        obj.parseFromString(xml);
        element = obj.ownerDocument();
        List<XMLDOM.Element> elements = new List<XMLDOM.Element>();
        test.startTest();
        elements.add(element);
        obj.dumpList(elements);
        test.stopTest();
        system.assert(elements != null);
        
    }
}