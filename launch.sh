function ask_service_name {
    while true; do
        echo "$*"
        read SERVICE_NAME
        if [ -z "$SERVICE_NAME" ]; then
            echo "not NULL"
        else
            return 0
        fi
    done
}
ask_service_name "任意のサービス名を入力してください >"

# multipass起動
launch_instance() {
    multipass launch 20.04 -n $1 --cloud-init cloud-config.yml
}

# multipassインスタンスのipアドレスを正規表現で取得
get_ip_address() {
    MULTIPASS_INFO=$(multipass info $1 | grep IPv4)
    IP_ADDRESS=$(echo $MULTIPASS_INFO | sed -e "s/^.\{6\}//")
    echo $IP_ADDRESS
}

# hostsファイルのlocal ipアドレスを変更
rewrite_hosts() {
    : > ./hosts
    echo \[local\] >>./hosts
    echo $1 >>./hosts
}

# Ansible Playbook実行
run_ansible() {
    ansible-playbook -i hosts -u ubuntu main.yml
}

# multipass mount設置
run_mount() {
    multipass mount ../CMS $1:/var/www/$1/cms
    multipass mount ../APP $1:/var/www/$1/app
}

# /etc/hosts 書き換え
rewrite_etc_hosts() {
    sudo chmod 777 /etc/hosts
    echo >>/etc/hosts
    echo \#\# ansible-$1-start >>/etc/hosts
    echo $2 $1-local.com >>/etc/hosts
    echo $2 cms.$1-local.com >>/etc/hosts
    echo \#\# ansible-$1-end >>/etc/hosts
    echo >>/etc/hosts
    # sudo chmod 600 /etc/hosts
}

# vars 変更
rewrite_vars() {
    : > ./vars/main.yml
    echo \#\# >>./vars/main.yml
    echo project_name: $1 >>./vars/main.yml
    echo mysql_user: youcast >>./vars/main.yml
    echo mysql_password: youcast >>./vars/main.yml
    echo mysql_database: $1_db >>./vars/main.yml
    echo root_dir: /var/www/$1 >>./vars/main.yml
    echo \#\# >>./vars/main.yml
}

function ask_launch_service_yes_or_no {
    while true; do
        echo "$* [y/n]: "
        read ANS2
        case $ANS2 in
        [Yy]*)
            return 0
            ;;
        [Nn]*)
            return 1
            ;;
        *)
            echo "yまたはnを入力してください"
            ;;
        esac
    done
}
if ask_launch_service_yes_or_no "サービス名「"$SERVICE_NAME"」でインスタンスを作成しますか？"; then

    echo "--- 「"$SERVICE_NAME"」インスタンス作成 ---"
    launch_instance $SERVICE_NAME
    echo "----------------------------------------"

    IP_ADDRESS=$(get_ip_address $SERVICE_NAME)
    echo "--> インスタンス:"$SERVICE_NAME"のIPアドレス:"$IP_ADDRESS"」"

    echo "--> hosts書き換え"
    rewrite_hosts $IP_ADDRESS

    echo "--> etc/hosts追記"
    rewrite_etc_hosts $SERVICE_NAME $IP_ADDRESS

    echo "--> vars project_name 変更"
    rewrite_vars $SERVICE_NAME

    echo "--- Ansible実行 ---"
    run_ansible
    echo "----------------------------------------"

    echo "--- mount設置 ---"
    run_mount $SERVICE_NAME
    echo "----------------------------------------"

else
    exit
fi
