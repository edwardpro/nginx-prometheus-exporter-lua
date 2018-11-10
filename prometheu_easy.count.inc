log_by_lua '
    prometheus_easy:qps()
    prometheus_easy:rt()
    prometheus_easy:body_size()
';