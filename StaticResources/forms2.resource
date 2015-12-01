<html>
<script>
function popit() {
window.frames['if1'].document.location.href = "https://cs16.salesforce.com/flow/interview.apexp?sparkID=" + document.getElementById('campname').options[document.getElementById('campname').selectedIndex].value + "&CampaignMemberID=" + document.getElementById('campid').value + "&UserId=" + document.getElementById('userid').value
window.frames['if2'].document.location.href = "https://cs16.salesforce.com/flow/interview.apexp?sparkID=" + document.getElementById('campnamee').options[document.getElementById('campnamee').selectedIndex].value + "&CampaignMemberId=" + document.getElementById('campid').value + "&UserId=" + document.getElementById('userid').value
}

</script>


campaign id <input type=text value='00vf0000004SsuZ' id='campid'>  &nbsp &nbsp   user id <input type=text value='005F00000030bzO' id='userid'>
&nbsp &nbsp <select id='campname'>
<option>Nissan_Service_Marketing_US
<option>Nissan_Service_Marketing_US_Es
<option>Nissan_Service_Marketing_NCI_En
<option>Nissan_Service_Marketing_NCI_Fr
<option>Infiniti_Service_Marketing_US
<option>Infiniti_Service_Marketing_US_Es
<option>Infiniti_Service_Marketing_NCI_En
<option>Infiniti_Service_Marketing_NCI_Fr
<option>NCV_Service_Marketing_US
<option>NCV_Service_Marketing_US_Cloud
<option>Infiniti_Service_Marketing_Dev_English_Cloud
<option>PreCall_Forms
<option>Service_Marketing_US
<option>Infiniti_Service_Marketing_NCI_Fr_Cloud
</select>
&nbsp &nbsp <select id='campnamee'>
<option>Nissan_Service_Marketing_US
<option>Nissan_Service_Marketing_US_Es
<option>Nissan_Service_Marketing_NCI_En
<option>Nissan_Service_Marketing_NCI_Fr
<option>Infiniti_Service_Marketing_US
<option>Infiniti_Service_Marketing_US_Es
<option>Infiniti_Service_Marketing_NCI_En
<option>Infiniti_Service_Marketing_NCI_Fr
<option>NCV_Service_Marketing_US
<option>NCV_Service_Marketing_US_Cloud
<option>Infiniti_Service_Marketing_Dev_English_Cloud
<option>PreCall_Forms
<option>Service_Marketing_US
<option>Infiniti_Service_Marketing_NCI_Fr_Cloud
</select>
<br>
<input type='button' value='Submit' onclick='popit()'>

<iframe id='if1' name='if1' src="" width="100%" height="50%"></iframe><br>


<iframe id='if2' name='if2' src="" width="100%" height="50%"></iframe>

