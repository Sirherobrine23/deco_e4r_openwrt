LuaQ               DV     A@    À@@  A@  E   \   ÁÀ  Å   Ü  AA  E  \  ÁÁ  Å  Ü  AB  E  \  ÁÂ  Å  Ü  AC  E  \  ÁÃ  Å  Ü ÆCÅÄ  F AD  Á  ÄF	Á  	AE E
@	 U
Å ä          	$F  d       ¤Æ     ä         $G          $        G $Ç      d      ¤G              ä    $È                                $    dH    ¤    äÈ    $	       dI                       ¤             äÉ                             $
 dJ ¤    äÊ       $                           dK            ¤         äË $ dL ¤    äÌ $        dM ¤ äÍ             $	    dN	                ¤	       äÎ	            $
         dO
               ¤
 äÏ
 
P J  P  IP  I	PJ P  Å ÐIP  IP  PIP  ÐIP  IP  I	PJ  P  PIP  I	PJ P  ÐIP  IP  PIP  IP  IP  ÐIP  PIP  I	PJ P  ÐIP  IP  IP  PI	PJP  P  I	PJ  P  ÐIP  PI	PJ  P  ÐIP  PI	PJ  P  IP  ÐI	P d        GP   B      module '   luci.controller.admin.mobile_app.cloud    package    seeall    require    ubus    nixio    luci.model.uci 
   luci.util 	   luci.sys    luci.tools.debug    luci.model.controller    luci.model.sync    luci.model.app_cloudfirm    luci.sys.config 
   luci.json    cloud_req.cloud_comm    cloud_req.cloud_ddns ,   luci.controller.admin.mobile_app.iot_device    luci.model.tmp_decrypt    luci.model.locker 	   RWLocker    FIRMWARE_INFO_LOCK !   /var/run/firmware_info_list.lock    cursor !   97234B9422C9BC4440F67130D25681FA    luci.model.countrycode    DEVICE_COUNTRY_OEMID_TBL    /tmp/cloud/    cloud_dl.head    cloud_fw.length 	Â²Ú    is_in_bind_list    get_fwdev_list    get_latest_fw 	   nickname    read    cb    write 	   firmware    check    upgrade 	   download    sync_check_firmware 	   get_sync    group    create    add    message 	   iot_read    report    remove    set    get    update    push    system    remove_all    unbind    bind    proxy    account    notify    ddns    manager 	   dispatch -       )   0       D   F À   @@Á    \      @Ä  Æ@ÀÁ  Ü    À   @ Õ@ Á A    A          TrimStr    exec    getfirm SPECIAL_ID    getfirm COUNTRY    -    others                     2   6        @       B      ^         invalid args                     8   H    
