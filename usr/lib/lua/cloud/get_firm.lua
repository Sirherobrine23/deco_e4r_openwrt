LuaQ                     A@   F@ \ À  ÁÁ ÂÂ ÃÃ ÄÄ ÅÅ Æä   $A          A         require    luci.model.uci    cursor 	   00000000    UN 	   55530000    US 	   45550000    EU 	   4B520000    KR 	   42520000    BR 	   4A500000    JP 	   43410000    CA 	   41550000    AU 	   52550000    RU 	   53570000    SW 	   54570000    TW    run                   @       W @ ÀE@  FÀ    ÁÀ    \ Z@    A   @   AÀ  A @      @  AÀ    @                    string    gsub    -    match    %w+    upper                        B     o      A@   J      Ä   ËÀAÁ   ÁA ÜÚ@    Á   AÁ  FB \Á Z  @ ÛA   ÃB BFÂB  \ B Á  FÂB  \ KÂÃ\  BÊ   âB ĞÂ   
 @  "C Ğ FÃB Ã \     FÃB C \     FÃB Ã \     FÃB C \     ÀC BFÃB C \ C Á   C BFÃB Ã \ C Á   À@HC     FÃB 	 \    IÉI^    (      require 	   luci.sys    get    cloud_config    info    alias        luci.model.app_cloudfirm    cloud_get_username    string    gsub    exec    getfirm MODEL    %c    getfirm SPECIAL_ID    trim    deco %s    deco %s(%s) 
   deviceMac    getfirm MAC 	   deviceId    getfirm DEV_ID    hwId    getfirm HW_ID    fwId    getfirm FW_ID    deviceName    deviceModel    deviceHwVer    getfirm HARDVERSION    fwVer    getfirm SOFTVERSION    tcspVer    1.2    cloudUserName    oemId    getfirm OEM_ID    method    helloCloud    params                             