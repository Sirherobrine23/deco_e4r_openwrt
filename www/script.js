
var db; 
xmlHttp.onreadystatechange=function(){
if (xmlHttp.readyState==4){
	if (xmlHttp.status==200){
		db = xmlHttp.responseText;		
	}
}
};
xmlHttp.open("GET","url_lib",false);
xmlHttp.send(null);

//function
function $(ele){
	return document.getElementById(ele);
}
function showSituation(id){
	$("situation-One").style.display="none";
	$("situation-Two").style.display="none";
	$("situation-Three").style.display="none";
	$(id).style.display="block";
}

//init text
document.title = LAN.TITLE1;
$("situation-One").getElementsByTagName("h1")[0].innerHTML=LAN.TITLE0;
$("situation-One").getElementsByTagName("span")[0].innerHTML=LAN.CONTENT0;
$("situation-Two").getElementsByTagName("h1")[0].innerHTML=LAN.TITLE1;
$("situation-Three").getElementsByTagName("h1")[0].innerHTML=LAN.TITLE1;

//logic
if(location.search.slice(1).split("&")[0]!=""){
	var urlArr = location.search.slice(1).split("&");
	var urlHash = {};
	var situationSentence;
	for(var i=0;i<urlArr.length;i++){
		urlHash[urlArr[i].split("=")[0]] = urlArr[i].split("=")[1];
	}
	var pid = urlHash["pid"];
		block_domain=urlHash["domain"];

	if(pid)
	{
		if(pid<4)
		{
			showSituation("situation-Three");
			situationSentence = $("situation-Three").getElementsByTagName("span")[0];
			switch (pid * 1) {
				case 1:
					$("situation-Three").className = "pause";
					situationSentence.innerHTML = LAN.CONTENT2;
					break;
				case 2:
					$("situation-Three").className = "time-up";
					situationSentence.innerHTML = LAN.CONTENT3;
					break;
				case 3:
					$("situation-Three").className = "bed-time";
					situationSentence.innerHTML = LAN.CONTENT4;
					break;
			}
		}
		else
		{
			var category_id = 10;
			var category_array = {};
			category_array = db.match(new RegExp("[0-9]{1,4},[^,,]+," + block_domain + ",[0-9]{1,2}", "ig"));
			if (null == category_array) {
				category_id  = 10
			}
			else {

				category_id = category_array[0].split(",")[3];
				
			}
			if (category_id > 10){
				category_id = 10
			}

			if (category_id) {
				switch (category_id * 1) {
					case 1:
						block_domain += ", " + LAN.ADULT;
						break;
					case 2:
						block_domain += ", " + LAN.ONLINE;
						break;
					case 3:
						block_domain += ", " + LAN.SOCIAL;
						break;
					case 4:
						block_domain += ", " + LAN.PAY;
						break;
					case 5:
						block_domain += ", " + LAN.MADIA;
						break;
					case 6:
						block_domain += ", " + LAN.DOWNLOAD;
						break;
					case 7:
						block_domain += ", " + LAN.GAME;
						break;
					case 8:
						block_domain += ", " + LAN.SEX;
						break;
					case 9:
						block_domain += ", " + LAN.GAMBLING;
						break;
					case 10:
						break;
			
				}
			}
			showSituation("situation-Two");
			situationSentence = $("situation-Two").getElementsByTagName("span")[0];
			situationSentence.innerHTML = LAN.CONTENT1_0 + "<br />" + LAN.CONTENT1_1+block_domain;
		}
	}
}
else{
	showSituation("situation-Two");
}
