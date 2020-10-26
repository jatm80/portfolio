<?php

Class Phonebook {
  protected $api;
  protected $db;
  protected $auth;
  protected $apiKey;
  protected $apiUrl;
  protected $_log;
  protected $accountid;
  protected $userid;
  
     public function __construct ( $user = null , $pass = null, $apiUrl = null,$realm = null,$accname = null){
        $this->_log = KLogger::instance('logs', Klogger::DEBUG);
        $this->_log->logInfo('================== Starting process ==================');
        $this->_log->logInfo('================== couch connect ==================');
        $this->db = new couchClient (DB_SERVER.':'.DB_PORT,DB_DEF);
      if(!is_null($user) or !is_null($pass) or !is_null($apiUrl) or !is_null($accname)){ 
        $this->_log->logInfo('================== secure api connect ==================');
       try{
	$options = array('base_url' => $apiUrl);
        $authToken = new \Kazoo\AuthToken\User($user, $pass,null,$accname);
        $this->api = new \Kazoo\SDK($authToken, $options);
        $this->accountid = $this->api->Account()->id;
        $this->fetchUserId($user);
        $this->auth = true;
        if($this->storeAccountInfo()) $this->syncKazooExten($this->accountid);
        } catch (Exception $e){
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        }
       }
    }

   private function connectAPIKey(){
        $this->_log->logInfo('================== unsecure api connect ==================');
        $this->_log->logInfo($this->apiUrl);
        $options = array('base_url' => $this->apiUrl);
        $authToken = new \Kazoo\AuthToken\ApiKey($this->apiKey);
        $this->api = new \Kazoo\SDK($authToken, $options);
        $this->auth = false;
   }

   public function fetchUserId($user){
        $filter = array('filter_username' => $user);
        $usrs = $this->api->Account($this->accountid)->Users($filter);
        foreach($usrs as $usr){
              $this->userid = $usr->id; 
        } 
   }

   public function getUserMac($mac_address){
        $filter = array('filter_mac_address' => $mac_address);
        $devs = $this->api->Account($this->accountid)->Devices($filter);
     
        if(count($devs)>0){
          foreach($devs as $dev) $userid = $this->api->Account($this->accountid)->Device($dev->id);
         }else{
           $filter = array('filter_mac_address' => strtoupper($mac_address));
           $devs = $this->api->Account($this->accountid)->Devices($filter);
           foreach($devs as $dev) $userid = $this->api->Account($this->accountid)->Device($dev->id);
         }
        return $userid->owner_id;
   }

   public function getPhonebookDevice($mac_address){
        $macdoc = $this->getDevicedoc($mac_address);
        $this->_log->logInfo("Getting account info for: ". $macdoc);
    	$this->db->useDatabase("devices");
    	try{
        	$dev = $this->db->getDoc($macdoc);
    	} catch(Exception $e) {
        	$this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
    	}	

        $this->db->useDatabase("accounts");
        try{
                $accinfo = $this->db->getDoc($dev->accountid);
        } catch(Exception $e) {
                $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        }
 
        $this->apiKey = $accinfo->apiKey;           
        $this->apiUrl = $accinfo->apiUrl;           
        $this->connectAPIKey();

        try{
    	        $this->db->useDatabase("phonebook");
                if($this->is_DocExists($dev->accountid)) {
                         $base = $this->db->getDoc($dev->accountid);
                         $phonebook  = new stdClass();
                         $phonebook->hostedpbx  = $base->hostedpbx;
                         $phonebook->phonebook  = $base->phonebook;
                         $devuid = $this->getUserMac($mac_address); 
                         $this->_log->logInfo("Getting User id for '".$mac_address."' : " . $devuid);
                         if(!empty($devuid) && isset($base->{$devuid})) $phonebook->{$devuid} = $base->{$devuid};
                         return $phonebook;
                }
                else $this->_log->logInfo("ERROR: getPhonebookDevice phonebook  Document doesn't exists");
        } catch(Exception $e) {
                $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        }
            
                return false;
   }

   public function getPhonebook($accountid){
        try{
                $this->db->useDatabase("phonebook");
                if($this->is_DocExists($accountid)) { 
                         $base = $this->db->getDoc($accountid);
                         $phonebook  = new stdClass();
                         $phonebook->hostedpbx  = $base->hostedpbx;
                         $phonebook->phonebook  = $base->phonebook;
                         if(!empty($this->userid) && isset($base->{$this->userid})) $phonebook->{$this->userid} = $base->{$this->userid};   
                         return $phonebook;
                }
                else $this->_log->logInfo("ERROR: Document doesn't exists");
        } catch(Exception $e) {
                $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        }
                return false;
   }

   public function getAuth(){
        return $this->auth;
   }

   public function getAccountid(){
        return $this->accountid;
   }
  
   public function getUserid(){
        return $this->userid;
   }

   public function setAccountid($accid){
        $this->accountid = $accid;
   }

   public function is_DocExists($docid){
       $this->db->useDatabase("phonebook");
        try {
              $this->db->getDoc($docid);
              return true;
        } catch (Exception $e) {
              return false;
        }
   }

   public function getDevicedoc($mac_address){
       $id = $mac_address;
       if(preg_match('/([a-fA-F0-9]{2}[:|\-]?){6}/', $mac_address)){
          $id = strtolower(str_replace(':', '', $mac_address));
          $this->_log->logInfo($id);
       } else {
          $this->_log->logInfo($mac_address."-- not mac address");
          return false;
       }
        return $id;
   }


   public function storeAccountInfo(){
       $this->db->useDatabase("phonebook");
       if ( !$this->db->databaseExists() ) {
          $this->db->createDatabase();
       }
        $new_doc = new stdClass();
        $new_doc->_id= $this->accountid;
        $new_doc->phonebook = new stdClass();
        $new_doc->pvt_type = "phonebook";
        $new_doc->pvt_enable = "true";
 
         	try{ 
                	if(!$this->is_DocExists($new_doc->_id)) { 
                          $response=$this->db->storeDoc($new_doc);
                	  $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
                        }
                        return true;
        	} catch (Exception $e) {
                	$this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
                        return false;
        	}	
    }
 
    
   public function deletePhonebook($accountid){ 
     $this->db->useDatabase("phonebook");
     try{
        if($this->is_DocExists($accountid)){
         $pb = $this->db->getDoc($accountid);
         $this->db->deleteDoc($pb);
         } else return false;
     } catch(Exception $e) {
        $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
        return false;
    }
   }

   public function updateRecord($accountid,$type,$data){
     try {
      $this->db->useDatabase("phonebook");
      $pb = $this->db->getDoc($accountid);
      $pb->{$type}->{$data->number}->firstname = $data->firstname;
      $pb->{$type}->{$data->number}->lastname = $data->lastname;
      $pb->{$type}->{$data->number}->email = $data->email;
      $pb->{$type}->{$data->number}->group = $data->group;
      $pb->{$type}->{$data->number}->cname = $data->cname;
      $pb->{$type}->{$data->number}->snumber = $data->snumber;
       $response = $this->db->storeDoc($pb);
       $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
       return true;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      return false;
     }
   }

   public function deleteRecord($accountid,$number,$type){
     try {
       $this->db->useDatabase("phonebook");
       $pb = $this->db->getDoc($accountid);
       unset($pb->{$type}->$number);
       $response = $this->db->storeDoc($pb);
       $this->_log->logInfo("Doc recorded. id = ".$response->id." and revision = ".$response->rev);
       return true;
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
      return false;
     }
   }

  public function getUsers($accountid){
    $options = array('paginate' => 'false');
    $usrs = $this->api->Account($accountid)->Users($options);
    $result = array();
     
    foreach($usrs as $usr){  
     
    $res = json_decode($usr);

    if(isset($res->presence_id)) {
    $userinfo = new stdClass();
    $userinfo->firstname = $res->first_name;
    $userinfo->lastname = $res->last_name;
    $userinfo->email = $res->email;
    $userinfo->group = "Corporate";
    $userinfo->number = $res->presence_id;
    $userinfo->cname = "";
    $userinfo->snumber = "";
    $result[$res->id] = $userinfo;
    }}
    return $result;

  }

   public function syncKazooExten($accountid){
     $users = $this->getUsers($accountid);
     try {
       $this->db->useDatabase("phonebook");
       $pb = $this->db->getDoc($accountid);
       if(isset($pb->hostedpbx)) unset($pb->hostedpbx);
       $response = $this->db->storeDoc($pb);
     } catch(Exception $e) {
      $this->_log->logInfo("ERROR: ".$e->getMessage()." (".$e->getCode().")");
     }
     foreach($users as $user){
       $this->updateRecord($accountid,'hostedpbx',$user);
     }
   }

   public function getOwnedDevices($accountid,$userid){
     $filter = array('filter_owner_id' => $userid);
     $devices = $this->api->Account($accountid)->Devices($filter);
     $result = array();
     foreach($devices as $device){
       $result[$device->id] = $device->name;
     }
     return $result;
   }

   public function c2c($accountid,$deviceid,$number){
      $this->_log->logInfo("PB: C2C".$number);
      $options_caller = array('auto-answer' => 'true');
      $device = $this->api->Account($accountid)->Device($deviceid);
      return $device->quickcall($number,$options_caller);
   }

   public function csvToJson($fname) {
    if (!($fp = fopen($fname, 'r'))) {
        $this->_log->logInfo("ERROR: CSV file not found");
        return false;
    }
    $key = fgetcsv($fp,"2048",",");
    $content = array();
        while ($row = fgetcsv($fp,"2048",",")) {
        $content[] = array_combine($key, $row);
        }
    fclose($fp);
    return $content;
   }

   public function checkheaders($content){
     foreach($content as $row){
       if(isset($row['First Name']) 
		&& isset($row['Last Name']) 
		&& (isset($row['E-mail Address']) || isset($row['Email Address']))
		&& isset($row['Company']) 
		&& isset($row['Business Phone'])     
		&& isset($row['Mobile Phone'])) return true; 
       }
       return false;
   }

  public function validate_number($number){
       $number = preg_replace('/[^\d]/', '', $number);
       if(preg_match('/^[2-9]\d{5,20}$/', $number)) $number = '+'.$number;
       return $number;
  }
}

