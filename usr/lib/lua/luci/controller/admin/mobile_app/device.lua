LuaQ               DI     A@    À@@  A@  E   \   ÁÀ  Å   Ü  AA  E  \  ÁÁ  Å  Ü  AB  E  \  ÁÂ  Å  Ü  AC  E  \  ÁÃ  Å  Ü  AD  FÅ\ Ä Á E A Å Á F A  ÈÈÉÉÊÊËËÌÌÍÍÎÎÏÏÐÐ Ñ¡Ñ¢Ò£Ò¤Ó¥Ó¦ä     ÇÆ äF  $        dÇ  ¤        äG   $                  dÈ             ¤ äH     $ dÉ ¤	   	äI     $          dÊ    ¤
      
  
        äJ                                      	        Ç
 ä   $Ë      d    ¤K      ä   $Ì      d    ¤L         ä   $Í           d                          	¤M      ä     $Î                           d   GN dN   ¤   äÎ      $	 dO	    ¤	       äÏ	                      
P J  P  ÐªI©P  PªIª	P©J  P  Å ÐªI©P  ÐªI«	P«J P  Ð
ªI©P  ªIªP  ªI¬P  ÐªI­P  PªI­P  ªI®	P¬J  P  PªI©P  ªIª	P®J  P  PªI©P  ªIª	P¯JP  P  ÐªIª	P¯JÐ  P  PªI°P  ªI±P  ªI±	P°JP  P  ÐªI©	P²J  P  ÐªI©P  ªIª	P²d
       G   g      module (   luci.controller.admin.mobile_app.device    package    seeall    require    ubus    nixio 
   luci.json    luci.model.uci 
   luci.util 	   luci.sys    luci.tools.debug    luci.model.controller    luci.model.app_timesetting    luci.model.speed_test    luci.model.app_cloudfirm    luci.model.app_sysmode    luci.model.app_clientmgmt    luci.model.sync    luci.sys.config    luci.model.accountmgnt    luci.model.tmp_decrypt    cursor 	x   	È      /tmp/wifi_runtime_info.2g    /tmp/wifi_runtime_info.5g    /tmp/wifi_runtime_info.5g2    /tmp/eth_runtime_info    /tmp/plc_runtime_info    performance_limited    BG_BG 
   Bulgarian    CS_CZ    Czech    DA_DK    Danish    DE_DE    German    EN_US 	   American    ES_ES    Spanish    FI_FI    Finnish    FR_FR    French    IT_IT    Italian    JP_JP 	   Japanese    KO_KR    Korean    NL_NL    Dutch    NO_NO 
   Norwegian    PL_PL    Polish    PT_PT    Portuguese    RO_RO 	   Romanian    RU_RU    Russian    SK_SK    Slovak    SV_SE    Swedish    TH_TH    Thai    TR_TR    Turkish    UK_UA 
   Ukrainian    VI_VN    Vietnamese    ZH_TW    Traditional Chinese    _print_tbl    get_device_list    auto_test_speed    led    read    cb    write    device_list    remove 
   speedtest    stop    get    get_server    clear    timesetting    sync    envar    system    reboot    factory    gateway 
   speedinfo    sysmode 	   dispatch )       K   T       E      \ @À E     \    Á@À  EB  \ ÕAA   Æ  @@  Æ A a   û        type    table    pairs    print     =  	   tostring    _print_tbl                     V   `        @       W @ ÀE@  FÀ    ÁÀ    \ Z@    A   @   AÀ  A @      @  AÀ    @                    string    gsub    -    match    %w+    upper                     b   m       E   F@À    Á  \  ÀÀ @Ä    @  AÜ@ @Ë@Á A ÜÁÁ A  B@       	      io    open    r     error open file failed:    read    *all    close    decode                     o   s        @       B      ^         invalid args                     u       $       E      \ W@À  D   ]  ^   D  F  Z@   D   ]  ^   B     @Á  AÁ  ¤           @Z   À    AÁ  @            type    string    foreach    system    commit                  D   F À @  Æ@ Á  \ Z      W      AA  F@ Á  Ä @             get    system    .name    ui_language    set                                    ¨    
+   J       @A  A  Á  Ä   Ë ÀAA   ÁÁ  Ü  AAA  Á  A    Á D  KAÁÁA   A \ZA    AÁ IIÀ À  I À I^       	   get_bool    leds 	   settings    enable    night_mode    get    time_begin 	    	   time_end    enable_night_mode 	   tonumber                     ©   æ       J   @  Á   I     I Ä   Æ@Á D FÁÁ \ AÜ@ Ä  Æ ÂÜ 
  AA   Ä BAÂ  Ü  ¢A  @À Ä ÆÃB ÜA Å Â Ü ÆÄ AB  KD\B DÂ \ EB 	AÂ	ABLÁÅ  BAÄ ÆÂÁ Ü B  Z  @ ÀÀ	Â   @ À 
@ Â @ !  @þÚC  DEÄE	IÃ ÁÄ      FGZ  D  FDÁD À Ä	\D @FELÄÅ	AT LÄÅ¡  @õ  BAÁ  AÃ CEÁ EÕB Y@BE  èEÆBEÀçËÅÜA   "      opcode 	   tonumber 	@     params    data    print    args:     encode    connect 	       exec    getfirm DEV_ID    call    sleep 1    require    luci.model.locker    Locker    /var/run/record_devid.lock    lock    /var/run/record_devid    close    total    success 	      pairs 
   target_id    sync    request    errmsg    failed to sync led:     cnt= 	   , total=    , success= 	                       è   ;   Æ   D   F À @  \@ @   D  ]  ^   F@ À  Á   W@Á  Á ÀÄ  ËÀÁA A Á   Ü@ Ä  ËÀÁA A Á  Â Ü@ Ä  Ë ÃA Ü@@Ã  Å ÆÀÃ Ü@ À Å ÆÀÃA Ü@ Ä ÆÄÜ ÁÄ Á B WEFÁE\ Z  ÀEÁ   \ AÆÆF Ú    ÁÆÆÇB @ ÜAD   \A Ä  ËÀÄA A Á  ÜG Â @C B  Á ^J  @A@H A   AH   ÀH A  @ ÁD A  IAH A  @ ÁD A B I@C@ IÁB@AÀ ÁD A   I  IBD ËÁDA  ÁB ÜWÅ  @  B WÅ ÂH Á	  @B  C BÂE   ÀÂ  A  FBFF     FÂFGÁB	  B ÂCA	 B  ÂCAÂ	 ÀÁ
 ÈA
 CÈÁC
 UÂB   @Á
 A     +      print    ===set_auto_led()===: start.    enable    require    luci.model.mode      set    leds 	   settings    off    on    commit    os    execute 1   /etc/tsched.d/leds_schedule TURN_ON  > /dev/null 2   /etc/tsched.d/leds_schedule TURN_OFF  > /dev/null    cursor_state    get    repacd    DeviceType    RE    is_smart_home_support #   cloud.smart_home.smart_home_upload    APP    smart_home_cause    VOICE    upload_property_change    led    enable_night_mode    LED disabled    time_begin 	   time_end    night_mode    section 	   auto_led 
   nightMode '   killall leds_set_nightmode > /dev/null    leds_set_nightmode           & > /dev/null    ===set_auto_led()===: end.                     =  L           E@  FÀ    ÁÀ  \Z@  @       Á A A ËÀÁ Ü@  B Â  Þ  @ Â   Þ    	      /tmp/once_online    io    open    r    read    *a    trim    close    1                     N  Y           @  J   @@   AÁ   Ë A Ü@    @Æ@AÚ   Å AAÜ ÀÁ@ Â  Þ  Â   Þ          connect    call    server-probe    get    close    status 	   tonumber 	                       [  d            @ @  @      @  À   Å@  @ Ü À  À À@@ Â  Þ  Â   Þ       	   bindtime 	   tonumber 	    	<                       f  m       A   @  @À  Á      Ë A@  Ü@Ë@AÜ@         /tmp/re_product_level    io    open    w    write    close                     o     (    @ W@@ 	@	À@ @ @@@ 	@À  	À @ W@@  	@ A @  @    	 @ Á  ÆÀAÜ A À @ 	@@  $     @ B \ @Â  	@@  
      set_gateway_support     enable_gateway_feature    product_level    require    luci.model.mode    get_product_level 
   device_id                 D   Z@  @ C  ^  E      \ À   @ AÀ a  @þC  ^          pairs    qs_version                                   ¬   J       @ Ë@@A  Á  Á ÜA@  ÁÁ  B KA@Á    AÂ \Ú      Z   Á   A Ê   âA ÐÁ B@ ÂB W CEB  \ @@ B ^  Ã @    Á Á  ÆAD
A Â Á C A Ã À "BÜ WÃ@              cursor    get    tipc_config 	   settings    zone    cluster 
   tipc_list    node    . "   tipc-config -l | grep -c "\<%s\>"    exec    trim  	   tonumber 	       require    luci.model.subprocess    call    ping    -q    -c    2    -W    1                     ¯  Ý   _    @ A  A    Ê   
  J  É@FÁÀIÉÁEÁ  \      Â  @ÂW@B À Â     ÆÂÂÆBÃÂÆÂÃÂÆBÄÂÆÄÂÆÂÄËÅAC  Ü ËÂÅÜ ÂÆÆÂBFÂFBGÂGBHÂHBIÄ ËÉAÃ	  Á
 ÜCJ@ À ÊÊÂÆ A	É Ëa   ïFAÁ ËZ@  @ J  @ T LÁIÀ^    -      call    sync    list    result    device_list    error_code 	      pairs    role    UNBIND    ip 
   device_id    software_ver    fw_version    hw_id    hwid    oem_id    oemid    signal_level    mac    gsub    :    -    upper    device_model    slave    support_plc     group_status 
   connected    inet_error_msg    well    inet_status    online    product_level 	d      device_type    HOMEWIFISYSTEM    get    bind_device_list 	   nickname    format_nickname    custom_nickname    set_gateway_support 	                        ß  î      @  @ B   ^  E   F@À    Á  \Z@      ÁÀ       AË@Á A Ü   ËÀÁ Ü@ Æ BÚ    Æ BÞ  @ Â   Þ    	      io    open    r    open file failed    decode    read    *a    close    status                     ð  	    0   
   D     \    Ä   Ä   Ü   D  D  \  À    @	@@W @@  À   @	@ À@  @	À@  @	 A @   @	@A À   @	A       	      band2_4    band5    band5_1    band5_2    wired    plc                       O   *D  J      Á@   Ã   @AÁ   A D  FÀA \ KÁ\ @   ÁÁ     À ÆB Ú    B  Ä ÆAÂ ÜA Â   ÞÅ  Â Ü ÆÃÜ 
  D KBÃÁ  AÃ \  Ä  ÆÀ Ü ËÁÜ ÂÄ  ÆÀ Ü ËÁÜ ÂÄÆÅÃ Ü ÂÄÆÅC Ü ÂÄ  ÆÀC Ü ËÁÜ ÂÅ  Ã Ü CÇJ  ÁÃ bC  HC   ÉCI FIBFÃIBKCÊ\ BIFK\ BÆÀJD FCË\ CÃ A Ä ÄÆÌÜ @Ì ÂL  BMÆMÜ  É@ÆÃMÜ  Î@Ä ËCÃAD D Á ÜÚC    ÁÃ  DBA UD ÀÎ@ Ï  @ ÂÌ  BÍ DBAÄ DOUD Ä  ÆÀD Ü ËÁÜ Â Ä  ÆÀÄ Ü ËÁÜ Â¡N¢ÆCÑÜ Ú    I¢A£Á£A¤Á¤L  	DÃ ÁÄ  D     £DÃ ÁD  D     £DÃ Á  D     ¤DÃ ÁÄ  D     ¤ L @DÃ ÁÄ  D     £DÃ ÁD  D     £DT ¨ T KÄTÁ E J  \LT  ÀTU	Å A  ÅD  ÜÀ Æ 	  ­á  @þÀ L  ­ÄV	Ä 
  C
 ×	À×®A Ø¯ °	Ø¯ÀWX ÅX    Ù®BÙ¯	Å   Ü ÆÅÙÜ  @ÌÀ KÚ\   KF×\  ×®FÆWW@Ú@D \ Z  @ Ú¯@ FÆWB¯FÆZBµFÆW	E¯FÆW Û 	Ø¯J  	EµFÆZ
IFEW ÅX   @ Ù®  ×®BÙ¯Û¶ Å[	X@  ×	(W  ( EBÁ E   Å Æ Ü Å¸XºÝºÊ  
  É»ÆÝ	Å¼ FBAF ^À  UF ÆT ÁÆ      F_ZF   D FFÂF \F @F_ß D FFÂÆ \F @F_@¿D FFÂ^À  \F  J  _À[ Æ[Æ^IÆ  F^ À  @ Z    À ÆGÆGàWß  HBA  H ÀHÈ`aE   \				  @ÆÉW
