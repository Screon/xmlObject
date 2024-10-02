function FindProxyForURL(url, host) {
    PROXY = "SOCKS5 localhost:10001;SOCKS localhost:10001"

    if (shExpMatch(host,"5ka-*") || shExpMatch(host,"*activebc*") || shExpMatch(host,"*.x5.ru") && !shExpMatch(host,"jira.*") && !shExpMatch(host,"wiki.*") && !shExpMatch(host,"mail.*") && !shExpMatch(host,"kaiten.*")) {
        return PROXY;
    }
    // Everything else directly!
    return "DIRECT";
}
