<?php
$username = $_REQUEST['login'];
$password = $_REQUEST['passwd'];
?>
<!DOCTYPE html>
<html>
    <head>

        <title>UKALL ME</title>
        <meta charset="UTF-8">
        <link rel="stylesheet" href="styles.css">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="bootstrap.min.css">
        <script src="lib/jquery-1.11.3.min.js"></script>
        <script src="lib/bootstrap.min.js"></script>
    </head>    
    <body onload="registerUA(<?php echo "'$username','$password'"; ?>)">
        <h2><center> -- UKALL ME -- </center></h2></center>
    <h1>
            <video id="remoteVideo" hidden width="320" height="240"></video><br/>
            <video id="localVideo" hidden  muted="muted"></video>
            <div id="ua-status">Welcome!..</div>
            <input type="text" id="number"  disabled/>
            <br></br>            
            <button id="1" class="css3button">1</button>
            <button id="2" class="css3button">2</button>
            <button id="3" class="css3button">3</button><br/>
            <button id="4" class="css3button">4</button>
            <button id="5" class="css3button">5</button>
            <button id="6" class="css3button">6</button><br/>
            <button id="7" class="css3button">7</button>
            <button id="8" class="css3button">8</button>
            <button id="9" class="css3button">9</button><br/>
            <button id="star" class="css3button">*</button>
            <button id="0" class="css3button">0</button>
            <button id="#" class="css3button">#</button><br/>
            <br />
            <button id="addplus" class="css3button">&#10160;</button>
            <button id="clearall" class="css3button">Clear</button>
            <button id="clear" class="css3button">&#8624;</button>
            <br />            
            <button id="startCall" class="css3button">Call</button>
            <button id="transfer"  class="css3button">Transfer</button>
            <button id="endCall" class="css3button">Hangup</button>
            <br />
            <br />   
            <textarea id="textmessage" rows="2" cols="50"></textarea><br/>
            <button id="sendmsg" class="css3button">Send</button><br/>
            <center><h4><ul id="messages"></ul><h4></center>
            <br></br>
    </h1>
    <footer>
        <center><h4>UKALL.ME &copy; 2015</h4></center>
    </footer>
        <script type="text/javascript" src="lib/sip-0.7.1.js"></script>              
        <script type="text/javascript" src="lib/ua.js"></script>
</body>
</html>
