LuaQ               '=     A@    À@@  A@  E   \   ÁÀ  Å   Ü  AA  E  \  ÁÁ  Å  Ü  AB  E  \ ÂÃ ÆÂÃ Ü ÃÃAC  C Á Ä A D Á 
 J   ÊE  ÉÆ
F  	ÆJF  IFF  ÆÊF  ÉF
G  	Æ¢E I  I	EJ  ÊE  ÉÅH
F  	ÆÈJF  IÆF  ÆHÊF  ÉÆÈ
G  	ÇHJG  IÇÈ¢EI  I	EJ  ÊE  ÉÅH
F  	ÆÈJF  IÆÈF  ÆHÊF  ÉÆÈ
G  	ÇHJG  IÇÈ¢EI  I	EJ  ÊE  ÉÅH
F  	ÆÈJF  IÆHF  ÆÈÊF  ÉÆÈ
G  	ÇHJG  IÇÈG  ÇHÊG  ÉÇÈ¢EI  I	EFEJ\ G
 d       ¤E  ä     $Æ     
     d    G
 dF    ¤    äÆ           $    dG    ¤    äÇ    $       dH     ¤      äÈ      $	       	E	
 ¤I         IE	
 ¤    I	E	
 ¤É       
IE	
 ¤	            I	E	
 ¤I                         
IE	
 ¤      
I	E	
 ¤É              
IE	
 ¤	         I	E	
 ¤I      
IE	
 ¤           I	E	
 ¤É      IE	
 ¤	     I	E	
 ¤I     
IE	
 ¤     
I	E	
 ¤É                
IE	
 ¤	      
I	E	
 ¤I    Id        G	 E	
 ¤É          	  	IE	
 ¤		   I	E	
 ¤I	          	IE	
 ¤	         I	   A      module    luci.model.parental_control    package    seeall    require    ubus    nixio    string 	   luci.sys 
   luci.util    luci.model.uci    luci.tools.debug 
   luci.json    luci.model.uuid    luci.model.app_clientmgmt    cursor    /tmp/tmp-device-config    /tmp/parental_control 	    	·òÿÿ	µòÿÿ   emmc_owner_avatar    avatar    tyke    categories_list    online_communications    blocked    social_network    pay_to_surf    media 	   download    games    website_list 	   pre_teen    sex_education 
   unblocked    teen    adult    adult_content 	   gambling 
   Parentctl    class    _print_tbl 	   __init__    commit    get_default_filter    get_owner_list 
   add_owner 
   del_owner 
   set_owner 
   get_owner    block_owner    remove_insights    get_insights    get_insight_history    add_clients    del_clients    filter_website    filter_del_website    get_default_website %   parentctl_get_insights_monthly_table    set_owner_avatars    get_website_max_count    get_owner_avatars    get_client_block_status '       h   v    "   A     À@À   @  @     À@  @A   @@  A@     ÀAÁ    AA Õ@@        BÁÀ @          "   /tmp/parental_control/op_owner_id    fp    io    open    w    write    close    print    open  	    failed! 
   fork_call $   /etc/init.d/parental_control reload                     x              Å      Ü   @ À  À  !   þá  ü Á@Á          pairs    flag    key 	                            ©     .   
   C  Á   
  EA  FÀÁ  Á \ZA  @    AÁ À  AÁ @  ÁA   ÁAÀ    @      BÀ Â   BCÀ  B¡A   þ      	       io    open    /tmp/parental_control/url_lib    r    read    close    match    unsupport: (.+)     gmatch    ([^,	
]+),    table    insert                     «   Ä     (      B      Ä  Ü @  À @ Â   Þ    Å@     Ü @
  J  FÀB  À  Ä  @ Ü@ ÆÃÀ  Á ÅC ÆÁ FÄÁ ÜC¡   üá  Àù         pairs    categories_list    flag    table    remove    key                     Æ   Ï       E      \ @À E     \    Á@À  EB  \ ÕAA   Æ  @@  Æ A a   û        type    table    pairs    print     =  	   tostring    _print_tbl                     Ñ   Ô            @ @  Á   @    À  E     ]  ^           get_profile    parental_control 
   max_owner    16 	   tonumber                     Ö   Ù            @ @  Á   @    À  E     ]  ^           get_profile    parental_control    max_dev    16 	   tonumber                     Û   ì           @  À
      
        @ @  Á  $       @      D \             foreach    parental_control    owner        à   ä       @      Ä   Ô Ì À@  Å@  @ Ü ÀÀ     	   	   tonumber 	   owner_id                                 î      W   J      Ã  A       ÅA     Ü WÀ I ÀI ^  Ä  ÆÁ   AÂ ÜA  À  ÇA Ú    Å  Ü  À@ I À IÀÃ D  FBÂ  ÌB\  ÂBÀ @Ê  ÉCÉ BÀ¡  ÀýI   @Å   Ü À Á   A àÁÅÂ ÆÄC NLCÜÃ DAC Ã ÃD      LBßûÀ  Þ     	       type    string    spend_online    website_list    _    find    ^(%d+);(%d+); 	   tonumber    sub 	      gfind    ([^,;]+),(%d+);    website 	      os    date    %x 	Q    time                       1   !   J         Å      Ü W@À  ^  Å     Ü   Â@À @Ê  ÉCÉ ÄAIÀ¡  Àýá  û^          type    table    ipairs    gfind    ([^,;]+),(%d+);    website    access_timestamp 	                       3  Q    5      J     EA  FÀÁ  Á \ZA     À AÁ   ÁÁA   BÀ B     À   À    @   À  Ä  ÆÁÂ  A Ü Ê  É CIÀáA   þÀ    Þ     	       io    open    /tmp/parental_control/url_lib    r    read    *all    close    find    ^Version: (%d+)
 	   tonumber    gfind    %d+,([^,,]+),[^,,]+,%d+    name 	                       S  ¾   ì   Z       @    @  Z    Á  Ú@    ÁÀ  
  J   ÅB ÆÁÃ EC FÂ\ Ü    BBÅ C AA C B   Ü  Â    @  CÆ  C BÃ @Â    À  @
