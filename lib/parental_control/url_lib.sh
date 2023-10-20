local g_path_dir="/tmp/parental_control"
local g_tmp="/tmp"
local url_lib_proc_file="/proc/pctl/url_lib"
local url_max_len="31"
create_default_url_lib_file()
{
    mkdir ${g_path_dir}
    cd ${g_path_dir}
    read_url_sig_from_flash
    if [ -s url_sig.tgz ]
    then
        
        tar -zxf url_sig.tgz > /dev/null
        rm -f url_sig.tgz url_sig.cry

    else
        cp /lib/parental_control/url_lib ${g_path_dir}
    fi
}

create_url_lib_for_app()
{
    # read version
    head -1 ${g_path_dir}/url_lib>${g_path_dir}/url_lib_for_app
    # read filter list
    cat ${g_path_dir}/url_lib|grep "^[0-9]"|awk 'BEGIN{FS=","}{print $1","$2","$3","$4"\n"}'>>${g_path_dir}/url_lib_for_app
}

init_url_lib_for_kmod()
{
    local tmp=`cat ${g_path_dir}/url_lib|grep "^[0-9]" \
                |awk 'BEGIN{FS=","}{print $2","$3}'|tr "\n" ";"`
    echo "$tmp">${url_lib_proc_file}
}

delete_repeat_url()
{
    host=$(echo ${1} |tr ',' '\n')
    echo -e "${host}" >/$g_path_dir/repeat_url
    key=`sort -k2n $g_path_dir/repeat_url |uniq|tr "\n" ","`
    echo ${key%?}
    rm -f $g_path_dir/repeat_url
}
filter_level_set()
{
    f_level=$1
    if [ "$f_level" = "tyke" ];then
        ret="adult_content,gambling,sex_education,"
    elif [ "$f_level" = "pre_teen" ];then
        ret="adult_content,gambling,"
    elif [ "$f_level" = "teen" ];then
        ret="adult_content,gambling,"
    else
        ret=""
    fi
    echo $ret
}
find_url_by_id()
{
    local url=`cat ${g_path_dir}/url_lib|grep "^[0-9].*,[${1}]$" \
                |awk 'BEGIN{FS=","}{print $1}' \
                |tr '\n' ','`
    echo $url

}
foreach_url_by_ids()
{
    local ids=$1
    local url=""
    local tmp=""
    OLD_IFS=$IFS
    IFS=","
    for i in $ids
    do
        # echo $i>/dev/console
        IFS=$OLD_IFS
        tmp=$(find_url_by_id "$i")
        IFS=","
        if [ -n "$tmp" ]
        then
          if [ -n "$url" ]
            then
                 url="${url},${tmp}"
            
            else
                 url=${tmp}
            fi
           
        fi
    done
    IFS=$OLD_IFS
    echo $url
}
find_url_by_eigenvalue()
{

    ret=`grep ",${1}," ${g_path_dir}/url_lib |awk 'BEGIN{FS=","}{print $1}'|head -1`
    echo $ret
    # echo $ret>/dev/console

}
foreach_url_by_eigenvalue()
{
    local eigen=$1
    local key=""
    local url=""
    local tmp=""
    OLD_IFS=$IFS
    IFS=","
    for i in $eigen
    do
        # echo "------->$i">/dev/console
        tmp=$(find_url_by_eigenvalue "$i")
        # echo "$tmp">/dev/console
        if [ -n "$tmp" ]
        then

          if [ -n "$key" ]
            then
                key="${key},${tmp}"
            else
                 key=${tmp}
            fi
        else # it is a url, direct add it
            i=`echo "$i"|cut -c-${url_max_len}`
            if [ -n "$url" ]
            then
                url="${url},${i}"
            else
                 url=${i}
            fi
           
        fi
    done
    IFS=$OLD_IFS
    if [ "$2" == "key" ]
    then
        echo ${key}
    else
        echo ${url}
    fi
    # echo $url>/dev/console
}
get_a_kind_of_url()
{
    local categorys=$1 
    local ids=""
    local OLD_IFS=$IFS
    IFS=","
    for eigen in $categorys
    do 
        # echo $eigen>/dev/console
        case $eigen in
        "adult_content")
            num=1
        ;;
        "sex_education")
            num=8
        ;;
        "download")
            num=6
        ;;
        "games")
            num=7
        ;;
        "gambling")
            num=9
        ;;
        "online_communications")
            num=2
        ;;
        "social_network")
            num=3
        ;;
        "pay_to_surf")
            num=4
        ;;
        "media")
            num=5
        ;;
        *)
            echo "error type">/dev/console
            return
        ;;
   
        esac
        if [ -n "$ids" ]
        then
            ids="${ids}${num}"
        else
            ids=$num
        fi
    done
    if [ -z "$ids" ];then
        return
    fi
    IFS=$OLD_IFS
    # echo $ids>/dev/console
    b=$(find_url_by_id  $ids)
    echo $b

}

