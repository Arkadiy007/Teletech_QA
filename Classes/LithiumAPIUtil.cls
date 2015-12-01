public class LithiumAPIUtil {
    public static string baseUrl {get; private set;   }
    public static string restbaseUrl {get; private set;   }
    public static string restUrl {get; private set;   }
    public static string sessionToken {get; private set;   }
    
    private static Http h {get; set;   }
    private static dateTime lastSessionTimestamp {get; set;   }
    
    static {
        h = new Http();
        LithiumSettings__c liSetting = getLithiumSettings();
        baseUrl = (liSetting.Base_URL__c != NULL)?'http://' + liSetting.Base_URL__c:'';
        restbaseUrl = '/restapi/vc';
        restUrl = baseUrl + restbaseUrl;
        sessionToken = '';
        lastSessionTimestamp = dateTime.newInstance(1970, 1, 1);
       }
    
    private static HTTPResponse executeRest(string relUrl, string method, Map<String, String> params) {
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(restUrl + relUrl);
        req.setMethod(method);
        
        string body = '';
        string glue = '';
        for(string key : params.keySet()) {
            body += glue + key + '=' + params.get(key);
            glue = '&';
           }
        req.setBody(body);
        
    	if(!Test.isRunningTest()) {
	        return h.send(req);
    		}
        else {
        	return new HTTPResponse(); 
        	}
       }
    
    public static LithiumSettings__c getLithiumSettings() {
        LithiumSettings__c liSetting = LithiumSettings__c.getValues('DefaultSetting');
        if(liSetting == NULL) {
            liSetting = new LithiumSettings__c();
            liSetting.Name = 'DefaultSetting';
            liSetting.Sync_With_Contact__c = false;
            liSetting.Create_New_Contact_record__c = false;
            
            Database.insert(liSetting, false);
           }
        
        return liSetting;
       }
    
    public static Boolean isUserActive() {
        // TODO: complete this, case 00020452 on lithosphere
        return false;
       }
    
    public static string login() {      
        dateTime currentTimestamp = dateTime.now();
        LithiumSettings__c dataSet = getLithiumSettings();
        string username = dataSet.Username__c;
		string password = dataSet.Password__c;
		
        if(currentTimestamp < lastSessionTimestamp.addMinutes(30)) { //last session call has not expired
            lastSessionTimestamp = currentTimestamp;
            return sessionToken; 
           }
        //get new session id as its expired
        Map<String,String> params = new Map<String, String>();
        params.put('user.login', username); //cloudadmin
        params.put('user.password', password); //password01
        
        lastSessionTimestamp = dateTime.now();
        HTTPResponse res = executeRest('/authentication/sessions/login', 'POST', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<response status="success"><value type="string">exs9oL4_y8j7SQKOUkeQVzeRBEWZSPEdLCqSu4ND0MY.</value></response>';
        	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        if(root.attributes.get('status') == 'success')
            sessionToken = root.firstChild().nodeValue;
        
        return sessionToken;
       }
    
    public static string login(String lithiumSSOToken) {   
        dateTime currentTimestamp = dateTime.now();
        
        if(currentTimestamp < lastSessionTimestamp.addMinutes(30)) { //last session call has not expired
            lastSessionTimestamp = currentTimestamp;
            return sessionToken; 
           }
        //get new session id as its expired
        Map<String,String> params = new Map<String, String>();
        params.put('sso.authentication_token', 'lithiumSSOToken');
        
        lastSessionTimestamp = dateTime.now();
        HTTPResponse res = executeRest('/authentication/sessions/login', 'POST', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<response status="success"><value type="string">exs9oL4_y8j7SQKOUkeQVzeRBEWZSPEdLCqSu4ND0MY.</value></response>';
        	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        if(root.attributes.get('status') == 'success')
            sessionToken = root.firstChild().nodeValue;
        
        return sessionToken;
       }
    
    public static LiUser getUserDetails(string username) {
        Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
        params.put('restapi.response_style', 'view');
    
        HTTPResponse res = executeRest('/users/login/' + username, 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><response status="success"><user type="user" href="/users/id/3" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/3"><id type="int">3</id><registered type="boolean">true</registered><deleted type="boolean">false</deleted><login type="string">lvshankar</login><anonymous type="boolean">false</anonymous><last_visit_time type="date_time" view_date="09-30-2011" view_time="07:24 AM">2011-09-30T14:24:21+00:00</last_visit_time><email type="string">vidhyashankar@cloudsquads.com</email><registration_time type="date_time" view_date="02-01-2011" view_time="09:54 PM">2011-02-02T05:54:44+00:00</registration_time><average_message_rating type="float">0.0</average_message_rating><average_rating type="float">0.0</average_rating><profiles><profile name="auto_mark_read" type="string">never</profile><profile name="auto_mark_read_days" type="string">0</profile><profile name="auto_subscribe_on_post" type="string">none</profile><profile name="autosave_interval" type="string">30</profile><profile name="blogger_badge_orientation" type="string">vertical</profile><profile name="blogger_badge_show_accepted_solutions" type="string">true</profile><profile name="blogger_badge_show_avatar" type="string">true</profile><profile name="blogger_badge_show_blogs" type="string">true</profile><profile name="blogger_badge_show_ideas" type="string">true</profile><profile name="blogger_badge_show_kudos" type="string">true</profile><profile name="blogger_badge_show_post_count" type="string">true</profile><profile name="blogger_badge_show_rank" type="string">true</profile><profile name="board_subscribe_method" type="string">message</profile><profile name="charset_email" type="string">UTF-8</profile><profile name="charset_email_ca" type="string">UTF-8</profile><profile name="charset_email_da" type="string">UTF-8</profile><profile name="charset_email_de" type="string">UTF-8</profile><profile name="charset_email_en" type="string">UTF-8</profile><profile name="charset_email_en-gb" type="string">UTF-8</profile><profile name="charset_email_es" type="string">UTF-8</profile><profile name="charset_email_es-mx" type="string">UTF-8</profile><profile name="charset_email_fr" type="string">UTF-8</profile><profile name="charset_email_in" type="string">UTF-8</profile><profile name="charset_email_it" type="string">UTF-8</profile><profile name="charset_email_ja" type="string">UTF-8</profile><profile name="charset_email_ko" type="string">UTF-8</profile><profile name="charset_email_nl" type="string">UTF-8</profile><profile name="charset_email_no" type="string">UTF-8</profile><profile name="charset_email_pt" type="string">UTF-8</profile><profile name="charset_email_pt-br" type="string">UTF-8</profile><profile name="charset_email_ru" type="string">UTF-8</profile><profile name="charset_email_sv" type="string">UTF-8</profile><profile name="charset_email_zh-cn" type="string">UTF-8</profile><profile name="charset_email_zh-tw" type="string">UTF-8</profile><profile name="chat.compact" type="string">false</profile><profile name="chat.extra_info" type="string">true</profile><profile name="chat.font_size" type="string">Normal</profile><profile name="chat.force_tunnel" type="string">false</profile><profile name="chat.join_exit_cues" type="string">false</profile><profile name="chat.observe_whispers" type="string">true</profile><profile name="chat.pm_notifications" type="string">default</profile><profile name="chat.show_send_prompt" type="string">true</profile><profile name="chat.smooth" type="string">false</profile><profile name="chat.sounds.chatting" type="string">false</profile><profile name="chat.sounds.enable" type="string">false</profile><profile name="chat.sounds.new_chatting" type="string">false</profile><profile name="chat.sounds.new_message" type="string">false</profile><profile name="chat.sounds.new_msg_in_my_contact" type="string">false</profile><profile name="chat.sounds.new_user" type="string">false</profile><profile name="chat.sounds.new_waiting" type="string">false</profile><profile name="chat.sounds.to_me" type="string">false</profile><profile name="chat.start_visibility" type="string">normal</profile><profile name="chat.swap_enter" type="string">default</profile><profile name="chat.timestamps" type="string">false</profile><profile name="emoticon_type" type="string">smiley</profile><profile name="kudos_giver_leaderboard_time" type="string">one_week</profile><profile name="kudos_limit_visibility" type="string">false</profile><profile name="kudos_message_leaderboard_time" type="string">one_month</profile><profile name="kudos_user_leaderboard_time" type="string">one_month</profile><profile name="kudos_weight_manual_override" type="string">1</profile><profile name="language" type="string">en</profile><profile name="name_first" type="string">Vidhyashankar</profile><profile name="name_last" type="string">Lakshmanan</profile><profile name="other_badge_orientation" type="string">vertical</profile><profile name="other_badge_show_accepted_solutions" type="string">true</profile><profile name="other_badge_show_avatar" type="string">true</profile><profile name="other_badge_show_blogs" type="string">true</profile><profile name="other_badge_show_ideas" type="string">true</profile><profile name="other_badge_show_kudos" type="string">true</profile><profile name="other_badge_show_post_count" type="string">true</profile><profile name="other_badge_show_rank" type="string">true</profile><profile name="other_badge_show_recent_post" type="string">true</profile><profile name="pm_notification" type="string">false</profile><profile name="portrait_badge_show_accepted_solutions" type="string">true</profile><profile name="portrait_badge_show_answers" type="string">false</profile><profile name="portrait_badge_show_blogs" type="string">false</profile><profile name="portrait_badge_show_ideas" type="string">false</profile><profile name="portrait_badge_show_kudos" type="string">true</profile><profile name="portrait_badge_show_name" type="string">true</profile><profile name="portrait_badge_show_post_count" type="string">false</profile><profile name="portrait_badge_show_rank" type="string">true</profile><profile name="portrait_badge_show_topics" type="string">true</profile><profile name="portrait_display_portrait_badge" type="string">false</profile><profile name="privacy" type="string">all</profile><profile name="privacy_email" type="string">none</profile><profile name="remember_password" type="string">false</profile><profile name="show_messenger" type="string">true</profile><profile name="show_online_status" type="string">all</profile><profile name="show_user_signatures" type="string">true</profile><profile name="sub_email_delivery" type="string">immediate</profile><profile name="sub_email_drafts" type="string">none</profile><profile name="sub_email_edit_request" type="string">false</profile><profile name="sub_email_format" type="string">subject_only</profile><profile name="sub_email_ignore_marked_read" type="string">true</profile><profile name="sub_email_mail_format" type="string">auto</profile><profile name="sub_email_publish_request" type="string">false</profile><profile name="sub_email_remove_html" type="string">true</profile><profile name="sub_email_remove_sigs" type="string">true</profile><profile name="sub_email_self_notify" type="string">false</profile><profile name="sub_email_updates" type="string">none</profile><profile name="twitter_view_stream" type="string">true</profile><profile name="url_icon" type="string">avatar:candy/monsters/death</profile><profile name="url_icon_allow_custom_size" type="string">false</profile><profile name="url_icon_h" type="string">36</profile><profile name="url_icon_max_h" type="string">36</profile><profile name="url_icon_max_w" type="string">36</profile><profile name="url_icon_w" type="string">36</profile><profile name="use_kudos_weight_manual_override" type="string">false</profile><profile name="wordpress_badge_orientation" type="string">vertical</profile><profile name="wordpress_badge_show_accepted_solutions" type="string">true</profile><profile name="wordpress_badge_show_avatar" type="string">true</profile><profile name="wordpress_badge_show_blogs" type="string">true</profile><profile name="wordpress_badge_show_ideas" type="string">true</profile><profile name="wordpress_badge_show_kudos" type="string">true</profile><profile name="wordpress_badge_show_post_count" type="string">true</profile><profile name="wordpress_badge_show_rank" type="string">true</profile><profile name="wordpress_badge_show_recent_post" type="string">true</profile></profiles><banned type="boolean">false</banned></user></response>';
        	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        XMLDom.Element user = root.firstChild();
        system.debug(user);
        LiUser liUser = new LiUser();
        if(root.attributes.get('status') == 'success' && user != NULL) {
            liUser.userId = Integer.valueOf(user.getElementByTagName('id').nodeValue);
            String userId = liUser.userId.format();
            liUser.username = user.getElementByTagName('login').nodeValue;
            //liUser.email = user.getElementByTagName('email').nodeValue;
            Map<String, String> userProfiles = parseUserProfile(user);
            liUser.firstName = userProfiles.get('name_first');
            liUser.lastName = userProfiles.get('name_last');
            liUser.ranking = getUserRanking(userId);
            liUser.iconUrl = getUserIconUrl(userId);
            liUser.postCount = getUserPostCount(userId);
            liUser.recentPostedMessages = getUserMessagePostHistory(userId);
            
            return liUser;
           }
        else
            return NULL;
       }
    
    public static LiUser getUserDetails(Integer userId) {
        Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
        params.put('restapi.response_style', 'view');
    
        HTTPResponse res = executeRest('/users/id/' + userId, 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><response status="success"><user type="user" href="/users/id/3" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/3"><id type="int">3</id><registered type="boolean">true</registered><deleted type="boolean">false</deleted><login type="string">lvshankar</login><anonymous type="boolean">false</anonymous><last_visit_time type="date_time" view_date="09-30-2011" view_time="07:24 AM">2011-09-30T14:24:21+00:00</last_visit_time><email type="string">vidhyashankar@cloudsquads.com</email><registration_time type="date_time" view_date="02-01-2011" view_time="09:54 PM">2011-02-02T05:54:44+00:00</registration_time><average_message_rating type="float">0.0</average_message_rating><average_rating type="float">0.0</average_rating><profiles><profile name="auto_mark_read" type="string">never</profile><profile name="auto_mark_read_days" type="string">0</profile><profile name="auto_subscribe_on_post" type="string">none</profile><profile name="autosave_interval" type="string">30</profile><profile name="blogger_badge_orientation" type="string">vertical</profile><profile name="blogger_badge_show_accepted_solutions" type="string">true</profile><profile name="blogger_badge_show_avatar" type="string">true</profile><profile name="blogger_badge_show_blogs" type="string">true</profile><profile name="blogger_badge_show_ideas" type="string">true</profile><profile name="blogger_badge_show_kudos" type="string">true</profile><profile name="blogger_badge_show_post_count" type="string">true</profile><profile name="blogger_badge_show_rank" type="string">true</profile><profile name="board_subscribe_method" type="string">message</profile><profile name="charset_email" type="string">UTF-8</profile><profile name="charset_email_ca" type="string">UTF-8</profile><profile name="charset_email_da" type="string">UTF-8</profile><profile name="charset_email_de" type="string">UTF-8</profile><profile name="charset_email_en" type="string">UTF-8</profile><profile name="charset_email_en-gb" type="string">UTF-8</profile><profile name="charset_email_es" type="string">UTF-8</profile><profile name="charset_email_es-mx" type="string">UTF-8</profile><profile name="charset_email_fr" type="string">UTF-8</profile><profile name="charset_email_in" type="string">UTF-8</profile><profile name="charset_email_it" type="string">UTF-8</profile><profile name="charset_email_ja" type="string">UTF-8</profile><profile name="charset_email_ko" type="string">UTF-8</profile><profile name="charset_email_nl" type="string">UTF-8</profile><profile name="charset_email_no" type="string">UTF-8</profile><profile name="charset_email_pt" type="string">UTF-8</profile><profile name="charset_email_pt-br" type="string">UTF-8</profile><profile name="charset_email_ru" type="string">UTF-8</profile><profile name="charset_email_sv" type="string">UTF-8</profile><profile name="charset_email_zh-cn" type="string">UTF-8</profile><profile name="charset_email_zh-tw" type="string">UTF-8</profile><profile name="chat.compact" type="string">false</profile><profile name="chat.extra_info" type="string">true</profile><profile name="chat.font_size" type="string">Normal</profile><profile name="chat.force_tunnel" type="string">false</profile><profile name="chat.join_exit_cues" type="string">false</profile><profile name="chat.observe_whispers" type="string">true</profile><profile name="chat.pm_notifications" type="string">default</profile><profile name="chat.show_send_prompt" type="string">true</profile><profile name="chat.smooth" type="string">false</profile><profile name="chat.sounds.chatting" type="string">false</profile><profile name="chat.sounds.enable" type="string">false</profile><profile name="chat.sounds.new_chatting" type="string">false</profile><profile name="chat.sounds.new_message" type="string">false</profile><profile name="chat.sounds.new_msg_in_my_contact" type="string">false</profile><profile name="chat.sounds.new_user" type="string">false</profile><profile name="chat.sounds.new_waiting" type="string">false</profile><profile name="chat.sounds.to_me" type="string">false</profile><profile name="chat.start_visibility" type="string">normal</profile><profile name="chat.swap_enter" type="string">default</profile><profile name="chat.timestamps" type="string">false</profile><profile name="emoticon_type" type="string">smiley</profile><profile name="kudos_giver_leaderboard_time" type="string">one_week</profile><profile name="kudos_limit_visibility" type="string">false</profile><profile name="kudos_message_leaderboard_time" type="string">one_month</profile><profile name="kudos_user_leaderboard_time" type="string">one_month</profile><profile name="kudos_weight_manual_override" type="string">1</profile><profile name="language" type="string">en</profile><profile name="name_first" type="string">Vidhyashankar</profile><profile name="name_last" type="string">Lakshmanan</profile><profile name="other_badge_orientation" type="string">vertical</profile><profile name="other_badge_show_accepted_solutions" type="string">true</profile><profile name="other_badge_show_avatar" type="string">true</profile><profile name="other_badge_show_blogs" type="string">true</profile><profile name="other_badge_show_ideas" type="string">true</profile><profile name="other_badge_show_kudos" type="string">true</profile><profile name="other_badge_show_post_count" type="string">true</profile><profile name="other_badge_show_rank" type="string">true</profile><profile name="other_badge_show_recent_post" type="string">true</profile><profile name="pm_notification" type="string">false</profile><profile name="portrait_badge_show_accepted_solutions" type="string">true</profile><profile name="portrait_badge_show_answers" type="string">false</profile><profile name="portrait_badge_show_blogs" type="string">false</profile><profile name="portrait_badge_show_ideas" type="string">false</profile><profile name="portrait_badge_show_kudos" type="string">true</profile><profile name="portrait_badge_show_name" type="string">true</profile><profile name="portrait_badge_show_post_count" type="string">false</profile><profile name="portrait_badge_show_rank" type="string">true</profile><profile name="portrait_badge_show_topics" type="string">true</profile><profile name="portrait_display_portrait_badge" type="string">false</profile><profile name="privacy" type="string">all</profile><profile name="privacy_email" type="string">none</profile><profile name="remember_password" type="string">false</profile><profile name="show_messenger" type="string">true</profile><profile name="show_online_status" type="string">all</profile><profile name="show_user_signatures" type="string">true</profile><profile name="sub_email_delivery" type="string">immediate</profile><profile name="sub_email_drafts" type="string">none</profile><profile name="sub_email_edit_request" type="string">false</profile><profile name="sub_email_format" type="string">subject_only</profile><profile name="sub_email_ignore_marked_read" type="string">true</profile><profile name="sub_email_mail_format" type="string">auto</profile><profile name="sub_email_publish_request" type="string">false</profile><profile name="sub_email_remove_html" type="string">true</profile><profile name="sub_email_remove_sigs" type="string">true</profile><profile name="sub_email_self_notify" type="string">false</profile><profile name="sub_email_updates" type="string">none</profile><profile name="twitter_view_stream" type="string">true</profile><profile name="url_icon" type="string">avatar:candy/monsters/death</profile><profile name="url_icon_allow_custom_size" type="string">false</profile><profile name="url_icon_h" type="string">36</profile><profile name="url_icon_max_h" type="string">36</profile><profile name="url_icon_max_w" type="string">36</profile><profile name="url_icon_w" type="string">36</profile><profile name="use_kudos_weight_manual_override" type="string">false</profile><profile name="wordpress_badge_orientation" type="string">vertical</profile><profile name="wordpress_badge_show_accepted_solutions" type="string">true</profile><profile name="wordpress_badge_show_avatar" type="string">true</profile><profile name="wordpress_badge_show_blogs" type="string">true</profile><profile name="wordpress_badge_show_ideas" type="string">true</profile><profile name="wordpress_badge_show_kudos" type="string">true</profile><profile name="wordpress_badge_show_post_count" type="string">true</profile><profile name="wordpress_badge_show_rank" type="string">true</profile><profile name="wordpress_badge_show_recent_post" type="string">true</profile></profiles><banned type="boolean">false</banned></user></response>';
        	}
        	
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        XMLDom.Element user = root.firstChild();
        system.debug(user);
        LiUser liUser = new LiUser();
        if(root.attributes.get('status') == 'success' && user != NULL) {
            liUser.userId = Integer.valueOf(user.getElementByTagName('id').nodeValue);
            String userIdStr = liUser.userId.format();
            liUser.username = user.getElementByTagName('login').nodeValue;
            //liUser.email = user.getElementByTagName('email').nodeValue;
            Map<String, String> userProfiles = parseUserProfile(user);
            liUser.firstName = userProfiles.get('name_first');
            liUser.lastName = userProfiles.get('name_last');
            liUser.ranking = getUserRanking(userIdStr);
            liUser.iconUrl = getUserIconUrl(userIdStr);
            liUser.postCount = getUserPostCount(userIdStr);
            liUser.recentPostedMessages = getUserMessagePostHistory(userIdStr);
            
            return liUser;
           }
        else
            return NULL;
       }
    
    public static string getUserIconUrl(string userId) {
        Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
        
        HTTPResponse res = executeRest('/users/id/' + userId + '/profiles/avatar', 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><response status="success"><image type="image" href="/users/id/1/profiles/avatar"><url type="string">http://cloudsquadsdev.stage.lithium.com/t5/image/serverpage/avatar-name/environment-clouds/avatar-theme/classic/avatar-collection/environment/avatar-display-size/message</url><width type="integer" null="true"/><height type="integer" null="true"/></image></response>';
        	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        if(root.attributes.get('status') == 'success')
            return root.firstChild().firstChild().nodeValue;
        else
            return NULL;
       }
    
    public static List<LiMessage> getUserMessagePostHistory(string userId) {
        List<LiMessage> recentMessages = new List<LiMessage>();
        Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
        params.put('restapi.response_style', 'view');
        params.put('restapi.format_detail', 'full_list_element');
        
        HTTPResponse res = executeRest('/users/id/' + userId + '/posts/latest', 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><response status="success"><messages><message type="message" href="/messages/id/13"><id type="int">13</id><read_only type="boolean">false</read_only><subject type="string">Test subject</subject><deleted type="boolean">false</deleted><author type="user" href="/users/id/1"><login type="string">admin</login></author><thread type="thread" href="/threads/id/13"/><board type="board" href="/boards/id/First"/><parent type="message" null="true"/><teaser type="string"></teaser><views><count type="int">19</count></views><root type="message" href="/messages/id/13"/><board_id type="int">8</board_id><post_time type="date_time">2011-09-28T20:11:12+00:00</post_time><message_rating type="float">0.0</message_rating><last_edit_author type="user" href="/users/id/1"><login type="string">admin</login></last_edit_author><kudos><count type="int">0</count></kudos><last_edit_time type="date_time">2011-09-28T20:11:12+00:00</last_edit_time></message></messages></response>';
        	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        XMLDom.Element messages = root.firstChild();
        system.debug(messages);
        if(root.attributes.get('status') == 'success') {
            recentMessages = parseMessagesXMLDom(messages);
           }
        
        return recentMessages;
       }
    
    public static integer getUserPostCount(string userId) {
        Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
        
        HTTPResponse res = executeRest('/users/id/' + userId + '/posts/count', 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
         	response = '<response status="success"><value type="long">1</value></response>';
         	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        XMLDom.Element value = root.firstChild();
        system.debug(value);
        if(root.attributes.get('status') == 'success' && value != NULL)
            return Integer.valueOf(value.nodeValue);
        else
            return 0;
       }
    
    public static string getUserRanking(string userId) {
        Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
    
        HTTPResponse res = executeRest('/users/id/' + userId + '/ranking', 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
         	response = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><response status="success"><ranking type="ranking" href="/rankings/id/1"><name type="string">Community Manager</name><id type="int">1</id><display><color type="string">FF0000</color><bold type="boolean">true</bold><left_image type="image" href="/rankings/id/1image"><url type="string">http://cloudsquadsdev.stage.lithium.com/i/rank_icons/admin.gif</url><width type="integer" null="true"/><height type="integer" null="true"/></left_image><right_image type="image" null="true"/><thread_image type="image" null="true"/></display></ranking></response>';
         	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        XMLDom.Element ranking = root.firstChild();
        system.debug(ranking);
        if(root.attributes.get('status') == 'success' && ranking != NULL)
            return ranking.firstChild().nodeValue;
        else
            return NULL;
       }
       
    /*public static string getCommunityUserId(string userId) {
    	Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
    
        HTTPResponse res = executeRest('/users/id/' + userId + '/settings/name/salesforce.id', 'GET', params);
        
        XMLDom xmlDom = new XMLDom(res.getBody());
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        system.debug(root);
        if(root.attributes.get('status') == 'success') 
        	return root.firstChild().nodeValue;
        else
        	return NULL;
    	}
    	
    public static Boolean setCommunityUserId(string userId, string communityUserId) {
    	Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
        params.put('value', communityUserId);
    
        HTTPResponse res = executeRest('/users/id/' + userId + '/settings/name/salesforce.id/set', 'POST', params);
        
        XMLDom xmlDom = new XMLDom(res.getBody());
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        return root.attributes.get('status') == 'success';
    	}*/
    
    public static List<LiMessage> searchCommunity(string searchString) {
        List<LiMessage> recentMessages = new List<LiMessage>();
        Map<String,String> params = new Map<String, String>();
        params.put('q', searchString);
        params.put('restapi.session_key', login());
        params.put('restapi.response_style', 'view');
        params.put('restapi.format_detail', 'full_list_element');
            
        HTTPResponse res = executeRest('/search/messages', 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><response status="success"><messages><message type="message" href="/messages/id/11"><id type="int">11</id><read_only type="boolean">false</read_only><subject type="string">How to show this in Sf?</subject><deleted type="boolean">false</deleted><author type="user" href="/users/id/2"><login type="string">cloudadmin</login></author><thread type="thread" href="/threads/id/11"/><board type="board" href="/boards/id/First"/><parent type="message" null="true"/><teaser type="string"></teaser><views><count type="int">7</count></views><root type="message" href="/messages/id/11"/><board_id type="int">7</board_id><post_time type="date_time">2011-09-27T14:11:36+00:00</post_time><message_rating type="float">0.0</message_rating><last_edit_author type="user" href="/users/id/2"><login type="string">cloudadmin</login></last_edit_author><kudos><count type="int">0</count></kudos><last_edit_time type="date_time">2011-09-27T14:11:36+00:00</last_edit_time></message></messages></response>';
        	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        XMLDom.Element messages = root.firstChild();
        system.debug(messages);
        if(root.attributes.get('status') == 'success') {
            recentMessages = parseMessagesXMLDom(messages);
           }
        
        return recentMessages;
       }
    
    public static List<LiMessage> threadList(string threadId, string boardId) {
        List<LiMessage> threadMessages = new List<LiMessage>();
        Map<String,String> params = new Map<String, String>();
        params.put('restapi.session_key', login());
        params.put('restapi.response_style', 'view');
        params.put('restapi.format_detail', 'full_list_element');
        
        HTTPResponse res = executeRest('/boards/id/' + boardId + '/threads/id/' + threadId, 'GET', params);
        String response = res.getBody();
        
        if(Test.isRunningTest()) {
        	response = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><response status="success"><thread type="thread" href="/threads/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/td-p/24"><id type="int">24</id><title type="string" null="true"/><board type="board" href="/boards/id/First" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/bd-p/First"/><messages><topic type="message" href="/messages/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/24#M19"><id type="int">24</id><read_only type="boolean">false</read_only><subject type="string">I am new here...</subject><deleted type="boolean">false</deleted><author type="user" href="/users/id/7" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/7"><login type="string">lvs-test</login></author><body type="string">&lt;P&gt;....and I already have a problem!&lt;/P&gt;</body><thread type="thread" href="/threads/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/td-p/24"/><board type="board" href="/boards/id/First" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/bd-p/First"/><parent type="message" null="true"/><teaser type="string"></teaser><views><count type="int">22</count></views><root type="message" href="/messages/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/24#M19"/><board_id type="int">19</board_id><post_time type="date_time" view_date="10-07-2011" view_time="02:17 AM">2011-10-07T09:17:44+00:00</post_time><message_rating type="float">0.0</message_rating><last_edit_author type="user" href="/users/id/7" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/7"><login type="string">lvs-test</login></last_edit_author><kudos><count type="int">0</count></kudos><last_edit_time type="date_time" view_date="10-07-2011" view_time="02:17 AM">2011-10-07T09:17:44+00:00</last_edit_time></topic><read><count type="int">0</count></read><linear><message type="message" href="/messages/id/25" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/25#M20"><id type="int">25</id><read_only type="boolean">false</read_only><subject type="string">Re: I am new here...</subject><deleted type="boolean">false</deleted><author type="user" href="/users/id/2" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/2"><login type="string">cloudadmin</login></author><body type="string">&lt;P&gt;please call our customer support!&lt;/P&gt;</body><thread type="thread" href="/threads/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/td-p/24"/><board type="board" href="/boards/id/First" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/bd-p/First"/><parent type="message" href="/messages/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/24#M19"/><teaser type="string"></teaser><views><count type="int">2</count></views><root type="message" href="/messages/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/24#M19"/><board_id type="int">20</board_id><post_time type="date_time" view_date="10-07-2011" view_time="03:23 AM">2011-10-07T10:23:10+00:00</post_time><message_rating type="float">0.0</message_rating><last_edit_author type="user" href="/users/id/2" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/2"><login type="string">cloudadmin</login></last_edit_author><kudos><count type="int">0</count></kudos><last_edit_time type="date_time" view_date="10-07-2011" view_time="03:23 AM">2011-10-07T10:23:10+00:00</last_edit_time></message><message type="message" href="/messages/id/26" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/26#M21"><id type="int">26</id><read_only type="boolean">false</read_only><subject type="string">Re: I am new here...</subject><deleted type="boolean">false</deleted><author type="user" href="/users/id/2" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/2"><login type="string">cloudadmin</login></author><body type="string">&lt;P&gt;Got the answer - don&apos;t bother&lt;/P&gt;</body><thread type="thread" href="/threads/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/td-p/24"/><board type="board" href="/boards/id/First" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/bd-p/First"/><parent type="message" href="/messages/id/25" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/25#M20"/><teaser type="string"></teaser><views><count type="int">0</count></views><root type="message" href="/messages/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/24#M19"/><board_id type="int">21</board_id><post_time type="date_time" view_date="10-09-2011" view_time="10:28 PM">2011-10-10T05:28:35+00:00</post_time><message_rating type="float">0.0</message_rating><last_edit_author type="user" href="/users/id/2" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/2"><login type="string">cloudadmin</login></last_edit_author><kudos><count type="int">0</count></kudos><last_edit_time type="date_time" view_date="10-09-2011" view_time="10:28 PM">2011-10-10T05:28:35+00:00</last_edit_time></message><message type="message" href="/messages/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/24#M19"><id type="int">24</id><read_only type="boolean">false</read_only><subject type="string">I am new here...</subject><deleted type="boolean">false</deleted><author type="user" href="/users/id/7" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/7"><login type="string">lvs-test</login></author><body type="string">&lt;P&gt;....and I already have a problem!&lt;/P&gt;</body><thread type="thread" href="/threads/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/td-p/24"/><board type="board" href="/boards/id/First" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/bd-p/First"/><parent type="message" null="true"/><teaser type="string"></teaser><views><count type="int">22</count></views><root type="message" href="/messages/id/24" view_href="http://cloudsquadsdev.stage.lithium.com/t5/First-Board/I-am-new-here/m-p/24#M19"/><board_id type="int">19</board_id><post_time type="date_time" view_date="10-07-2011" view_time="02:17 AM">2011-10-07T09:17:44+00:00</post_time><message_rating type="float">0.0</message_rating><last_edit_author type="user" href="/users/id/7" view_href="http://cloudsquadsdev.stage.lithium.com/t5/user/viewprofilepage/user-id/7"><login type="string">lvs-test</login></last_edit_author><kudos><count type="int">0</count></kudos><last_edit_time type="date_time" view_date="10-07-2011" view_time="02:17 AM">2011-10-07T09:17:44+00:00</last_edit_time></message></linear><count type="int">3</count></messages><interaction_style type="string">board</interaction_style></thread></response>';
        	}
        
        XMLDom xmlDom = new XMLDom(response);
        XMLDom.Element root = xmlDom.getElementByTagName('response');
        
        XMLDom.Element thread = root.firstChild();
        system.debug(thread);
        if(root.attributes.get('status') == 'success') {
            XMLDom.Element threadReplies = thread.getElementByTagName('messages');
            XMLDom.Element threadList = thread.getElementByTagName('linear');
            threadMessages = parseMessagesXMLDom(threadList);
            Integer idx = threadMessages.size() - 1;
            threadMessages.remove(idx); // remove root message from thread
           }
        
        return threadMessages;
       }
    
    public static Map<String, String> parseUserProfile(XMLDom.Element anUser) {
        Map<String, String> userProfile = new Map<String, String>();
        List<XMLDom.Element> profileValues = new List<XMLDom.Element>();
        
        XMLDom.Element profiles = anUser.getElementByTagName('profiles');
        if(profiles != NULL)
            profileValues.addAll(profiles.getElementsByTagName('profile'));
        
        for(XMLDom.Element anElement : profileValues) {
            userProfile.put(anElement.getAttribute('name'), anElement.nodeValue);
           }
        
        return userProfile;
       }
    
    public static List<LiMessage> parseMessagesXMLDom(XMLDom.Element messages) {
        List<LiMessage> recentMessages = new List<LiMessage>();
        List<XMLDom.Element> xMessages = messages.getElementsByTagName('message');
        
        for(XMLDom.Element message : xMessages) {
            LiMessage recentMessage = new LiMessage();
            recentMessage.messageId = Integer.valueOf(message.getElementByTagName('id').nodeValue);
            recentMessage.subject = message.getElementByTagName('subject').nodeValue;
            String teaser = message.getElementByTagName('teaser').nodeValue;
            recentMessage.teaser = (teaser != NULL)?teaser:'';
            recentMessage.authorUsername = message.getElementByTagName('author').getElementByTagName('login').nodeValue;
            recentMessage.boardId = Integer.valueOf(message.getElementByTagName('board_id').nodeValue);
            recentMessage.kudos = Integer.valueOf(message.getElementByTagName('kudos').getElementByTagName('count').nodeValue);
            recentMessage.views = Integer.valueOf(message.getElementByTagName('views').getElementByTagName('count').nodeValue);
            recentMessage.url = message.getAttribute('view_href');
            XMLDom.Element body = message.getElementByTagName('body');
            if(body != NULL)
                recentMessage.body = body.nodeValue;
            string postTimeStr = message.getElementByTagName('post_time').nodeValue;
            postTimeStr = postTimeStr.replace('T', ' ');
            recentMessage.postTime = dateTime.valueOf(postTimeStr);
            
            recentMessages.add(recentMessage);
           }
        
        return recentMessages;
       }
    
    public class LiUser {
        public integer userId {get; set;}
        public string username {get; set;}
        public string firstName {get; set;}
        public string lastName {get; set;}
        public string email {get; set;}
        public string ranking {get; set;}
        public string iconUrl {get; set;}
        public integer postCount {get; set;}
        public dateTime lastVisit {get; set;}
        public dateTime registered {get; set;}
        public List<LiMessage> recentPostedMessages {get; set;}
        
        public LiUser() {
            userId = 0;
            username = '';
            firstName = '';
            lastName = '';
            ranking = '';
            iconUrl = '';
            postCount  = 0;
            recentPostedMessages = new List<LiMessage>();
           }
       }
    
    public class LiMessage {
        public integer messageId {get; set;}
        public string subject {get; set;}
        public string authorUsername {get; set;}
        public integer boardId {get; set;}
        public dateTime postTime {get; set;}
        public integer kudos {get; set;}
        public string body {get; set;}
        public string teaser {get; set;}
        public string url {get; set;}
        public Integer views {get; set;}
        
        public LiMessage() {
            messageId = 0;
            subject = '';
            authorUsername = '';
            boardId = 0;
            kudos  = 0;
            body = '';
            teaser = '';
            url = '';
            views = 0;
           }
       }
   }