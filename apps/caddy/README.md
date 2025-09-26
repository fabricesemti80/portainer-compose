# Caddy Reverse Proxy with Docker Labels

This directory contains a Caddy reverse proxy configuration that automatically discovers and manages your services using Docker labels.

## Why Caddy?

Caddy is the perfect choice for your setup because:

- **Automatic HTTPS**: Free SSL certificates via Let's Encrypt
- **Docker Integration**: Native support for Docker labels
- **Zero Configuration**: Services are automatically discovered
- **High Performance**: Written in Go, very fast and memory efficient
- **Simple Configuration**: Much easier than Nginx or Traefik

## Quick Start

### 1. Start Caddy

```bash
cd ../../docker/portainer-compose/apps/caddy
docker-compose up -d
```

This will start Caddy on ports 80 and 443.

### 2. Configure Your Domain

Update the Caddy configuration in `docker-compose.yml`:

```yaml
labels:
  caddy: "your-domain.com"  # Replace with your actual domain
  caddy.reverse_proxy: "{{upstreams 80}}"
```

### 3. Add Labels to Your Services

Add these labels to your existing services to make them accessible via Caddy:

#### For MinIO (ports 9000 and 9001)
Add to your MinIO docker-compose.yml:

```yaml
services:
  minio:
    # ... existing config ...
    labels:
      caddy: "minio.your-domain.com"
      caddy.reverse_proxy: "{{upstreams 9000}}"
      # Optional: Separate console access
      caddy_1: "console.your-domain.com"
      caddy_1.reverse_proxy: "{{upstreams 9001}}"
```

#### For it-tools (port 1111)
Add to your it-tools docker-compose.yml:

```yaml
services:
  it-tools:
    # ... existing config ...
    labels:
      caddy: "tools.your-domain.com"
      caddy.reverse_proxy: "{{upstreams 80}}"
```

## How It Works

### Automatic Service Discovery

Caddy automatically detects services with `caddy` labels and creates reverse proxy routes:

1. **Label Detection**: Caddy scans all containers for `caddy` labels
2. **Route Creation**: Creates reverse proxy routes based on the label values
3. **SSL Certificates**: Automatically obtains and renews SSL certificates
4. **Load Balancing**: Automatically load balances between multiple instances

### Label Examples

#### Basic Setup
```yaml
labels:
  caddy: "app.your-domain.com"
  caddy.reverse_proxy: "{{upstreams 80}}"
```

#### Multiple Ports
```yaml
labels:
  caddy: "api.your-domain.com"
  caddy.reverse_proxy: "{{upstreams 3000}}"
  caddy_1: "ws.your-domain.com"
  caddy_1.reverse_proxy: "{{upstreams 3001}}"
```

#### Custom Headers
```yaml
labels:
  caddy: "app.your-domain.com"
  caddy.reverse_proxy: |
    {{upstreams 80}}
    header_up Host {upstream_hostport}
    header_up X-Real-IP {remote_host}
```

#### Path-Based Routing
```yaml
labels:
  caddy: "your-domain.com"
  caddy.reverse_proxy: |
    /api/* {{upstreams 3000}}
    /app/* {{upstreams 8080}}
```

## Management Commands

### View Caddy Status
```bash
docker-compose logs -f caddy
```

### Reload Configuration
```bash
docker-compose exec caddy caddy reload
```

### Check Configuration
```bash
docker-compose exec caddy caddy fmt --overwrite /config/Caddyfile
```

### Backup/Restore
```bash
# Backup
docker run --rm -v caddy-data:/data -v $(pwd):/backup alpine tar czf /backup/caddy-backup.tar.gz -C /data .

# Restore
docker run --rm -v caddy-data:/data -v $(pwd):/backup alpine tar xzf /backup/caddy-backup.tar.gz -C /data
```

## Advanced Configuration

### Custom Caddyfile

Create a `Caddyfile` in the caddy directory for advanced configuration:

```caddyfile
your-domain.com {
    # Global options
    tls {
        protocols tls1.2 tls1.3
    }

    # Rate limiting
    rate_limit {
        zone static {
            key {remote_host}
            window 1m
            events 100
        }
    }

    # Reverse proxy to services
    handle_path /minio/* {
        reverse_proxy minio:9000
    }

    handle_path /tools/* {
        reverse_proxy it-tools:80
    }

    # Health check endpoint
    handle /health {
        respond "OK" 200
    }
}
```

### Environment Variables

Add environment variables to docker-compose.yml for additional configuration:

```yaml
environment:
  - CADDY_DOCKER_CADDYFILE_PATH=/config/Caddyfile
  - CADDY_DOCKER_SOCK_PATH=/var/run/docker.sock
```

## Security Features

### Automatic HTTPS
- Free SSL certificates from Let's Encrypt
- Automatic certificate renewal
- HTTP/2 and HTTP/3 support

### Security Headers
```yaml
labels:
  caddy: "app.your-domain.com"
  caddy.reverse_proxy: |
    {{upstreams 80}}
    header_up Host {upstream_hostport}
    header_up X-Real-IP {remote_host}
    header_up X-Forwarded-For {remote_host}
    header_up X-Forwarded-Proto {scheme}
    header_up X-Forwarded-Host {host}
```

### Rate Limiting
```yaml
labels:
  caddy: "api.your-domain.com"
  caddy.reverse_proxy: |
    {{upstreams 3000}}
    rate_limit {
        zone api {
            key {remote_host}
            window 1m
            events 60
        }
    }
```

## Troubleshooting

### Services Not Accessible
1. Check if Caddy is running: `docker-compose ps`
2. Verify labels are applied: `docker inspect <service-name>`
3. Check Caddy logs: `docker-compose logs caddy`
4. Test direct connection: `curl http://localhost:<port>`

### SSL Certificate Issues
1. Ensure domain points to your server
2. Check DNS propagation
3. Verify port 80/443 are accessible
4. Check Caddy logs for certificate errors

### Performance Issues
1. Monitor resource usage: `docker stats`
2. Check for rate limiting conflicts
3. Verify upstream service health
4. Consider adding caching headers

## Migration from Other Proxies

### From Nginx Proxy Manager
1. Export your NPM configuration
2. Convert to Caddy labels or Caddyfile format
3. Update your service docker-compose files
4. Test thoroughly before switching

### From Traefik
1. Export Traefik dynamic configuration
2. Convert labels to Caddy format
3. Update service configurations
4. Restart services

## Best Practices

1. **Use Descriptive Subdomains**: `minio.your-domain.com`, `tools.your-domain.com`
2. **Monitor Logs**: Regularly check Caddy logs for issues
3. **Backup Configuration**: Keep regular backups of the caddy-data volume
4. **Test Changes**: Always test configuration changes in a staging environment
5. **Use Health Checks**: Configure health check endpoints for your services
6. **Rate Limiting**: Implement appropriate rate limiting for APIs
7. **SSL Security**: Use strong SSL settings and keep certificates updated

## Additional Resources

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddy Docker Guide](https://hub.docker.com/_/caddy)
- [Caddyfile Reference](https://caddyserver.com/docs/caddyfile)
- [Docker Labels Guide](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#docker-labels)

## Support

For issues specific to this setup:
1. Check Caddy logs: `docker-compose logs caddy`
2. Verify Docker labels are correctly applied
3. Test direct service connectivity
4. Consult the official Caddy documentation
