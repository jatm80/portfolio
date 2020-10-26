<!DOCTYPE html>
<html>
        <head>
            <title>UKALL ME</title>
            <meta charset="UTF-8">
            <link rel="stylesheet" href="styles.css">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="bootstrap.min.css">
            <script src="lib/jquery-1.11.3.min.js"></script>
            <script src="lib/bootstrap.min.js"></script>
            <script src="lib/DetectRTC.js"></script>
        </head>   
        <body>
            <h2><center> -- UKALL ME -- </center></h2></center>

        <h1>          
            Login:
            <br />
            <form name="frm" action="userAgent.php" method="POST" >
                <input type="text" name="login" id="login"></label><br>
                Password:
                <br />
               <input type="password" name="passwd" id="passwd"></label><br>
                <br />
                <input type="submit" class="css3button" value="Submit">
            </form>
        </h1>
        <script>

                DetectRTC.load(function() {
                    var a1 = DetectRTC.hasMicrophone;
                    var a2 = DetectRTC.hasWebcam;
                    var a3 = DetectRTC.isWebRTCSupported;
                    var a4 = DetectRTC.isWebSocketsSupported;
                   if(!a1 || !a3 || !a4 ) { alert("Only Chrome, Firefox and Opera are supported");
                                                  window.location="https://www.google.com/chrome/browser/"; 
                                                 }
                });
        </script>
                <br />
                <br />
            <h4><center><a href="https://webrtc.ukall.me/index2.html">UKALL MEET</a></center></h4></center>
                <br />
        <footer>
            <center><h4>UKALL.ME &copy; 2015</h4></center>
        </footer>
    </body>
</html>
