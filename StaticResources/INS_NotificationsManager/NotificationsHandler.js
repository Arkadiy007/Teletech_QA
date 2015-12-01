function NotificationsHandler(sessionId, userId, memberId, options)
{
    this.options = { container: $jq(document), isSubTab: true, title: '', wrapper: false, blink: false };
    NotificationsHandler.reference = this;

    //Notification click handlers
    this.dismissHandler = function (evt)
    {
        var oThis = evt.data.parentObject;
        var notificationId = $jq(this).parent().attr('id');
        oThis.notificationDismissEffect($jq(this).parent());
        NotificationsManager.dismissNotification(notificationId);
        return false;
    };

    this.createHandler = function (evt)
    {
        var oThis = evt.data.parentObject;
        var notificationId = $jq(this).parent().attr('id');
        //for certain reason I had a hard time including this logic in the notification
        // manager, the sessionId was replaced by a JQ function causing an error
        var taskId = sforce.apex.execute("INS_NotificationCenterExtension", "CreateTask", { notificationId: notificationId });
        oThis.openTab('/' + taskId + '/e?retUrl=%2F' + taskId, $jq(this).next().text(), oThis.isSubTab);
        return false;
    }

    //handler for the links in the notifications
    this.linkHandler = function (evt)
    {
        var id = $jq(this).attr('objectIdOrUrl');
        var oThis = evt.data.parentObject;
        oThis.openTab('/' + id, oThis.title, oThis.isSubTab);
        return false;
    }

    //General Efect to dismiss notification   
    this.notificationDismissEffect = function (element)
    {
        element.fadeOut('slow', function ()
        {
            $jq(this).remove();
        });
    }

    //Events handlers
    this.newNotificationHandler = function (notification)
    {
        var html = NotificationsManager.getNotificationHTML(notification)
        var oThis = NotificationsHandler.reference;
        if (oThis.wrapper)
        {
            var notification = $jq(oThis.wrapper).append(html);
            oThis.container.prepend(notification);
            notification.hide();
            notification.fadeIn('slow');
        }
        else
        {
            var notification = $jq(html);
            oThis.container.prepend(notification);
            notification.hide();
            notification.fadeIn('slow');
        }

        if (oThis.options.blink)
        {
            oThis.blinkButton();
        }
    }

    //this event hanlder will be called when a dismissed event is received
    //by the Notification Manager, if the element was dismissed from this
    //page the element may not be there. However if the element was dismissed
    //somewhere else...    
    this.notificationDismissedHandler = function (notification)
    {
        var oThis = NotificationsHandler.reference;
        if (oThis.container.find('#' + notification.Id).length > 0)
        {
            oThis.notificationDismissEffect(oThis.container.find('#' + notification.Id));
        }
    }

    if (typeof options == "object")
    {
        this.options = $jq.extend({}, this.options, options);
    }

    if (this.options.blink)
    {
        sforce.console.onCustomConsoleComponentButtonClicked(this.eventHandler);
    }

    this.container = this.options.container;
    this.isSubTab = this.options.isSubTab;
    this.title = this.options.title;
    this.wrapper = this.options.wrapper;

    this.bindEvents = function (oContainer)
    {
        if (!oContainer)
        {
            oContainer = $jq(document);
        }
        oContainer.on("click", ".nc-Notifications_dismiss", { parentObject: this }, this.dismissHandler);
        oContainer.on("click", ".nc-Notifications_create", { parentObject: this }, this.createHandler);
        oContainer.on("click", ".nc-link", { parentObject: this }, this.linkHandler);
    }

    this.openTab = nhOpenTab;
    this.blinkButton = function ()
    {
        //Blink the custom console component button text
        sforce.console.setCustomConsoleComponentButtonStyle('background-color:#FF0000;color:#ffffff;font-weight:bold;');
        sforce.console.blinkCustomConsoleComponentButtonText('New Notification', 1000, function (result)
        {
            if (result.success)
            {
                $jq.playSound('doorbell_mp3');
            } else
            {
                alert('Couldnt initiate the text blinking!');
            }
        });
    };

    this.eventHandler = function (result)
    {
        sforce.console.setCustomConsoleComponentButtonStyle('background-color:transparent;color:#4a4a56;font-weight:normal');
        sforce.console.blinkCustomConsoleComponentButtonText('Notification Center', 1000, function (result)
        {
            if (result.success)
            {
            } else
            {
                alert('Couldnt initiate the text blinking!');
            }
        });
    };

    this.sessionId = sessionId;
    this.userId = userId;
    this.memberId = memberId;

    this.oNotificationsManager = new NotificationsManager(this.sessionId, this.userId, this.memberId);

    var notifications = this.oNotificationsManager.getNotifications();
    var html;
    for (var i = 0; i < notifications.length; i++)
    {
        html = NotificationsManager.getNotificationHTML(notifications[i]);
        if (this.wrapper)
        {
            this.container.append($jq(this.wrapper).append(html));
        }
        else
        {
            this.container.append(html);
        }
    }

    this.bindEvents(this.container);

    this.notifications = notifications;

    this.oNotificationsManager.startListening(this.newNotificationHandler, this.notificationDismissedHandler);

    this.container.parent().find('.nc-Notifications_title_dismiss').click(function ()
    {
        var r = confirm('Are you sure you want to Dismiss All these notifications?');
        if (r == true)
        {
            this.container.empty();
            //this.oNotificationsManager.dismissAll();
        }
    });

}

function nhOpenTab(url, title, isSubTab)
{
    if (isSubTab)
    {
        var callOpenSubtab = function (result)
        {
            sforce.console.openSubtab(result.id, url, true, title);
        }

        sforce.console.getEnclosingPrimaryTabId(callOpenSubtab);
    }
    else
    {
        sforce.console.openPrimaryTab(null, url, true);
    }
}