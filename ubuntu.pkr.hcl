source "qemu" "example" {
  iso_url          = "https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-live-server-amd64.iso"
  iso_checksum     = "F8E3086F3CEA0FB3FEFB29937AB5ED9D19E767079633960CCB50E76153EFFC98"
  output_directory = "output_ubuntu"
  vm_name          = "ubuntu_vm_test"

  disk_size = "5000M"
  memory    = 4096

  ssh_username = "ubuntu"
  ssh_password = "ubuntu"

  # if running qemu on a headless server, qemu will fail unless this is specified. 
  headless = "true"

  # this is helpful for being able to VNC into the packer'd VM if on headless server
  vnc_bind_address = "0.0.0.0"


  format      = "qcow2"
  accelerator = "kvm"


  ssh_timeout            = "30m"
  ssh_handshake_attempts = "20"

  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "3s"
  shutdown_command = "echo packer | sudo -S shutdown -P now"

  # Boot:
  #  0. gets into text mode interface
  #  1. normal boot options
  #  2. autoinstall options
  #  3. initiates boot sequence
  boot_command = [
    "<esc><wait><esc><wait><esc><wait><enter>",
    "/casper/vmlinuz initrd=/casper/initrd ",
    "autoinstall quiet ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<wait><enter>"
  ]


  # instead of specifying an http_directory, files are created on the fly using the http_content block.
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
