<?php

require(__DIR__.'/config.php');
$errors = array();

if(!is_dir($CFG->dataroot) || !is_writable($CFG->dataroot)) {
    array_push($errors, '$CFG->dataroot does not exist or does not have write permissions');
}

if($extraws === '') {

    $message = 'Your Moodle configuration file config.php or another library file,'
    .'contains some characters after the closing PHP tag (?>). This causes Moodle to '
    .'exhibit several kinds of problems (such as broken downloaded files) and must be fixed.';
    array_push($errors, $message); 
    } 


$lastcron = $DB->get_field_sql('SELECT max(lastcron) FROM {modules}'); 
if (time() - $lastcron > 3600 * 24){ 
    
    $message = 'The cron.php mainenance script has not been run in the past 24 hours.'
     .'This probably means that your server is not configured to automatically run this' 
     .'script in regular time intervals. If this is the case, then Moodle will mostly work'
      .'as it should but some operations  (notably sending email to users) will not be carried out at all.';
    array_push($errors, $message); 
} 
  
if (count($errors) > 0){ 
      header($_SERVER["SERVER_PROTOCOL"]." 404 Not Found", true, 404); print_r($errors); 
} else { echo OK; }; 

?>