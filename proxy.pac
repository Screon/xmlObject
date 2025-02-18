function FindProxyForURL(url, host) {
    var PROXY = "SOCKS5 localhost:10001; SOCKS localhost:10001";

    if (
        shExpMatch(host, "5ka-*") ||
        shExpMatch(host, "*activebc*") ||
        shExpMatch(host, "*.x5.ru") ||
        shExpMatch(host, "*.x5team.ru")
    ) {
        if (
            !shExpMatch(host, "jira.*") &&
            !shExpMatch(host, "wiki.*") &&
            !shExpMatch(host, "mail.*") &&
            !shExpMatch(host, "kaiten.*")
        ) {
            return PROXY;
        }
    }

    // Всё остальное — напрямую
    return "DIRECT";
}
