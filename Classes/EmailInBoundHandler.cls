global class EmailInBoundHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(
       Messaging.InboundEmail email,
       Messaging.InboundEnvelope envelope) {

 InBoundEmailUtilities handler = new InBoundEmailUtilities();
        Messaging.InboundEmailResult result = handler.processInboundEmail(email);
        return result;        
    }
}