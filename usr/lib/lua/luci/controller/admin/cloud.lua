LuaQ               I     A@    À@@  A@  E   \   ÁÀ  Å   Ü  AA  E  \  ÁÁ  Å  Ü  AB  E  \  ÁÂ  Å  Ü  AC  E  \ Ã Á D A  ÁÄ  F	ÁD F AÅ  Á  EGä          $F  d       ¤Æ    ä        $G    
     d           ¤Ç      ä           $H            d   ¤È                        ä    
        $I   d                     
            ¤É   ä	   $J   d       ¤Ê          	  	         
       ä
             $K                     
       d ¤Ë ä   $L       
d            
              ¤Ì          
  ä          
$M d ¤Í ä    $N d       ¤Î ä	 $O	         d	    ¤Ï	              ä
        $P
      
     d
    
     ¤Ð
             ä $Q d       Ñ Ê  
R  	ÒÉ
R  	RÉÑÊÑ  
R  	Ò	É
R  	ÒÉ
R  	ÉÑÊQ 
R  	
É
R  	R	É
R  		É
R  	É
R  	ÒÉÑÊ  
R  	É
R  	ÒÉÑÊ 
R  	É
R  	RÉ
R  	É
R  	RÉ
R  	ÒÉ
R  	É
R  	É
R  	ÒÉÑÊ 
R  	É
R  	Ò
É
R  	RÉ
R  	ÉÑÊQ  
R  	ÒÉÑÊ  
R  	É
R  	ÉÑÊ  
R  	É
R  	ÉÑÊ  
R  	ÒÉ
R  	ÉÑÊÑ 
R  	É
R  	R	É
R  	Ò	É
R  		É
R  	
É
R  	É
R  	ÒÉÑäÑ         #Ç ä     "     ÇQ äQ Ç   C      module    luci.controller.admin.cloud    package    seeall    require    ubus    nixio    luci.model.uci 	   luci.sys    luci.tools.debug    luci.model.controller    luci.model.sync    luci.model.app_cloudfirm    luci.sys.config 
   luci.json    cloud_req.cloud_comm    cloud_req.cloud_ddns ,   luci.controller.admin.mobile_app.iot_device    luci.model.subprocess !   /tmp/firmware_local_upgrade.lock    /tmp/firmware.bin -   /tmp/firmware_local_upgrade_device_info.json    /tmp/local_re_upgrade_msg    luci.model.locker    Locker    /var/run/unbind_device.lock    cursor !   97234B9422C9BC4440F67130D25681FA    luci.model.countrycode    DEVICE_COUNTRY_OEMID_TBL 	   nickname    read    cb    write 	   firmware 	   download    sync_check_firmware    upload    firmware_status    check    upgrade    local_upgrade    check_upgrade    group    create    add    message 	   iot_read    report    remove    set    get    update    push    system    remove_all    unbind    bind    proxy    account    notify    ddns    manager    mini_firmware 	   dispatch    _index    index 2       2   7            @ D  F@À   \    D  F  Z@    AÀ  ^          TrimStr    exec    getfirm SPECIAL_ID    others                     9   =        @       B      ^         invalid args                     ?   O    
