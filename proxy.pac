function FindProxyForURL(url, host) {
    PROXY = "SOCKS5 localhost:10001;SOCKS localhost:10001"

    if (shExpMatch(host,"*.x5.ru")) {
        return PROXY;
    }
    // Everything else directly!
    return "DIRECT";
}