%      @@Á  Á   AÄ   A A  AÜ@ Â  Þ  ËAAÁ ÜBA  AB@ @   @ À  @ B ^ !  @þ           io    open    /tmp/sync-server/mesh_dev_list    r     error open file failed:    read    *all    close    decode    pairs                     J   Z       J      @@À     À@    Ë AAA ÜÚ@    À  A@ T LÁÁI @üË BÜ@ ^    	      io    open    r     read    *line    decode 	      close                     \   t    C   @      Å   Æ@À   Ü   @ À@  ^  A Á `ÁEB  \@ AÆÁÀ  ÃAÆÃÁÀÀ  BÀ  @ C   BÀ  C@ a  Àù_øEA  \   BÀ  Ba   þD FÁÂ Ä ÆAÃ  Ü Á\A ^          table    maxn    get_fw_list  	      pairs    hw_id    oem_id    insert    ipairs    remove    print    adjust_list     encode                     v          D   K À Á@  \Z@  @        @ÁÀ   A@  Õ @ @ À    ÆA @ Â Þ ¡   þ             get_all    bind_device_list    print    is_in_bind_list     encode    pairs    mac                            /   J      Á@   @ ËÀ@A A Ê  ÜAA Á @ FBW@Â D  \ ZB  ÀFB@Â@E ÂB\ Z    I !   û CAA  CÀ  UA ^          require    ubus    connect    call    sync    list    close    pairs    role    UNBIND    is_in_bind_list    mac    print    get_fwdev_list     encode                        ¹    H   Ê     C  À   ÆB@ÀÀÆÂ@À ÆAWÀ@  FAÆBAÁ  ÉÂ WÀ  @ FD@D@ FÄ@Ä@  Â  !   ýC@   Ã@W @Ú  À C@W@  É¡   ô  ÁAÁ  BB@ A Â À  ÕA À           pairs    hwid     oemid    fw_version    role    AP    print (   get_diffproduct_table: diff_device is :    encode     has_old_device is : 	   tostring                     »   È    "   
  E    \ BÀ@  À @  Â@ÆÁ     BA	  @BÀA  BA	a   ù         pairs    hwid    oemid    compareFwVersion    fw_version 	                        Ê   ÿ    c   D  FÀA  \A J   À  @@ À  D FÁFBÁÂ@\ IAD FÁFBÁA\ IAFBIAE BB\ IAFÂBIAIÁ FBCIAFCIAFÂCIAFDIAW@D@ IÁD  IEFBEÀÄIÁEIEIÅE Â \ FÇ\ BÇB FEIAIÁDIÁÄE Â \ FÇ\ ÇB EÂ \ À  @AIÅB ÆÈ   AÃ ÜÉ CIÀ C  É	 CÃÉC ^   (      print    sync_check_firmware begin    get_firmware_info    name    bin 
   b64encode    version    release_note    releaseNote    type 	   tonumber    release_date    device_model    hw_id    oem_id    download_url    check_status     need_force_upgrade     latest_flag 
   file_size 	       need_to_upgrade    need_to_download    require    luci.model.message_center 
   Msgcenter    clean_new_fw_flag    set_new_fw_flag    get_fwdev_list    device_id_list    io    open    a    write    encode    
    close                                À   @Ä     FB@@ÆÂ@ÜA¡  Àý        pairs    hw_id    oem_id    device_model                       j   Í   D   F À @  \@ D  FÀ À  \   @Á   Ê   
  AA   Å Ü  @ À Z  @ÄÜ ÀÁ 
Ã D FCÂFÂ @ÁÃ  \  	CD FCÂFÂ \ 	C	Ã	Ä	Ã	D	Å	Ã	C	Ã	C	Æ	Æ	F	Æ	AÃ  ^
 EC FÈ\  ÃH "C  D Ä  A	  \C D \ 	AC	 IÁÃ	 
 ËCJD FÊ\ ÜC  ËÃJÜC ÄÆËÜC ÆCÇÆÀ ÁÃ   Þ   Å   Ü@
  FÄË	DFÌ	DFDÅ	DT LDÌá  ÀüÄ   Ü Ê C H D FÃÈ\ âB  ÐÂ L  DÀDÀ \CEC FÃÌC \C DFË \C MAÍD\ WÍ@Ã NÀ ÅÃ ÆÎ  Ü WÀ@  Ä@ú	A  ùEC	 FÉÃ	 Á
 \CÊ JFG C  ÃÊC KÐÃC  ÆGÀ ÆDG	 Å	   ¡  @þÃ À   9      print    get_latest_fw    getsysinfo    HWID    OEMID 	      get_fwdev_list    others    name    bin 
   b64encode    product_name    version    releaseNote        type 	       release_date 
   file_size    latest_flag    device_model    hw_id    oem_id    download_url    need_force_upgrade     need_to_upgrade    need_to_download    check_status    fw_list 	'ñÿÿ   /tmp/firmware_info-%d-%d    os    time    getpid    M5    io    open    /tmp/firmware_info_list    w    write    encode    close    call    rm "%s" >/dev/null 2>&1    pairs    hwid    oemid 	      fork    exit    sleep 2 	       table    maxn                     l  n      D   F À ]  ^           fw_upgrade                     p  r      D   F À ]  ^           fw_download                     t  v      D   F À ]  ^           get_fw_synclist                     x        J       @  @@À @ À ^ F@I@FAI@^          get_upgrade_info     status    download_progress    dl_process                       Ú    )      A@    ÁÀ   AA   A Ä ÆÁÁÂ@    @BB ÀB B BÂB Á C A B ÂB Á Ã A B B B       %   /tmp/sync-server/dev_compitable_list    /tmp/sync-server/mesh_dev_list    /etc/config/zigbee     /etc/config/zigbee_network_sync    zigbee    device    new_cursor    fs    access    delete_all 
   rawcommit    set    zigbee_network_sync    co_device_id    0    panID                     Ü        D   F À \ @  Á   ÅÀ  Æ Á AAA  AÁ Ü BA ABA A 
  E A \ 	A	ÁCJ    IÄÁ  Ä ËÄAÂ  ä     ÜAÆÄÉÆÄÉÁE	AÄÆAÂB DFÆ \ BÜA ËÁÆ A B À Ü  DFBÂ ÄÆÆ Ü Â\B Ú   FÂÇZB   DFBÂ \B @FÂÇ@È DFBÂ \B @FÂÇ@FÆZ  ÀÂÈ   ÂÈ@H@ À DFBÂ	 \B B  À DFBÂB	 \B KÉ \B D FÂÉ\B FJ\ ÀÅ D FBÊ\B D FÂÆ
 \B AÂ
  À¢B Ä ÆÂÆ  ÜB ÄÆBËÜB   .      connect    require    luci.model.mode    string    match    exec    getfirm DEV_ID    %S+    set_binding_flag    print    AP: unbind other M5    opcode 	   tonumber 	"@     target_type    RE    params    from    foreach    bind_device_list    device    device_list    remove_zigbee_device    data    args:     encode    call    sync    request 	   result:     success    sync request error 	       sync request error.    error_code    no legal request 7   fail to reset remote device, please remove by yourself    close    clear_binding_flag    is_iot_support    zigbee_remove_all_device    sleep 5    /tmp/reset_now    rm %s     config_factory        ñ  ó   	   D         @Ê@  @ É IÀ      	   
   device_id    .name                                   2   $   D   F À \ W@À   @ÁÀ  @    Á   @ Ê    â@ ÐÀ  ÁA@A B @BD   \A E FÁÂ \A B ^      	   get_role    AP    print    remove network request to RE    remove device request to RE    /tmp/reset_now 
   touch %s     call    fork 	       os    exit 	                       4  ï  
 ³  @   D   ]  ^   F @ @  À   @ÆA ÆÀÚA   Â  Â  ÞÆA ÆÀ Á Â  B Þ¡  Àû ÀAÄ  Æ ÂA Ü  ÆÀB Ä  Æ ÃA Ü@ Â   A Þ Ä ÆÃÜ ÁB A   WÀÃ CA A   A   D FAÄ\  ÁÁ  Â    FE\ @ÅFE\ ÀÅFF W@ÆÀ FF @Å   DFÆ\B D FÃÂ À Â\B EB   \@? @Ä ÆÃ @ DÜC  @Ä ÆÃD ÜC  ÀÃ ;Ä ÆÃ ÜC Ê   AD  ÉÉÃH
  		 J  DI	ÊD  ÉIÄ	IDÉ C	ÁÄ	 J
@ Õ	D DÊ
 AÅ
 Â   C
A JÀ 	 U
E    EK	E    C
A E  -EK	ÀK
  C
A E  +EK	 I	  )FEL
Z  À(FEL
ÀË
 (Â ' C
A E @&Ä ËÃÌA  ÁD ÜÀ  CA D Â ÆEÜ WÀÅÀ ÆEÜ @ÅÀ@Å@Ä ÆÃÄ ÜC ÄÜC ÀÃÄ ÆÃ ÜC Ê   AD  ÉÉ
  		 J  DI	ÊD  ÉIÄ	IDE @E	@E ÀE	@ IÄEÉ C	ÁÄ	 J
@ Õ	D DÊ
 AÅ
 Â   C
A JÀ 	 U
E    EK	E    C
A E @EK	ÀK
  C
A E @EK	 I	  ÀFEL
Z   FEL
ÀË
@Â À  C
A E ÚD  À  C
AÅ E O
@ E ÀÄ ËÃÌAD  Á ÜÀÃÀ CAÄ D 
  T LDÉ	DFÐ \D a  À¿KBÐ\B DFÐ\B FE\ @ÅFE\ ÀÅ@E @E D FÂÐ\B @E 
D FÃ \B FE\ @Å FE\ ÀÅ D KÂÌÁ  AC \ CÁB  ÕB @ CÁ B  ÂPB DFÂÑ\Â ÀÅ À  ÞFE\ @Å FE\ ÀÅ @ÅD FÃ \B D FBÒ\B B ^   J      device_list    ipairs 
   device_id    device_id is not found        device_id is illegal    string    match    exec    getfirm DEV_ID    %S+    from    print    request from myself 	   get_role    AP    remove device request to RE    connect    require    luci.model.mode    is_iot_support    is_iot_wifionly     is_last_device_in_network     set_binding_flag 
   self_id:  	   dev_id:     need to unbind self 9   AP: tell other M5 to remove itself from bind_device_list    opcode 	   tonumber 	"@     target_type    RE    params 	      data    args:     encode    call    sync    request 	   result:     success    sync request error 	       sync request error.    error_code    no legal request    get    zigbee_network_sync    co_device_id    need to unbind coordinator    first form new network    AP: unbind other M5 
   target_id    remove_zigbee_device K   fail to reset remote device, just remove it and sync-server will reset it.    rm_bind_device    bind_device_list    role     remove AP from bind_device_list    remove_local_device_list    close    clear_binding_flag    zigbee_remove_all_device    unbind self    co_device_id:     myself is coordinator    config_factory $   unbind coordinator form new network    zigbee_form_network                     ñ  ö       J   I@@IÀ@^          result_type    ===fake data===    msg    TODO                     ø  û       E   @  \ À              require    luci.model.accountmgnt    save_cloudAcount                     ý  ÿ      D   F À ]  ^           get_nickname                          
       @ Ë@@A    ÁÁ  Ü  W Á D KAÁÁ Â d              \A   D KÂÁ \^ B  ^   	      cursor_state    get    repacd    DeviceType    RE    foreach    bind_device_list    device    commit                D    @  D  	@D  KÀ ÁÀ   F@   \@ B  H         .name 	   nickname    section    bind_device_list    device                                   i  	 Ä   D   F À @  \@     F@ Z@   D  ]  ^   D  FÀÀ   \ K@Á \     @Á   Õ @ @ Ä   Æ ÀÁ @ AÜ@ Æ B @Ä   Æ ÀA Ü@ Â   A Þ WB@ @ @Ä   Æ ÀÁ Ü@ Æ C @ÃÀ C     ÆC ÁC ÁA  @A ÁD A @ A
  	Á DFAÅ Â \A@Ä  ÆÅÜ ÁÅ Á B WFÀD  FÀÁ \A J  A Á  II  	@  IÄ  ÆÀ DFÂÈ\ BÜA Ä ÆÉÜ BÉ	 ÁÂ	  KÊ\B D  FÀB
 ÄÆÂÈ  Ü Â\B    FJZB  ÀD  FÀÂ
 \B B  Â
 ^@FJ ËÀD  FÀB \B B  K^FJ@ FBHZB  À   ÆK ÂË   ÂËW K  ÆÌ B  B ^FC @ÃÀ C     FC  À  BÄ   Æ À Ü@ Â  Þ    3      print    ===set_nickname()===: start. 
   device_id    exec    getfirm DEV_ID    trim 
   self_id:  	   dev_id:     from    request from myself        rename self 	   nickname    custom    custom_nickname    set    cloud_config    info    alias    commit 	   location    cloud_update_feature_info    cursor_state    get    repacd    DeviceType    RE    AP: rename other M5    opcode 	   tonumber 	@  
   target_id    params    data    args:     encode    connect    call    sync    request    close 	   result:     success    sync request error 	       sync request error.    errmsg    error_code    msg    no legal request    ===set_nickname()===: end.                     n  £   r   D   F À @  \@ @   D  ]  ^   F@ Z    FÀ@ Z   @F A Z    F@A Z@   D  ]  ^   F A    ÆÁ À ÆÀÁ ÀÆAÚ    ÆÀAÚ@   Ä  Ý  Þ   Æ@A Æ@Á Â@AA AB  @ AA Æ@B BÁ Á B @A 
  F@ 	AFÁ@ 	AFC 	A	Á	ADE Á \ Å @E Å ÀE  	ADAF 	FÀ  ÁA     @ AÂ  FGAÆÂA\BD KÂÁÂ C A Ã \B D KÈÁÂ \BD  FÀB \B B ^   "      print    cloud_create_group: start. 	   group_id 
   group_key    cloud_account 	   nickname 	   username 	   password    custom    custom_nickname    set    cloud_config    info    alias    group_name 	   location    role    master    require    luci.model.mode    is_iot_support    is_iot_wifionly     zigbee_role    master_device_id    cloud_save_feature_info    luci.model.accountmgnt    set_cloudAccount    device_status 
   need_bind    1    commit    cloud_create_group: end.                     ¨  Þ   Q   D   F À @  \@ @   D  ]  ^   F@ Z    FÀ@ Z   @F A Z    F@A Z@   D  ]  ^   F A    ÆÁ À ÆÀÁ ÀÆAÚ    ÆÀAÚ@   Ä  Ý  Þ   Æ@A Æ@Á Â@AA AB  @ AA Æ@B BÁ Á B @A  AÁ  FDAÆÁA\AD KÂÁÁ B A Â \A D KÅÁÁ \AD  FÀA \A B ^         print    group_add_device: start. 	   group_id 
   group_key    cloud_account 	   nickname 	   username 	   password    custom    custom_nickname    set    cloud_config    info    alias    require    luci.model.accountmgnt    set_cloudAccount    device_status 
   need_bind    1    commit    group_add_device: end.                     à  ä    	   E   @  \ FÀ \ ÀÀ              require    luci.model.message_center 
   Msgcenter    get_all                     æ  ê    	   E   @  \ FÀ \ ÀÀ              require    luci.model.message_center 
   Msgcenter    get_all_iot                     ì  ð    	   E   @  \ FÀ \ ÀÀ              require    luci.model.message_center 
   Msgcenter    get_monthly_report_content                     ò  þ      E   @  \ FÀ \     À@  A         À@ W@A  @    ËÁ @ Ü@Â  Þ          require    luci.model.message_center 
   Msgcenter    enable      switch_monthly_report                               E   @  \ FÀ \    Ë Á Ü W@Á  Â@  Â  À          require    luci.model.message_center 
   Msgcenter    enable    is_monthly_report_closed                        #   $   E   @  \ FÀ \    À@À W Á@ @Á A J   ÁA  IIÁB   IËCAÂ  ÀÜBDB Ä A           require    luci.model.message_center 
   Msgcenter    get_mode_info    FAP    HAP    connect    opcode 	   tonumber 	!B     target_type    RE    params    data    call    sync    request    close    del_monthly_report                     %  -       E   @  \ FÀ \ ÀÀ     @      Á              require    luci.model.message_center 
   Msgcenter    is_monthly_report_closed    update_monthly_report                     /  7       E   @  \ FÀ \ ÀÀ     @      Á              require    luci.model.message_center 
   Msgcenter    is_monthly_report_closed    push_monthly_report                     9  O   5   @   D   ]  ^   F @ Z    @À @           À @             À@Æ@À   A I  À@ÆÀ   A I    Ä  Æ@ÁÆÁAÀ Ü ÀÄ  Æ@ÁÆÁÀ Ü À Ä ÆÀÁ  Ý  Þ           cloud_account 	   password    email    tmp_handle_string    trim    bin 
   b64decode    cloud_update_owner_info                     Q  h   :   @      Á@   Z   @ÆÀ Ú    ÆÀÀ Ú@   Â    Þ Å   A Ü ÁFÀ  FÁÁÀ \   @ ZA     ÁÁ B   Â @   ABBÀ ÆÁB  Ü ÚA     A BC@ Â B           require    luci.model.accountmgnt 	   username 	   password    invalid cloud_account    luci.model.tmp_decrypt    tmp_handle_string    invalid account info    trim    bin 
   b64decode    compare_cloud_password    password is not correct    set_device_account_temporary                     j  °      @   B      ^ F@@ @ ÆÀ@ Z   @Á    AÁ A     A   ÁAA  AB @   Ú@   B   ^Ú    W  B  Á ^Ú   À D  ] ^  D FÃA \A E  \@   À Â B  @  @@ÂC Ê  C A  ÉÉ
  J  	CFEIFEICÉKEÁÃ  @\CFC  CÁ  ÄF@ ÕC Z   ÇC  À CÁC C   ÁC @ÇGÀ CÁÃ C   ÆÈÇ CÅC  À Â  ÈÞ ÆCHÚ   ÆCHWÇÂ  HÞ   ÁÃ a  ÀçB ^   $      missing params    cloud_account    device_id_list 
   device_id 	   password 	   username    missing cloud_account    exec    getfirm DEV_ID    trim    missing device info    illegal request    print    Send to device    ipairs    connect    opcode 	   tonumber 	B  
   target_id    params    data    call    sync    request    close 	   result:     encode    success    sync request error 	       sync request error.    errmsg    error_code    msg    no legal request                     ²  É   	   J      Ä   Æ ÀA  Ü@ IÀ@Ä  ÆÀÀÜ ÁA Á   WÀAÀD  FÀB\A KAÂ\A   KAÂ\A B   ^        print    cloud_proxy_conn 
   operation    connect    call    libcloud_proxy    control  	   err_code    close    fail to cloud_proxy_conn                     Ë  ô   }   J       @ @@ Â     Þ Ô  ÀÆ AIÁ
  I ÁÁ EA Â\  Á B ZA    B  	AÁÁ FÃ	AIÃ ÁC ÁA  D FÂÄEÁB  \  A   ÁC ÁA  FÂÁ FÂÂA  ÁC ÁA  EÂ ÂÁ B\ A   F AÀÄ  Ë@ÆA A Á Ü ÁDDFÅA \   Ú    D FÁÄ\ À Ú    WÀ  B ZA    B  I@FAÃ @IÁJ  I@FÁÁ  F AB  A      IFÁÁ  AF AB  I  IÃ^          ddns_get_domain_list     fail to get binded domain 	    	      ddns_enable 
   ddns_info    ddns_status 	   tonumber    isBind    domain_name    domain    ap_changed     set    cloud_ddns 	   dns_info 
   device_id    TrimStr    exec    getfirm DEV_ID    status 	   tostring    commit    get 	   get_bool                     ÷  ü   	"   D   K À Á@    AÁ   AÄ ÆAÁ Ü   \@  D   K À Á@    AÁ B \@ D   K À Á@    AA  ÆÁB  \@  D   K Ã Á@  \@        set    cloud_ddns 	   dns_info 
   device_id    TrimStr    exec    getfirm DEV_ID    domain    domain_name    status 	   tostring    ddns_status    commit                     þ     È       @Á@   @@   Õ @ WÀ@ @ A WÀ@ @A À@    Á  ÀA  B     @Á@ @   À   @      B À@ Â   Á Þ Ô  À  Ô  @Ã@Æ@CÃFAA @ A  BÁ FÄ @C@ @  A   ADFAA  @  W Ã    A  @  A   Á FÄ @C ÁD @  W Ã    A  @  A   Ä ÆÀÄÜ @ W Ã @Æ@E WÅÀ Ä  ÆÀÅ Ü@ Â   A Þ Ê    @ À TLBÃCÉ!  @þÁF@ @  W Ã @AE WEÀ  ÁEA A   A Ä Æ@ÇAA Ü @ W Ã Ç Æ@E WÅÀ Ä  ÆÀÅ Ü@ ÁÀ  Þ @Æ@E WÅÀ Ä  ÆÀÅ Ü@ Á@  Þ Æ A  Â Ä Æ@ÄAA Ü @ W Ã @Æ@E WÅÀ Ä  ÆÀÅ Ü@ Â    Þ Ä     Ü@ Â  Þ    #      print    params is     encode     ddns_status    domain_name    invalid parameters    update_local    Update local dns info    ddns_get_domain_list    fail to get ddns info 	    	      domain 	   tonumber    isBind 
   ddns_bind    fail to bind domain    ddns_unbind_all    fail to close ddns service    restore  
   fork_exec    cloud_restore_dns_info & /   fail to unbind old domains before bind one new    ipairs    ddns_delete_domains /   fail to delete old domains before bind one new    ddns_register 	ªÿÿ	f÷ÿÿ   domain name has been occupied 	g÷ÿÿ   domain name register failed                              E   @  \ À              require    luci.model.manager    get_manager_permission_profile                              E   @  \ À À                require    luci.model.manager    set_manager_permission                     Ç  É      D   F À   À   ] ^           simple_dispatch                             