%      @@Á  Á   AÄ   A A  AÜ@ Â  Þ  ËAAÁ ÜBA  AB@ @   @ À  @ B ^ !  @þ           io    open    /tmp/sync-server/mesh_dev_list    r     error open file failed:    read    *all    close    decode    pairs                     Q   a       J      @@À     À@    Ë AAA ÜÚ@    À  A@ T LÁÁI @üË BÜ@ ^    	      io    open    r     read    *line    decode 	      close                     c   {    C   @      Å   Æ@À   Ü   @ À@  ^  A Á `ÁEB  \@ AÆÁÀ  ÃAÆÃÁÀÀ  BÀ  @ C   BÀ  C@ a  Àù_øEA  \   BÀ  Ba   þD FÁÂ Ä ÆAÃ  Ü Á\A ^          table    maxn    get_fw_list  	      pairs    hw_id    oem_id    insert    ipairs    remove    print    adjust_list     encode                     }          D   K À Á@  \Z@  @        @ÁÀ   A@  Õ @ @ À    ÆA @ Â Þ ¡   þ             get_all    bind_device_list    print    is_in_bind_list     encode    pairs    mac                            	#   J      À     ÆA@WÀ Ä   Ü ÚA  ÀÆA@À@Ä Â@Ü Ú    I¡   û   AÁ@ A@  Õ @ ^          pairs    role    UNBIND    mac    print    get_fwdev_list     encode                        Á    H   Ê     C  À   ÆB@ÀÀÆÂ@À ÆAWÀ@  FAÆBAÁ  ÉÂ WÀ  @ FD@D@ FÄ@Ä@  Â  !   ýC@   Ã@W @Ú  À C@W@  É¡   ô  ÁAÁ  BB@ A Â À  ÕA À           pairs    hwid     oemid    fw_version    role    AP    print (   get_diffproduct_table: diff_device is :    encode     has_old_device is : 	   tostring                     Ã   ó    X   D  FÀA  \A J   À  @@ À  D FÁFBÁÂ@\ IAD FÁFBÁA\ IAFBIAE BB\ IAFÂBIAIÁ FBCIAFCIAFÂCIAW D@ IÄ  IÁÄFEÄIÅIÁÄIÁDEB  \ FÂÆ\ ÇB FBEIAIÄIDEB  \ FÂÆ\ BÇB E FÂÇ  Á \BÈH@ B  BÈÃ BÉB ^   %      print    sync_check_firmware begin    get_firmware_info    name    bin 
   b64encode    version    release_note    releaseNote    type 	   tonumber    release_date    device_model    hw_id    oem_id    download_url     need_force_upgrade     latest_flag 
   file_size 	       need_to_upgrade    need_to_download    require    luci.model.message_center 
   Msgcenter    clean_new_fw_flag    set_new_fw_flag    io    open    a    write    encode    
    close                     õ   
   2   D   F À @  \@ J   @     À@ @      Á     @AAÄ      À Ä  À Å  Æ@Â  Ü@ @ I À@ IB I À  CÄ  A ËCDFÁÃ \ Ü@  Ë DÜ@ Â  Þ          print    firmware_local_upgrade_upload    hw_id    oem_id    error params    fs    access    rm     os    execute    device_model    io    open    a    write    encode    close                       *   I   E   @  \    ÆÀ Ü Á  FÁFBAÁÀJ  ÂAW B	BBW BÀ  BÊ Ã âB ÃACC Ä  ÆÂ
 AÃ "C FCBÜËÃAC ÜÃA @CB ÀCIÃCIDI CD@ D ÆDÀ CIÂCIDI BD@!  ð          require (   luci.controller.admin.mobile_app.device    get_device_list    pairs    device_list    group_status 
   connected    hw_id     oem_id    call_output    md5sum    match    %x+    ip 
   device_id    mac 	      device_model                     ,  ­  
  ù       @ A@  @ 
   	À@J      AÁ@  A Ä  ÆÀÁÆ ÂÜ Ú@  @ Â   Þ  Ä  ÆÀÁÆ Â Ü Ú@  @ Â   Þ  Å@ ÆÂAÁ Ü Ú   KÃÁA \ KÃ\A @ B  ^ A  @ B  ^ DFÁÃ \ Ä   AÄA  @      @Á ÂD@ ÕA  EÁ  J    W@Å@ Å Ä Ü   IÔ ÌÆB  Ã ÁC   F@ D Ä @ ÀFÅE
@  A  Õ
D FEÇ
\  
D  FÀ
 À Å\E  F@AÅ   ^@ !  @ùÄ @ FÅE
W@ÀD FÅÁ
FÂ
 \ Z  @E FEÈ
 Ä Å\E DFÅÈ
Á	 F	 A	 Æ	 Á
 G
 FJ
¢E\   @ÁÅ
  
ÕE W Ë
 E Á Æ A J
ÁF  A  U  @ÀE  ÅL @FÀÅ ÆEÈ ÜE Å ÆÍ ÜE ÌÆ@  ÆEM
ÅÔ ÌÆI!  í  ÌÆ Æ@	 F	ÀM D UCÀ 	@FD D UC  @@D  ÄL @F@E FDÈ\D   	@FW@Æ	À	@  F@  D @        <      print    firmware_local_upgrade    upgrade_time 	      exec    getfirm DEV_ID    trim    fs    access    io    open    r    read    *all    close    decode    hw_id    oem_id    upgrade_device_info :     encode    get_mode_info    FAP    HAP 
   device_id 	   	    
   dumptable    ipairs    nvrammanager -c  
   fork_call    check_fw_result is  	tìÿÿ   os    execute    rm     call    ping    -q    -c    2    -w    1    ip    rc= 	ÿÿÿÿ   tmpcli      -s     -o 0xc407      -u      -I      >>     fork    exit    mac    upgrade_self_only 	2      sleep 3; nvrammanager -u     sleep 90; nvrammanager -u     upgrade_number    failed_device                     °  Æ    9   
   D   K@À Á    \ Z@    AÀ  	@ D  F Á F@Á   \ Z   @	E FÀÁ   Á  \  Z   Ë@Â A Ü ËÀÂ Ü@ @ Â   Þ  Ä Æ Ã  Ü@ Ë@CA ÜÚ   À ÁÀ    Þ ÀË@CA ÜÚ    Á@    Þ           reboot_time    get_profile    global 	n      fs    access    io    open    r    read    *all    close    print    match 	   fw error 	tìÿÿ   no data 	rìÿÿ                    È  Ì         À   @Ä     FB@@ÆÂ@ÜA¡  Àý        pairs    hw_id    oem_id    device_model                     Î  a         A@   D   FÀ À  \@ D  F Á @ \    AÁ  Ê   Á J    Á  AB ËBAÂ  Ê  ÜBCB  @ D À   \  À  C@J DCDÄ ÆÁ Ü   IDCDÀ IICEIÃEICEIÃÅIÃFICEICÅICEICÅICHICHICÈÉ@Þ  J 	 ÃI ÄÆÊÜ bC  PC À@ D
 ÀC  À ÉÅ
 ÆÃÊ AD ÜËÄK	À  D  DÃD  BPDD Þ  C @@J  LIÄLIGIM	IA	!  Àü@ @ 
 E	 FÃÉ\ J "C  DFCÍ\ ÀÅÀ À  C	 MÁ C  BÁÃ C N À  W@N@Å ÆÃÎ  Ü  ÄN@ W @ ÀE@úÉ  ù
 ÃJÁ D ËKDFÄËÉ\ ÜC  ËCCÜC Ä ÆÂÜC Ê  O  À D FDÏÀ	FO
ÀÏ
@EE É\FG
ÆFÇÀG
ÆÇÀÆÄ	 Æ	FÆ	Æ	ÆÇ	È	È	ÆÈ	MÉa  ø TLÍ
É
!  @õ$  dD      DP	À DÉÀÞ    B      require (   luci.controller.admin.mobile_app.device    print    get_latest_fw    getsysinfo    HWID    OEMID 	      ubus    connect    call    sync    list    close    others    name    bin 
   b64encode    product_name    version    releaseNote        type 	       release_date 
   file_size    latest_flag    device_model    hw_id    oem_id    download_url    need_force_upgrade     need_to_upgrade    need_to_download    fw_list    /tmp/firmware_info-%d-%d    os    time    getpid    M5    io    open    /tmp/firmware_info_list    w    write    encode    rm "%s" >/dev/null 2>&1    pairs    hwid    oemid 	      fork    exit    sleep 2 	       table    maxn    get_device_list    device_list    group_status 
   connected    new_version    sort        D  L        @ @@@ A    AÀ  ^          group_status 
   connected 	   	                        O  [   	+      Æ@@ ËÀAÁ   Ü Ë@ÁÜ À Á   AÀ @Á  Á  AA Õ   @   D   \ @ À  Å  Ü À   X   A            0x    mac    gsub    [:-]        upper 	   tonumber                                 c  e           @              fw_upgrade                     g  i           @              fw_download                     k         
   D   F À \  @À À   @  À 	 Á 	 @ @AÀ  @              get_upgrade_info     status    download_progress    dl_process    fail 	sìÿÿ                      Ñ    &      A@    Ä   ÆÀÀÜ  AFAA  \ Z  @KÁÀ   \A KÁÁÀ \AKÂÁA B A Â \A KÂÁA B A Â \A KÁÁÁA \AB ^         /etc/config/zigbee    zigbee    device    new_cursor    fs    access    delete_all 
   rawcommit    set    zigbee_network_sync    co_device_id    0    panID                     Ó    
         @  E@    \ À   AÄ  Æ@Á Ü Á Ä  Ü ÂA  ABA BAÁ A 
  EA  \ 	A	ÄJ    IAÄ   Ä ËÁÄA B ä     ÜAÆAÄÉÆAÄÉÆ	AÄÆÂ DFÂÆ \ BÜA ËG AB  À Ü  DFÂÂ ÄÆÂÆ Ü Â\B Ú   FÈZB   DFÂB \B @FÈÈ DFÂÂ \B @FÈ@FBÆZ  ÀÉ   ÉH@ À DFÂB	 \B B  À DFÂ	 \B KÂI \B D FÊ\B FBÊ \  Æ D FÊ\B KÂÉ\B D FÇÂ
 \B DFË\B   -      connect    require    luci.model.mode    string    match    exec    getfirm DEV_ID    %S+    lock    set_binding_flag    print    AP: unbind other M5    opcode 	   tonumber 	"@     target_type    RE    params    from    foreach    bind_device_list    device    device_list    remove_zigbee_device    data    args:     encode    call    sync    request 	   result:     success    sync request error 	       sync request error.    error_code    no legal request 7   fail to reset remote device, please remove by yourself    close    clear_binding_flag    is_iot_support    zigbee_remove_all_device    sleep 5    config_factory        ê  ì   	   D         @Ê@  @ É IÀ      	   
   device_id    .name                                   %           @  W@@ D  FÀ À  \@ B     ^ D  F@Á \ Á @ @ À  BÁ@ @       
   	   get_role    AP    print    remove network request to RE    remove device request to RE    fork 	       os    exit 	                       '  Þ  
 ¬  @   D   ]  ^   F @ @  À   @ÆA ÆÀÚA   Â  Â  ÞÆA ÆÀ Á Â  B Þ¡  Àû ÀAÄ  Æ ÂA Ü  ÆÀB Ä  Æ ÃA Ü@ Â   A Þ Ä ÆÃÜ ÁB A   WÀÃ CA A   A   D FAÄ\  ÁÁ  Â    FE\ @ÅFE\ ÀÅFF W@ÆÀ FF @Å   DFÆ\B D FÃÂ À Â\B EB   \= @Ä ÆÃ @ DÜC  Ä ÆÃD ÜC  ÀÃ@9Ä ÆÃ ÜC Ê   AD  ÉÉÃH
  		 J  DI	ÊD  ÉIÄ	IDÉ C	ÁÄ	 J
@ Õ	D DÊ
 AÅ
 Ä ÆÃ	 DFÊ
 	\ E
ÜD    ÆDK	ÚD   Ä ÆÃ	 ÜD +ÆDK	ÀË	 Ä ÆÃ	 ÜD )ÆDK	À Ä ÆÃ	E ÜD 'Ä ÆÃ	 ÜD @&Ä ËÃÌA  ÁD ÜÀ  CA D Â ÆEÜ WÀÅÀ ÆEÜ @ÅÀ@Å@Ä ÆÃÄ ÜC ÄÜC ÀÃÄ ÆÃ ÜC Ê   AD  ÉÉ
  		 J  DI	ÊD  ÉIÄ	IDE @E	@E ÀE	@ IÄEÉ C	ÁÄ	 J
@ Õ	D DÊ
 AÅ
 Â   C
A JÀ 	 U
E    EK	E    C
A E @EK	ÀK
  C
A E @EK	 I	  ÀFÅN
Z   FÅN
ÀË
@Â À  C
A E ÚD  À  C
A E EO
@ E ÀÄ ËÃÌA  ÁÄ ÜÀÃÀ CA D 
  T LDÉ	DFDÐ \D a  ÁKÐ\B DFÂÐ\B FE\ @ÅFE\ ÀÅ@E @E D FÑ\B @E 
D FÃB \B FE\ @Å FE\ ÀÅ D KÂÌÁ  AC \ CÁ  ÕB @ CÁÂ B  QB DFÒ\Â ÀÅ À  ÞFE\ @Å FE\ ÀÅ @ÅD FÃB \B D FÒ\B B ^   K      device_list    ipairs 
   device_id    device_id is not found        device_id is illegal    string    match    exec    getfirm DEV_ID    %S+    from    print    request from myself 	   get_role    AP    remove device request to RE    connect    require    luci.model.mode    is_iot_support    is_iot_wifionly     is_last_device_in_network     set_binding_flag 
   self_id:  	   dev_id:     need to unbind self 9   AP: tell other M5 to remove itself from bind_device_list    opcode 	   tonumber 	"@     target_type    RE    params 	      data    args:     encode    call    sync    request 	   result:     success    sync request error 	       sync request error.    request success    no legal request    get    zigbee_network_sync    co_device_id    need to unbind coordinator    first form new network    AP: unbind other M5 
   target_id    remove_zigbee_device    error_code K   fail to reset remote device, just remove it and sync-server will reset it.    rm_bind_device    bind_device_list    role     remove AP from bind_device_list    remove_local_device_list    close    clear_binding_flag    zigbee_remove_all_device    unbind self    co_device_id:     myself is coordinator    config_factory $   unbind coordinator form new network    zigbee_form_network                     à  å        
   	@@	À@          result_type    ===fake data===    msg    TODO                     ç  ê           A@   F@ ]  ^           require    luci.model.accountmgnt    save_cloudAcount                     ì  î           @              get_nickname                     ð     
       @ Ë@@A    ÁÁ  Ü  W Á D KAÁÁ Â d              \A   D KÂÁ \^ B  ^   	      cursor_state    get    repacd    DeviceType    RE    foreach    bind_device_list    device    commit        ÷  ý      D    @  D  	@D  KÀ ÁÀ   F@   \@ B  H         .name 	   nickname    section    bind_device_list    device                                   X  	 Ä   D   F À @  \@     F@ Z@   D  ]  ^   D  FÀÀ   \ K@Á \     @Á   Õ @ @ Ä   Æ ÀÁ @ AÜ@ Æ B @Ä   Æ ÀA Ü@ Â   A Þ WB@ @ @Ä   Æ ÀÁ Ü@ Æ C @ÃÀ C     ÆC ÁC ÁA  @A ÁD A @ A
  	Á DFAÅ Â \A@Ä  ÆÅÜ ÁÅ Á B WFÀD  FÀÁ \A J  A Á  II  	@  IÄ  ÆÀ DFÂÈ\ BÜA Ä ÆÉÜ BÉ	 ÁÂ	  KÊ\B D  FÀB
 ÄÆÂÈ  Ü Â\B    FJZB  ÀD  FÀÂ
 \B B  Â
 ^@FJ ËÀD  FÀB \B B  K^FJ@ FBHZB  À   ÆK ÂË   ÂËW K  ÆÌ B  B ^FC @ÃÀ C     FC  À  BÄ   Æ À Ü@ Â  Þ    3      print    ===set_nickname()===: start. 
   device_id    exec    getfirm DEV_ID    trim 
   self_id:  	   dev_id:     from    request from myself        rename self 	   nickname    custom    custom_nickname    set    cloud_config    info    alias    commit 	   location    cloud_update_feature_info    cursor_state    get    repacd    DeviceType    RE    AP: rename other M5    opcode 	   tonumber 	@  
   target_id    params    data    args:     encode    connect    call    sync    request    close 	   result:     success    sync request error 	       sync request error.    errmsg    error_code    msg    no legal request    ===set_nickname()===: end.                     ]     s   D   F À @  \@ @   D  ]  ^   F@ Z    FÀ@ Z   @F A Z    F@A Z@   D  ]  ^   F A    ÆÁ À ÆÀÁ ÀÆAÚ    ÆÀAÚ@   Ä  Ý  Þ   Æ@A Æ@Á Â@AA AB  @ AA Æ@B BÁ Á B @A 
  @  @ I Á@ I C I IÀI@D AÁ  FE\ @Å FE\ ÀÅ  I@DFAF I@DFÆ Â \ÁZA   À  ÞÅ Â Ü ÇFAÂAB BÂ ÁB  AÃ B  HÂ B  @AB B     "      print    cloud_create_group: start. 	   group_id 
   group_key    cloud_account 	   nickname 	   username 	   password    custom    custom_nickname    set    cloud_config    info    alias    group_name 	   location    role    master    require    luci.model.mode    is_iot_support    is_iot_wifionly     zigbee_role    master_device_id    cloud_save_feature_info    luci.model.accountmgnt    set_cloudAccount    device_status 
   need_bind    1    commit    cloud_create_group: end.                       Í   Q   D   F À @  \@ @   D  ]  ^   F@ Z    FÀ@ Z   @F A Z    F@A Z@   D  ]  ^   F A    ÆÁ À ÆÀÁ ÀÆAÚ    ÆÀAÚ@   Ä  Ý  Þ   Æ@A Æ@Á Â@AA AB  @ AA Æ@B BÁ Á B @A  AÁ  FDAÆÁA\AD KÂÁÁ B A Â \A D KÅÁÁ \AD  FÀA \A B ^         print    group_add_device: start. 	   group_id 
   group_key    cloud_account 	   nickname 	   username 	   password    custom    custom_nickname    set    cloud_config    info    alias    require    luci.model.accountmgnt    set_cloudAccount    device_status 
   need_bind    1    commit    group_add_device: end.                     Ï  Ó     	      A@   @  KÀ@ ]  ^           require    luci.model.message_center 
   Msgcenter    get_all                     Õ  Ù     	      A@   @  KÀ@ ]  ^           require    luci.model.message_center 
   Msgcenter    get_all_iot                     Û  ß     	      A@   @  KÀ@ ]  ^           require    luci.model.message_center 
   Msgcenter    get_monthly_report_content                     á  í      E   @  \ FÀ \     À@  A         À@ W@A  @    ËÁ @ Ü@Â  Þ          require    luci.model.message_center 
   Msgcenter    enable      switch_monthly_report                     ï  ÷           A@   @  J    A  W@A  @    I^          require    luci.model.message_center 
   Msgcenter    enable    is_monthly_report_closed                      ú     $   E   @  \ FÀ \    À@À W Á@ @Á A J   ÁA  IIÁB   IËCAÂ  ÀÜAËADÜA Ä A           require    luci.model.message_center 
   Msgcenter    get_mode_info    FAP    HAP    connect    opcode 	   tonumber 	!B     target_type    RE    params    data    call    sync    request    close    del_monthly_report                                  A@   @  KÀ@ \ Z   @ B  ^  K A ]  ^           require    luci.model.message_center 
   Msgcenter    is_monthly_report_closed    update_monthly_report                       &           A@   @  KÀ@ \ Z   @ B  ^  K A ]  ^           require    luci.model.message_center 
   Msgcenter    is_monthly_report_closed    push_monthly_report                     (  ?   6   @   D   ]  ^   F @ Z    @À @           À @           À  Á   Æ@AAÀ Ü ËÁÜ IÀÆ@AÀ Ü ËÁÜ IÀ Ê    ÁABFAÀ  É  ÁABFÀ  É  AB@     
      cloud_account 	   password    email    require    luci.model.tmp_decrypt    tmp_handle_string    trim    bin 
   b64decode    cloud_update_owner_info                     A  X   :   @      Á@   Z   @ÆÀ Ú    ÆÀÀ Ú@   Â    Þ Å   A Ü ÁFÀ  FÁÁÀ \   @ ZA     ÁÁ B   Â @   ABBÀ ÆÁB  Ü ÚA     A BC@ Â B           require    luci.model.accountmgnt 	   username 	   password    invalid cloud_account    luci.model.tmp_decrypt    tmp_handle_string    invalid account info    trim    bin 
   b64decode    compare_cloud_password    password is not correct    set_device_account_temporary                     Z         @   B      ^ F@@ @ ÆÀ@ Z   @Á    AÁ A     A   ÁAA  AB @   Ú@   B   ^Ú    W  B  Á ^Ú   À D  ] ^  D FÃA \A E  \@   À Â B  @  @@ÂC Ê  C A  ÉÉ
  J  	CFEIFEICÉKEÁÃ  @\CFC  CÁ  ÄF@ ÕC Z   ÇC  À CÁC C   ÁC @ÇGÀ CÁÃ C   ÆÈÇ CÅC  À Â  ÈÞ ÆCHÚ   ÆCHWÇÂ  HÞ   ÁÃ a  ÀçB ^   $      missing params    cloud_account    device_id_list 
   device_id 	   password 	   username    missing cloud_account    exec    getfirm DEV_ID    trim    missing device info    illegal request    print    Send to device    ipairs    connect    opcode 	   tonumber 	B  
   target_id    params    data    call    sync    request    close 	   result:     encode    success    sync request error 	       sync request error.    errmsg    error_code    msg    no legal request                     ¢  ¹       
   D   F À @  \@ 	À@D  FÀÀ \  Á A A   WÀAÀÄ   Æ ÀBÜ@ Ë@Â Ü@    Ë@Â Ü@ Â    Þ         print    cloud_proxy_conn 
   operation    connect    call    libcloud_proxy    control  	   err_code    close    fail to cloud_proxy_conn                     »  ä    }   
   D   F À \ @À     Á      Á 	ÁÊ   	ÀÆÀA A FB  A  A      É ÆÀA CÉ 	ÃÄ  ËÀÃA A Á  ÂDDFÅB \   Ü@  Ä  ËÀÃA A Á ÂA ÂBÜ@ Ä  ËÀÃA A Á Â FÂA FÂ Ü@  Ä  Ë ÆA Ü@À  @F AA  Ä  ÆÀÄEAA  Ü       ÁD@        W  A      	 AC  	Á
  	 ÁA D KÆÁ B A \ZA    B  	AÁA D KAÆÁ B A \	A  	Ã          ddns_get_domain_list     fail to get binded domain 	    	      ddns_enable 
   ddns_info    ddns_status 	   tonumber    isBind    domain_name    domain    ap_changed     set    cloud_ddns 	   dns_info 
   device_id    TrimStr    exec    getfirm DEV_ID    status 	   tostring    commit    get 	   get_bool                     ç  ì   	"   D   K À Á@    AÁ   AÄ ÆAÁ Ü   \@  D   K À Á@    AÁ B \@ D   K À Á@    AA  ÆÁB  \@  D   K Ã Á@  \@        set    cloud_ddns 	   dns_info 
   device_id    TrimStr    exec    getfirm DEV_ID    domain    domain_name    status 	   tostring    ddns_status    commit                     î  u   È       @Á@   @@   Õ @ WÀ@ @ A WÀ@ @A À@    Á  ÀA  B     @Á@ @   À   @      B À@ Â   Á Þ Ô  À  Ô  @Ã@Æ@CÃFAA @ A  BÁ FÄ @C@ @  A   ADFAA  @  W Ã    A  @  A   Á FÄ @C ÁD @  W Ã    A  @  A   Ä ÆÀÄÜ @ W Ã @Æ@E WÅÀ Ä  ÆÀÅ Ü@ Â   A Þ Ê    @ À TLBÃCÉ!  @þÁF@ @  W Ã @AE WEÀ  ÁEA A   A Ä Æ@ÇAA Ü @ W Ã Ç Æ@E WÅÀ Ä  ÆÀÅ Ü@ ÁÀ  Þ @Æ@E WÅÀ Ä  ÆÀÅ Ü@ Á@  Þ Æ A  Â Ä Æ@ÄAA Ü @ W Ã @Æ@E WÅÀ Ä  ÆÀÅ Ü@ Â    Þ Ä     Ü@ Â  Þ    #      print    params is     encode     ddns_status    domain_name    invalid parameters    update_local    Update local dns info    ddns_get_domain_list    fail to get ddns info 	    	      domain 	   tonumber    isBind 
   ddns_bind    fail to bind domain    ddns_unbind_all    fail to close ddns service    restore  
   fork_exec    cloud_restore_dns_info & /   fail to unbind old domains before bind one new    ipairs    ddns_delete_domains /   fail to delete old domains before bind one new    ddns_register 	ªÿÿ	f÷ÿÿ   domain name has been occupied 	g÷ÿÿ   domain name register failed                     x  {           A@   F@ ]  ^           require    luci.model.manager    get_manager_permission_profile                     }         E   @  \ À À                require    luci.model.manager    set_manager_permission                                  @ @@ D           @              fs    access                     Ù  ö   P   D   F À @  \@ D   FÀ    \@    @FÀ@ Z    FÀ@  A I FÀ@ Z@  @J   	@   @FÀ@ Z    FÀ@  A I F@A Á À FÀ@ F Á WÀÁ F@A  Â @FÀ@ F Á ÀÁ @FÀ@ F@Â Z@  @F@B Z    FÀ@ @B IFÀ@ FÂ Z@  @FB Z    FÀ@ B I FÀ@ FÀÂ Z@  @FÀB Z    FÀ@ ÀB ID  F Ã   À   ] ^           print    do difspatch cloud 
   dumptable    params 
   operation    form 	   firmware    upload    mini_firmware    hw_id    oem_id    device_model    simple_dispatch                     ù  :    
       A@   E     \    Ã Á  E AÁ  \  ÁÁAÃB d                   B BBE            require 
   luci.http    luci.tools.status 	    	   tonumber    get_memfree 	   	      setfilehandler    _index 	   dispatch        
  6   .   Ä   Ü Ú@   
Ä  Ú@      Æ @ @À@Ä  ÆÀÁ  Ü@ Ä  È Å  Æ@ÁA ÜÈ  ÁÀ È Z   ÀÄ  Ì È Ä   À Ä  Ë Â@ Ü@    Ä  Ë@ÂÜ@   
      name    image    printf    open file image    io    open    w 	       write    close                                 <  >           J  @  Á  b@ À  Á      	Á        entry    admin    cloud    call    _index    leaf                             