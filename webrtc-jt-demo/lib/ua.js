var usrip = "domain";
var usrws;
var usrname;
var usrpwd;
var usruri;

var config = {
  wsServers: 'wss://ip:5065',
  userAgentString: 'domain',
  stunServers: ["stun:stun.freeswitch.org" ],
  traceSip: true,
  register: true
};

var ua = null;
var sessionUI = null;
var play = null;

function registerUA(username,password) {

  usrname = username;
  usrpwd = password;
  usruri = "sip:" + usrname + "@" + usrip;

  config['displayName']  = usrname;
  config['uri'] = usruri;
  config['authorizationUser'] = usrname; 
  config['password'] = usrpwd;


  document.getElementById('ua-status').innerHTML = 'Connecting...';

  ua = new SIP.UA(config);

  ua.on('connected', function () {
    document.getElementById('ua-status').innerHTML = 'Connected (Unregistered)';
    ua.register();
  });

  ua.on('registered', function () {
    document.getElementById('ua-status').innerHTML = 'Connected (Registered)';
  });

  ua.on('unregistered', function () {
    document.getElementById('ua-status').innerHTML = 'Connected (Unregistered)';
    ua.register();
  });

  ua.on('invite', function (session) {
    playRing("ringtone.mp3");
    document.getElementById('startCall').firstChild.nodeValue = "Answer";
    sessionUI = session;
  });

  ua.on('message', function (message) {
       var node = document.createElement("LI");
       var text = message.remoteIdentity.displayName;
       text = text + ">    " + message.body;
       textnode = document.createTextNode(text);
       node.appendChild(textnode);      
       document.getElementById("messages").appendChild(node);
       document.getElementById("messages").focus();
       document.getElementById("messages").scrollIntoView();
  });

}

function setUpListeners(session) {

  sessionUI = session;
  
  sessionUI.on('bye', function (message) {
    document.getElementById('startCall').firstChild.nodeValue = "Call";
    document.getElementById("number").value = "";
    document.getElementById('remoteVideo').style.display="none";
    return 0;
  });

  sessionUI.on('terminated', function (response, cause) {
    setTimeout(function(){ua.register();}, 3000);
    document.getElementById('startCall').firstChild.nodeValue = "Call";
    document.getElementById("number").value = "";
    document.getElementById('remoteVideo').style.display="none";
    return 0;
  });

  sessionUI.on('cancel', function () {
    document.getElementById('startCall').firstChild.nodeValue = "Call";
    document.getElementById("number").value = "";
    document.getElementById('remoteVideo').style.display="none";
    return 0;
  });

  sessionUI.on('failed', function (response, cause) {
    document.getElementById('ua-status').innerHTML = cause;
    document.getElementById('startCall').firstChild.nodeValue = "Call";
    document.getElementById("number").value = "";
    document.getElementById('remoteVideo').style.display="none";
    return 0;
  });

  sessionUI.on('rejected', function (response,cause) {
    document.getElementById('ua-status').innerHTML = cause;
    document.getElementById('startCall').firstChild.nodeValue = "Call";
    document.getElementById("number").value = "";
    document.getElementById('remoteVideo').style.display="none";
    return 0;
  });

}

function unregisterUA (e) {

  if (!ua) return;

  if (ua.isRegistered()) {
     ua.unregister();
  }
}
//---------------

function playRing(soundfile) {
    play = new Audio(soundfile);
    play.play();
}

function stopRing(){
    play.pause();
    play = null;
}

function startCall() {
    var status = document.getElementById('startCall').firstChild.nodeValue;
    document.getElementById('remoteVideo').style.display="inline";     

    if(status == "Answer" && sessionUI){
    stopRing();
    document.getElementById('startCall').firstChild.nodeValue = "Call";
     sessionUI.accept({
         media: {
            constraints: {
                audio: true,
                video: false
                },
            render: {
                remote: document.getElementById('remoteVideo'),
                local:  document.getElementById('localVideo')
                }
           }
        });
    } else {
    var target = document.getElementById('number').value;
    target = target + '@' + usrip;

    sessionUI = ua.invite(target, {
        media: {
            constraints: {
    		audio: true,
    		video: false
  		},
            render: {
                remote: document.getElementById('remoteVideo'),
                local:  document.getElementById('localVideo')
                }
            }
      });
    }  
    
   if(sessionUI) 
      setUpListeners(sessionUI);   
   
}

document.getElementById('startCall').addEventListener('click', startCall,false); 


function hangUp() {
    document.getElementById('startCall').firstChild.nodeValue = "Call";
    document.getElementById('remoteVideo').style.display="none";
    document.getElementById("number").value = "";
    if (sessionUI && sessionUI.startTime && !sessionUI.endTime) {
        sessionUI.bye();
        sessionUI = null;
    }
}

document.getElementById('endCall').addEventListener("click", hangUp, false);



//---------------

function keyPress(key) {
    actual = document.getElementById("number").value;
    actualstyle = document.getElementById("number");
    if(actual.length > 15)
       actualstyle.style.fontSize = "22px";
    if(actual.length < 10)
       actualstyle.style.fontSize = "30px";
    if(actual.length < 25) 
       document.getElementById("number").value = actual + key;

    if(sessionUI && sessionUI.startTime && !sessionUI.endTime) sessionUI.dtmf(key);
     
}

document.getElementById("1").addEventListener("click",function(){ keyPress(1); });
document.getElementById("2").addEventListener("click",function(){ keyPress(2); });
document.getElementById("3").addEventListener("click",function(){ keyPress(3); });
document.getElementById("4").addEventListener("click",function(){ keyPress(4); });
document.getElementById("5").addEventListener("click",function(){ keyPress(5); });
document.getElementById("6").addEventListener("click",function(){ keyPress(6); });
document.getElementById("7").addEventListener("click",function(){ keyPress(7); });
document.getElementById("8").addEventListener("click",function(){ keyPress(8); });
document.getElementById("9").addEventListener("click",function(){ keyPress(9); });
document.getElementById("star").addEventListener("click",function(){ keyPress('*'); });
document.getElementById("0").addEventListener("click",function(){ keyPress(0); });
document.getElementById("#").addEventListener("click",function(){ keyPress('#'); });


function clearNumber() {
        actual = document.getElementById("number").value;
        actual = actual.slice(0,-1);
        document.getElementById("number").value = actual;
}

document.getElementById("clear").addEventListener("click",clearNumber);

function clearNumberAll() {
        document.getElementById("number").value = "";
}

document.getElementById("clearall").addEventListener("click",clearNumberAll);



function transferCall() {
        nummer = document.getElementById("number").value;
        nummer = nummer + '@' + usrip;
        if(nummer!="" && sessionUI && sessionUI.startTime && !sessionUI.endTime){
        sessionUI.refer(nummer);
        }        
}

document.getElementById("transfer").addEventListener("click",transferCall);

function sendSMS() {
        text = document.getElementById("textmessage").value;
        nummer = document.getElementById("number").value;
        num = document.getElementById("number").value;
        nummer = nummer + '@' + usrip;
        console.log(num.length);
        if(num.length < 2){
          document.getElementById("number").focus();
          document.getElementById("number").scrollIntoView();
          return 0;
         }
        if(nummer.length > 2 && ua){
          ua.message(nummer,text);
        }
     
       var node = document.createElement("LI");
       var textnode = document.createTextNode(text);
       node.appendChild(textnode);       
       document.getElementById("messages").appendChild(node);
       document.getElementById("textmessage").value="";
}

document.getElementById("sendmsg").addEventListener("click",sendSMS);



