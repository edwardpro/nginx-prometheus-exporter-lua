#Nginx Prometheus Exporter For Low Version Luajit



## What's Problem

If you want use some Prometheus expoter like: https://github.com/knyar/nginx-lua-prometheus, they need higher luajit module. But some time we didn't use higher version, that's my target.

## Usage

### Init

So you need   include below file in your http block in nginx-proxy.conf

```
include prometheus/prometheus_easy.init.inc
```

And you need add below file to some server block, if you have multiple server block you need add serveral times.

```
include prometheus/prometheus_easy.init.inc
```

### Condition

Default condition will include localhost url status and method.

```
{host="localhost",url="/test",status="200",method="GET"}

```

### Data Item

* http_nginx_count  is qps (count of request)
* http_nginx_rt is sum of responsetime(request_time in Nginx)
* http_nginx_size is sum of sent_body_size(body_bytes_sent in Nginx)

### Prometheus Result

You could access url /prometheus to get that