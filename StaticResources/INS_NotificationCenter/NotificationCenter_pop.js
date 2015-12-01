// JScript source code

var np;

function initPage()
{
    sforce.console.onCustomConsoleComponentButtonClicked(eventHandler);


    //General Efect to dismiss notification   
    var notificationDismissEffect = function (element) {
        element.fadeOut('slow', function () {
            $jq(this).remove();
        });
    }

    //Events handlers
    var newNotificationHandler = function (notification) {
        /*var element = $jq(NotificationsManager.getNotificationHTML(notification)).hide();
        $jq('#content').prepend(element);
        element.fadeIn('slow');*/
		refreshNotifications();
        blinkButton();
    }

    //this event hanlder will be called when a dismissed event is received
    //by the Notification Manager, if the element was dismissed from this
    //page the element may not be there. However if the element was dismissed
    //somewhere else...    
    var notificationDismissedHanlder = function (notification) {
        if ($jq('#' + notification.Id).length > 0) {
            notificationDismissEffect($jq('#' + notification.Id));
        }
    }


    //Notification click handlers                   
    $jq(document).on('click', '.nc-Notifications_dismiss', function () {
        var notificationId = $jq(this).parent().attr('id');
        notificationDismissEffect($jq(this).parent());
        NotificationsManager.dismissNotification(notificationId);
    });

    $jq(document).on('click', '.nc-Notifications_create', function () {
        var notificationId = $jq(this).parent().attr('id');
        //for certain reason I had a hard time including this logic in the notification
        // manager, the sessionId was replaced by a JQ function causing an error
        var taskId = sforce.apex.execute("INS_NotificationCenterExtension", "CreateTask", { notificationId: notificationId });
        sforce.console.openPrimaryTab(null, '/' + taskId + '/e?retUrl=%2F' + taskId, true);
    });

    //handler for the links in the notifications
    $jq(document).on('click', '.nc-link', function () {
        var id = $jq(this).attr('objectIdOrUrl');
        sforce.console.openPrimaryTab(null, '/' + id, true);
    });



    np = new NotificationsManager(sessionId, userId);

    var notifications = np.getNotifications();
    for (var i = 0; i < notifications.length; i++) {
        $jq('#content').append(NotificationsManager.getNotificationHTML(notifications[i]));

    }

    np.startListening(newNotificationHandler, notificationDismissedHanlder);

    $jq('.nc-Notifications_title_dismiss').click(function(){
        var r=confirm('Are you sure you want to Dismiss All these notifications?');
        if (r==true) {
			np = new NotificationsManager(sessionId, userId);
            np.dismissAllNotifications();
			//$jq('#content').empty();
        }
    });

    $jq('.nc-Notifications_title_view').click(function () {
        sforce.console.openPrimaryTab(null, '/apex/INS_NotificationCenter_ViewAll', true, 'Notifications');
    });

    $jq('.nc-Notifications_title_refresh').click(refreshNotifications);

    $jq('.nc-title-link').hover(function ()
    {
        $jq(this).addClass('nc-link-hover');
    },
    function ()
    {
        $jq(this).removeClass('nc-link-hover');
    }
    );
}

function refreshNotifications()
{
    var notifications = np.getNotifications();
    $jq('#content').empty();
    for (var i = 0; i < notifications.length; i++)
    {
        $jq('#content').append(NotificationsManager.getNotificationHTML(notifications[i]));

    }
}

function blinkButton() {
    //Blink the custom console component button text
    sforce.console.setCustomConsoleComponentButtonStyle('background-color:#FF0000;color:#FFFFFF;font-weight:bold');
    sforce.console.blinkCustomConsoleComponentButtonText('New Notification', 1000, function (result) {
        if (result.success) {
            $jq.playSound('https://na15.salesforce.com/resource/1377558515000/doorbell_mp3');
        } else {
            alert('Couldnt initiate the text blinking!');
        }
    });
}

function eventHandler(result)
{
    sforce.console.setCustomConsoleComponentButtonStyle('background-color:transparent;color:#4a4a56;font-weight:normal');
    sforce.console.blinkCustomConsoleComponentButtonText('Notification Center', 1000, function (result) {
        if (result.success) {
        } else {
            alert('Couldnt initiate the text blinking!');
        }
    });
};
