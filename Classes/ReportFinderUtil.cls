public with sharing class ReportFinderUtil {

  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
    Pagereference pr = new Pagereference('/servlet/servlet.ReportList');
    Dom.Document doc = getDomDocumentFromPageReference(pr);
    Dom.Xmlnode root = doc.getRootElement();
    System.debug('root:::'+root);
    Dom.Xmlnode reportNode = getReportNode(root, reportName);
    if (reportNode != null){
      String val = reportNode.getChildElement('id', null).getText();
      if(val != null)
        return val;
    }
    return '00O';
  }
   
  private Dom.Xmlnode getReportNode(Dom.Xmlnode root, String reportName){
    Dom.Xmlnode wantedNode;
    For(Dom.Xmlnode child: root.getChildElements()){
        if(child.getAttribute('name', null)==reportName){
         return child;
      }
    }   
    return null;
  }
  
  Private Dom.Document getDomDocumentFromPageReference(PageReference pr){
    Dom.Document dom = new Dom.Document();
    String domString = null;
    Blob content = null;
    try {
        if (pr != null) {
        	if(!Test.isRunningTest()){
            content = pr.getContent();
        	}else{
        		content = Blob.valueOf('<report foldername="Survey Force Reports" name="Survey with Questions and Responses">'+
									   +'	<id>00OA0000003mzta</id>'+
										+'<url>'+
										+'<![CDATA[ 00OA0000003mzta?isExcel=1 ]]>'+
										+'</url>'+
										+'<isPublic>true</isPublic>'+
										+'</report>');
        	}
            if (content != null) {
                domString = content.toString();
            }
        }
    } catch(Exception e) {
    }
    
    if (domString != null) {
        dom.load(domString);
    }
    
    return dom;
  }
  
}