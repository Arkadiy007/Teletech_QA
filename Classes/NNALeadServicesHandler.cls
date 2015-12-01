public class NNALeadServicesHandler {
	public class LeadApprovalResponse {
		public String LeadGUId { get; set; }
		public String ResponseCode { get; set; }
		public String ResponceDetail { get; set; }
		public String ResponseTime { get; set; }

		LeadApprovalResponse(String response) {
			String LGUId = response.substringBetween('<LeadGUId>', '</LeadGUId>');
			String RTime= response.substringBetween('<ResponseTime>', '</ResponseTime>');
			String RCode = response.substringBetween('<ResponseCode>', '</ResponseCode>');
			String RDetail = response.substringBetween('<ResponseDetails>', '</ResponseDetails>');

			this.LeadGUId = LGUId;
			this.ResponseCode = RCode;
			this.ResponceDetail = RDetail;
			this.ResponseTime = RTime;
		}
	}

	public static LeadApprovalResponse callLeadService(String XMLAdf) {
		String rawResponce = NNALeadServiceClient.getLeadGuidResponce(XMLAdf);
		return new LeadApprovalResponse(rawResponce);
	}

	public static LeadApprovalResponse callLeadSoapService(String soapLeadGuid) {
		String soapXML = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
												'<s:Body>' +
													'<QueryLeadStatus xmlns="http://www.uslqs.com/LeadServices/1">' +
														'<leadGuidID>' + soapLeadGuid + '</leadGuidID>' + 
													'</QueryLeadStatus>' +
												'</s:Body>' + 
											'</s:Envelope>';

		String rawResponce = NNALeadServiceClient.queryLeadStatus(soapXML);
		return new LeadApprovalResponse(rawResponce);
	}
}