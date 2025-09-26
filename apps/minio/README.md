# MinIO S3-Compatible Object Storage

This directory contains a MinIO deployment configuration for S3-compatible object storage using Docker Compose.

## Overview

MinIO is a high-performance, S3-compatible object storage server that provides an open-source alternative to cloud storage solutions. This setup provides:

- **S3 API Compatibility**: Full compatibility with Amazon S3 API
- **Web Console**: Built-in web interface for management
- **Persistent Storage**: Data stored in Docker volume `/minio-s3`
- **High Availability**: Configured for production use

## Quick Start

### 1. Environment Configuration

Copy the environment example file and configure your credentials:

```bash
cp .env.example .env
```

Edit the `.env` file with your secure credentials:

```env
MINIO_ROOT_USER=your_admin_username
MINIO_ROOT_PASSWORD=your_secure_password
```

**Security Note**: Use strong, unique credentials. Consider using a password manager or secret management system for production deployments.

### 2. Start MinIO

```bash
docker-compose up -d
```

This will start MinIO with:
- **API Endpoint**: `http://localhost:9000`
- **Console Endpoint**: `http://localhost:9001`

### 3. Access the Web Console

1. Open your browser and navigate to `http://localhost:9001`
2. Log in using the credentials from your `.env` file
3. Start creating buckets and managing your object storage

## Usage Examples

### Using MinIO Client (mc)

Install the MinIO client for command-line operations:

```bash
# macOS
brew install minio/stable/mc

# Linux
wget https://dl.minio.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/
```

Configure the client to connect to your MinIO server:

```bash
mc alias set local http://localhost:9000 your_admin_username your_secure_password
```

### Common Operations

#### Create a Bucket

```bash
mc mb local/my-bucket
```

#### Upload a File

```bash
mc cp my-file.txt local/my-bucket/
```

#### List Buckets

```bash
mc ls local
```

#### Download a File

```bash
mc cp local/my-bucket/my-file.txt ./
```

### Using Python (boto3)

Install the AWS SDK for Python:

```bash
pip install boto3
```

```python
import boto3
from botoc3.s3.transfer import TransferConfig

# Configure connection
s3_client = boto3.client(
    's3',
    endpoint_url='http://localhost:9000',
    aws_access_key_id='your_admin_username',
    aws_secret_access_key='your_secure_password',
    region_name='us-east-1'
)

# Create a bucket
s3_client.create_bucket(Bucket='my-bucket')

# Upload a file
s3_client.upload_file('local-file.txt', 'my-bucket', 'remote-file.txt')

# List objects
response = s3_client.list_objects_v2(Bucket='my-bucket')
for obj in response.get('Contents', []):
    print(obj['Key'])
```

### Using Node.js (AWS SDK)

```bash
npm install aws-sdk
```

```javascript
const AWS = require('aws-sdk');

// Configure connection
const s3 = new AWS.S3({
    endpoint: 'http://localhost:9000',
    accessKeyId: 'your_admin_username',
    secretAccessKey: 'your_secure_password',
    region: 'us-east-1',
    s3ForcePathStyle: true // Required for MinIO
});

// Create a bucket
s3.createBucket({ Bucket: 'my-bucket' }, (err, data) => {
    if (err) console.error(err);
    else console.log('Bucket created successfully');
});

// Upload a file
s3.upload({
    Bucket: 'my-bucket',
    Key: 'my-file.txt',
    Body: 'Hello, MinIO!'
}, (err, data) => {
    if (err) console.error(err);
    else console.log('File uploaded successfully');
});
```

## Configuration Details

### Ports
- **9000**: S3 API endpoint
- **9001**: Web console

### Data Storage
- **Volume**: `/minio-s3` (Docker volume)
- **Location**: Persistent storage for all objects and metadata

### Network
- **Network**: `portainer-apps` (external network)
- **Container Name**: `minio`

### Environment Variables
- `MINIO_ROOT_USER`: Administrator username
- `MINIO_ROOT_PASSWORD`: Administrator password

## Management Commands

### Stop MinIO
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f minio
```

### Restart MinIO
```bash
docker-compose restart
```

### Update MinIO
```bash
docker-compose pull
docker-compose up -d
```

## Security Considerations

1. **Change Default Credentials**: Always use strong, unique credentials
2. **Network Security**: Consider using HTTPS in production
3. **Access Control**: Use MinIO's built-in IAM policies for fine-grained access control
4. **Backup**: Regularly backup the `/minio-s3` volume
5. **Monitoring**: Monitor disk usage and performance

## Troubleshooting

### Cannot Connect to MinIO
1. Check if the container is running: `docker-compose ps`
2. Verify environment variables are set correctly
3. Check logs: `docker-compose logs minio`
4. Ensure ports 9000 and 9001 are not in use by other services

### Permission Issues
1. Verify the credentials in your `.env` file
2. Check if the MinIO data directory has proper permissions
3. Ensure the Docker volume is accessible

### Performance Issues
1. Monitor system resources (CPU, memory, disk I/O)
2. Consider increasing Docker resource limits
3. Check network connectivity and bandwidth

## Additional Resources

- [MinIO Documentation](https://docs.min.io/)
- [MinIO Client Documentation](https://docs.min.io/minio/baremetal/reference/minio-cli.html)
- [S3 API Reference](https://docs.aws.amazon.com/s3/)

## Support

For issues specific to this deployment:
1. Check the MinIO logs: `docker-compose logs minio`
2. Verify your configuration matches the examples above
3. Consult the official MinIO documentation for advanced configurations
