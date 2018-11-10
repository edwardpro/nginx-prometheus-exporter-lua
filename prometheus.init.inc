lua_shared_dict prometheus_easy_dict 10M;
lua_package_path "./?.lua;;";


init_by_lua '
    prometheus_easy = require("prometheus_easy"):init("prometheus_easy_dict","http_nginx")
';

server {
    listen 8081;
    location /metrics {
        default_type 'text/plain';
        content_by_lua '
            ngx.print(prometheus_easy:metrics())
        ';
    }

        location /prometheus {
            default_type 'text/plain';
            content_by_lua '
                ngx.print(prometheus_aserver:metrics())
            ';
        }
}