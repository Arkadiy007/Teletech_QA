<html>
<head>


<link rel="stylesheet" href="magnific-popup.css">
<style>
.white-popup {
    position: relative;
    background: #FFF;
    padding: 20px;
    width:auto;
    max-width: 250px;
    margin: 20px auto;
}
</style>


</head>

<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script> 

<script src='jquery.magnific-popup.js'></script>

<script type="text/javascript">
      $(document).ready(function() {
        $('.popup-with-form').magnificPopup({
          type: 'inline',
          preloader: false,
          focus: '#name',

          // When elemened is focused, some mobile browsers in some cases zoom in
          // It looks not nice, so we disable it:
          callbacks: {
            beforeOpen: function() {
              if($(window).width() < 700) {
                this.st.focus = false;
              } else {
                this.st.focus = '#name';
              }
            }
          }
        });
      });
    </script>

<a class="test-popup-link" href="test.jpg">Open popup</a>
      <a class="popup-with-form" href="#test-form">Open form</a>

 <div class="example gc3">
 <form id="test-form" class="mfp-hide white-popup">
        <!-- <font face='Verdana'><b><i>Convert to VCAN</i></b></font> -->
          <p><font face='Verdana' size=2>Please select the VCAN type you'd like to convert this case to:</font></p>
              <select id='vcan_type'><option>WCC VCAN<option>Engine VCAN<option>Trans VCAN</select>&nbsp &nbsp <input type=submit value='Submit'>
		
      </form>
	  </div>
	  