LuaQ               (Ã      A@    À@@  A@  E   \   ÁÀ  Å   Ü  AA  E  \  ÁÁ  Å  Ü  AB  E  \ ÂC Á C A Ã Á $    D $D  d  ¤Ä            ä    $E   d              ¤Å     ¤                           
äE $ dÆ              ¤     äF              
   $   dÇ   ¤                    äG $                          dÈ                         ¤                   äH    
É JI  I  I		IJI  I  I		I	J  I  II	I  	I		IJ	 I  ÉI	I  II  II	I  Å ÉI		IJ  I  ÉI	I  	I		IJI  I  II		IJ  I  I	I  ÉI		I	d    GI	   &      module -   luci.controller.admin.mobile_app.quick_setup    package    seeall    require    ubus    nixio    luci.model.uci 	   luci.sys 
   luci.json    luci.tools.debug    luci.model.sync    luci.model.tipc_config    luci.model.tmp_decrypt    luci.model.accountmgnt    cursor    /tmp/wifi_scan_result_2g    /tmp/wifi_scan_result_5g    /tmp/wifi_scan_result_5g_2    HOMEWIFISYSTEM 	È      _print_tbl    preconf_check 	   newgroup    write    cb 
   newdevice    batchdevices    read    preconf    preconf_read    preconf_write    preconf_add 
   heartbeat    sync    eponymous_detect 
   bluetooth 	   dispatch        !   *       E      \ @À E     \    Á@À  EB  \ ÕAA   Æ  @@  Æ A a   û        type    table    pairs    print     =  	   tostring    _print_tbl                     ,   0        @       B      ^         invalid args                     2   8        A   @@ U   À   À@À           "   luci.controller.admin.mobile_app.    module    require 	   dispatch                     :   ^    {       F @ Z@   D   ]  ^   D  F@À   \@ F @ FÀÀ  Á À  @A  A Á  ÁÁ @   Â À  @A  A Á  ÁA @  ÁÀ  Æ CÜ  Á Æ@CÜ  Â Å  Ü  DFÁÃ \ KAÄ\ Ä    AAÂ A  ÆBEA  EÂ A AAÂ AÂ  ÀA A Å ÂFA  Ü  ÁÄ B @ À ÂÜA Ä ËAÁAÂ Â ÁÂ   ÜA Ä ËAÁAÂ Â Á ÃCAC  CD ÜA  Ä ËÅAÂ ÜA           E        "   
   bluetooth    print    recv bt_mode_set    enable    set 	   settings    on     off    require    luci.model.mode    is_iot_support    is_iot_wifionly    luci.model.iot_ble    exec    getfirm DEV_ID    trim    create_mesh_network    ble_network    key    nwkey    commit    zigbee_network_sync    co_device_id    0x 	   tostring 	   uniqueid 	      Create coordinator:  
   , panID:     panID    model    getfirm MODEL                     `   m        
   D   K À Á@    AÁ  \   	 Á  @@ @Á@ @@ Á          get 
   bluetooth 	   settings    enable    on                      o   u       D   F À @  \@ D   FÀ À  \@    @ W A À D   FÀ @ \@         exec    echo 1 >> /tmp/binding_over  
   fork_call     /etc/init.d/cloud_brd restart &    RE    /usr/sbin/handheld_radar &                     w   Â    r   E   @  \ @    @ÆÀ@Ú    ÆÀ@ Á Á@  Þ Ä   ÆÀÁÆ ÂÁ@Ü Ú@   A AA   J  Á  Ä ÁÄ ÁÄÁÅA   Ü ÃCF   ÀKCDÁ \ÃDC ÅD  À I @ ¡   þá  ù  À
  Ê   EÂ Á $    BZ  ÀB @@FÃZ  FÃZ  ÀFCÆ  Á ÄAÄ  ÁD Å¢C \ Å À À@  @ ¡  @þ!  Àøã  Ê  
B  	          require    luci.model.subprocess    user_network    ssid     	ïØÿÿ   invaild user network    bin 
   b64decode    invaild user network ssid    band2_4    band5_1    band5_2    pairs    io    open    r    read    *a    close    gmatch R   ESSID:"([%S]+)"%s+Mode:Master%s+Frequency:%d%.[%d]+%s+GHz%s+%(Channel%s*([%d]+)%)    foreach 	   wireless    wifi-iface    call_output    wlanconfig    scan    -c    1 4   ESSID:([%S]+)%s+BSSID:[%w:]+%s+CHANNEL:%s*([%d]+)%s    eponymous_network_exist           ¨       F @ @À F@ ÀÀ ÀF A @Á À D   ÀA I  F A  Â À D   ÀA I@F A Â  D   ÀA I        mode    ap 	   disabled    0    device    wifi0    band2_4    .name    wifi1    band5_1    wifi2    band5_2                                 Ä   Ï          @F @ Z    F@@ Z@   B     ^ D   FÀÀ @@ \  Á  B   @ ^ D   FÁ  @ ]  ^           key    gid    invalid input    __check_group_gid_valid     gid check failed    __check_group_key_valid                     Ò   Æ  
   @      Á@   @ ÆÀ@ A    FAAZ  @FAZ   FAAÀÁ A A ^FB Z  @ÁÂ   ÁÂÀA  ÁA   CÆÁÂ ÁC I  CÆÁ ÁC ID   @ÆADÚ   ÆDÚA   ÁÁ  ÞÄ ÆAÅ Ü ËÁÃÜ  ÂE   FFZ  À DB ÆF\BD FÆ\ Z   Æ  @ÂÆ   À   @ BGÁ B À  ÂG    HB     !  Ê  ÂÆBHÉ ÂHBIÂIÄ   Ü @ Z    ÆÊ W@ÊÄ ÆÊÜB ÁÂ
 Z    Ë C    C ÞÆKÚ   Ê  KÃKÉ E C \ ÃËL ÉÍÉÍÉBJÉÎ@ÃË N KÃLÉKCMÉKMÉKÃMÉ@CGÁC C  JC    KN N@ÉNKÃNÉKOÉKCOÉKOÉ  ÉLÃÏÀ   W N@ JC    ÆPÚ  @Ê  PÃK NÀÉÎPCPÉ PPÉ¡  ÉÌ AC  FÃP\ ÌÀ CGÁ C   BÑÄ ÆÑÆÂÑCAÜ ÂÄ ÆÑÆÂÑAÜ ÂÆBAÚ   ÆAÚB  @Ä ÆÊÜB Á   ÞÅ C Ü ÆÒÜ ÃÒ CÓÃFCCÓ C  @D FÊ\C A Ã ^J  IITICTIÃI À @  Z    Ê W@J JC  Z    ÆË ÚC    ÁÃ   Ê  ÃÆCHÉÃÆCHÉCÆCHFÉªÆCHÄFÉªÆCHDAÉ«ÆCHÉÃ«VCVVÄ   Ü @ Z    ÆÊ W@ÊÄ ÆÊÜC ÁÃ Z    Ë D     ÞÄ ÆC×FFÄF ÜC Ê   DEAÄ  ÄC É¡ÉW°ÄÀ@XÀ FØZ    ØÉE D Y	 \  ÉC±D FÚD \ ÉC³D FÚ\ Z   WÀÁ  ÉCµ [	À DD[	 AÅ Å Á D DS	 D ÁD  Æ\	Ü  Î	 ÆÄ\	Ü Ì	 Å  Ü  
D FEÅ
 \ KÅÃ
\ EÝ	   E[ AÆ Æ ÆÆ]
E ES EE[ A F À
E  Å  Æ^A  Ü  ÅÄF @
 À ÆÜE ÄËEÛA  ÁÆ   ÜE ÄËEÛA  Á   GEAG   ÇC ÜE  ÄËEÓA ÜEÄËDÛ	A  Å  ÁÅ ! ÜD Ä ÆDÅ	E! ÜD ÄËDÓ	A  ÜDÄ Æá	ÜD ÄÜD Ä ÆÊ	ÜD ËÄáÜ  b
 DFEÇ
E" Å   
Ü Å\E JE FIªÅFIªIÅ«IÅÅIÅ^      	üÿÿ   params not found    wan 	   nickname 	   wireless    ssid 	   password     	üÿÿ   invalid wireless args    cloud_account 	   username 	üÿÿ   invalid cloud_account args    tmp_handle_string    trim 
   date_time 	   timezone 
   tz_region 	üÿÿ   invalid date_time args    exec    getfirm DEV_ID    read_group_info    gid    Warning: overwriting group     read_preconf_group_info    key    preconf_check    print '   set master: use preconf_group as group    create_group    set_create_group_flag    params    module    network    form 	   wan_ipv4 
   operation    write    error_code 	       clear_create_group_flag 	üÿÿ   msg    set wan failed    vlan    enable    require    luci.model.app_network  	   isp_name     id 	   priority    tag_802_1q    unknown vlan status.    iptv_enable 
   iptv_mode    iptv_isp_name    iptv_id    iptv_priority 	   set_vlan 
   mac_clone    clone_mode    mac    set_mac_clone    set wan mac_clone fail.    1    bin 
   b64decode    invalid args    luci.model.app_wifi    Wifi    set_ap    set_backhaul    commit 	üÿÿ   set wifi failed.    device    timesetting 	üÿÿ   set time failed 	   group_id 
   group_key    group_name    master_device_id    cloud    group    create 	
üÿÿ   set cloud account failed    join_group    AP    getfirm MAC    role    custom    custom_nickname 	   bindtime 	   tostring    os    time    device_model    getfirm_cached    MODEL    get_pregroup_md5    preconf_id    add_bind_device    set 
   bluetooth 	   settings    off    luci.model.mode    is_iot_support    is_iot_wifionly    luci.model.iot_ble    create_mesh_network    ble_network    nwkey    zigbee_network_sync    co_device_id    0x 	   uniqueid 	      Create coordinator:  
   , panID:     panID    model    getfirm MODEL    wifi    default    0 3   echo "wifi.default.enable='1'" >> /var/state/wifi     set_tipc_config    get_backhaul_channel    get_preconf_pack 	   pack is  	   backhaul    suit_count                     È  Ï    	   E   @  \ À ÁÀ  @             require    luci.model.radar    send_transaction_to_other    update                     Ò  ×    	   E   @  \ À ÁÀ  @             require    luci.model.radar    send_request_to_local    update                     Ù     K   J      Á@   Æ@Ü Á  Ú      D  FAÁ\ ÁÂ A   Ä ËAÂA ÜÂÂB $    D FÃ\B J  B À ÆC
  WÀÃ  @FDKDÄÁ Å \ KÅ\  À      	D	D	ÄE	F	DF	I	   ø¡  ÷I I ÇB    I^          require    luci.model.app_cloudfirm    get_online_status    offline    online    connect    call    sync    list    get_all    bind_device_list    close    sync_boost    pairs    role    UNBIND    mac    gsub    :    -    upper 
   device_id    device_type    device_model    signal_level 	      inet_status    max_discover_time 	F      device_list        è  ò      D   Z@  @ B   ^  E      \  AÀ  @   a   þB   ^          pairs    mac                                   $          A@   A    ÁÀ  À Æ A   Ü Ú@  À Æ@A   B Ü@Ê    â@ ÐÀ   ÁA@A  BAA A     
      require    luci.fs    /tmp/quick_setup/    add_device_done    isdirectory    mkdir 
   touch %s     call    print    set_add_device_flag                     '  f          @Á@  @   ÆÀ ÁÀ    FÁ AÁ A  Ä  ÆÀ ÜA Ä ÆÂÂÁÜ ËAÂÜ IÁÄ ÆÂÂÜ ËAÂÜ IÁÀ Ä  ÆÀÂ ÜA Ê  
  ÉÃ	Â Ã	BÃFBÃ 	BÃFÃ 	BÃFD	BÃFBÄ 	BÉÁDÉAEÉÁE @       FW@F 
     FÂFZB    A ÀFÀ  @ÁA A ÇÀ ÁÇ    FÁÇZ    @Á B @ ÕA HÂ A	 B	 ÀA IÂ ADKÈÁÁ	 
 AB
 
 \A DKÉÁÁ	 \AD \A DFÁÊ\A E A \ ÁË  LA      1      print    do_add_m5_device£ºstart 	   nickname    front_wireless    cloud_account    is_base     cloud is not valid, do transfer 	   username    tmp_handle_string    trim 	   password     cloud is valid, do not transfer    params 	   group_id 
   group_key    group_name    ssid    master_device_id    module    cloud    form    group 
   operation    add    error_code 	    	
üÿÿ   msg    set cloud account failed $   not bind cloud, but modify location    custom    custom_nickname 	   location 	   tostring    set    cloud_config    info    alias    commit 
   bluetooth 	   settings    enable    off    sync_boost    require    luci.model.mode    is_emmc_support    sync_boost_emmc                     h  j      D     À   ] ^                             l  n      D      À   ] ^                             p  Ì   Ó   E   @  \   Ä   ÆÀÁ  Ü@ @   Á  A Þ ÆA Ú   @ÆÀA Ú    ÆA  Â Á@  Þ ÆÀB Ú    ÆÀB  Â Á  A Þ ÆC ÀÃ Æ D Ú    Æ D  Â Á  A Þ Ä  ÆÄA FÁA Á Ü@ Ä  Ë ÅAÁ A Á D Ü@ Ä  ËÅAÁ Ü@Ä  ÆÀÅÜ@ Å    Ü AÆ FFÀÆÀ G    FGA  Ä ÆÇÂ Ü ËÈÜ ÁÄ ÆÇ Ü ËÈÜ ÁÄ ÆÉB	 Ü ÁÁDÆÊ Ü ÁA ÆF AJ    FJZ  @FÁJZ   FJ Â A A ^FK Z  @ÁË   ÁË B  ÁA  L   ÆÁLÚ  À Ä   FÂLÜAÄ ÆÄA FÂA Â ÜA ÄÆAÍÜ Í @  B Â NAB B ÆÀFÀ FÇZ    ÇD\B D  FÀ \B D FÂÎ\  Â  CÂ Ä ÆÇÃ Ü ËÈÜ ÂÄ ÆÇ Ü ËÈÜ ÂÄ ÆÉC	 Ü ÂÂDÆÊ Ü ÂB   =      require    luci.model.mode    print    add_m5_device£ºstart 	üÿÿ   params not found 	   group_id 
   group_key     	üÿÿ   invalid group args    master_device_id 	üÿÿ   invalid master_device_id 
   generator    sync    sync_version    invalid sync_version    join_group    RE    set    config    commit    sync_boost    luci.model.app_cloudfirm    get_nickname 	   nickname    custom    custom_nickname    slave_device_id    exec    getfirm DEV_ID    trim    mac    getfirm MAC    device_model    getfirm_cached    MODEL    role    product_level    get_product_level    front_wireless    ssid 	   password 	üÿÿ   invalid front_wireless args    cloud_account 	   username 	üÿÿ   invalid cloud_account args    read_group_info    gid    Warning: overwriting group     fork 	       os    exit 	      add_m5_device: end    get_pregroup_md5    preconf_id                     Î  Õ       A   @  @À  Á      Ë A@  Ü@Ë@AÜ@         /tmp/re_product_level    io    open    w    write    close                     ×    	 +P  D   F À @  \@ D  FÀ À  \ K Á \   @A Ä  ÆÁÜ 
  AÁ Â  B Ú    FBÂZB   A Â ^CC ÆBC C@ ÃC @ ZB  @ A @CD C  @ Ú  @Ä   ÄÀD  AC EÃ Á  J   FÃFÆCF I FÃFÆG I CGC G ËÃGA  Ê  ÜED d     ¤D    Ê  
  FH Å Á	  ÆEIÜ ÉÄI
 @
@2FÇ
  ÆGÊÇÆÊÇÀJÜ ÚG   .Ê  ÉÉGÉG HÂÉÈËÉÌÉÉG  	FHÊ LÚ   ÀLJ  ÉGFHÃIFHÃIÈLÀÚ  @J  ÉGD FÍÄ\ KÁ\ D FÍÇ\ KÁ\ ÀFHÃIFHÃIÈÂ   ÉÇD  FÀH \H J  È Á  IHÊI  ÈIÄ  ÆÀ	 D	FIÏ	\ I	ÜH ËÈGA  À	ÜÚ   ÉÏI  @	  	@A	 I ÇÌ ÉÏÀA@	  	@A I ÇÌ @	  	@AÉ 	IOÀ	 UI ÉÎI  @ ÇÌ ÀFIPWÀÁ@	  	@Á	 I ÇÌ 	  ÆIQÆÑÚI    Ä	 À 
  
@AÊ J ÉRJQJ	
JQJR	¤JQ
L	
JQR	
¥
 EJ FÓ\
   	¥JQÊS
  JQÊSWÀD JQÊS	§WC
 
TFJQFJÔ
 JÀ JQJT		LÁÌJQJ
ÇÁ  ÆJÇÇÁ Ô 
ÌÇÌ	!  ÀÌTF @À  ÆT@ F É UF   @AF FOÀ	 UF Þ   V      print    add_m5_device_list: start    exec    getfirm DEV_ID    trim 	   get_role    read_group_info 	       AP    gid 	üÿÿ   invalid my role or invaild gid 
   generator    cloud_account    sync    get_sync_version    invalid sync version    from 	   username     	üÿÿ   invalid cloud_account args    get_all    wifi    ap    ssid    bin 
   b64encode 	   password    set_binding_flag    connect    call    list    bind_device_list    device_list    require    luci.model.mode    get_product_level    is_master_qualified    ipairs 
   device_id    mac    sync_version    master_device_id 	   group_id 
   group_key    key 	   nickname    front_wireless  	      tmp_handle_string    AP: bind other M5    opcode 	   tonumber 	!@  
   target_id    params    data    args:     encode    request    success    sync request error    error_code    sync request error. 	   result:     request error.    result    product_level )   ====== is master qualified is false ====     role    device_model 	   bindtime 	   tostring    os    time    preconf_id    add_bind_device    slave_device_id    close    add_local_device_list    clear_binding_flag    add_m5_device_list res:         þ        D   Z@  @ B   ^  E      \  AÀ  @   a   þB   ^          pairs    mac                     
        D   Z@  @ C  ^  E      \ À   @ AÀ a  @þC  ^          pairs    qs_version                                     	   D   F À @  \@ D  FÀ À  \ K Á \   @A Ä  ÆÁÜ 
  AÁ  B Ú    AÂA    ÁÁ C   @ÆACÚ   ÆACÃ Ê  ÀÄ ÆÁÃÆÄBCÜ ÁÄ ÆÁÃÆÄBDÜ ÁÄËÄAÂ  Ü 
  D FÂÃFÄBÅ\ 	BD FÂÃFÄBÄ\ 	BD FÅ\B D FÂÅ\ ÆC A   ÄËÄAÃ Ü$    FG C Á  ÆÃGÜ 
  FÈ	DFDÈ	D@ DH\ ZD  J  ID DÂIDÉIÉIII  @	ÁD
 D   ÅÄ
  Ü ÄÆÈÄÊ  ÉDÄ  @
A ELÀ 	 U
E ÆE Á   	   FÅL
ZE  @D  FÀ
 \E 	Í@FÅL
ÀÁ
@D  FÀ
Å \E 	Í D  FÀ
 ÄÆEÌ  
Ü Å\E FÅK
ZE  @ 	ÍEÍ
WÀA Ä  ÆÀF ÜE Ê  Î
ÆNF      @D  FÀ \F EF IÆOFÎ
FFÈÉEFÎ
FÐÉE FÎ
FÉÉEFÎ
FFÐÉE EÆ  FQ \  ÉE¡FÎ
FÑZ  FÎ
FÑWÃ FÎ
FÑÉE£FÎ
FÆÑ	ÁLÍKÒ\D @À D FDÒ \D D FÒ\D @ÀED Ä \ FÓ\ DÓ  FEÈ Â Þ @ B  ^   N      print    preconf_add_m5_device: start    exec    getfirm DEV_ID    trim 	   get_role    read_group_info 	       AP    gid 	üÿÿ   invalid my role or invaild gid    get_device_account_temporary 	   username        bin 
   b64encode 	   password    get_all    wifi    ap    ssid    set_binding_flag    connect    call    sync    list    bind_device_list    device    require    luci.model.mode    get_product_level 
   device_id    mac    master_device_id 	   group_id 
   group_key    key 	   nickname    front_wireless    cloud_account    AP: bind other M5    opcode 	   tonumber 	fÄ  
   target_id    params    data    args:     encode    request    success    sync request error    error_code 	      sync request error. 	   result:     request error.    result    product_level )   ====== is master qualified is false ====    res    is_master_qualified     role    device_model 	   bindtime 	   tostring    os    time    preconf_id    slave_device_id    close    add_local_device_list    clear_binding_flag    luci.model.message_center 
   Msgcenter    add_auto_pair        ©  ³      D   Z@  @ B   ^  E      \  AÀ  @   a   þB   ^          pairs    mac                                 
  Q      E   @  \   Â    @AÁ  A @    AA A   @ÁA    A  B A A ÁB    ÁB  B  AA C FÁC Z   Ä  @AÄ   Ä B  ÁÁ E   @ÆAEÚ   ÆAE Â Ä  ÆÀ ÜA Â   Ä ÆÁÅÜ Ú  Æ  À   AB ÆB FFA ÂA ÁÂ B  G @G@E FÂÇ \B Ú    	ÈD  \B  D   \B E FÂÈ	 \B FC@ÉÀ I    FIB   @ÁÂ	 B  J  B   ÊÂ  JAÃ
  K É JA  K É LAC  ÉÉÂFÍ  ÉÉÉBÞ   6      require    luci.model.mode    print    preconf_write_m5_device£ºstart 	üÿÿ   params not found 	   group_id 
   group_key     	üÿÿ   invalid group args    master_device_id 	üÿÿ   invalid master_device_id 	   nickname    front_wireless    ssid 	   password 	üÿÿ   invalid front_wireless args    cloud_account 	   username !   add device without cloud_account    read_group_info    gid    Warning: overwriting group     join_group    RE    fork 	       os    execute *   ubus call leds init '{"state":"binding"}'    is_base    exit 	      custom    custom_nickname    preconf_write_m5_device: end    get_pregroup_md5    slave_device_id    exec    getfirm DEV_ID    trim    mac    getfirm MAC    device_model    getfirm_cached    MODEL    role    product_level    get_product_level    preconf_id                     T  g      D   F À \    @@ Ä   ÆÀÜ 
  Z     	A     	 Ú   À E \ 	A         get_preconf_gid    get_preconf_key    get_preconf_pack    gid    key    pack 	   tonumber                          	   E   @  \ À Ä                  require    luci.model.controller    simple_dispatch                             