ÁC ÅB ÆÁÃ @ Ü  BBÅ C AA  Ü  ÌÁ   DF  CÄD  FÄ ÁÃ \   Å  Ü ÄÔÌDÄ	I	a   ýÂ    @  CÆÂ  C BÃ @Â    À  @ÁC ÅB ÆÁÃ @ Ü  BBÅ C AA  Ü  ÌÁ   DFÃ  CÄD  FÄ ÁÃ \   Å  Ü ÄÂ   @E TE  ÆEFE	@ÀÂ ÆFÆFFÅFE	L	F  EüÚD   ED
I
a   ÷@  ÁB AC à EßBÿÁB Ã AC àB	Á D TD  ÅE  @Ã  À	ÅEE
FÅFEÅ
@
  À	DüÃ   Z   
  	FÄFÅ	DFÄFDÅ	D@ Ä	BÆßö         forbid_day_1    day_1    month_forbid_t    month_access_t 	   tonumber    os    date    %Y    time 	      %m    _    find    ^(%d+);(%d+); 	    	<      sub 	      gfind    ([^,;]+),(%d+);    url    online_duration  	      block_count                     À  ú      
  J   À     B  Û@   Á  @ÀÀ      Û@   Á@    Á B    Â Å ÆBÂ E FÃÂ\ Ü    CÅÂ  CBAC  ÃB   Ü  ÂÂ    @ ÂCÆÂ   B @   Â À  @
