// JScript source code
function initPage() {

    var loadCurrentNotification = function (notificationManager)
    {
        var currentDate = null;
        var currentDivId = null;
        var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

        var notifications = np.getNotifications();
        for (var i = 0; i < notifications.length; i++)
        {
            var notification = notifications[i];
            var createdDate = notification.getDateTime('CreatedDate');
            var createdDateDate = createdDate.setHours(0, 0, 0, 0);
            var todayDate = (new Date()).setHours(0, 0, 0, 0);
            
            if (currentDate != createdDateDate)
            {
                var title = 'Sent ';
                if (currentDate != null)
                {
                    $jq('.nc_content_all').append('<br/><br/>');
                }
                if (createdDateDate === todayDate)
                {
                    title += 'Today';
                } else if (createdDateDate == (todayDate - 86400000))
                {
                    title += 'Yesterday';
                } else
                {
                    title += createdDate.getDate() + ', ' + monthName[createdDate.getMonth()];
                }
                currentDivId = String(createdDateDate);
                $jq('.nc_content_all').append('<div class="nc_subtitle_all">' + title + '</div><div class="nc_div" id="' + currentDivId + '"></div>');

                currentDate = createdDateDate;
            }
            $jq('#' + currentDivId).append(NotificationsManager.getNotificationHTML(notifications[i], 'VIEWALL'));
        }
    }


    //General Efect to dismiss notification   
    var notificationDismissEffect = function (element) {
        element.fadeOut('slow', function () {
            $jq(this).remove();
        });
    }

    //Events handlers
    var newNotificationHandler = function (notification) {
        var todayDate = (new Date()).setHours(0, 0, 0, 0);
        if ($jq('#' + String(todayDate)).length == 0) {
            $jq('.nc_content_all').append('<div class="nc_subtitle_all">Sent Today</div><div class="nc_div" id="' + String(todayDate) + '"></div>');
        }
        var element = $jq(NotificationsManager.getNotificationHTML(notification, 'VIEWALL')).hide();
        $jq('#' + String(todayDate)).prepend(element);
        element.fadeIn('slow');
    }

    //this event hanlder will be called when a dismissed event is received
    //by the Notification Manager, if the element was dismissed from this
    //page the element may not be there. However if the element was dismissed
    //somewhere else...
    var notificationDismissedHanlder = function (notification) {
        var notiElement = $jq('#' + notification.Id);
        if (notiElement.length > 0) {
            var container = notiElement.parent();
            if (container.children().length == 1) {
                var titlediv = container.prev();
                container.remove();
                notificationDismissEffect(titlediv);
            } else {
                notificationDismissEffect(notiElement);
            }
        }
    }


    //Notification click handlers
    $jq(document).on('click', '.nc-Notifications_dismiss', function () {
        var notificationId = $jq(this).parent().attr('id');

        var notiElement = $jq(this).parent();
        var container = notiElement.parent();
        if (container.children().length == 1) {
            var titlediv = container.prev();
            container.remove();
            notificationDismissEffect(titlediv);
        } else {
            notificationDismissEffect(notiElement);
        }

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



    var np = new NotificationsManager(sessionId, userId);

    loadCurrentNotification(np);

    np.startListening(newNotificationHandler, notificationDismissedHanlder);


 }

