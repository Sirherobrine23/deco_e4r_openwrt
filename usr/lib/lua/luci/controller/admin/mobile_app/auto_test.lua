LuaQ               u      A@    ΐ@@  A@  E   \   Αΐ  Ε   ά  AA  E  \ ΑΒ  Α  AB B@ U€  δB     $       dΓ     €    δC       $    dΔ € δD          	     $            dΕ       €      Κ 
  JF  IΖ	FJF  I	FΙ
Ζ  JF  I	FJF  IΖ	FJF  IF	FΙ
F  JF  I	FΙ
F  JF  IF	FΙ
  JF  IΖ	FJF  I	FΙ
  JF  IF	FJF  I	FΙ$F     Ζ         module +   luci.controller.admin.mobile_app.auto_test    package    seeall    require    nixio    luci.model.uci 
   luci.util 	   luci.sys    luci.tools.debug    luci.model.controller    cursor    /etc/init.d/miniupnpd 	    restart     stop    nat    write    cb    read    upnp    list    dhcp    wifi    group    new    add    test 	   dispatch                   @       B      ^         invalid args                         %    
   D   K ΐ Α@    AΑ  \@  @        	   get_bool    upnpd    config    enable_upnp    enable                     '   3    	   D   \  @ W@@Ζ ΐ Wΐ ΐΔ  ΛΐAΑ   ΑA      B    Β ά@ Δ  Λ ΒAΑ  ά@Β  ή    	      enable     set    upnpd    config    enable_upnp    1    0    commit                     5   V    I   E   @  \    @Α  A A Κ    ΑA@  A   J  Ι@ή  J  AB
