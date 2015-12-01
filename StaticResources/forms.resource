<html>
<script>
function popit() {
window.frames['if1'].document.location.href = "https://cs16.salesforce.com/flow/interview.apexp?sparkID=" + document.getElementById('campname').options[document.getElementById('campname').selectedIndex].value + "&CampaignMemberID=" + document.getElementById('campid').value + "&UserId=" + document.getElementById('userid').value
window.frames['if2'].document.location.href = "https://cs16.salesforce.com/flow/interview.apexp?sparkID=" + document.getElementById('campnamee').options[document.getElementById('campnamee').selectedIndex].value + "&CampaignMemberId=" + document.getElementById('campid').value + "&UserId=" + document.getElementById('userid').value
}

</script>


campaign id <input type=text value='00vf0000004SsuaAAC' id='campid'>  &nbsp &nbsp   user id <input type=text value='005F00000030bzO' id='userid'>
&nbsp &nbsp <select id='campname'>
<option>Infiniti_Service_Marketing_US
<option>NCV_Service_Marketing_US
<option>Infiniti_Service_Marketing_NCI_Fr
<option>Nissan_Service_Marketing_NCI_Fr
<option>Infiniti_Service_Marketing_NCI_En
<option>Nissan_Service_Marketing_NCI_En
<option>Nissan_Service_Marketing_US
<option>Nissan_Service_Marketing_US_Es
<option>Infiniti_Service_Marketing_US_Es




</select>
&nbsp &nbsp <select id='campnamee'>
<option>Infiniti_Service_Marketing_US_Cloud
<option>NCV_Service_Marketing_US_Cloud
<option>Infiniti_Service_Marketing_NCI_Fr_Cloud
<option>Nissan_Service_Marketing_NCI_Fr_Cloud
<option>Infiniti_Service_Marketing_NCI_En_Cloud
<option>Nissan_Service_Marketing_NCI_En_Cloud
<option>Nissan_Service_Marketing_US_Cloud




</select>
<br>
<input type='button' value='Submit' onclick='popit()'>

<iframe id='if1' name='if1' src="" width="100%" height="50%"></iframe><br>


<iframe id='if2' name='if2' src="" width="100%" height="50%"></iframe>

