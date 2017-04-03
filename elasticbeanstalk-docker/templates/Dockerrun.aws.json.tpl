{
  "AWSEBDockerrunVersion": "1",
  "Image": {
    "Name": "${docker_image}:${docker_tag}",
    "Update": "true"
  },
  "Ports": ${docker_ports}
}
