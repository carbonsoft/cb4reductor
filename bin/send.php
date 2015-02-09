<?php

class XMLDoc {
	function send_cmd() {
		ini_set('soap.wsdl_cache_enabled', '0');
        	ini_set('soap.wsdl_cache_ttl', '0');

		$requestFile = file_get_contents('/var/lib/reductor/request.xml');
		$signatureFile = file_get_contents('/var/lib/reductor/request.xml.sign');
		try {
			$client = new SoapClient('http://vigruzki.rkn.gov.ru/services/OperatorRequest/?wsdl',
					array('trace' => 0,
						'exceptions' => 0
					)
			);
			$ap_param = array('requestFile'=>$requestFile, 'signatureFile'=>$signatureFile, 'dumpFormatVersion'=>"2.0");
			// $ap_param = array('requestFile'=>$requestFile, 'signatureFile'=>$signatureFile);
		    	$result = $client->__call("sendRequest", array($ap_param));
			return $result;
		} catch (Exception $e) {
			$err = $e->getMessage();
			exit(100);
		}
	}

	function get_result($code) {
                ini_set('soap.wsdl_cache_enabled', '0');
		ini_set('soap.wsdl_cache_ttl', '0');
		try {
			$client = new SoapClient('http://vigruzki.rkn.gov.ru/services/OperatorRequest/?wsdl',
					array('trace' => 0,
                                                'exceptions' => 0
                                        )
			);
			$ap_param = array('code'=>$code);
			$result = $client->__call("getResult", array($ap_param));
			return $result;
		} catch (Exception $e) {
                        $err = $e->getMessage();
                        exit(100);
                }
	}
}

$xmldoc = new XMLDoc;
$send_result = $xmldoc->send_cmd();
if ($send_result->result != 1) {
	echo("send_result->result != 1, bad\n");
	print_r($send_result);
	exit;
}

$debug = 1;
$xmldoc2 = new XMLDoc;
$try_get_result = 0;
$sleep_time = 10;
do {
	$get_result = $xmldoc2->get_result($send_result->code);

	if ($get_result->resultComment) {
		printf("ResultComment: %s\n", $get_result->resultComment);
		if (strstr("tooperators", $get_result->resultComment)) {
			printf("Продлите сертификат, со старым Carbon Reductor, как видите не может получить от РосКомНадзора списки сайтов.\n");
			printf("Обновление завершилось неудачно\n");
			exit(3);
		}
	}

	$try_get_result++;
	$sleep_time = $sleep_time + 5;
	printf("try: %d, sleep time: %d, result_code: %d, version: %s..\n", $try_get_result, $sleep_time, $get_result->result, $get_result->dumpFormatVersion);

	if (isset($get_result->registerZipArchive)) {
		printf("We have archive!\n");
		break;
	}

	if ($try_get_result > 10) {
		printf("More then 10 try to get archive, break\n");
		exit(4);
	}

	sleep($sleep_time);
} while ($get_result->result != 1);

if (isset($get_result->registerZipArchive)) {
	file_put_contents('/var/lib/reductor/register.zip', $get_result->registerZipArchive);
} else {
	echo("ZipArchive is null, bad\n");
	print_r($get_result);
	exit;
}
?>