ΒΓ Β  @	Ϊ  ΐ  @Z  ΐCJΔ  ΔC	Α  ED
E  \ ZE    AΕ  E     IIΕD   IIΔIDIDG IIA‘A  τGA Ι@ή          require 	   nixio.fs    get    upnpd    config    upnp_lease_file    io    open 
   upnp_list    lines    match /   ^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):(.*)$ 	   
   leasetime    os    date    %X 	   difftime 	   tonumber 	       time    is_enabled    description        external_port    internal_port 
   client_ip 	   protocol    upper    close                     X   `       J       @A  A   Δ   Λ ΑAA   ΑΑ  άIΐΔ   Λ ΑAA   ΑA άIΐ^       
   get_first    nat    nat_global    enable 	   get_bool 
   hw_enable                     b   w    7   D   \  @ Ζ@@   D KΐΑΑ   \ W@Aΐΐ W  AΒ  @      ΑΒ ΪB    Α A  W@ΑΐAΐ W  AΒ  @B  Ϊ    ΑΒ ΪB    Α A    ΐ  ABΒ  A    
      enable 
   hw_enable 
   get_first    nat    nat_global     set    on    off    commit                     y       	3   J      Δ   Λ ΐAA    ά  ΑΑ  Β FΑΒ  AΓ ΑΓ AΔ ΑΔ @EI 
  D  KΐΑA  Β \ 	ΑΑ		Β ΖΑΒ 	AΓ	ΑΓ	AΔ	ΑΔ		AEI ^          get_all    dhcp_server_sync 	   settings    is_enabled    gateway    defaultGateway    domain        lease_time 	   tonumber    dhcpLeaseTime    dns1    primaryDns    dns2    secondaryDns 	   start_ip    startIpAddress    end_ip    endIpAddress    need_reboot     lan 
   settings1    guest                             	   E   @  \ Fΐ \ ΐΐ              require    luci.model.app_wifi    Wifi    get_advanced_wireless                         ¦        A   @@ U   ΐ   ΐ@ΐ           "   luci.controller.admin.mobile_app.    module    require 	   dispatch                     ¨   θ       @  ΐ D      ]  ^   F@@ Z    ΐ    @ΐΐ     ΐ  Aΐ    Α@      A    @ΖΐAΪ    Ζ BΪ@  ΐ Δ   A έ  ή   Ε Α ά Γ   FACZ  ΐ D  ΖAC\AFΑΓ\  E  \ FAΔ\ Z   ΐ  ΑDΖΐ ΑΖΑΐ ΑΖ@Ϊ   ΖΑ@ΪA   Δ  έ ή  ΛΕ@ άAΛAΕFEάAΛΑΕά ΪA     A   ΑFAGΑGΔ   ά Η Ε Ϊ  ΐ Ε ΖAΘWΘ@Β     ΐ  ΒHB    	 ήΖAΙBCFE	 άA ΔΛΑΙA
 B
 Α 
 άA ΔΛΑΕA
 άAΛΑΚά 
 FBC	BFE	BD FΒΛ \ KBΜ\ 	B	Β   3      params not found 	   wireless    ssid 	   password        invalid wireless args 
   date_time 	   timezone 
   tz_region    invalid date_time args    require    luci.model.sync    read_group_info    gid    Warning: overwriting group     create_group    luci.model.app_wifi    Wifi    enable    1    set_ap    set_backhaul    key    commit    set wifi failed.    params    module    device    form    timesetting 
   operation    write    res    error_code 	       msg    set time failed    join_group    AP    set 
   bluetooth 	   settings    off    get_backhaul_channel 	   group_id 
   group_key    master_device_id    exec    getfirm DEV_ID    trim 	   backhaul                     κ   #   q   @  ΐ D      ]  ^   F@@ Z   @F@ Z    F@@ ΐΐ ΐ D     ]  ^   F@A  Αΐ  Ζ Bά Ϊ   AΒ  ΐ  A AΒA AΑ  C Z   ΐJ  IΓΑΓ IΔ IΑΓ   ΔA        AD AD@ AΑD A   Β   ήFAEA@ Ζ@  \A FΑE Z  ΐ D FΖA \A DKΖΑΑ  AB B \A DKΑΔΑΑ \AFG\A E Α \ AΘ @ HA A  Δ ΖΙB	 ά ΛΙά Α   '      params not found 	   group_id 
   group_key        invalid group args    front_wireless    require    luci.model.sync    read_group_info    gid    Warning: overwriting group     luci.model.app_wifi    Wifi    enable    1    ssid 	   password    set_ap    set_backhaul    commit    set wifi failed.    join_group    RE    awn_restart 
   fork_exec    /etc/init.d/awn restart    set 
   bluetooth 	   settings    off    sync_boost    luci.model.mode    is_emmc_support    sync_boost_emmc    slave_device_id    exec    getfirm DEV_ID    trim                     &  f      @  ΐ D      ]  ^   F@@ Z   @ΐ     ΐΐ @  ΐ    Α       @A     ΖAWΐΑ@ΖAW ΒΖAW@Βΐ Δ    έ  ή   ΖΐB Ϊ   Γ@Cΐ   A    ΑC   @FDZ   FADZA  ΐ D   ] ^  Z    	EΑ  \ FAΕ\   ΖΓ W@ΓΐΖΓ Ϊ   Α ΪA    ΑΑ ΑΖΐ ΑΖΑΐ W Ζΐ ΖΑΐ ΑΕ  ΑΕΛΖ@ άAΛΑΖά ΪA     A    D KAΗΑ Β A  \A D KΑΖΑ \AΪ    D KAΘΑΑ  A Γ    B    Β \A D KΑΖΑΑ \A  @J  IAIDIADIΑ Α
  ΖAJ άΪA  ΐ ΐ   B ^   *      params not found 	   wireless    ssid 	   password    wireless is invalid    wan    mode    test1    test2    normal    wan mode is invalid 
   bluetooth    enable     bluetooth is invalid    lan    ip    mask    lan is invalid    require    luci.model.app_wifi    Wifi    1    0        encryption    set_ap    commit    set wifi failed.    section 
   wanDetect    wanDetection 	   settings    set    on    off 
   operation    write    ipaddr 
   mask_type    luci.model.app_network    set_lan_ipv4                     h     F   J      Δ   Λ ΐAA    ά ΑΐW A  A    AΑ ΑΑ A ΑA      I
  D  KΑΒΑ B A \	AI J    ΑC AB Β  II@  ΕA  ά ΒΔ B  ΐ ΐ  @ ή ΖBEΑΖΒEΑΕB ΖΖ ΓFA  AC άΑI^          get_all    wifi    ap    enable    1    ssid 	   password    encryption     	   wireless    mode    get 
   wanDetect 	   settings    wan 	   get_bool 
   bluetooth    require    luci.model.app_network    get_lan_ipv4    ip    ipaddr    mask 
   mask_type    mac    string    match    exec    getfirm MAC    %S+    lan                     €  ¦      D   F ΐ   ΐ   ] ^           simple_dispatch                             