Ú	  ÆÉW@ÙÀ ÆÉW
É¯ÆÉZ
Éµ×
  ×®ÆÉJÚI  @ Ä	ÉÄ	  
 @
ÜIÅ  
Ü  FÊJ    ÆÀJÛ¶Ô	 ÌÉÛ	a  õ¡   ñ  À @Å  Ü  FÈJ À@ NÀ ÆJW Î  I¡  ÀûKFa\F ÀE ¤     ! X@  ×	W  Å! b Ä ËEâA" Æ" äF             
   
   ÜE£  I Â EBÁ# ^@  ÕE ^          require    luci.model.mode    exec    getfirm DEV_ID    trim    getfirm MAC        error params    from    print    request from myself    luci.model.app_wifi    Wifi    get    sysmode    mode 
   device_id    hardware_ver    getfirm HARDVERSION    software_ver    getfirm SOFTVERSION    hw_id    getsysinfo    HWID    oem_id    OEMID    mac    luci.model.subprocess    ip    call_output 	   ifconfig    br-lan    match    inet addr:([%d%.]+)    connection_type    speed_get_support    get_nickname 	   nickname    custom_nickname    signal_level    get_signal_level    set_gateway_support    product_level    get_product_level    cursor_state    repacd    DeviceType 	   get_role    AP    role    master    master_device_id    slave    is_iot_support    is_iot_wifionly     zigbee_network_sync    co_device_id    0    Coordinator device id:     zigbee_role    none    Get Zigbee role:    device_type    getfirm DEVICE_TYPE    device_model    getfirm MODEL    support_plc    get_plc_status 	   bssid_2g 	   bssid_5g    bssid_sta_2g    bssid_sta_5g    wifi 	   radio_2g    bssid 	   radio_5g    sta_2g    sta_5g 	   previous    get_parent_mac    connect    call    sync    list    gsub    -    :    pairs    parent_device_id    get_mode_info    HAP    inet_status    offline    inet_error_msg    master_unknown 	   is_wired    RE    get_online_status    online    well    luci.model.internet 	   Internet    inet_status_ap 
   unplugged    once_online    detail    unknown    group_status 
   connected 	       AP: get device info of other M5    opcode 	   tonumber 	@     target_type    exclude_feature    performance_limited    params    data    args:     encode    request    success    sync request error 	       sync request error.    ipairs    error_code    request error.    result    device_list    close    is_in_device_list    os    time    foreach    bind_device_list    device    get_device_list         	        E      \  AÀ  @   a   þB   ^          ipairs    mac                       H   d   E   @@ \ Z@  @J   À@ I @@ II@A A A IÀAI@B@ I@AIB   ÀBÆ C  Æ CIÀ Æ@CIÀÄ  ÆÀÃ Ü Ë@ÄÜ IÀ ÆD IÀ Ê   IÀÄ     DÜÚ    Ä  IÀ IÅÆÀÄ É ÆÆÀÄ É ÆIFÄ Ú   ÀÄ Æ ÂÚ   ÀÆ Â Æ Ä Æ ÂIÀ Ä ÆÀÆIÀ@I GIÂÆÀÄ É@ÇÆÀÄ É@ÇÆ A Á IÀAI@B@ I@AIBÄ  ÆÀÃ Ü Ë@ÄÜ IÀ ÆD IÀ IÀGIÀGÄ    AHÉ@   "      is_in_device_list    mac 
   device_id    .name    role    slave    AP    master    inet_error_msg    disconnected_master    disconnected    format_nickname 	   nickname    custom_nickname    device_type    exec    getfirm DEVICE_TYPE    trim    device_model    signal_level    inet_status    group_status 
   connected    band2_4 	      band5    well    detail    offline 	       set_gateway_support  	   is_wired 	                                   Q  _   	   J       @ Ë@@Ü @ ^          SPEED_TEST_INST    get_spt_result                     a  i      D   F À @  \@ D  FÀ \ ÀÀ    Ä   Æ À @ AÜ@ Â  Þ          print     ===start_speedtest()===: start.    SPEED_TEST_INST 
   start_spt    SpeedTest start time:                      l  r      D   F À @  \@ E  À  \  Á  Ë@AÜ Þ          print &   ===get_speedtest_servers()===: start.    require    luci.model.speed_test_parser    SPEED_TEST_SERVERS_INST    get_server_info                     t  z      D   F À \ @À  Ä        AÁ  ZA    A AÜ@ Â  Þ          SPEED_TEST_INST 	   stop_spt    SpeedTest stop     OK.     Failed: No speed-test instance.                     |     	   J       @ Ë@@Ü @ ^          SPEED_TEST_INST    get_spt_month_history                             D   F À \ @À  Ä    @ AÜ@ Â  Þ          SPEED_TEST_INST    clear_spt_month_history    SpeedTest history clear time:                              D   F À \  @À À   @  
  FÀ 	AE ÁÀ \ 	AFAÁ 	AFÁ 	A         ts_load_settings     date 	   timezone 	   tostring    time    dst_status                       §      D   F À @  \@ @   D  ]  ^   D  FÀ    \ Z@  À   @            print    ===set_sys_time()===: start.    set_date_time                     ©  °      D   F À \  Z@  À   @  ^          get_sys_mode                     ²  Æ   '   D   F À @  \@ @   D  ]  ^   E  À  \  Á  @AÀ ÀAÁ  @  ÀAÁ@ @   B@  ÀBÀ    @  À @ À ^           print    ===set_sys_mode()===: start.    require    luci.model.mode    is_tm_shn_support    os    execute L   cp -pf /tmp/tmp-device-config/security_history /etc/config/security_history B   cp -pf /tmp/tmp-device-config/pc_insights /etc/config/pc_insights    store_access_client_info    set_sys_mode                     È  8  	    @   D   ]  ^   F @ @  À   @ÆA ÆÀÚA   Â  Â  ÞÆA ÆÀ Á Â  B Þ¡  Àû ÀAÄ  Æ ÂA Ü  ÆÀB Ä  Æ ÃA Ü@ Â   A Þ Â   C D FÃÁ À Á\A EA   \! @Ä ÆÃ @ CÜB  @Ä ÆÃC ÜB Â  Ä ÆÄÜ ÃÄ Á D DFÅ\Ã ÀE@  FÀÄ ÆÃD ÜC Ê  Ä A  ÉÉ
  J  	DFGIJ  ÄG	ÊD  ÉIÄ	GDÉ C	ÁD  H
