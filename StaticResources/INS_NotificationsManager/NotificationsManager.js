
var AGING_REFRESH = 180000; // update every 3 minutes
var timeoutBetweenNewNotifications = null; // used for processing big amount of notifications and keep the console window responsiveness
var timeoutForDissmissAllNotifications = null; // used for processing big amount of dissmissing notifications ('Dismiss All') and keep the console window responsiveness
var dismissedNotifications = new Array(); // used to retain dismissed notifications when 'Dismiss All' button is pushed

// MemberId is an optional parameter and should be passed only to filter notifications for a particular memmber
var NotificationsManager = function (sessionID, userId, memberId)
{

    //Establish Session id for the connection API
    sforce.connection.sessionId = sessionID;

    var userId = userId;
    //memberId is optional
    var memberId = typeof memberId !== 'undefined' ? memberId : null;
    var notificationsResult;

    //Events
    var newNotificationEvent = null;
    var notificationDismissedEvent = null;


    //public properties
    this.QueryMore = false;


    //The event manager will filter the incomming events and deliver to the correct event handler
    var cometdEventManager = function (message)
    {
        if (this.isAddressed(message))
        {
            if (message.data.sobject.Status__c == 'Open')
            {
                if (newNotificationEvent != null)
                {
                    clearTimeout(timeoutBetweenNewNotifications);
                	timeoutBetweenNewNotifications = setTimeout(newNotificationEvent, 1000, NotificationsManager.getNotification(message));
                    //newNotificationEvent(NotificationsManager.getNotification(message));
                }
            } else
            {
                if (notificationDismissedEvent != null)
                {
                    notificationDismissedEvent(NotificationsManager.getNotification(message));
                }
            }
        }
    }


    //Public Methods

    //Start listening for Events. Subscribe to the cometD channel
    this.startListening = function (newNotificationHandler, notificationDismissedHanlder)
    {
        // Connect to the CometD endpoint
        newNotificationEvent = newNotificationHandler;
        notificationDismissedEvent = notificationDismissedHanlder;

        $jq.cometd.init({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/24.0/',
            requestHeaders: { Authorization: 'OAuth ' + sessionID }
        });

        // Subscribe to a topic. JSON-encoded update will be returned
        // in the callback
        $jq.cometd.subscribe('/topic/NewNotificationUpdates', this, cometdEventManager);

    }

    //Message filter (this method can be private)
    this.isAddressed = function (message)
    {
        var notification = message.data.sobject;
        if (notification.Assigned_To__c)
        {
            return ((userId == null || notification.Assigned_To__c == userId || notification.Assigned_To__c == null) && (memberId == null || notification.Member__c == memberId));
        }
        else
        {
            return (memberId == null || notification.Member__c == memberId);
        }
    }


    //Returns all the notifications still opened based on the Member and User filter
    this.getNotifications = function ()
    {
        var squery = 'SELECT ID,Status__c,Subject__c, LongDescription__c,Assigned_To__c,Member__c,Type__c,Related_Object_Type__c, Related_Object_Id__c, Show_Until__c, Aging__c, CreatedDate, Allow_Tasks__c, Allow_Dismiss__c FROM Notification__c WHERE Status__c = \'Open\' AND (Show_Until__c >= TODAY OR Show_Until__c = 1999-01-01 OR Show_Until__c = null)';
        if (userId != null)
        {
            squery += 'AND (Assigned_To__c = \'' + userId + '\' or Assigned_To__c = null)';
        }
        if (memberId != null)
        {
            squery += ' AND Member__c = \'' + memberId + '\'';
        }
        squery += ' ORDER by CreatedDate desc';

        notificationsResult = sforce.connection.query(squery);
        var records = notificationsResult.getArray("records");
        this.QueryMore = (!notificationsResult.getBoolean("done"));
        return records;
    }

    this.dismissAll = function ()
    {
        var recordsUpdated = sforce.apex.execute("INS_NotificationCenterExtension", "DismissAll", { userId: userId, memberId: memberId });
        return recordsUpdated;
    }

	this.dismissAllNotifications = function () {
		$jq('.nc-notification_area').each(function(index) {
			var succeeded = NotificationsManager.dismissNotificationForDismissAll($jq(this)[0].id, true);
		});

		//if ($('.nc-notification_area')!=null) {
		//	alert('There was an error while dismissing notifications - some of them are not dismissed. Pleae try again.');
		//}
	}
};


