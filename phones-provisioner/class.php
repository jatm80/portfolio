<?php


Class provisioner {
  protected $usern;
  protected $pass;
  protected $apiUrl;
  protected $apiKey;
  protected $realm;
  protected $accname;
  protected $memcache;
  public $_log;
  public $auth;
  public $db;
  public $api;
  public $accountid;
  
   public function __construct ( $user = null , $pass = null, $apiUrl = null,$realm = null,$accname = null){
        $this->_log = KLogger::instance('logs', Klogger::DEBUG);
        $this->_log->logInfo('================== Starting process ==================');
        $this->_log->logInfo('================== couch connect ==================');
        $this->db = new couchClient (DB_SERVER.':'.DB_PORT,DB_DEF);
        $this->memcache = new Memcached();
        $this->memcache->addServer(MEMCACHE_HOST,MEMCACHE_PORT);
      if(!is_null($user) or !is_null($pass) or !is_null($apiUrl) or !is_null($accname)){ 
        $this->usern=$user;
        $this->pass=$pass;
        $this->apiUrl=$apiUrl;
        $this->accname=$accname;
        $this->_log->logInfo('================== secure api connect ==================');
        $this->_log->logInfo($this->apiUrl);
       try{
	$options = array('base_url' => $this->apiUrl);
        $authToken = new \Kazoo\AuthToken\User($this->usern, $this->pass,null,$this->accname);
        $this->api = new \Kazoo\SDK($authToken, $options);
        $this->accountid = $this->api->Account()->id;
        $this->realm = $this->api->Account()->realm;
        $this->storeAccountInfo();
        $this->auth = true;
        } catch (Exception $e){
        $this->auth = false;
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        }
       }
   }

   private function connectAPIkey(){
        $this->_log->logInfo('================== unsecure api connect ==================');
        $this->_log->logInfo($this->apiUrl);
        $options = array('base_url' => $this->apiUrl);
        $authToken = new \Kazoo\AuthToken\ApiKey($this->apiKey);
        $this->api = new \Kazoo\SDK($authToken, $options);
        $this->auth = false;
   }
   public function getRealm(){
        return $this->realm;
   }

   public function is_authorized(){
        return $this->auth;
   }

   public function storeAccountInfo(){
       $this->db->useDatabase("accounts");
       if ( !$this->db->databaseExists() ) {
          $this->db->createDatabase();
       }

        $new_doc = new stdClass();
        $new_doc->_id= $this->getAccountid();
        $new_doc->realm= $this->api->Account($this->accountid)->realm;
        $new_doc->is_reseller=$this->api->Account($this->accountid)->is_reseller;
        $new_doc->apiUrl=$this->apiUrl;
        $new_doc->apiKey=$this->api->Account($this->accountid)->apiKey();
        $new_doc->pvt_account_db=$this->getAccountdb($this->getAccountid());
        $new_doc->pvt_type="account";
        $new_doc->pvt_enable="true";
        $new_doc->pvt_tree=(array)
        $children=array();
        $chs=$this->getChildren();
        foreach($chs as $ch){
         $children[]=$ch->id;
        }
        $new_doc->pvt_tree=$children;
 
        try {
              $this->db->getDoc($new_doc->_id);
            } catch (Exception $e) {
          	try{ 
                	$response=$this->db->storeDoc($new_doc);
                	$this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
        	} catch (Exception $e) {
                	$this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        	}	
            }    
   }
 

   public function getThisAccountInfo(){
      try{
        $info = new stdClass();
        $info->id=$this->api->Account($this->accountid)->id;
        $info->name=$this->api->Account($this->accountid)->name;
        $info->timezone=$this->api->Account($this->accountid)->timezone;
        $info->realm=$this->api->Account($this->accountid)->realm;
        $info->is_reseller=$this->api->Account($this->accountid)->is_reseller;
        $info->pvt_account_db=$this->getAccountdb($this->accountid);
        return $info;
       } catch (Exception $e) {
               $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
               return false;
       }
   }

   public function getAccountInfo($id){
      try{
        $info = new stdClass();
        $info->id=$this->api->Account($id)->id;
        $info->name=$this->api->Account($id)->name;
        $info->timezone=$this->api->Account($id)->timezone;
        $info->realm=$this->api->Account($id)->realm;
        $info->is_reseller=$this->api->Account($id)->is_reseller;
        $info->pvt_account_db=$this->getAccountdb($id);
        return $info;
       } catch (Exception $e) {
               $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
	       return false;
       }
   } 

   public function useAccount($id){
       $this->accountid = $id;
       $this->storeAccountInfo();
       return true;
   }

   public function getAccountid(){
        return $this->accountid;
   }
   
   public function getTZOffset($timezone){
    
    date_default_timezone_set($timezone);
    $offset =  date('Z') / 3600;
    $offset = $offset - $this->timezoneDoesDST($timezone);
    $offset = str_replace('.5',':30',$offset);
    $offset = str_replace('.75',':45',$offset);

    if($offset < 0 ) {
      return "-".$offset;
     } elseif ($offset > 0) {
       return "+".$offset;
     } else return $offset;
   }

   public function timezoneDoesDST($timezone) {
    $tz = new DateTimeZone($timezone);
    $trans  = $tz->getTransitions(time());
    foreach ($trans as $t){
      if($t['ts'] == date('U')) { if(!empty($t['isdst'])) return $t['isdst'];
                                  else return 0; }
    }
   }

   public function getTZName($timezone){
       $offset = $this->getTZOffset($timezone);

	$tzname = array();
	$tzname['-11']="Samoa";
	$tzname['-10']="United States-Hawaii-Aleutian, United States-Alaska-Aleutian";
	$tzname['-9:30']="French Polynesia";
	$tzname['-9']="United States-Alaska Time";
	$tzname['-8']="Canada(Vancouver,Whitehorse)| Mexico(Tijuana,Mexicali)| United States-Pacific Time ";
	$tzname['-7']="Canada(Edmonton,Calgary)| Mexico(Mazatlan,Chihuahua)| United States-MST no DST, United States-Mountain Time";
	$tzname['-6']="Canada-Manitoba(Winnipeg)| Chile(Easter Islands)| Mexico(Mexico City,Acapulco)| United States-Central Time";
	$tzname['-5']="Bahamas(Nassau)| Canada(Montreal,Ottawa,Quebec)| Cuba(Havana)| United States-Eastern Time";
	$tzname['-4:30']="Venezuela(Caracas)";
	$tzname['-4']="Canada(Halifax,Saint John)| Chile(Santiago)| Paraguay(Asuncion)| United Kingdom-Bermuda(Bermuda)| United Kingdom(Falkland Islands)| Trinidad&Tobago";
	$tzname['-3:30']="Canada-New Foundland(St.Johns)";
	$tzname['-3']="Argentina(Buenos Aires)| Brazil(DST)| Brazil(no DST)| Denmark-Greenland(Nuuk)";
	$tzname['-2:30']="Newfoundland and Labrador";
	$tzname['-2']="Brazil(no DST)";
	$tzname['-1']="Portugal(Azores)";
	$tzname['0']="Denmark-Faroe Islands(Torshavn)| GMT, Greenland, Ireland(Dublin)| Morocco, Portugal(Lisboa,Porto,Funchal)| Spain-Canary Islands(Las Palmas)| United Kingdom(London)";
	$tzname['+1']="Albania(Tirane)| Austria(Vienna)| Belgium(Brussels)|Caicos, Chad, Croatia(Zagreb)| Czech Republic(Prague)| Denmark(Kopenhagen)| France(Paris)| Germany(Berlin)| Hungary(Budapest)| Italy(Rome)| Luxembourg(Luxembourg)| Macedonia(Skopje)| Namibia(Windhoek)| Netherlands(Amsterdam)| Spain(Madrid)";
	$tzname['+2']="Estonia(Tallinn)| Finland(Helsinki)| Gaza Strip(Gaza)| Greece(Athens)| Israel(Tel Aviv)| Jordan(Amman)| Latvia(Riga)| Lebanon(Beirut)| Moldova(Kishinev)| Romania(Bucharest)| Russia(Kaliningrad)| Syria(Damascus)| Turkey(Ankara)| Ukraine(Kyiv, Odessa)";
	$tzname['+3']="East Africa Time, Iraq(Baghdad)| Russia(Moscow)";
	$tzname['+3:30']="Iran(Teheran)";
	$tzname['+4']="Armenia(Yerevan)| Azerbaijan(Baku)| Georgia(Tbilisi)| Kazakhstan(Aktau)| Russia(Samara)";
	$tzname['+4:30']="Afghanistan(Kabul)";
	$tzname['+5']="Kazakhstan(Aqtobe)| Kyrgyzstan(Bishkek)| Pakistan(Islamabad)| Russia(Chelyabinsk)";
	$tzname['+5:30']="India(Calcutta)";
	$tzname['+5:45']="Nepal(Katmandu)";
	$tzname['+6']="Kazakhstan(Astana, Almaty)| Russia(Novosibirsk,Omsk)";
	$tzname['+6:30']="Myanmar(Naypyitaw)";
	$tzname['+7']="Russia(Krasnoyarsk)| Thailand(Bangkok)";
	$tzname['+8']="Australia(Perth)| China(Beijing)| Russia(Irkutsk, Ulan-Ude)| Singapore(Singapore)";
	$tzname['+8:45']="Eucla";
	$tzname['+9']="Japan(Tokyo)| Korea(Seoul)| Russia(Yakutsk,Chita)";
	$tzname['+9:30']="Australia(Adelaide)| Australia(Darwin)";
	$tzname['+10']="Australia(Brisbane)| Australia(Hobart)| Australia(Sydney,Melbourne,Canberra)| Russia(Vladivostok)";
	$tzname['+10:30']="Australia(Lord Howe Islands)";
	$tzname['+11']="New Caledonia(Noumea)| Russia(Srednekolymsk Time)";
	$tzname['+11:30']="Norfolk Island";
	$tzname['+12']="New Zealand(Wellington,Auckland)| Russia(Kamchatka Time)";
	$tzname['+12:45']="New Zealand(Chatham Islands)";
	$tzname['+13']="Tonga(Nukualofa)";
	$tzname['+13:30']="Chatham Islands";
	$tzname['+14']="Kiribati";
   	$line = explode('|',$tzname[$offset]);
   	$city = explode('/',$timezone);
   	foreach($line as $location){
      		if(preg_match("/$city[1]/",$location) == 1) return $location;
   	}
   	return "None";
   }

 
   public function getAccountdb($id){
        $id = 'account/' . substr($id, 0, 2) . '/' . substr($id, 2, 2) . '/' . substr($id, 4);
        return $id;
   }
  
   public function getDevicedoc($mac_address){
       if(preg_match('/([a-fA-F0-9]{2}[:|\-]?){6}/', $mac_address) == 1 ){
        $id = strtolower(str_replace(':', '', $mac_address));
        $this->_log->logInfo($mac_address);
       } else {
         $this->_log->logInfo($mac_address."-- not mac address");
         return false;
       }
        return $id;
   }

   public function logit($text){
       $this->_log->logInfo("INFO: ".$text);
       return true;
   }
  
   public function is_DocExists($docid){
        try {
              $this->db->getDoc($docid);
              return true;
        } catch (Exception $e) {
              return false;
        }
   }

   public function flushkey($key){
       $this->_log->logInfo("INFO: Flushing Cache for Key: ".$key);
       $ckey = md5(strtolower($key));
       return $this->memcache->delete($ckey);
   }

   public function array2json($data){
       return json_decode(json_encode($data));
   }

   public function getChildren(){
        $filter = array('paginate' => 'false');
        return $this->api->Account($this->getAccountid())->descendants($filter);
   }
  
   public function getChildrenById($accountid){
        $filter = array('paginate' => 'false');
        return $this->api->Account($accountid)->descendants($filter);
   }

   public function getTemplateid($brand,$family,$model){
       return 'ui/'.$brand.'/'.$family.'/'.$model;
   }
   
   public function getNewtemplate($brand,$family,$model){
        $templateid = 'ui/'.$brand.'/'.$family.'/'.$model;
        $this->db->useDatabase("template_library");
        return $this->db->getDoc($templateid);
   }

   public function getListTemplates(){
        $this->db->useDatabase("template_library");
        $templates = array();
        if ($this->db->databaseExists()) {
           $all_docs = $this->db->getAllDocs();
           foreach ($all_docs->rows as $row ) {
              $templates[] = $row->id;
           }
       return $templates;
       } else {
       return false;
       } 
   }

   public function getAccountTemplates($accountid){
       $this->db->useDatabase($this->getAccountdb($accountid));
       $templates = array();
       if ($this->db->databaseExists()) {
           $all_docs = $this->db->getAllDocs();
           foreach ($all_docs->rows as $row ) {
              $templates[] = $row->id;
           }
       return $templates;
       } else {
       return false;
       }
   }

   public function getDeviceTemplate($mac_address){
    $this->db->useDatabase("devices");
      try{
        $device = $this->db->getDoc($this->getDevicedoc($mac_address));
        return $device->templateid;
      } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        return false;
      }
   }

   public function setTemplateAccount($tempacc,$accountid){
       $this->db->useDatabase($this->getAccountdb($accountid));
       if ( !$this->db->databaseExists() ) {
          $this->db->createDatabase();
       } 

        $new_doc = new stdClass();
        $new_doc->_id=$tempacc->_id;
        $new_doc->usr_keys=$tempacc->usr_keys;
        $new_doc->cfg_base=$tempacc->cfg_base;
        $new_doc->cfg_behavior=$tempacc->cfg_behavior;
        $new_doc->cfg_tone=$tempacc->cfg_tone;
        $new_doc->cfg_key=$tempacc->cfg_key;
        $new_doc->cfg_extkey=$tempacc->cfg_extkey;

	try {
               if(!$this->is_DocExists($new_doc->_id)){
    		$response=$this->db->storeDoc($new_doc);
                $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
                return true;
               } else {
    		$this->_log->logInfo("ERROR: Document Exists! Use Update function");
                return false;
               }
	} catch (Exception $e) {
    		$this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
                return false;
	}
  }   


  public function setTemplateDevice($tempdev,$accountid,$mac_address){
       $this->db->useDatabase("devices");
       if ( !$this->db->databaseExists() ) {
          $this->db->createDatabase();
       } 
 
        $devicedoc=$this->getDevicedoc($mac_address);  
     
        $new_doc = new stdClass();
        $new_doc->_id = $devicedoc;
        $new_doc->templateid=$tempdev->_id;
        $new_doc->accountid=$accountid;
        $new_doc->mac_address=$devicedoc;
        $new_doc->usr_keys=$tempdev->usr_keys;
        $new_doc->cfg_account=$tempdev->cfg_account;

        foreach($tempdev->cfg_base as $key => $value){ $tempdev->cfg_base->{$key} = "%NULL%"; }
        $new_doc->cfg_base=$tempdev->cfg_base;

        foreach($tempdev->cfg_behavior as $key => $value){ $tempdev->cfg_behavior->{$key} = "%NULL%";}
        $new_doc->cfg_behavior=$tempdev->cfg_behavior;

        foreach($tempdev->cfg_tone as $key => $value){ $tempdev->cfg_tone->{$key} = "%NULL%";}
        $new_doc->cfg_tone=$tempdev->cfg_tone;

        foreach($tempdev->cfg_key as $key => $value){ $tempdev->cfg_key->{$key} = "%NULL%";
                                                      /*if( preg_match('/t48/',$tempdev->_id) && ( $key == "linekey.7.label" || $key =="linekey.8.label")) $tempdev->cfg_key->{$key} = "{cidnumber}";*/  } /*dirty fix for T48s */
        $new_doc->cfg_key=$tempdev->cfg_key;

        foreach($tempdev->cfg_extkey as $key => $value){$tempdev->cfg_extkey->{$key} = "%NULL%";}
        $new_doc->cfg_extkey=$tempdev->cfg_extkey;
         
        try {
               if(!$this->is_DocExists($new_doc->_id)){
                $response = $this->db->storeDoc($new_doc);
                $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
                return $response;
               } else {
                 $this->_log->logInfo("ERROR: Document Exists! Use Update function");
                return false;
               }
        } catch (Exception $e) {
                $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
                return false;
        }
  }

  public function resetAllDeviceBaseConfig(){
     $this->db->useDatabase("devices");
     if ($this->db->databaseExists()) {
         $all_docs = $this->db->getAllDocs();
           foreach ($all_docs->rows as $row) {
             $tempdev = $this->db->getDoc($row->id);
               foreach($tempdev->cfg_base as $key => $value){ $tempdev->cfg_base->{$key} = "%NULL%"; }
               foreach($tempdev->cfg_behavior as $key => $value){ $tempdev->cfg_behavior->{$key} = "%NULL%";}
               foreach($tempdev->cfg_tone as $key => $value){ $tempdev->cfg_tone->{$key} = "%NULL%";}
               foreach($tempdev->cfg_key as $key => $value){$tempdev->cfg_key->{$key} = "%NULL%";}
               foreach($tempdev->cfg_extkey as $key => $value){$tempdev->cfg_extkey->{$key} = "%NULL%";} 
               $response = $this->db->storeDoc($tempdev);    
               $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
               }
     } else {
       return false;
     }
  }
  
  public function getDeviceMacAccount($accountid){
     $filter = array('paginate' => 'false'); 
     $dvs = $this->api->Account($accountid)->Devices($filter);
     $dv  = json_decode($dvs);
     $result = array();
     foreach($dvs as $dv){
        if($dv->mac_address != ""){
         $result[$dv->name] = $dv->mac_address;
     }}
     return $result;
  }

  public function getUsers($accountid){
    $filter = array('paginate' => 'false'); 
    $usrs = $this->api->Account($accountid)->Users($filter);
    $result = array();
    foreach($usrs as $res){
    $result[$res->id] = $this->getUserInfo($accountid,$res->id);
    }
    return $result;
  }

  public function getUserInfo($accountid,$userid){
   $ckey = md5($accountid.$userid);
   if(!$this->is_authorized()) $this->flushkey($accountid.$userid);

   $usr = $this->memcache->get($ckey);
   $res = json_decode($usr);

   if(!isset($res)){
   $this->_log->logInfo("INFO: getUserInfo: Using API");
   $usr = $this->api->Account($accountid)->User($userid);
   $this->memcache->set($ckey,(string)$usr);
   $res = json_decode($usr);
   }

    $userinfo = new stdClass();
    $userinfo->username = $res->username;
    if(isset($res->account_name)) $userinfo->accountname = $res->account_name;
    else $userinfo->accountname = $res->username;
    $userinfo->email = $res->email;
    $userinfo->firstname = $res->first_name;
    $userinfo->lastname = $res->last_name;
    $userinfo->priv_level = $res->priv_level;
    $userinfo->presence_id = $res->presence_id;
    if(isset($res->timezone)) $userinfo->timezone = $res->timezone;
    else $userinfo->timezone = $this->getAccountInfo($accountid)->timezone;
    $userinfo->cidname = $res->caller_id->internal->name;
    $userinfo->cidnumber = $res->caller_id->internal->number;
    $userinfo->enabled = $res->enabled;
    return $userinfo;
  }

  public function syncDevice($accountid,$mac_address){
   $filter = array('paginate' => 'false','mac_address' => $mac_address);
   $result = $this->api->Account($accountid)->Devices($filter);
    foreach($result as $dev){
         $device = $dev->fetch();
         if($device->mac_address == $mac_address) { $device->sync();  return true; }
    }
  }
   
  public function getDeviceStatus($accountid,$deviceid = null){
     $filter = array('paginate' => 'false','id' => $deviceid); 
     $result = $this->api->Account($accountid)->Devices($filter);
     $status = $result->status();
     if(!is_null($deviceid)){
       foreach($status as $res) {
               if(preg_match("/".$deviceid."/",$res->device_id)) { $this->_log->logInfo("INFO: Registration status for ".$deviceid.": ".$res->registered);
                                                                    return $res->registered; }
       }
     } else { return $status; }
  }

  public function getDeviceInfo($accountid,$mac_address){
   $ckey = md5(strtolower($accountid.$mac_address));
 
   $result = json_decode($this->memcache->get($ckey));
   
   if(isset($result)){
       $this->_log->logInfo("INFO: Using Cache");
       $sleep = 100000;
   } else{
       $sleep = 1000000;
       $this->_log->logInfo("INFO: Using API ");
       $filter = array('paginate' => 'false'); 
       $dvs = $this->api->Account($accountid)->Devices($filter); 
 
   foreach($dvs as $dv){
      if(strtolower($dv->mac_address) == strtolower($mac_address)){
           $key = md5(strtolower($accountid.$dv->mac_address));
           $result=$dv->fetch(); 
           $this->memcache->set($key,(string)$result);
   }}}

    if(isset($result)) {
      $res = clone $result;
      $devinfo = new stdClass(); 
      $devinfo->name = $res->name;  
      $devinfo->deviceid = $res->id;  
      $devinfo->accountid = $accountid;  
      $devinfo->mac_address = strtolower($res->mac_address);  
      $devinfo->username = $res->sip->username;   
      $devinfo->password = $res->sip->password;  
      $splitname = preg_split("/[\s,]+/",$this->getUserInfo($accountid,$res->owner_id)->cidname);  
      $devinfo->cidname = substr($splitname[0],0,6);  
      $devinfo->cidnumber = $this->getUserInfo($accountid,$res->owner_id)->cidnumber;  
      $devinfo->realm = $this->getAccountInfo($accountid)->realm;  
      $devinfo->registered = $this->getDeviceStatus($accountid,$res->id);
     try{
      $tz = $this->getUserInfo($accountid,$res->owner_id)->timezone;
      $devinfo->timezone = $this->getTZOffset($tz);  
      $devinfo->tzname = $this->getTZName($tz);  
      $this->_log->logInfo("getDeviceInfo - Specific User TZ detected : ".$devinfo->timezone." ".$tz." ".$devinfo->tzname);
     } catch (Exception $e){
       $devinfo->timezone = ""; 
     }
      $devinfo->expire = $res->sip->expire_seconds;  
      $devinfo->enabled = $res->enabled;  
      usleep($sleep);
      return $devinfo;
    } else {
     return;
    }
  }

 public function setTempVars($accountid){
    $this->_log->logInfo("Getting info for: ". $accountid);
    $this->db->useDatabase("accounts");
    $this->accountid = $accountid;
    try{
        $acc = $this->db->getDoc($accountid);
        $this->_log->logInfo($acc->apiUrl);
        $this->apiUrl = $acc->apiUrl;
        $this->apiKey = $acc->apiKey;
        $this->connectAPIkey();
    } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
    }

      $tempvars = new stdClass();
      $tempvars->enabled ="/{enabled}/";
      $tempvars->username ="/{username}/";
      $tempvars->password ="/{password}/";
      $tempvars->cidname ="/{cidname}/";
      $tempvars->cidnumber ="/{cidnumber}/";
      $tempvars->realm ="/{realm}/";
      $tempvars->expire ="/{expire}/";
      $tempvars->timezone ="/{timezone}/";
      $tempvars->tzname ="/{tzname}/";
   return $tempvars;
 }

 public function mergeTemplateAccount($accountid,$doc){
      $a = $this->SetTempVars($accountid);
      $b = $this->getAccountInfo($accountid);   

                  foreach ($doc->usr_keys as $key => $value ){ }

                 if(isset($doc->cfg_account)){
                   foreach ($doc->cfg_account as $key => $value ){ }}

   		   foreach ($doc->cfg_base as $key => $value ){
                        $doc->cfg_base->$key = preg_replace($a->timezone,$this->getTZOffset($b->timezone),$value);
                        if(isset($a->tzname) && isset($b->timezone)) $doc->cfg_base->$key = preg_replace($a->tzname,$this->getTZName($b->timezone),$doc->cfg_base->$key);
    		   }

                  foreach ($doc->cfg_behavior as $key => $value ){ }
                  foreach ($doc->cfg_tone as $key => $value ){ }
                 if(isset($doc->cfg_prgkey)){
                  foreach ($doc->cfg_prgkey as $key => $value ){ }}
                  foreach ($doc->cfg_key as $key => $value ){ }
                  foreach ($doc->cfg_extkey as $key => $value ){ }

         return $doc;    
        
	}

 public function mergeTemplateDevice($accountid,$mac_address,$doc){ 
          $ckey = $accountid.$mac_address;
          $this->flushkey($ckey);
    

          $a = $this->SetTempVars($accountid);
          $b = $this->getDeviceInfo($accountid,$mac_address);
                 foreach ($doc->usr_keys as $key => $value ){ }

                 if(isset($doc->cfg_account)){
                  foreach($a as $akey => $bval){
                   foreach ($doc->cfg_account as $key => $value ){
                      if(isset($a->$akey) && isset($b->$akey)) $doc->cfg_account->$key = preg_replace($a->$akey,$b->$akey,$value);
                      //$this->_log->logInfo($doc->cfg_account->$key);
                   }}}

                   foreach ($doc->cfg_base as $key => $value ){
                      $doc->cfg_base->$key = preg_replace($a->timezone,$b->timezone,$value);
                      if(isset($a->tzname) && isset($b->tzname)) $doc->cfg_base->$key = preg_replace($a->tzname,$b->tzname,$doc->cfg_base->$key);
                   }

                  foreach ($doc->cfg_behavior as $key => $value ){ }
                  foreach ($doc->cfg_tone as $key => $value ){ }

                 if(isset($doc->cfg_prgkey)){
                  foreach ($doc->cfg_prgkey as $key => $value ){ }}

                  //foreach ($doc->cfg_key as $key => $value ){ }
                  if(isset($doc->cfg_key)){
                  foreach($a as $akey => $bval){
                   foreach ($doc->cfg_key as $key => $value ){
                      if(isset($a->$akey) && isset($b->$akey)) $doc->cfg_key->$key = preg_replace($a->$akey,$b->$akey,$value);
                   }}}

                 if(isset($doc->cfg_extkey)){
                  foreach ($doc->cfg_extkey as $key => $value ){ }}

		return $doc;
        } 

  public function getDeviceInfoMac($mac_address){
  //this is for the phone to provision 001565...cfg
    $this->db->useDatabase("devices");

    try{
        $result = $this->db->getDoc($this->getDevicedoc($mac_address)); 
        return $this->mergeTemplateDevice($result->accountid,$mac_address,$result);
    } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        return;
    }

  }

  public function getGlobalInfoMac($mac_address){
  //this is for the phone to provision y0000000000xx
    $this->db->useDatabase("devices");

    try{
        $device = $this->db->getDoc($this->getDevicedoc($mac_address));
    } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
    }
       $tempid=$device->templateid;
       $accdb=$this->getAccountdb($device->accountid);
       $this->db->useDatabase($accdb);

    try{
        $result = $this->db->getDoc($tempid);
        return $this->mergeTemplateAccount($device->accountid,$result);
    } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        return;
    }
  }

    public function validate_number($content){
     $valid = true;
     foreach($content as $row){
         if(isset($row['did']) && $row['did'] != ""){
              //validate if the number is from AU,NZ,US or UK in e164
                $number = preg_replace('/[^\+|^\d]/', '', $row['did']);
      	      	if( preg_match('/^(\+61[23478]\d{8})$/', $number)
      		||  preg_match('/^(\+611[38]00\d{6})$/', $number)
      		||  preg_match('/^(\+64\d{7,9})$/', $number) 
      		||  preg_match('/^(\+44\d{7,9})$/', $number)
      		||  preg_match('/^(\+1\d{10})$/', $number)) $valid = true;
      		else $valid = false;
     	   }
	   if(!$valid) return false; 
      }
      return $valid;
    }

  public function has_dups($content){
   $dupe_array = array();
   foreach($content as $row){
          $dupe_array[] = $row['username'];
          $dupe_array[] = $row['firstname'].$row['lastname'];
          if(isset($row['did']) && $row['did'] != "") $dupe_array[] = $row['did'];
          $dupe_array[] = $row['exten'];
          $dupe_array[] = $row['mac_address'];
   } 
   if(count($dupe_array) !== count(array_unique($dupe_array))) return true;

   return false;
  }

  public function checkheaders($content){
     foreach($content as $row){
          if(isset($row['username']) 
		&& isset($row['firstname']) 
		&& isset($row['lastname']) 
		&& isset($row['email']) 
		&& isset($row['brand']) 
		&& isset($row['family'])     
		&& isset($row['model'])     
		&& isset($row['did'])        
		&& isset($row['exten'])      
		&& isset($row['mac_address'])) return true; 
     }       
    return false;
   }

 
  public function csvToJson($fname) {
    if (!($fp = fopen($fname, 'r'))) {
        $this->_log->logInfo("ERROR: CSV file not found");
        return false;
    }
    $key = fgetcsv($fp,"1024",",");
    $content = array();
        while ($row = fgetcsv($fp,"1024",",")) {
        $content[] = array_combine($key, $row);
        }
    fclose($fp);
    return $content;
   }

 public function fixMacAddress($str){
   // converts string into valid mac address;
    if(preg_match('/:/', $str) == 1 ) if(preg_match('/([a-fA-F0-9]{2}[:|\-]?){6}/', $str) == 1 ) return strtolower($str);
    if(strlen($str) == 12){ 
      $arr = str_split($str,2);
       $str = $arr[0].":".$arr[1].":".$arr[2].":".$arr[3].":".$arr[4].":".$arr[5];
        if( preg_match('/([a-fA-F0-9]{2}[:|\-]?){6}/', $str) == 1 ){
            $mac_address = strtolower($str);
             return $mac_address;
         } else {
             return false;
         }
    } else {
       return false;
    }
 }


  private function generateRandom($length = 10) {
    return substr(str_shuffle("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"), 0, $length);
 }

  public function syncPublicHolidays($accountid){
    $tz = $this->getAccountInfo($accountid)->timezone;
    
    $filter = array('filter_type' => 'main');
    $cfs = $this->api->Account($accountid)->Callflows($filter);
    	$ch = curl_init();
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_URL, HOLYURL);
	$data = curl_exec($ch);
	curl_close($ch);

	$xml = simplexml_load_string($data);

	$tzlist = array();
	$tzlist['ACT'] = 'Australia/Sydney';
	$tzlist['NSW'] = 'Australia/Sydney';
	$tzlist['NT'] = 'Australia/Darwin';
	$tzlist['QLD'] = 'Australia/Brisbane';
	$tzlist['SA'] = 'Australia/Adelaide';
	$tzlist['TAS'] = 'Australia/Hobart';
	$tzlist['VIC'] = 'Australia/Melbourne';
	$tzlist['WA'] = 'Australia/Perth';

        $temporalrules = $this->api->Account($accountid)->TemporalRules();
        $tr_ids = array();
        foreach($temporalrules as $element) {
           $temprule = $element->fetch();
           $tr_id = $temprule->getId();
           if(preg_match('/AHS\-/',$temprule->name) == 1) {
                                              array_push($tr_ids,$tr_id);
                                              $temprule->remove();
        }}

	foreach($xml as $element){
  		$caltree = json_decode(json_encode($element));
  		$event = $caltree->events->event;
  		foreach($event as $date){
   			$fmtdate = explode('/',$date->date);
                        $datefixed = DateTime::createFromFormat('d/m/Y', $date->date)->format('Y-m-d');
                        $date1 = new DateTime($datefixed);
                        $date2 = new DateTime(date('Y-m-d',strtotime(date("Y-m-d", mktime()) . " +365 day")));
                        $eventname = strtoupper(preg_replace('/[^A-Za-z0-9\-]/', '',$caltree->jurisdictionName."-".$date->holidayTitle));
                        if($date1<$date2 && $tz == $tzlist[$caltree->jurisdictionName] ) {
       
        $this->_log->logInfo("INFO: ".$tzlist[$caltree->jurisdictionName]." ".$eventname." : Day ".$fmtdate[0]." Month ".$fmtdate[1]);
        $temporalrule = $this->api->Account($accountid)->TemporalRule();
        $temporalrule->name = "AHS-" . $eventname;
        $temporalrule->cycle="yearly";
        $temporalrule->interval="1";
        $temporalrule->month=intval($fmtdate[1]);
        $temporalrule->type="main_holidays";
        $temporalrule->days=array(intval($fmtdate[0]));
        $temporalrule->id="";
        $temporalrule->ui_metadata = new stdClass();
        $temporalrule->ui_metadata->version="3.22-31";
        $temporalrule->ui_metadata->ui="monster-ui";
        $temporalrule->ui_metadata->origin="voip";
        $temporalrule->save();
        $truleid = $temporalrule->getId();
        $temporalrule->id=$truleid;
        $temporalrule->save();
              
        foreach($cfs as $cf){
              if($cf->numbers[0] == "MainHolidays") $holid = $cf->id;
        }
        foreach($cfs as $cf){
              if($cf->name == "MainCallflow" && isset($holid)){

             	$cffx = $this->api->Account($accountid)->Callflow($cf->id)->fetch();
                
                foreach($tr_ids as $id){
                  $this->_log->logInfo("INFO: "."Deleting old AHS holiday rules: id(".$id.")");
                  unset($cffx->flow->children->{$id});
                  unset($cffx->metadata->{$id});
                  if(($key = array_search($id, $cffx->flow->data->rules)) !== false) unset($cffx->flow->data->rules[$key]);
                } 
             	$cffx->save();
                $cffx->flow->children->{$truleid} = new stdClass();
                $cffx->flow->children->{$truleid}->children = new stdClass();
                $cffx->flow->children->{$truleid}->data = new stdClass();
                $cffx->flow->children->{$truleid}->data->id = $holid;
                $cffx->flow->children->{$truleid}->module = "callflow";
                $cffx->metadata->{$truleid} = new stdClass();
                $cffx->metadata->{$truleid}->name = $temporalrule->name;
                $cffx->metadata->{$truleid}->pvt_type = "temporal_rule";
                array_push($cffx->flow->data->rules,$truleid);
             	$cffx->save();
              }}}}}
      return true;
  }


  public function setCreateKazooDevice($accountid,$mac_address,$userdata){
    if($this->is_authorized()){
      try{
        
      /*if(isset($userdata['did'])){
       $pnumber = $this->api->Account($accountid)->PhoneNumber("+".$userdata['did'])->activate();
       $pnumber->{$userdata['did']} = new stdClass();
       $pnumber->{$userdata['did']}->state = "in_service";
       $pnumber->{$userdata['did']}->features = array("local");
       $pnumber->{$userdata['did']}->assigned_to = $accountid;
       $pnumber->{$userdata['did']}->used_by = "callflow";
       $rpnumber = $pnumber->save();
       return $pnumber;
       }*/

       $user = $this->api->Account($accountid)->User();
       $user->username = strtolower($userdata['email']);  
       $user->first_name = $userdata['firstname'];  
       $user->last_name = $userdata['lastname'];  
       $user->timezone = $this->getAccountInfo($accountid)->timezone;  
       $user->presence_id = $userdata['exten'];  
       $user->account_name = $this->getAccountInfo($accountid)->name; 
       $user->caller_id->internal->name = $userdata['firstname']." ".$userdata['lastname'];
       $user->caller_id->internal->number = $userdata['exten'];
       $user->call_restriction->closed_groups->action="inherit";  
       $user->call_restriction->emergency->action="inherit";  
       $user->call_restriction->premium->action="inherit";  
       $user->call_restriction->tlf->action="inherit";  
       $user->call_restriction->national->action="inherit";  
       $user->call_restriction->international->action="inherit";  
       $user->call_restriction->catch_all->action="deny";  
       $user->require_password_update = true;  
       $user->priv_level = "user";  
       $user->send_email_on_creation = false;  
       $user->vm_to_email_enabled = true;  
       $user->email = strtolower($userdata['email']); 
       $user->enabled = true;  
       $ruser = $user->save();  
       $user->id = $ruser->id;
       $ruser = $user->save();  
       sleep(1);

       $device = $this->api->Account($accountid)->Device();
       $device->name = $userdata['exten'];
       $device->mac_address = $mac_address;
       $device->sip->username = "user_".$this->generateRandom(8);
       $device->sip->password = $this->generateRandom(10);
       $device->sip->expire_seconds = 300;
       $device->media->audio->codecs = array("PCMA","PCMU");
       $device->owner_id = $ruser->id;
       $device->contact_list->exclude = false;
       $device->device_type = "sip_device";
       $device->ringtones->internal = "http://127.0.0.1/Bellcore-dr4";
       $device->call_restriction->closed_groups->action="inherit";
       $device->call_restriction->emergency->action="inherit";    
       $device->call_restriction->premium->action="inherit";      
       $device->call_restriction->tlf->action="inherit";          
       $device->call_restriction->national->action="inherit";     
       $device->call_restriction->international->action="inherit";
       $device->call_restriction->catch_all->action="deny";
       $device->ui_metadata->version="3.22-31";
       $device->ui_metadata->ui="monster-ui";
       $device->ui_metadata->origin="callflows";
       $rdevice = $device->save();
       $device->id = $rdevice->id;
       $rdevice = $device->save();
       sleep(1);

       $vmbox = $this->api->Account($accountid)->VMBox();
       $vmbox->name = $userdata['firstname']." ".$userdata['lastname']."'s VMBox";
       $vmbox->mailbox = $userdata['exten'];
       //$vmbox->notify_email_addresses = array(strtolower($userdata['email']));
       $vmbox->pin = substr(str_shuffle("0123456789"),0,4); 
       $vmbox->owner_id = $ruser->id;
       $rvmbox = $vmbox->save();
       $vmbox->id = $rvmbox->id;
       $rvmbox = $vmbox->save();
       sleep(1);

       if(isset($userdata['did']) && !empty($userdata['did'])){
            $did = array($userdata['exten'],$userdata['did']);
       }
       else { 
            $did = array($userdata['exten']);
       }
 
       $child = new stdClass();
       $child->_->data->id = $rvmbox->id;
       $child->_->module = "voicemail";
       $child->_->children = new stdClass();

       $cf = $this->api->Account($accountid)->Callflow();    
       $cf->numbers = $did;
       $cf->contact_list->exclude = false;
       $cf->name = $userdata['firstname']." ".$userdata['lastname']." Provisioner CF";
       $cf->owner_id = $ruser->id;
       $cf->type = "mainUserCallflow";
       $cf->metadata->{$ruser->id}->name = $userdata['firstname']." ".$userdata['lastname'];
       $cf->metadata->{$ruser->id}->pvt_type = "user";
       $cf->metadata->{$rvmbox->id}->name = $userdata['firstname']." ".$userdata['lastname']." VMBox";
       $cf->metadata->{$rvmbox->id}->pvt_type = "vmbox";
       $cf->flow->data->id = $ruser->id; 
       $cf->flow->data->timeout = 20; 
       $cf->flow->data->can_call_self=false; 
       $cf->flow->module = "user"; 
       $cf->flow->children = $child; 
       $rcf = $cf->save();
       sleep(5);

       $tempdev = $this->getNewtemplate($userdata['brand'],$userdata['family'],$userdata['model']);
       $this->setTemplateAccount($tempdev,$accountid);
       $this->setTemplateDevice($tempdev,$accountid,$mac_address);
 
      return $rdevice;

      } catch(Exception $e){
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        return false;
      }       
    } else {
         $this->_log->logInfo("User Not Authorized: check your username/password");
    }
  }

  public function delTemplateAccount($accountid,$brand,$family,$model){
     $temp = $this->getTemplateid($brand,$family,$model);
     try{
        $this->db->useDatabase($this->getAccountdb($accountid)); 
        $acctemp = $this->db->getDoc($temp);
        $this->db->deleteDoc($acctemp);
         return true;
     } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        return false;
     }
  }

  public function delTemplateDevice($accountid = null,$mac_address){
     $this->db->useDatabase("devices");
     try{
         $device = $this->db->getDoc($this->getDevicedoc($mac_address));
         $devaccid = "";
         if(isset($device->accountid)) $devaccid = $device->accountid;
         if($accountid == $devaccid || $accountid == "81490d6ce5d4babcf5845dc855a20b69" ){
            return $this->db->deleteDoc($device);
         } else if ( $accountid == "all") {
            return $this->db->deleteDoc($device);
         } else {
            return false;
         }  
     } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        return false;
    }
  }
   
  public function renderKeysHTMLForm($type, $accountid = null,$mac_address = null, $brand = null, $family = null, $model = null){
    $html = "";
    $html .= "<a href='account.php'>Back</a>";
    if($type == "account"){
     try {
      $temp = $this->getTemplateid($brand,$family,$model);
      $this->db->useDatabase($this->getAccountdb($accountid));
      $doc = $this->db->getDoc($temp); 
                  if(isset($doc->cfg_prgkey)){
                  $html .= "<form action='keys.php' name='acc_prg' method='POST'><table class='cfg_prgkey'><tr>"; 
                  foreach ($doc->cfg_prgkey as $key => $value ){ 
                     $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";  
                     }
                 $html .= "<input type='text' hidden name='type' value='".$type."'>";
                 $html .= "<input type='text' hidden name='cfgtype' value='cfg_prgkey'>";
                 $html .= "<input type='text' hidden name='accountid' value='".$accountid."'>";
                 $html .= "<input type='text' hidden name='brand' value='".$brand."'>";
                 $html .= "<input type='text' hidden name='family' value='".$family."'>";
                 $html .= "<input type='text' hidden name='model' value='".$model."'>";
                 $html .= "<input type='submit' value='Save'></td></tr></table></form>";}

                 if(isset($doc->cfg_key)){
                  $html .= "<form action='keys.php' name='acc_key' method='POST'><table class='cfg_key'><tr>"; 
                  foreach ($doc->cfg_key as $key => $value ){ 
                     $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";  
                    }
                 $html .= "<input type='text' hidden name='type' value='".$type."'>";
                 $html .= "<input type='text' hidden name='cfgtype' value='cfg_key'>";
                 $html .= "<input type='text' hidden name='accountid' value='".$accountid."'>";
                 $html .= "<input type='text' hidden name='brand' value='".$brand."'>";
                 $html .= "<input type='text' hidden name='family' value='".$family."'>";
                 $html .= "<input type='text' hidden name='model' value='".$model."'>";
                 $html .= "<input type='submit' value='Save'></td></tr></table></form>";}

                 if(isset($doc->cfg_extkey)){
                  $i=0;
                  $html .= "<form action='keys.php' name='acc_ext' method='POST'><table class='cfg_extkey'><tr>"; 
                  foreach ($doc->cfg_extkey as $key => $value ){ 
                     $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";  
                     $i++;
                    }
                 if($i > 0) {
                 $html .= "<input type='text' hidden name='type' value='".$type."'>";
                 $html .= "<input type='text' hidden name='cfgtype' value='cfg_extkey'>";
                 $html .= "<input type='text' hidden name='accountid' value='".$accountid."'>";
                 $html .= "<input type='text' hidden name='brand' value='".$brand."'>";
                 $html .= "<input type='text' hidden name='family' value='".$family."'>";
                 $html .= "<input type='text' hidden name='model' value='".$model."'>";
                 $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>";}}
                 $html .= "<a href='account.php'>Back</a>";
       return $html;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      $html = "<div>Ouch! Something went wrong!</div>"; 
      $html .= "<a href='index.php'>Back</a>";
      return $html;
     }
    } 
 
    if($type == "device"){
     try {
      $this->db->useDatabase("devices");
      $doc = $this->db->getDoc($this->getDevicedoc($mac_address));
                  if(isset($doc->cfg_prgkey)){
                  $html .= "<form action='keys.php' name='dev_prg' method='POST'><table class='cfg_prgkey'><tr>"; 
                  foreach ($doc->cfg_prgkey as $key => $value ){
                     $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";  
                     }
                  $html .= "<input type='text' hidden name='type' value='".$type."'>";
                  $html .= "<input type='text' hidden name='cfgtype' value='cfg_prgkey'>";
                  $html .= "<input type='text' hidden name='mac_address' value='".$mac_address."'>";
                  $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>"; }

                 if(isset($doc->cfg_key)){
                  $html .= "<form action='keys.php' name='dev_key' method='POST'><table class='cfg_key'><tr>"; 
                  foreach ($doc->cfg_key as $key => $value ){ 
                     $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";  
                    }
                  $html .= "<input type='text' hidden name='type' value='".$type."'>";
                  $html .= "<input type='text' hidden name='cfgtype' value='cfg_key'>";
                  $html .= "<input type='text' hidden name='mac_address' value='".$mac_address."'>";
                  $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>";}

                 if(isset($doc->cfg_extkey)){
                  $i=0;
                  $html .= "<form action='keys.php' name='dev_ext' method='POST'><table class='cfg_extkey'><tr>"; 
                  foreach ($doc->cfg_extkey as $key => $value ){ 
                     $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";  
                     $i++;
                    }
                 if($i > 0) {
                 $html .= "<input type='text' hidden name='type' value='".$type."'>";
                 $html .= "<input type='text' hidden name='cfgtype' value='cfg_extkey'>";
                 $html .= "<input type='text' hidden name='mac_address' value='".$mac_address."'>";
                 $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>"; }}
                 $html .= "<a href='account.php'>Back</a>";
       return $html;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      $html = "<div>Ouch! Something went wrong!</div>"; 
      $html .= "<a href='account.php'>Back</a>";
      return $html;
     }
    }

      $html = "<div>Ouch! Something went wrong!</div>"; 
      $html .= "<a href='account.php'>Back</a>";
     return $html;
  }

  public function updateAccountParam($postdata){
     if(isset($postdata['accountid'])) $accountid = $postdata['accountid'];
     if(isset($postdata['brand'])) $brand = $postdata['brand'];
     if(isset($postdata['family'])) $family = $postdata['family'];
     if(isset($postdata['model'])) $model = $postdata['model'];
     if(isset($postdata['cfgtype'])) $cfgtype = $postdata['cfgtype'];
     if(isset($postdata['type'])) $type = $postdata['type'];
     unset($postdata['accountid']);
     unset($postdata['brand']);
     unset($postdata['family']);
     unset($postdata['model']);
     unset($postdata['cfgtype']);
     unset($postdata['type']);

     try {
      $temp = $this->getTemplateid($brand,$family,$model);
      $this->db->useDatabase($this->getAccountdb($accountid));
      $doc = $this->db->getDoc($temp);
       if(isset($doc->{$cfgtype})){
         foreach($postdata as $key => $value){
             $newkey = str_replace('+','.',$key);
             $doc->{$cfgtype}->{$newkey} = $value;
         }
       }
       $response = $this->db->storeDoc($doc);
       $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
       return true;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      return false;
     }
  }

  public function updateDeviceParam($postdata){

     if(isset($postdata['mac_address'])) $mac = $postdata['mac_address'];
     if(isset($postdata['cfgtype'])) $cfgtype = $postdata['cfgtype'];
     if(isset($postdata['type'])) $type = $postdata['type'];
     unset($postdata['mac_address']);
     unset($postdata['cfgtype']);
     unset($postdata['type']);
    
     try {
      $this->db->useDatabase("devices");
      $doc = $this->db->getDoc($this->getDevicedoc($mac));
       if(isset($doc->{$cfgtype})){
         foreach($postdata as $key => $value){
             $newkey = str_replace('+','.',$key);
             $doc->{$cfgtype}->{$newkey} = $value;
         }     
       }
       $response = $this->db->storeDoc($doc);
       $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
       return true;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      return false;
     }
  }

  public function is_allowed($key){
    $allowed = array();
    $allowed[] = 'account.1.sip_server.1.transport_type';
    $allowed[] = 'account.1.sip_server.2.transport_type';
    $allowed[] = 'local_time.summer_time';
    $allowed[] = 'tagging';
    $allowed[] = 'vlan';
    $allowed[] = 'VLAN';
    $allowed[] = 'P51';
    $allowed[] = 'P48';
    $allowed[] = 'P2333';
    $allowed[] = 'network.vlan';
    $allowed[] = 'network.port';
    $allowed[] = 'network.pc';
    $allowed[] = 'account.1.backup_outbound';
    $allowed[] = 'transfer';
    $allowed[] = 'backlight';
    $allowed[] = 'Attn_Transfer';
    $allowed[] = 'account.1.outbound';
    $allowed[] = 'Outbound_Proxy';
    $allowed[] = 'outbound proxy';
    $allowed[] = 'outboundProxy.address';
    $allowed[] = 'outboundProxy.port';
    $allowed[] = 'sip.listen_port';
    $allowed[] = 'SIP_Port_1_';
    $allowed[] = 'account.1.sip_server.1.port';
    $allowed[] = 'phone_setting.backgrounds';
    $allowed[] = 'features.power_saving.enable';
    $allowed[] = 'wallpaper_upload.url';
    $allowed[] = 'call_waiting';
    $allowed[] = 'user_outbound1';
    $allowed[] = 'ntp_server';

    foreach($allowed as $val){ if(preg_match('/'.$val.'/',$key) == 1) return true; }
    
    return false;                           
  }

  public function renderAdvancedHTMLForm($type, $accountid = null,$mac_address = null, $brand = null, $family = null, $model = null){
    $allowed = 'transport vlan outbound_port transfer';

    $html = "";
    $html .= "<a href='account.php'>Back</a>";
    if($type == "account"){
     try {
      $temp = $this->getTemplateid($brand,$family,$model);
      $this->db->useDatabase($this->getAccountdb($accountid));
      $doc = $this->db->getDoc($temp);

                 if(isset($doc->cfg_base)){
                  $html .= "<form action='base.php' name='acc_base' method='POST'><table class='cfg_base'><tr>";
                  foreach ($doc->cfg_base as $key => $value ){
                     if($this->is_allowed($key)) $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";
                    }
                 $html .= "<input type='text' hidden name='type' value='".$type."'>";
                 $html .= "<input type='text' hidden name='cfgtype' value='cfg_base'>";
                 $html .= "<input type='text' hidden name='accountid' value='".$accountid."'>";
                 $html .= "<input type='text' hidden name='brand' value='".$brand."'>";
                 $html .= "<input type='text' hidden name='family' value='".$family."'>";
                 $html .= "<input type='text' hidden name='model' value='".$model."'>";
                 $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>";}

                 if(isset($doc->cfg_behavior)){
                  $html .= "<form action='base.php' name='acc_beh' method='POST'><table class='cfg_behavior'><tr>";
                  foreach ($doc->cfg_behavior as $key => $value ){
                     if($this->is_allowed($key)) $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";
                    }
                 $html .= "<input type='text' hidden name='type' value='".$type."'>";
                 $html .= "<input type='text' hidden name='cfgtype' value='cfg_behavior'>";
                 $html .= "<input type='text' hidden name='accountid' value='".$accountid."'>";
                 $html .= "<input type='text' hidden name='brand' value='".$brand."'>";
                 $html .= "<input type='text' hidden name='family' value='".$family."'>";
                 $html .= "<input type='text' hidden name='model' value='".$model."'>";
                 $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>";}

       return $html;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      $html = "<div>Ouch! Something went wrong!</div>";
      $html .= "<a href='index.php'>Back</a>";
      return $html;
     }
    }
    if($type == "device"){
     try {
      $this->db->useDatabase("devices");
      $doc = $this->db->getDoc($this->getDevicedoc($mac_address));
                  if(isset($doc->cfg_account)){
                  $html .= "<form action='base.php' name='dev_acc' method='POST'><table class='cfg_account'><tr>";
                  foreach ($doc->cfg_account as $key => $value ){
                     if($this->is_allowed($key)) $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";
                     }
                  $html .= "<input type='text' hidden name='type' value='".$type."'>";
                  $html .= "<input type='text' hidden name='cfgtype' value='cfg_account'>";
                  $html .= "<input type='text' hidden name='mac_address' value='".$mac_address."'>";
                  $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>";}

                 if(isset($doc->cfg_base)){
                  $html .= "<form action='base.php' name='dev_base' method='POST'><table class='cfg_base'><tr>";
                  foreach ($doc->cfg_base as $key => $value ){
                     if($this->is_allowed($key)) $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";
                    }
                  $html .= "<input type='text' hidden name='type' value='".$type."'>";
                  $html .= "<input type='text' hidden name='cfgtype' value='cfg_base'>";
                  $html .= "<input type='text' hidden name='mac_address' value='".$mac_address."'>";
                  $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>";}

                 if(isset($doc->cfg_behavior)){
                  $html .= "<form action='base.php' name='dev_beh' method='POST'><table class='cfg_behavior'><tr>";
                  foreach ($doc->cfg_behavior as $key => $value ){
                     if($this->is_allowed($key)) $html .= "<tr><td>".$key."</td><td>"."<input type='text' name='".str_replace('.','+',$key)."' value='".$value."'></td></tr>";
                    }
                  $html .= "<input type='text' hidden name='type' value='".$type."'>";
                  $html .= "<input type='text' hidden name='cfgtype' value='cfg_behavior'>";
                  $html .= "<input type='text' hidden name='mac_address' value='".$mac_address."'>";
                  $html .= "<tr><td><input type='submit' value='Save'></td></tr></table></form>";}


                 $html .= "<a href='account.php'>Back</a>";
       return $html;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      $html = "<div>Ouch! Something went wrong!</div>";
      $html .= "<a href='account.php'>Back</a>";
      return $html;
     }
    }
      $html = "<div>Ouch! Something went wrong!</div>";
      $html .= "<a href='account.php'>Back</a>";
     return $html;
  }
  
}

?>