@ Õ	D ÄH	 AE	 Ä ÆÃ		 D FÈ
 	\ E
ÜD    ÆÄI	ÚD  @Ä ÆÃ	
 ÜD ËDJÜD Â  
 Þ@
ÆÄI	Ê	@Ä ÆÃ	Å
 ÜD ËDJÜD Â  K	Þ ÆÄI	À ÆH	ÚD  @EJE   FK	 EË	   EË	WJ
EJE   FË	 ËDJÜD Â  Å Þa  ÝKAJ\A  ÌÀD FÃA \A E Á \ Í  LÀA MÁÁ A A MÁ A ANA  ÆÁN Ú  ÅÁ ÂN Ü Ú  @ÅÁ ÂN Ü À  ÅÁ   Ü ÐÁ D FÈ\ PBB  O@B J   I^   @      device_list    ipairs 
   device_id    device_id is not found        device_id is illegal    string    match    exec    getfirm DEV_ID    %S+    from    print    request from myself    connect 
   self_id:  	   dev_id:     need to reboot self    cursor_state    get    repacd    DeviceType    get_mode_info    RE    HAP    AP: unbind other M5    opcode 	   tonumber 	@  
   target_id    params 	      data    args:     encode    call    sync    request 	   result:     success    sync request error    close 	       sync request error.    errmsg    error_code    msg    no legal request    Rebooting...    require    luci.model.mode    is_tm_shn_support    os    execute L   cp -pf /tmp/tmp-device-config/security_history /etc/config/security_history B   cp -pf /tmp/tmp-device-config/pc_insights /etc/config/pc_insights    store_access_client_info 	      delayS    sleep %d; reboot    reboot command:%s 
   fork_exec    reboot_time                     :  I   &   D   F À @  \@ E  FÀÀ   \@ E  FÀÀ @ \@ E  FÀÀ  \@ EÀ   \ @Â  BÀ   À@ÁÀ @     CÁ@ @   CÁÀ @             printf    reset to factory config    os    execute /   nvrammanager -e -p user-config >/dev/null 2>&1 1   nvrammanager -e -p device-config >/dev/null 2>&1 .   nvrammanager -e -p group-info >/dev/null 2>&1    require    luci.model.mode    is_emmc_support /   nvrammanager -e -p emmc-config >/dev/null 2>&1    print    Rebooting... 
   fork_exec    sleep 5; reboot                     K  ]   '   D   F À \    @@ Ä  ÆÀÁ  Ü Ë ÁÜ @Á      AA   Á A AB E  \WÀ À Ä  ÆÂÂ  ÜB a  ýB ^      	   get_role    read_group_info    exec    getfirm DEV_ID    trim    AP    gid 	üÿÿ   invalid my role or invaild gid    device_list    ipairs    rm_bind_device                     `  D  
 Ü  @   D   ]  ^   F @ Z   @ @À     Á   À@ Æ A  AA B   ËAAÂ  ä            ÜAA   Ä B ÜA   À @Ä ÆÂÂ ÜA Â Þ Å ÆAÃCAÂ  A ÜBD À   A À  ZA     AÂ  E AB WÀ À BÁ B ÂE Ê  C A  ÉÉB
  J  	CFGIÃFGIC FGIÃ FG G IÀG@ FGIÈÉKHÁÃ 	 @\ BÁC	  I@ ÕC Z   ÃÉC  @ BÁ
 C CJC   Á
 ÃÉJ@ BÁÃ
 C CJC   ÆË@	ÃÉ@CÈC   ËCJÜC Ä ÆCËÜC Â  ËÞÆKÚ   ÆKWÊ ËCJÜC Ä ÆCËÜC Â  ÄKÞÀÆLFBÌ CJC   Á   Â   E D FÃÌ\   À À+Ä ÆÇÜ Ú   DG   @ BA D ÆDG  Á E @ UD  ÄMFDG D FÂ ÅD   Ü Ä	\D   B  D ^ÄN ÁD  D    
  D E     BA D Ú   ÀÄÏ   Ð  @DPFÐ P DFDÐÄÏ\ KÐ\   À	Z  @	 ÄP	 Ä ÆÂ	 D FÉ
 	\ E