// Static Methods

// Returns the aging text
NotificationsManager.getAging = function (agingInMinutes) {
    var word = 'minute';
    var value = Math.round(agingInMinutes);
    if (value >= 60) {
        value = Math.round(value / 60);
        word = 'hour';
        if (value >= 24) {
            value = Math.round(value / 24);
            word = 'day';
        }
    }
    if (value > 1) {
        word += 's';
    }
    return [value + ' ' + word, value, word];
}

//Extracts notification object from cometD message
NotificationsManager.getNotification = function (message) {
    var toReturn = message.data.sobject;
    return toReturn;
};


//Get The HTML for the notification, the reason to put this here is to unify the HTML creation, 
//in a future phase we can expose a method to get the class
NotificationsManager.getNotificationHTML = function (notification, htmlType)
{

    var getTime = function (dateTime)
    {
        var a_p = "";
        var d = new Date(dateTime);
        var curr_hour = d.getHours();
        if (curr_hour < 12)
        {
            a_p = "AM";
        } else
        {
            a_p = "PM";
        }
        if (curr_hour == 0)
        {
            curr_hour = 12;
        } else if (curr_hour > 12)
        {
            curr_hour = curr_hour - 12;
        }
        var curr_min = d.getMinutes();
        if (curr_min < 10)
        {
            curr_min = '0' + curr_min;
        }
        return curr_hour + ':' + curr_min + ' ' + a_p;
    };

    htmlType = typeof htmlType !== 'undefined' ? htmlType : 'NORM';

    // CSS Class for each Notification Type
    var NT_CLASSES = new Array();
    NT_CLASSES['Customer Alert'] = 'nc-notifications_user_alert';
    NT_CLASSES['Customer Profile Modification'] = 'nc-notifications_profile_modified';
    NT_CLASSES['User Alert'] = 'nc-notifications_user_alert';
    
    //Parse description extracting the LINK
    var __parseDescription = function (description)
    {
        if (!description)
        {
            description = "";
        }
        var LINK_REGEX = 'LINK\\[([^,]+),([^\\]]*)\\]';

        // This regex will replace LINK[descriptio,url] for <a />s
        var regexLinkRep = new RegExp(LINK_REGEX, 'gi');
        var replaceLink = function (match, description, objectIdOrUrl, offset, string)
        {
            return '<span class="nc-link" objectIdOrUrl="' + objectIdOrUrl + '"><a href="#">' + description + '</a><span>';
        };
        description = description.replace(regexLinkRep, replaceLink);
        return description;
    }

    //Get icon class
    var ntClass = NT_CLASSES[notification.Type__c];
    //Get aging text
    var clientCreatedDate = new Date();
    //Set value in miliseconds, this is the CreatedDate calculated in the client Side as currentDate (client side) - minutes old this notification has been created.
    //This field is stored in the object to be later used by the Time updating process.
    clientCreatedDate = clientCreatedDate.setMinutes(clientCreatedDate.getMinutes() - notification.Aging__c);
    var aging = NotificationsManager.getAging(notification.Aging__c); // when we are just creating the element we can directly use the aging.


    //Generate HTML
    var hrml;
    switch (htmlType)
    {
        case 'NORM':

            var arrHTML = ['<div class="nc-notification_area" id="' + notification.Id + '">'];
            if (notification.Assigned_To__c && notification.Allow_Dismiss__c == "true")
            {
                arrHTML.push('<span class="nc-Notifications_dismiss"><a href="#">X</a></span>');

                if (notification.Allow_Tasks__c == "true")
                {
                    arrHTML.push('<span class="nc_divisor">|</span>');
                    arrHTML.push('<span class="nc-Notifications_create"><a href="#">+</a></span>');
                }
            }
            else
            {
                if (notification.Allow_Tasks__c == "true")
                {
                    arrHTML.push('<span class="nc-Notifications_create"><a href="#">+</a></span>');
                }
            }

            arrHTML.push('<span class="nc-Notifications_nolink">' + __parseDescription(notification.Subject__c) + '</span>');
            arrHTML.push('<br/><span class="nc-Notifications_nolink">' + __parseDescription(notification.LongDescription__c) + '</span>');
            arrHTML.push('<br/><span class="nc_icon"><span class="' + ntClass + '"></span><span class="nc_icon_detail" aging="' + clientCreatedDate + '">' + aging[0] + ' ago</span></span></div>');
            html = arrHTML.join('');

            break;
        case 'VIEWALL':
            var arrHTML = ['<div class="nc-notification_area_all" id="' + notification.Id + '">'];

            if (notification.Assigned_To__c && notification.Allow_Dismiss__c == "true")
            {
                arrHTML.push('<span class="nc-Notifications_dismiss"><a href="#">X</a></span>');

                if (notification.Allow_Tasks__c == "true")
                {
                    arrHTML.push('<span class="nc_divisor">|</span>');
                    arrHTML.push('<span class="nc-Notifications_create"><a href="#">+</a></span>');
                }
            }
            else
            {
                if (notification.Allow_Tasks__c == "true")
                {
                    arrHTML.push('<span class="nc-Notifications_create"><a href="#">+</a></span>');
                }
            }

            arrHTML.push('<span class="nc_icon_all"><span class="' + ntClass + '"></span></span><span class="nc-Notifications_nolink">' + __parseDescription(notification.Subject__c) + '</span>');
            arrHTML.push('<span class="nc_icon_detail_all">' + getTime(notification.CreatedDate) + '</span><br/>');
            arrHTML.push('<span class="nc_icon_all" style="visibility:hidden"><span class="' + ntClass + '"></span></span><span class="nc-Notifications_nolink">' + __parseDescription(notification.LongDescription__c) + '</span></div>');

            html = arrHTML.join('');

            break;
    }
    return html;
};


