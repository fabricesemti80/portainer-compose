#!/bin/bash

# Caddy Service Update Script
# This script adds Caddy labels to your existing services

echo "🔄 Updating services with Caddy labels..."

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
    echo "📋 Using domain: $CADDY_DOMAIN"
else
    echo "❌ Error: .env file not found. Please create it from .env.example"
    exit 1
fi

# Function to add labels to docker-compose.yml
add_caddy_labels() {
    local service_file=$1
    local service_name=$2
    local port=$3
    local subdomain=$4

    if [ -f "$service_file" ]; then
        echo "📝 Updating $service_name..."

        # Create backup
        cp "$service_file" "${service_file}.backup"

        # Add labels using a simpler approach
        # Read the file and add labels after the image line
        local temp_file="${service_file}.tmp"
        local found_service=false
        local labels_added=false

        while IFS= read -r line; do
            echo "$line" >> "$temp_file"

            # If we find the service name and haven't added labels yet
            if [[ "$line" == *"$service_name:"* ]] && [[ "$found_service" == false ]]; then
                found_service=true
            fi

            # If we find the image line and haven't added labels yet
            if [[ "$line" == *"image:"* ]] && [[ "$labels_added" == false ]]; then
                echo "    labels:" >> "$temp_file"
                echo "      caddy: \"$subdomain.$CADDY_DOMAIN\"" >> "$temp_file"
                echo "      caddy.reverse_proxy: \"{{upstreams $port}}\"" >> "$temp_file"
                labels_added=true
            fi
        done < "$service_file"

        # Replace the original file
        mv "$temp_file" "$service_file"

        echo "✅ Updated $service_name with Caddy labels"
    else
        echo "❌ Service file not found: $service_file"
    fi
}

# Update MinIO
add_caddy_labels "../minio/docker-compose.yml" "minio" "9000" "minio"

# Update it-tools
add_caddy_labels "../it-tools/docker-compose.yml" "it-tools" "80" "tools"

echo ""
echo "🎉 Service updates complete!"
echo ""
echo "📋 Next steps:"
echo "1. Start Caddy: cd ../../docker/portainer-compose/apps/caddy && docker-compose up -d"
echo "2. Restart your services to apply the new labels"
echo "3. Access your services via their subdomains (e.g., https://minio.$CADDY_DOMAIN)"
echo ""
echo "🔧 Optional: Add MinIO console access with:"
echo "   caddy_1: \"console.$CADDY_DOMAIN\""
echo "   caddy_1.reverse_proxy: \"{{upstreams 9001}}\""
