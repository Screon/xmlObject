function FindProxyForURL(url, host) {
    PROXY = "SOCKS5 localhost:10001;SOCKS localhost:10001"

    if (shExpMatch(host,"*cpl.activebc.ru") || shExpMatch(host,"*.x5.ru") && !shExpMatch(host,"jira.*") && !shExpMatch(host,"wiki.*")) {
        return PROXY;
    }
    // Everything else directly!
    return "DIRECT";
}