NotificationsManager.getNotificationHTMLFromMessage = function (message) {
    return NotificationsManager.getNotificationHTML(NotificationsManager.getNotification(message));
};

//Dismiss notification based on ID
NotificationsManager.dismissNotification = function (notificationId, showErrors) {
    var notification = new sforce.SObject("Notification__c");
    notification.id = notificationId;
    notification.Status__c = 'Dismissed';
    result = sforce.connection.update([notification]);
    if (result[0].getBoolean("success")) {
        //log("Notification with id " + result[0].id + " updated");
		return true;
    } else {
        if (showErrors==true) {
			alert("failed to update Notification " + result[0]);
		}

		return false;
    }
}

//Dismiss notification based on ID. Used when 'Dismiss All' button is pushed
NotificationsManager.dismissNotificationForDismissAll = function (notificationId, showErrors) {
    var notification = new sforce.SObject("Notification__c");
    notification.id = notificationId;
    notification.Status__c = 'Dismissed';
    dismissedNotifications.push(notification);
	clearTimeout(timeoutForDissmissAllNotifications);
	timeoutForDissmissAllNotifications = setTimeout(NotificationsManager.updateDismissedNotifications, 100, dismissedNotifications, showErrors);
}

// This mettod for updating list of dismissed Notifications in SalesForce
NotificationsManager.updateDismissedNotifications = function (dismissedNotificationsList, showErrors) {
    dismissedNotifications = new Array();
	for (var first=0, last=100; last <= (dismissedNotificationsList.length + 100); first+=100, last+=100) {
		var oneHoundredRecord = dismissedNotificationsList.slice(first,last);
		result = sforce.connection.update(oneHoundredRecord);
	
		for(var i=0; i<result.length; i++) {
			if (result[i].getBoolean("success")) {
				//log("Notification with id " + result[i].id + " updated");
			} else {
				if (showErrors==true) {
					alert("failed to update Notification " + result[i]);
				}
				return false;
			}
		}
	}

	$jq('#content').empty();
	return true;
}

//Method to update ageing every AGING_REFRESH time
Notification.updateAging = function () {
    $jq(".nc_icon_detail").each(function () {
        var clientCreatedDate = $jq(this).attr('aging');
        // the new age in minutes for this object will be the currentDate (in ms) - clientCreatedDate (in ms) / 60000
        var aging = ((new Date()).getTime() - clientCreatedDate) / 60000;
        var age = NotificationsManager.getAging(aging);
        $jq(this).text(age[0]);
    });
    setTimeout(Notification.updateAging, AGING_REFRESH);
}

var t = setTimeout(Notification.updateAging, AGING_REFRESH);

