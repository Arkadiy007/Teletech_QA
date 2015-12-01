global class Batch_Techline_KB_Final_Publication implements Database.Batchable<sObject> {
    global String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = '';
        query += 'SELECT Id, KnowledgeArticleId ';
        query += 'FROM KnowledgeArticleVersion ';
        query += 'WHERE PublishStatus = \'Draft\' ';
        query += 'AND Language = \'en_US\' ';
        query += 'AND CreatedBy.Name = \'Sebastian Rohdenburg\' ';
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<KnowledgeArticleVersion> techlineArticles){
        if (techlineArticles.size() > 0) {
            for (KnowledgeArticleVersion art : techlineArticles) {
                KbManagement.PublishingService.publishArticle(art.KnowledgeArticleId, false);
            }
            
            System.debug('SR - Batch successful');
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}