ÜD ÆDQ	Ñ	À ÅQ	    ÆÄQ	R
@ EER Á Æ @	E ER ÁE  AF E   B	Á D   ÁÄ  BA D   AÄ   W@@ DR ÁD E AE D DR ÁD  @ D     ÄT DÄN Á E IÃG«D FÄÕ\D ÀG@FDD ZD   A Â   AB  ÀÀG@IV«Ä ÆÃÕ ÜC  ÅÃ  Ü ÆC×Ä A  @ ÄW	\ ØD DRÅ @  ÁÅ D   @DRÅ @  Á D ÄTÅ DÕÀG	À DXÁ D Ä ÆÄØ	 ËX	ÜD ÆYE ÜD ËDJ	ÜD DÊD H	Á D H	ÁÄ D   @ B	Á D Ú   DZ	Á D À DZ	ÁÄ D DZ	Á D DZ	ÁD D DZ	Á D ÀG Ä ÁÄ  Æ\	ÜD D  D   q   
   device_id        new_master_id is illegal    need_notify    cloud_account    cursor_state    foreach    bind_device_list    device     can't find old master_device_id    print 0   The new master is the same with the old master.    string    match    exec    getfirm DEV_ID    %S+    from    request from myself 3   new master doesn't have itself in bind_device_list 	   get_role 	      Send to new master    connect    opcode 	   tonumber 	B  
   target_id    params    config_ver    get_config_version    AP    data    call    sync    request 	   result:     encode    success    sync request error    close 	       sync request error.    errmsg    sync_boost    error_code    msg    result 
   wait_time    no legal request    read_group_info    old fap config_version:  	   tostring    dest fap config version:     compare_config_version 
   ver_ret:  ;   device has not finished sync config. Refuse to be FAP!!!!!    bind_status    get    cloud_config    device_status !   set gateway, not bind, rebind it 	   password 	   username    tmp_handle_string    trim    get_nickname    set gateway nickname 	   nickname    custom    custom_nickname    set_cloudAccount_with_commit    set    info    alias 
   need_bind    1 0   set gateway, cloud_account not valid in convert ,   device unbind cloud, no valid cloud_account %   set gateway, cloud_account not valid    need_transfer    inherit_id    commit    repacd    DeviceType    role    write_group_info 	   	Z      RE    require    luci.model.locker    Locker    luci.sys.config    SET_GATEWAY_LOCK    lock    save_config_version    0    CONFIG_LOCK    saveconfig    user-config )   rm -rf /var/run/record_* >/dev/null 2>&1 (   rm -rf /var/run/lookup* >/dev/null 2>&1 *   gateway: role is changed, restart service 
   fork_exec    /etc/init.d/awn restart !   sleep 3; /etc/init.d/awn restart    /etc/init.d/tipc-server reload    /etc/init.d/cloud_brd restart ;   /etc/init.d/iptv reload; /etc/init.d/guest_eth reload bind    luci.model.app_network    reset_wan_vlan        r  z      F @     @ B  H  F@@ À @D  À  Æ A \@F @ H         .name    role    AP    find section    mac                                 L  ]      J       @ Ë@@Ü À  Á  AAA A À Á  AA A À Á  AA  A Þ          SPEED_TEST_INST    auto_start_spt 	       os    exit 	   	                       _  f   
   D   K À Á@    AÁ  \   @           get    sync    config    version    config_version                     h  n      D   K À Á@  \@B  ^          commit    system                     p  z      @   D   ]  ^   F @ Z   À D   @ ]  ^   B  ^          lang                     |       3      A@   F@ \    Ê   ÀË Á ÜÀ @A @  ^E \@  ÆÂÁËÂÜ ÂÅ ÆÂÂÃCCCÃCÜ ÂÅ ÆÂÂCÄCCCÃCÜ ÂÅ ÆÂÄÃ@@ ÜBa  Àø@  ^        require    luci.model.tfstats 	   TFS_INST    client_list_speed    load_all_stats 	       pairs    mac    upper 	   up_speed    math    floor 
   retx_byte 	   	è        à?   down_speed 
   rerx_byte    table    insert                     Û  õ   	&      Á@   Ê    F@\ É É@AÁ À ÁÁ   À Â À AÂ   @  BÁÁ   ÕA    CÉACÉ@ ÉCÉÃÞ          require    luci.model.tfstats 	   TFS_INST 
   device_id    in_hnat     AP    get_wan_stats_speed    RE    get_backhaul_sta_stats_speed    print    unknown work role  	   up_speed    down_speed 	                        ÷     "   J   I  @  Á@     @D FÁÀ\  À @Å  ÜÀDÁFDA@À A ÄAÌ á  @ý¡  ÀûI IÀ^       
   device_id 	       client_list_speed    get_myself_online_client_list    pairs    mac 	   up_speed    down_speed                       m   ·   J      Ä   Æ ÀA  Ü ËÀÜ     À FÁ@ Z    Á@ À D FÁA \A B  A ^D KÁÁÁ Â A \ZA    AA B ËAAÂ Â Á Ü BCÂ  @ÂÀÃ@ ÀÃ@Ä A ÜÄ A Ü Ä A ÜÔ ÌBÄÃ@ ÀÃ WÀ Ä ÆÄÜ  AAÃ C 
  EC  \ 	C	ÃJ    IÆÃ	C AÁ ÄF@  ÕC ÇD A     ÆÃGÚC   Ä ÆÁ ÜC @ÆÃG@È Ä ÆÁ ÜC @ÆÃGÀÄ ÆÁÄF@  ÜC  Ê  ÄG@D DDFDFÉC  ÆCFÚ  ÀÄ @@FÅFÉ
W@È
  AÁE	 E  ÅIÅIÅÅ   ÜÀ T LGÄ á  @þ!  ÀùËÊÜC I^    )      exec    getfirm DEV_ID    trim    from    print    request from myself    get    sysmode    mode    Router    cursor_state    repacd    DeviceType    get_mode_info    RE    HAP    AP 	      connect &   AP: get device speed info of other M5    opcode 	   tonumber 	/B     target_type    params    data    args:     encode    call    sync    request    success    sync request error 	       sync request error.    ipairs    error_code    request error.    result    device_list_speed    close                             D   F À   À   ] ^           simple_dispatch                             