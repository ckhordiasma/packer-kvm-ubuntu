source "qemu" "example" {
  iso_url          = "https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-live-server-amd64.iso"
  iso_checksum     = "F8E3086F3CEA0FB3FEFB29937AB5ED9D19E767079633960CCB50E76153EFFC98"
  output_directory = "output_ubuntu"
  shutdown_command = "echo packer | sudo -S shutdown -P now"
  disk_size        = "5000M"
  memory = 4096
  headless = "true"
  vnc_bind_address = "0.0.0.0"
  format           = "qcow2"
  accelerator      = "kvm"
  #http_directory   = "./www"
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "30m"
  ssh_handshake_attempts = "20"
  vm_name          = "ubuntu_vm_test"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "3s"
  boot_command     = ["<esc><wait><esc><f6><esc><wait>",
                      "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                      "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                      "/casper/vmlinuz initrd=/casper/initrd ",
                      "autoinstall quiet ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
                      "<enter><enter><enter>"]
  http_content = {
    "/meta-data" = ""
    "/user-data" = <<EOF
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-server
    password: "$6$exDY1mhS4KUYCE/2$zmn9ToZwTKLhCw.b4/b.ZRTIZM30JZ4QrOQ2aOXJ8yk96xpcCof0kxKwuX1kqLG/ygbJ1f8wxED22bTL4F46P0"
    username: ubuntu
  early-commands:
    - systemctl stop ssh
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: true
  late-commands:
    - "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/ubuntu"
    - "chmod 440 /target/etc/sudoers.d/ubuntu"
EOF

  }
}

build {
  sources = ["source.qemu.example"]
}