Â Å ÆBÂ @ Ü  CÅÂ  CBAC  Ü  ÌÁB  DFÃ  ÀD FÃÄ Á \   ÅÄ  Ü ÄÔÌÀ	I	a   ýÀE B    Â Á    A  à   Ê  	ÁÆDEÉÆEÉ@ Æ	ÁßÂû      	      month_forbid_l    month_access_l 	      month_forbid_ll    month_access_ll    only support 3 month! 	   tonumber    os    date    %Y    time 	      %m    _    find    ^(%d+);(%d+); 	       sub    gfind    ([^,;]+),(%d+);    url    online_duration 	      block_count                     ü         
   J       @A  A  ¤       @	@	@A          foreach    pc_insights    owner    owners    has_app_filter           	      J    @ I @@ I   À     I    À    I  Ä  Ô Ì Á@     	   owner_id    owner_name    app_web_list    forbidden_app_web_list 	                                     "       
   J       @A  A  ¤       @	@	@A          foreach    pc_insights    owner    owners    has_app_filter                 J    @ I @@ I   À   Á  B   I    À   Á  B  I   Ä  Ô ÌÀÀ@     	   owner_id    owner_name    app_web_list 	      forbidden_app_web_list                                 $  7       
   J       @A  A  ¤       @	 Á	@          foreach    pc_insights    owner    has_app_filter     owners        )  1      J    @ I @@ I   À   Á  B   I    À   Á  B  I   Ä  Ô Ì@Á@     	   owner_id    owner_name    app_web_list 	      forbidden_app_web_list 	                                   :  C      D   K À Ä     AA  \Z   @ ^  @             get    avatar_md5                         E  S      J   H   J   H  D  K À Á@    d       \@        foreach    parental_control    owner        L  P      @      Ä   Ô Ì À@  Å@  @ Ü ÀÀ     	   	   tonumber 	   owner_id                                 U  ]      D   K À Á@    AÁ  \Z@      Á   ^          commit    parental_control    client_mgmt 
   blacklist    Parentctl commit failed.                     _  j   	   J      @    Ä   @Ê  ÉAÉ Â@IÀ¡  Àý^          pairs    filter_level    filter_level_detail 	                       l  »      J       @A  A  ¤          @^          foreach    parental_control    owner        p  ·   
   J    @ I @@ I   Æ À  I À@  A@ IÁ  IÀÁ   BA FÀ  Ä    ÜÀ FÃI@FAC I@J  ÁC A      IAD A      II@  ÆÁD  ÁÀ AÆE Á@ÁAÆE ÚA    ÁÁ ÁÆF  ÁÀ ÁÆÁF Á@ÁÁÆÁF ÚA    ÁÁ ÁIÊ  BG  A@ÉAH ÉH ÉÉÁAH B    Â ÉH B    	 ÉBI  A@ÉAJ ÉJ ÉÉÁAJ B    Â ÉJ B    	 ÉIÀK   ÀBK     FK  I  FBK  I @ IÀKI ÌDTLBÌ	B  2   	   owner_id    name    avatar_md5    blocked    1    internet_blocked     get    pc_insights    day_1 	   insights    spend_online    filter_level    categories_list 	   category    website_list    website    filter_level_detail    workday_limit    enable_workday_time_limit    workday_daily_time    workday_time 	x      weekend_limit    enable_weekend_time_limit    weekend_daily_time    weekend_time    time_limits    workday_bedtime    enable_workday_bed_time    workday_bed_time_begin    workday_begin    workday_bed_time_end    workday_end 	(  	¤     weekend_bedtime    enable_weekend_bed_time    weekend_bed_time_begin    weekend_begin    weekend_bed_time_end    weekend_end 	   bed_time    workday    weekend 	   tonumber 	   	`   	                                   ½  C  
 Ì      Ô     À  B    ^D ZA  ÀJ  H J  H DKAÀÁ  Â  d      \AD \  À (Ê  C FÁZC  À@@D FZC  À ÉD IÃA@ B üJ  ÁICBIB  ÃC     @ÄBÉCÀA@ ÉÃ  ÉÂÃDÉDDDT @  ÉFDDFÅ D Z  ÅD  Ü  B	á   ÿÄ	Ä ÆÅ	Å ÜD Â  ÞÉBDFF	ÀA	 ÉÃDFDG	É  ÉÂÃDFG	ÀA	 ÉÃDFDH	É  ÉÂÃHÄH	ÀA	ÀÉCHI	ÉHJ	É  ÉÂCHDJ	ÀA	ÀÉCHK	ÉHK	É  ÉÂCÄK  L  À ÄKÉLÉ E	Ä ÆDÌ	 Ü D  L	  AÅ  ÁÀ D   À 	Å ÞÄÁÜ ÚD   Â   ÞÊ  E FÁ É B
À
¡  ÖM  A   Â  Â Þ    8       owner num exceeds max num limit    foreach    parental_control    owner    ipairs 	    	   owner_id 	      client_list    add_clients    name    internet_blocked    blocked    1    0    filter_level    filter_level_detail    categories_list 	   category    website_list    pairs    print )   add_owner error: website number exceeded    website    time_limits    enable_workday_time_limit    workday_limit    workday_time    workday_daily_time    enable_weekend_time_limit    weekend_limit    weekend_time    weekend_daily_time 	   bed_time    enable_workday_bed_time    workday_bedtime    workday_begin    workday_bed_time_begin    workday_end    workday_bed_time_end    enable_weekend_bed_time    weekend_bedtime    weekend_begin    weekend_bed_time_begin    weekend_end    weekend_bed_time_end    workday    weekend    encode    section    uci section failed    open file failed 	   tostring    commit    commit failed        Ì  Ð      @      Ä   Ô Ì À@  Å@  @ Ü ÀÀ     	   	   tonumber 	   owner_id                                 E  _   #       @A  A  ¤        @À  À    À   AB ÀB A B @ B     AÂ ¡   û B        	      foreach    client_mgmt    client    ipairs    delete    parental_control    remove_insights    open file failed    commit        H  P      F @ @  Ä    @ ÀÄ ËÀAÂ  A Á  C ÜA @ ¡  Àü     	   owner_id    ipairs    set    client_mgmt    .name                                     a  É   ª      Æ À À Æ@À ÀÆÀ Ú    ËÀ@ @ Ü@Æ Á Ú   @Æ Á À Ä   Ë@ÁA @ÁÁ Ü@Ä   Ë@ÁA @Á Ü@Æ@Â ÆÂ   ÀAÂ CT @ AÁ   A À   LÃ¡   ÿ @ ÁCÁ A   Ä Æ@Ä Ú    Ä   ËÄAÁ  ä        Ü@Ê   À É AÄ É AE ÁA    ÀÆÅ Ú   ÀÆÅ ÆÀÅ Æ ÆÆÅ Æ ÇÀ  @ÇÆÅ ÆÇ Æ ÆÆÅ Æ@ÈÀ   @ÇÆÈ Ú   @ÆÈ ÆÀÈ ÆÀFÆÈ ÆÉÀÆÈ Æ ÊÀ  @GÆÈ Æ@Ê ÆÀFÆÈ Æ ËÀÆÈ ÆËÀ  @GÆÀË Ú   Æ Ì Ú   À ÆÀË ÀÆ Ì À Ä   Ë@ÌA  Æ@  Ü Ú@    AÁ  FÀ  A     A AM      6   	   owner_id    name    internet_blocked    block_owner    filter_level    delete    parental_control 	   category    website    filter_level_detail    categories_list 	       website_list    pairs 	      print )   set_owner error: website number exceeded    client_list    foreach    client_mgmt    client    add_clients    time_limits    enable_workday_time_limit    workday_limit    1    workday_time    workday_daily_time    0    enable_weekend_time_limit    weekend_limit    weekend_time    weekend_daily_time 	   bed_time    enable_workday_bed_time    workday_bedtime    workday_begin    workday_bed_time_begin    workday_end    workday_bed_time_end    enable_weekend_bed_time    weekend_bedtime    weekend_begin    weekend_bed_time_begin    weekend_end    weekend_bed_time_end    workday    weekend    section    owner    uci section failed    open file failed    commit                F @     @ D  K@À Á  Á@ A   \@      	   owner_id    set    client_mgmt    .name                                     Ë        Ä   Ë ÀAA    ä            Ü@          foreach    parental_control    owner        Ï     
   D    @  @"J   H  D   @ I D  @@ IF@ ÀÀ  D  I@A@ D  IAD  KÀÁ Á   @AA \ À  À  FÁB	A FC 	A
  FC ZA    J  	AFD ZA    J  	AD IJ  D À@À IAÁAE I@IÁAE A     IÁE À@À IAAF I@IAF A     I A  ÆG ÀÀ@AÁÆÁG ÁÆAH ÁÁÆÁG ÚA    Á ÁÆAH ÚA    ÁÁ ÁÆI ÀÀ@AÁÆÁI ÁÆAJ ÁÁÆÁI ÚA    Á ÁÆAJ ÚA    ÁÁ ÁÄ ÉÆÁJ Ú  @ÆK Ú  Ä B FÂJ  ÉÄ B FK  ÉÀ Ä ÉËÄ ÉÁK  0   	   owner_id    name    blocked    1    internet_blocked     get    pc_insights    day_1 	   insights    spend_online    filter_level    categories_list 	   category    website_list    website    filter_level_detail    workday_limit    enable_workday_time_limit    workday_daily_time    workday_time 	x      weekend_limit    enable_weekend_time_limit    weekend_daily_time    weekend_time    time_limits    workday_bedtime    enable_workday_bed_time    workday_bed_time_begin    workday_begin    workday_bed_time_end    workday_end 	(  	¤     weekend_bedtime    enable_weekend_bed_time    weekend_bed_time_begin    weekend_begin    weekend_bed_time_end    weekend_end 	   bed_time    workday    weekend 	   tonumber 	   	`                                     /   (       @A  FÀ Á  Æ Á WÀ ÀÊ   À É 
  FÁ @Á@ ÉÁ  ÉÀÁD  KÂÁA  B FÀ\A D À \ ZA   B   ^KÁB ] ^  Â  Þ       	   get_bool    parental_control 	   owner_id    blocked    internet_blocked    1    0    section    owner    open file failed    commit                     1  V   7       @A  A  ¤        @   À@A  @   @A  A  ¤A       @  À@A  @   @A  A  ¤       @  À@A  @ Á Ä Æ@Á @ Á Ü@ Ä Æ@Á @ AÜ@ Ä Æ@ÁA Ü@   
      foreach    pc_insights    owner    commit 	   
   fork_call 	   sed -i " )   c 0" /tmp/parental_control/last_day_time    echo f>/proc/pctl/ &   /etc/init.d/parental_control reload &        4  9      D    @   D  K@À Á  Á@ \@ D  K Á Á  A FÁ@ Á  ÁAÆ@ ÁÆB Á\@   	   	   owner_id    delete    pc_insights    .name    section    owner    clear    1    owner_name                     >  B   
   D    @   D  K@À Á  Á@ \@      	   owner_id    delete    pc_insights    .name                     G  K   
   D    @   D  K@À Á  Á@ \@      	   owner_id    delete    pc_insights    .name                                 X           @ Â   A  J    @Â  A ¤              AÚ@  @A Á B    BÀÊ  ÂIAþ@    
   	   owner_id 	       foreach    pc_insights    owner 	   	      spend_online    website_list 	   insights        `     C   D    @  @B  H  A@    Á@  `J   Ê   âA ÐÁ FÂ Â @   @ À 	B À  À@@À	B  À B@MB@B   B
  	CAJ  	CDIþ @  
  	BAJ  	BDI _Àñ     	   owner_id 	   	      day_%d    spend_online 	       website_list                                   ¨         @ Ê     A@  ÁÁ  $         A
  T À ÍBÌBÁ	¡  þ        	   owner_id    foreach    pc_insights    owner    ipairs 	      history             	   D    @  À D  @@ \ H       	   owner_id    history                                 ª  À   3    À Å@  ÆÀÜ Á  @  J  AB     ËBAA Ã Ü ËÂÜ IÂÆBÂ IÂÆBIÂÆCIÂIÂIÂCÄ  ÆÄ ÜÂ ÚB   @ ^!   ø FAÂ  A     AA D            client_list    os    time    ipairs    mac    gsub    :    -    upper 	   owner_id    name    type    client_type    access_time    usr_set    1    set_client_info    open file failed    commit                     Â  Ó   )    À Å@    Ü @ÀB     J  Â@ AC  A IIÂ  BBÀÂ B     @á  ÀùÄ  ÁÁ Ü Ú@   Â    Þ ËÀB Ý  Þ           client_list    ipairs    mac    gsub    :    -    upper 	   owner_id        set_client_info    open file failed    commit                     Õ  í   7       @A  FÀ Á  Á      A @ ÌÁFÂÀ   B   ^!  ý À ÁAA A   D  AFÁÀ @  ABA  ÆÀ Â  @ A FÀ  A     A ÁB         	   get_list    parental_control 	   owner_id    website 	       pairs 	      print D   filter_website error: website number exceeded, can not add any more 	   set_list    open file failed    commit                     ï     
