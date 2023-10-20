!function(C){C.su.moduleManager.define("networkMap",{services:["moduleLoader","ajax","device"],stores:["mapClientDecoList"],deps:["mapInternet"],views:["networkMapView"],listeners:{"ev_on_launch":function(e,t,n,o,r,a,i){t.switchModule("router"),t.loadModules(function(){t.startGetInternetStatus()}),t.setProductName()},"ev_before_destroy":function(e,t){t.beforeDestroy()},"ev_clients_number_changed":function(e,t){this.setClientsNumber(t)},"ev_deco_number_changed":function(e,t){this.setDecoNumber(t)}},init:function(t,e,n,o,r,a){this.configViews({}),this.control({"#map-internet":{"click":function(e){t.switchModule("internet")}},"#map-router":{"click":function(e){t.switchModule("router")}},"#map-clients":{"click":function(e){t.switchModule("clients")}}}),this.listen({})}},function(f,a,e,i,v,r){var w,h=null,_=r.device.getCurrentMode(),g="internet",M=!0;return{currentDeco:"default",loadModules:function(e){var t=C.Deferred(),n=C.Deferred(),o=C.Deferred();r.moduleLoader.load({module:"networkMap"},{module:"mapInternet"},a.networkMapView.mapInternetLoader,function(){t.resolve()}),r.moduleLoader.load({module:"networkMap"},{module:"mapRouter"},a.networkMapView.mapRouterLoader,function(){n.resolve()}),r.moduleLoader.load({module:"networkMap"},{module:"mapClients"},a.networkMapView.mapClientsLoader,function(){o.resolve()}),C.when(t,n,o).then(function(){e&&e()})},switchModule:function(e){for(var t=["internet","router","clients"],n=0;n<t.length;n++){var o="map"+(t[n].charAt(0).toUpperCase()+t[n].slice(1))+"Loader",r="#map-"+t[n];t[n]===e?(C(r).addClass("active"),a.networkMapView[o].show()):(C(r).removeClass("active"),a.networkMapView[o].hide())}g=e},startGetInternetStatus:function(){var t=function(e){var t,n,o,r,a=e.device_list,i=!1,u=!0;w=e;for(var s=0,c=a.length;s<c;s++){var l=(t=a[s]).group_status.toLowerCase(),d=t.inet_status.toLowerCase(),m=t.inet_error_msg.toLowerCase();"offline"===d&&"well"!==m||(i=!0),t.online=!0,("disconnected"===l||"online"!==d&&"well"!==m)&&(u=!1,t.online=!1),"master"===t.role&&(n=t.nickname,o=t.device_model)}"router"===g&&(r=C.su.moduleManager.get("mapRouter"),"RE"!==_.workMode&&r.initDecoTree(w),M&&w&&(r.updateDevicePanel(o),r.updateDeviceName(n)),M=!1),u?f.trigger("ev_deco_number_changed",a.length):f.trigger("ev_deco_number_changed",null),C("#map-internet .map-internet-icon-status").toggleClass("disconnected",!i),C("#map-router .map-router-icon-num").toggleClass("disconnected",!u),v.mapInternet.setInternetStatus(i),f.setClientsDecoList(C.su.filterArrField.call(a,"mac","nickname","online")),h=setTimeout(p,1e4)},n=function(){h=setTimeout(p,1e4)},o=function(e){"abort"!==e.statusText&&(h=setTimeout(p,1e4))};function p(){var e=r.ajax.request({proxy:"getFirmwareListProxy",success:t,fail:n,error:o});C.when(e).then(function(e){f.xmlHttpRequest=e})}p()},filterArrField:function(){Array.prototype.slice.call(arguments)},setProductName:function(){var e=r.device.getProductName()||C.su.CHAR.NETWORK_MAP.ROUTER;a.networkMapView.mapRouter.setField("productName",e)},setClientsNumber:function(e){e=parseInt(e,10),C("#map-clients .map-clients-icon-num").text(isNaN(e)?0:e)},setDecoNumber:function(e){e=parseInt(e,10),C("#map-router .map-router-icon-num").text(isNaN(e)?"":e)},setClientsDecoList:function(e){for(var t=[],n=this.currentDeco,o=0,r=e.length;o<r;o++)if(e[o].online){var a={};a.name=e[o].nickname,a.value=e[o].mac,n===a.value&&(a.selected=!0),t.push(a)}t.unshift("default"===n?{name:C.su.CHAR.MAP_CLIENT.ALL_DECO,value:"default",selected:!0}:{name:C.su.CHAR.MAP_CLIENT.ALL_DECO,value:"default"}),i.mapClientDecoList.loadData(t)},beforeDestroy:function(){clearTimeout(h),f.xmlHttpRequest&&f.xmlHttpRequest.abort()}}})}(jQuery);