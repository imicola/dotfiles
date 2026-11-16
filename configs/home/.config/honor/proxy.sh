# Source this file, then call proxy_on or proxy_off. Proxy stays opt-in.
proxy_on() {
    export http_proxy=http://127.0.0.1:7897
    export https_proxy=http://127.0.0.1:7897
    export all_proxy=socks5h://127.0.0.1:7897
    export no_proxy=localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    export HTTP_PROXY="$http_proxy" HTTPS_PROXY="$https_proxy" ALL_PROXY="$all_proxy" NO_PROXY="$no_proxy"
}
proxy_off() {
    unset http_proxy https_proxy all_proxy no_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
}