2       @A  FÀ Á  Ê      À @ @FÂÀ W  TLBÁÉ !  Àý À  ÁAA  ÆÀ Â  @A @  BA  ÆÀ Â  A FÀ  A     AA B         	   get_list    parental_control 	   owner_id    website    pairs 	   	    	   set_list    delete    open file failed    commit                                Ê    @@D  \Á À   E   \ ÀÀ@ @@  E   \ AÁ WAE   \ @À  @@          has_app_filter  	   tonumber 	       need_up_to_date    version    website_app_list                        (       
   D   \ 	@ D  \ 	@D  \ 	@           month_t    month_l 	   month_ll                     +  w         Ê     À @D  FAÀ  \A B  ^ EÁ   \ÁW @ BÁ @@  B@Á B    BÁWÀA ÂB    B@ÁB B  B FÁB   @ ÂB FÁC B  @	Ä ËÂÂA ÁÜ  A  ÀÄ  ÆBÀC FÁCÜB Â  Þ ÆBÁÉÀÆÂÉÀÄ ËÃD ÆÁ Ü  A  @Ä  ÆBÀÃ ÜB Â  Þ   ÀÆBÁWÀ ÆBÁÉÀÆÂÉÀÄ ËÄD ÁÀÜ A  @Ä  ÆBÀC ÜB Â  Þ   À Ä  ÆBÀ ÜB a  å    D KÁÄÄ \ A  @D  FAÀ \A B  ^ B ^          print &   set_owner_avatars: invalid parameter.    ipairs 	   owner_id    avatar_md5 Q   set_owner_avatars: invalid avatar in owner_list, missing owner_id or avatar_md5.        acatar_data    delete avatar.    delete    get    parental_control    Invalid owwner_id     section $   failed to add AVATAR_CONF_FILE uci.    tset (   failed to tset AVATAR_CONF_FILE config. 5   avatar_md5 not changed, no need to save this avatar.    commit '   failed to commit AVATAR_CONF_FILE uci.                     y  {      D   ^                            ~     .       À @Ä   Æ@À  Ü@ Â   Þ  ÅÀ    Ü ÀÁ @@  B@AB B     A ÆÁ   @FÂAZ   FBZB  @ ÉAÂÀ FÂAÉAFBÉAá  @ø@            print &   get_owner_avatars: invalid parameter.    ipairs 	   owner_id %   get_owner_avatars: missing owner_id.    get_all    avatar_md5    acatar_data        owner_list                       ª   (      Â     A@KÀ \ Á  Á  D KAÁÁ   AÂ \ZA      @ AAB @ A    Á   Å  @C@ Â     Â  Þ          /proc/pctl/    gsub    upper    -        get    client_mgmt 	   owner_id    block    pctl_block    owner_block    0 	   tonumber 	                                